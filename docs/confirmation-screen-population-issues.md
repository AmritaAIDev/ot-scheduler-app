# Confirmation Screen — Unpopulated Dropdown Issues

Analysis of `frontend/docs/input-sheet-30062026.xlsx` upload logs (2026-09-07). 21 rows were
submitted to `/api/parse-excel/`; a majority came back with an empty `SURGERY` and/or an
unrecognized `SPECIALITY`, leaving the corresponding dropdowns unpopulated on the List
Confirmation screen. Root causes below are traced to specific code paths, not guessed.

Notably, an unmatched surgery name is **not** the only cause: of the 16 non-null `SURGERY_CODE`
values the backend returned in this response, 8 (50%) still failed to populate their dropdown on
the confirmation screen — see issue #8.

| # | Issue | Evidence | Possible Fix | Effort | Component |
|---|-------|----------|---------------|--------|-----------|
| 1 | **Multi-doctor field: only the *first* doctor's "Dr." prefix is stripped.** `determineSpecialty()` strips a leading `Dr.` from the whole string *before* splitting on `/`. The mid-string strip regex (`\s+dr\.?\s*`) only matches when "Dr." is preceded by whitespace — but doctors are separated by `/` with no space (e.g. `"Dr.Puneet/Dr.Saleem/Dr.Jaya"`). So doctor #2, #3, etc. keep their `"dr."` prefix and never match `doctorSpecialtyMap`. | Log: lookup keys `'puneet'` (stripped OK) then `'dr.saleem'`, `'dr.jaya'` (prefix left on) — both come back blank. | Split on `/` first, then run the prefix-strip on each resulting name individually (in `SchedulerInput.dart`). | **S** (~30 min) | Frontend |
| 2 | **Surgery-name matcher has a "dead zone" for 6–7 character single-word inputs**, so close typos never match even when the correct entry is one letter away. `is_short` only fires for ≤5 chars (unlocks abbreviation matching); the character-level fallback stages (`Spelling/root`, `LCS`) only fire for `is_single_long_word` (≥8 chars) *or* when a whole word token already overlaps — impossible for a misspelling. A 6–7 char single word like `"bental"` (6 chars) satisfies neither, so it's silently dropped even though `"Bentall Procedure"` exists in the reference sheet one letter away. | Confirmed by tracing `process_surgery_name()` for input `"Bental"`: skips abbreviation dominance (6>5 chars), 0 cosine hits (unseen token), 0 word overlap, and both fallback stages `continue` past every candidate because `token_overlap==0` and `is_single_long_word("bental")` is `False`. | Lower `is_single_long_word`'s `min_len` (e.g. to 5–6) or add a dedicated short-single-word character-similarity stage that isn't gated behind `token_overlap>0`. | **M** (~2 hrs incl. regression check against existing passing cases) | Backend |
| 3 | **Ambiguous short abbreviations (e.g. "LSCS") are discarded entirely instead of resolving to a base/default variant.** The reference sheet has 6 different "LSCS" entries (`Timed LSCS`, `LSCS + Myomectomy`, `Caesarian Section LSCS`, …). Abbreviation-dominance correctly finds all of them, but since their scores cluster closely, neither the `DOMINANCE_MIN_SCORE` (0.9) nor `DOMINANCE_MIN_LEAD` (0.15) threshold is met, so the row is left unmatched — even though `"LSCS"` alone most plausibly means the plain `"Caesarian Section LSCS"`. Given LSCS is one of the most common obstetric procedures in the data, this is high-impact. | Log: two separate rows with `SURGERY: "LSCS"` both return `[(None, None)]`; reference sheet confirmed to contain `'Caesarian Section LSCS'`, `'Timed LSCS'`, `'LSCS with Tubal Ligation'`, `'LSCS + Myomectomy'`, etc. | When multiple abbreviation-dominance candidates tie, prefer the shortest/most literal one (closest to an exact "base" match) instead of returning nothing. | **M** (~2–3 hrs, needs validation across other abbreviations to avoid picking the wrong variant) | Backend |
| 4 | **Several other procedure names fail to match despite a plausible standard entry existing** — `"Craniotomy and tumour excision of tumour"`, `"Right Side Close Reduction and K-wire Fixation"`, `"B/L Simple Orchidectomy"`, `"Resurfacing of Night Half of face…"`, `"ORIF Diag Right Mandible fracture"`. Reference-sheet check shows related entries exist (`Orchidectomy Bilateral - Simple`, `Closed Reduction and K Wire Fixation…`, `Rigid Fixation - Mandible…`, etc.) but with different word choices, hyphenation (`K-wire` vs `K Wire`), or phrasing the word-level TF-IDF/word-overlap stages don't bridge. Likely the same class of limitation as #2/#3 rather than a data gap. | Backend log: each of these returns `(None, None)` / a list of `None`s despite semantically-close standard names existing (confirmed via direct search of `Standard Surgery Names & Codes.xlsx`). | Broader matcher tuning pass: character-level fuzzy fallback (e.g. `rapidfuzz`) that isn't gated behind exact word-token overlap, tested against a labeled sample of real hospital input strings before shipping. | **L** (~1–2 days; needs a regression test set so tuning doesn't reopen other issues — note a similar attempt was merged and then reverted once already) | Backend |
| 5 | **Surgeon names that are bare initials (`"MS/AM/DJ/AS/SG"`) or first-name-only (`"Puneet"`, `"Saleem"`, `"Jaya"`) aren't in `doctorSpecialtyMap` at all** — no code fix can resolve these since there's no full name to match against the roster. | Log: every lookup for `'ms'`, `'am'`, `'dj'`, `'as'`, `'sg'`, `'puneet'`, `'saleem'`, `'jaya'` returns an empty specialty. | Not purely a code fix: (a) add any identifiable missing doctors to `doctorSpecialtyMap`, and (b) flag to the hospital that initials-only surgeon entries need either full names or an explicit department column filled in on the source sheet — the app can't guess this. | **S** (data curation, ~30–60 min per doctor) + **process fix** (ongoing) | Frontend data / data-entry process |
| 6 | **Raw department text that isn't a simple spelling/case variant doesn't canonicalize** — `"Pead Ortho"` and `"Plastic and Surgery"` both fail to match any entry in `Constants.departmentList`, even through `_canonicalDepartment()`'s case/whitespace/punctuation/plural-"s" tolerance, because they're not simple variants: `"Pead Ortho"` likely means a Paediatric Orthopaedics sub-specialty that doesn't exist as its own department at all, and `"Plastic and Surgery"` differs by an actual word (`Surgery` vs `Reconstructive`), not just spelling. Rows fall through to the raw, unmatched text, so the department dropdown shows nothing recognizable. | Backend log: `'SPECIALITY': 'Pead Ortho'` and `'SPECIALITY': 'Plastic and Surgery'`; neither exists in `departmentList`. | Add a small hand-maintained alias table in `_canonicalDepartment()` for recurring real-world phrasings (e.g. `"Plastic and Surgery"` → `"Plastic & Reconstructive"`), and confirm with the hospital whether `"Pead Ortho"` should map to an existing department or needs to become a new one. | **S–M** (~1–2 hrs code + needs a business decision on "Pead Ortho") | Frontend + product decision |
| 7 | **Duration doesn't reliably follow a successfully-matched surgery name**, because the two are resolved via completely independent lookups against two *different* spreadsheets. The surgery name/code comes from the fuzzy matcher against `Standard Surgery Names & Codes.xlsx`; the duration comes from `process_duration()` doing a **plain exact-string lookup** (`duration_map.get(lookup_key, None)`, no fuzzy fallback) against a separate file, `Aug 2022-Dec 2023.xlsx`. A name can match the first file yet have no exact-matching key in the second, silently leaving duration blank even though the surgery itself resolved correctly. | Verified directly against `Aug 2022-Dec 2023.xlsx`: `"Selective Nerve Root Block - Single Level (Service)"` normalizes to `"selective nerve root block single level"`, but the file only has `"selective nerve root block"` / `"...package"` — no exact match. `"Wertheims Hysterectomy"` and `"Microlaryngoscopy - Diagnostic/Biopsy"` don't exist in that file **at all**. All three matched a surgery/code successfully but got `duration: null`. For comparison, `"Spinal Fusion/Fixation Anterior/Posterior"` exists in both files under matching wording and correctly got `duration: 7.04`. | Either (a) reuse the same fuzzy-matching machinery for the duration lookup instead of a strict exact match, or (b) merge/reconcile the two reference spreadsheets so every standard surgery name has a corresponding duration entry under the same exact wording. (b) is the more durable fix — two independently-maintained spreadsheets for the same surgery list is the actual root cause. | **M** (~2–3 hrs for (a) as a quick mitigation) or **L** (reconciling the two spreadsheets, one-time data cleanup + ongoing process to keep them in sync) | Backend (+ data) |
| 8 | **A correctly-matched surgery code still fails to populate its dropdown when the code lives in a *different* department's map than the row's stated speciality.** `_canonicalizeSurgery()` in `ListConfirmation.dart` looks up the returned code inside exactly one map, `_getSurgeryMap(row.speciality)` — strictly scoped to whatever department string the row carries. But the backend's surgery matcher draws from one unified master sheet that doesn't respect that per-department siloing: a spine procedure gets filed under `divisionOfSpineMap`, a sentinel node biopsy under `breastOncologyMap`, a laryngoscopy under `headAndNeckSurgeryMap` — regardless of what department the hospital's own sheet says. These are legitimate cross-specialty procedures (same pattern as the Laparoscopic Cholecystectomy / A.V. Fistula cases already manually cross-added to multiple departments), just happening far more often than anyone's gone through and fixed by hand. This is the dominant cause of "code was clearly returned in the response, but the dropdown stayed empty." | Traced all 16 non-null `SURGERY_CODE` values in this response against every `Constants.*Map`: **8 of 16 (50%) are broken.** 2 are broken because the department text itself doesn't canonicalize at all (issue #6 — `"Pead Ortho"`, `"Plastic and Surgery"`). The other 6 are broken purely by this cross-department mismatch: `NENS00120`×2 and `ININ00029`×2 (row says `Orthopaedic`, code lives in `divisionOfSpineMap`), `SUBS00028` (row says `General Surgery`, code lives in `breastOncologyMap`), `HEHN00083` (row says `ENT`, code lives in `headAndNeckSurgeryMap`). | Build one global `code → (name, owning department)` index across *all* department maps, and use that for surgery-code reconciliation instead of restricting the lookup to `_getSurgeryMap(row.speciality)` alone. When a code is found only in a different department's map, either auto-correct `row.speciality` to the code's true owning department, or at minimum still populate the surgery-name dropdown from the global index while flagging the department mismatch for manual review. | **M** (~3–4 hrs: build the global index + decide the auto-correct-vs-flag UX, plus a pass to confirm it doesn't fight the department-priority fix already in place) | Frontend |

## Suggested priority order

1. **#1** (multi-doctor prefix strip) — smallest, safest fix, unblocks any row where a later-listed doctor is actually in the roster.
2. **#6** (department alias table) — small, immediately restores the department dropdown for two recurring real-world phrasings.
3. **#8** (cross-department code lookup) — highest-confidence, highest-impact fix: explains half of all "code was returned but dropdown stayed empty" cases in this sample, and doesn't depend on any matcher-accuracy improvements.
4. **#7** (duration lookup) — quick mitigation is cheap (reuse fuzzy matching), but the durable fix (reconciling the two spreadsheets) should be scheduled since it'll keep causing silent gaps otherwise.
5. **#2 / #3 / #4** (surgery-name matcher) — highest volume of impact on *unmatched* surgeries (roughly half the rows in this sample had no matched surgery at all), but needs care: bundle into one tuning pass with a proper before/after regression check against a labeled sample, given a similar change was already merged and reverted once.
6. **#5** — ongoing data hygiene, not a one-time code fix.

## Root cause behind all 8 issues

Every issue above is a symptom of the same underlying problem, not eight unrelated bugs: there is
no single source of truth for "surgery ↔ department ↔ code ↔ duration ↔ doctor." That data is
split across a ~7,500-line hand-maintained `constants.dart` (a `List<String>` *and* a
`Map<String, String>` per department, kept in sync by hand) on the frontend, plus two
independently-maintained Excel spreadsheets on the backend (`Standard Surgery Names &
Codes.xlsx` for matching, `Aug 2022-Dec 2023.xlsx` for durations) — none of which know about each
other or enforce consistency. A surgery spanning multiple departments requires manually
duplicating entries in N places; nothing catches it when that duplication is missed, or drifts.
Patching individual symptoms (as issues #1–#8 do) will keep surfacing new ones. The durable fix is
consolidating this reference data into one backend-owned source of truth, served to the frontend
via API instead of hardcoded constants.

## Proposed long-term fix: consolidated reference data model

Replace the current split (Dart constants + 2 Excel spreadsheets) with one backend-owned data
model — `Department`, `Surgery` (duration included, and a many-to-many relation to the
departments that legitimately perform it), and `Doctor` (many-to-many to departments) — served to
the Flutter app via API and cached locally, instead of hardcoded in `constants.dart`.

| # | Phase | Task | Subtask | Effort | Component |
|---|-------|------|---------|--------|-----------|
| 1.1 | Design | Define canonical data model | Schema for `Department`, `Surgery` (name, code, duration, department(s)), `Doctor` (department(s)) | S (2–3 hrs) | Backend |
| 1.2 | Design | Define API contract | Endpoints/response shapes: list departments, list surgeries (filterable by department), surgery search/lookup by code or fuzzy name, doctor roster | S (1–2 hrs) | Backend |
| 1.3 | Design | Decide migration strategy | Big-bang cutover vs. a dual-read transition period (frontend falls back to `Constants.*` if API unreachable) | S (1 hr, decision only) | Both |
| 2.1 | Data consolidation | Resolve `constants.dart` List-vs-Map drift | Fix the mismatches already catalogued (ENT name typo, GI `GAGI00005` gap, Ophthalmology/Orthopaedic list gaps, etc.) | M (2–3 hrs) | Data |
| 2.2 | Data consolidation | Resolve cross-department code ownership | Systematically scan **every** code (not just this session's 16-code sample) for the "code lives in a different department's map" pattern found in issue #8, and decide the correct department tag(s) for each | L (4–6 hrs) | Data |
| 2.3 | Data consolidation | Merge the two backend spreadsheets | Reconcile `Standard Surgery Names & Codes.xlsx` and `Aug 2022-Dec 2023.xlsx` into one canonical surgery+duration dataset, eliminating issue #7 at the source | L (~1 day) | Data |
| 2.4 | Data consolidation | Consolidate doctor roster | Turn `doctorSpecialtyMap` into real distinct doctor records; resolve name collisions (Sachin Gupta, Mohit Sharma, etc.) into separate doctor entries instead of one ambiguous name key | M (2–3 hrs + hospital input needed to disambiguate real people) | Data |
| 2.5 | Data consolidation | Write one-time import/ETL script | Seed the new DB tables from the reconciled dataset produced in 2.1–2.4 | M (3–4 hrs) | Backend |
| 3.1 | Backend build | Extend existing models + migrations | Add `Department` model; convert `Doctors.department`/`Procedures.department` from free-text `CharField` to `ManyToManyField(Department)`; add `Procedures.code`. *(Reduced from a from-scratch build — `Doctors`/`Procedures` models, serializers, and CRUD endpoints already exist, see Phase 1 output below.)* | S (1–2 hrs) | Backend |
| 3.2 | Backend build | New/updated REST endpoints | `GET /api/departments/` (new); update `/api/doctors/`, `/api/procedure/` filtering for the M2M field; add a `/api/procedure/search/` fuzzy-match action | S–M (2–3 hrs) | Backend |
| 3.3 | Backend build | Repoint the surgery-name matcher | Keep the existing fuzzy-matching algorithm, swap its data source from the Excel sheet to the new `Surgery` table (natural place to also fold in fixes for issues #2–#4) | M (2–3 hrs) | Backend |
| 3.4 | Backend build | Repoint the duration lookup | Read `duration` directly off the matched `Surgery` record instead of a separate spreadsheet lookup — eliminates issue #7 in code, not just data | S (~1 hr) | Backend |
| 3.5 | Backend build | Register Django admin | Admin UI for `Department`/`Surgery`/`Doctor` so future edits happen there instead of in code or Excel | S (1–2 hrs) | Backend |
| 4.1 | Frontend migration | API client + local cache | Fetch departments/surgeries/doctors once, cache locally, refresh on demand | M (3–4 hrs) | Frontend |
| 4.2 | Frontend migration | Replace `Constants.departmentList`/`surgeryMap`/per-department maps | Rewire `SchedulerInput.dart`, `ListConfirmation.dart`, `SchedulerOutput.dart` to read from the cached API data | L (~1 day, touches multiple screens) | Frontend |
| 4.3 | Frontend migration | Replace `Constants.doctorSpecialtyMap`/`ambiguousDoctorNames` | Swap to the API-backed doctor roster; keep the ambiguity-guard behavior, now backed by real distinct doctor IDs instead of colliding name strings | M (2–3 hrs) | Frontend |
| 4.4 | Frontend migration | Rework surgery-code reconciliation | Replace `_getSurgeryMap(row.speciality)`'s single-department lookup with the new model's native multi-department surgery lookup — structurally fixes issue #8 instead of patching it | M (3–4 hrs) | Frontend |
| 4.5 | Frontend migration | Remove dead code | Delete the now-unused `Constants.*` content (~7,500 lines) once the migration is verified | S (~1 hr) | Frontend |
| 5.1 | Validation & rollout | Regression test | Re-run against `input-sheet-30062026.xlsx` and any additional sheets collected since | M (2–3 hrs) | QA |
| 5.2 | Validation & rollout | Confirm dropdown-population fix | Re-run this session's trace analysis against the new system; confirm 0 of the 8 previously-broken cases still fail | S (~1 hr) | QA |
| 5.3 | Validation & rollout | Staged rollout | ~~Feature-flagged fallback~~ — not needed; **decision: big-bang cutover** (see Phase 1 output below) | — | — |

**Revised total estimate:** ~6–8 working days for one engineer (down from 8–10) now that Phase 3's
backend scaffolding turns out to already exist. Migration strategy decided: **big-bang cutover** —
repoint everything to the DB in one release and remove the `Constants.dart` data once verified, no
dual-read fallback period.

## Phase 1 output: data model & API design

**Finding that changes the plan:** the backend already has a `Doctors` model and a `Procedures`
model (`backend/OT_Scheduling/models.py`), each with a full DRF `ModelViewSet`
(`DoctorListCreateView` / `ProcedureListCreateView`), already routed at `/api/doctors/` and
`/api/procedure/`, and already registered in Django admin. They're just never queried by the
actual scheduling pipeline — `/parse-excel` and `/ot-schedule` bypass them entirely via
`Constants.dart` and the two Excel files. So Phase 3 is mostly **extending** these models, not
building new ones.

Two gaps in them today, both directly responsible for issues already catalogued in this doc:
- `department` is a free-text `CharField(max_length=50)` on `Doctors`, `Procedures`, `OTs`, and
  `OTstaff` — no dedicated table, no enforced canonical spelling, no way for one row to belong to
  more than one department. This is the same class of bug as issues #6 and #8, just one layer
  deeper (in the DB, not just `constants.dart`).
- `Procedures` has no `code` field at all — the surgery code only exists in
  `Standard Surgery Names & Codes.xlsx` today.

### Proposed schema

```python
class Department(models.Model):
    name = models.CharField(max_length=100, unique=True)  # canonical display name, e.g. "Orthopaedic"
    # Known real-world spelling/phrasing variants seen in uploaded sheets (e.g. "Orthopaedics",
    # "Plastic and Surgery"), so canonicalization lives in the DB, not a hardcoded Dart function.
    aliases = models.JSONField(default=list, blank=True)

    def __str__(self):
        return self.name


class Doctors(models.Model):
    doctor_id = models.AutoField(primary_key=True)
    doctor_name = models.CharField(max_length=1000, null=True, blank=True)
    departments = models.ManyToManyField(Department, related_name='doctors', blank=True)  # was: department CharField


class Procedures(models.Model):
    procedure_id = models.AutoField(primary_key=True)
    procedure_name = models.TextField(null=True, blank=True)
    code = models.CharField(max_length=20, unique=True, null=True, blank=True)  # NEW
    departments = models.ManyToManyField(Department, related_name='procedures', blank=True)  # was: department CharField
    estimated_duration = models.FloatField(null=True, blank=True)  # already exists - this becomes the single duration source, closing issue #7
```

`OTs.department` and `OTstaff.ot_staff_department` stay as-is for now (single-department entities,
not implicated in any of the 8 issues found) — converting them to `ForeignKey(Department)` is a
nice-to-have, not required for this migration, and can be done separately later.

### API contract

| Endpoint | Status | Purpose |
|---|---|---|
| `GET /api/departments/` | **New** | Replaces `Constants.departmentList` |
| `GET /api/doctors/?department=<id>` | Exists, needs filter update for M2M | Replaces `Constants.doctorSpecialtyMap` |
| `GET /api/procedure/?department=<id>` | Exists, needs filter update for M2M | Replaces the per-department `Constants.<dept>Map`/list pairs — natively returns a procedure's *actual* department(s), fixing issue #8 by construction |
| `GET /api/procedure/search/?q=<free text>` | **New** (custom action on the existing viewset) | Replaces the in-memory fuzzy matcher over `Standard Surgery Names & Codes.xlsx` — same matching algorithm, now querying `Procedures.objects.all()` instead of the Excel file |

## Phase 2 output: reconciled data

Reconciled all three sources — `constants.dart`, `Standard Surgery Names & Codes.xlsx` (3,764
rows), `Aug 2022-Dec 2023.xlsx` (2,518 duration rows) — plus a fourth source found during this
pass: `frontend/assets/docs/DoctorsList-31-01-2026.xlsx`, a 209-row doctor roster with a stable
**Employee ID** per doctor that nothing in the current app actually uses. Output saved to
`backend/OT_Scheduling/assets/reconciled/` (`departments.json`, `procedures.json`,
`code_collisions.json`, `doctors.json`) — ready to feed the Phase 2.5 / Phase 3 seed script.

### Departments (31 canonical + aliases)

The master sheet's 47 raw `Department` strings (billing-category style, e.g.
`"Orthopaedic- Robotic Charges"`, `"ENT Surgery - Package"`) normalize **cleanly and
unambiguously** onto `departmentList`'s 32 names — no leftover cases. One further consolidation:
`'Cardiology -Pacemaker and ICD'` and `'Cardiology Procedure -Pacemaker and ICD'` (which
`constants.dart`'s `surgeryMap` already treats as two labels for the same list) are merged into
one canonical department with the other as an alias, bringing the canonical count to **31**.
`departments.json`'s `aliases` field also folds in the real-world sheet variants found earlier
(`"Orthopaedics"`, `"Plastic and Surgery"`, `"HPB & Liver Tranplant"`, etc.) so canonicalization
lives in one data file instead of a hardcoded Dart function.

### Procedures — constants.dart vs. the master sheet agree far more than issue #8 implied

Cross-checking every code in both sources: of 3,576 codes present in both, **only 1 genuine
department disagreement** remains after filtering out two sources of false-positive noise (the
Pacemaker/ICD alias, and codes `constants.dart` had already legitimately made multi-department).
That real disagreement is a **data bug in the master sheet itself**: code `NENS00129` is assigned
to two different procedures under two different departments (`'Traumatic Bone Defect
Cranioplasty'` under Neurosurgery vs. `'Cerival/Thoracic/Lumbar Laminectomy/Decompression'` under
Division of Spine) — needs a human call on which is correct, or whether one needs a new code.
Also found: `OPPH00238` is a literal duplicate row in the master sheet carrying the same
"Aurosling" typo already flagged in issue #1 of this doc — confirms that typo originates in the
source spreadsheet, not just `constants.dart`'s copy of it.

Coverage gaps (not conflicts, just gaps): 185 codes exist in the master sheet but were never
copied into any `constants.dart` dropdown — 112 of these are `Vascular & Endovascular` (the
already-known orphaned `vascularEndovascularSurgery` list) and 71 are `Ophthalmology` (consistent
with the already-known short Ophthalmology list/map gap). 2 codes exist only in `constants.dart`
and not the master sheet at all (`NENS00108`, `OPPH00028`) — the fuzzy matcher can never return
these today regardless of what's in the dropdown.

Both `NENS00129` and `OPPH00238`'s conflicting rows are excluded from `procedures.json` pending a
decision — see `code_collisions.json`.

### Duration coverage is far worse than issue #7's original example suggested

Issue #7 was written from 3 examples in a 21-row sample. Reconciling the **full** dataset: only
**8.8% (329 of 3,759) of all procedures get a duration** via the current exact-normalized-name
match against `Aug 2022-Dec 2023.xlsx`. This raises issue #7's severity substantially — it's not
an edge case, it's the default outcome. Reinforces that merging the two spreadsheets (rather than
patching the lookup with fuzzy matching) is the right call for Phase 3, since over 90% of
durations are silently missing today no matter how good the surgery-name match is.

### Doctors — the real fix for the name-collision problem already exists as a file

`DoctorsList-31-01-2026.xlsx` has an `Emp ID` column that nothing currently reads (it's the file a
previously-merged-then-reverted PR referenced, see the earlier merge-conflict discussion in this
session). Of 209 doctors, 68 map to one of the 31 canonical OT/surgical departments (the other 141
are legitimate non-surgical specialties — Anaesthesiology, Radiology, Psychiatry, etc. — out of
scope for OT scheduling). Confirmed **3 genuine same-name-different-person collisions**, each with
two distinct Employee IDs:

| Name | Emp IDs | Departments |
|---|---|---|
| Sachin Gupta | `MC00199`, `MC00290` | Pediatric Neurosurgery, Dermatology |
| Mohit Sharma | `MC00100`, `MC00223` | Plastic and Reconstructive Surgery, General Medicine |
| Anshul Jain | `MC00129`, `MC00703` | Emergency Medicine, Medical Oncology (both out of OT-scheduling scope) |

This is exactly the Sachin Gupta scenario from the start of this conversation, confirmed with real
data. It validates that `constants.dart`'s `ambiguousDoctorNames` guard (built earlier this
session) was the right stopgap for the current name-only architecture, but the durable fix is
what Phase 3 already plans: key `Doctors` by Employee ID, not name. The input Excel's `SURGEON`
column still won't carry an Emp ID, so per-surgery disambiguation still depends on the row's own
department field being trusted — which the department-priority fix (also already shipped this
session) already does.

## Phase 3 output: backend build

All 3.1–3.5 subtasks complete, applied to the local dev DB.

- **Models** (`backend/OT_Scheduling/models.py`): added `Department` (`name`, `aliases`); converted
  `Doctors.department` and `Procedures.department` from free-text `CharField` to
  `ManyToManyField(Department)`; added `Doctors.emp_id` (unique) and `Procedures.code` (unique).
- **Migrations**: generated cleanly split into two — `0013_preexisting_model_drift.py` (unrelated
  model/DB drift that predated this session entirely; several fields in `models.py` had never had
  a migration generated for them, and the actual DB schema had already diverged from Django's
  migration-tracked state in multiple places) and `0014_add_department_model.py` (this session's
  actual changes, made to depend directly on `0012` so it applies independently of `0013`'s
  state). `0013` was `--fake`-applied since its target state already existed in the DB by other
  means; `0014` was applied for real. A `0015` merge migration reconciles the resulting two-leaf
  graph. `python manage.py check` passes clean.
- **Endpoints**: `GET /api/departments/` (new), `/api/doctors/` and `/api/procedure/` (existing,
  `department` filter updated for the M2M field), `GET /api/procedure/search/?q=` (new — the
  fuzzy-match action described below).
- **`SurgeryMatcher`**: the matching algorithm from `ExcelProcessingView.process_surgery_name` was
  extracted into a standalone class, unchanged in behavior, now reading `Procedures.objects` (DB)
  instead of `Standard Surgery Names & Codes.xlsx`. `ExcelProcessingView.process_surgery_name` is
  now a one-line delegator, so `/parse-excel` keeps working exactly as before with no behavior
  change - only its data source moved. Matcher *accuracy* (issues #2–#4) was explicitly left
  untouched, confirmed by testing the same known-failing inputs (`"Bental"`, `"LSCS"`) still fail
  to match, same as before - that's separate future work, not part of this migration.
- **Duration** (issue #7, structurally fixed): `process_duration` now reads
  `Procedures.estimated_duration` directly off the matched record by code, instead of a separate
  exact-string lookup against `Aug 2022-Dec 2023.xlsx`. Verified: `NENS00120` (previously
  duration-less due to a spreadsheet mismatch) now correctly returns `7.04`.
- **Cross-department lookup** (issue #8, structurally fixed): a procedure's department(s) now live
  on the same DB row returned by the matcher, so there's no more separate
  `_getSurgeryMap(row.speciality)` lookup that can disagree with what was actually matched.
  Verified: `NENS00120` now correctly reports `Division of Spine` as its department (the master
  sheet's authoritative assignment) rather than depending on whatever the input row's `SPECIALITY`
  text said.

**Data seeded**: `python manage.py seed_reconciled_data --yes` (new management command) replaced
the existing 215 stale `Doctors` / 232 stale `Procedures` dev rows with the Phase 2 reconciled
set: 31 departments, 3,759 procedures, 209 doctors (68 linked to a canonical OT department).

**Known gap fixed during verification**: the master-sheet-derived seed only carries one department
per procedure (it has almost no native multi-department rows - see Phase 2 output). This dropped
the two cross-department associations already confirmed earlier in this session (Laparoscopic
Cholecystectomy → Gastrointestinal Surgery + General Surgery + Liver Transplant; A.V. Fistula
`CTVA00608` → Vascular & Endovascular + Urology + Plastic & Reconstructive). Both were re-applied
to the DB and written back into `procedures.json` so a future re-seed reproduces them. Any *other*
multi-department procedures beyond these two (there are likely more in real-world use, per issue
#8's broader pattern) still need to be identified and added the same way — a data-curation task,
not a code task, now that the model supports it natively.

## Phase 4 output: frontend migration

- **New file** `frontend/lib/services/department_data_service.dart`: a singleton
  `DepartmentDataService` that fetches `/api/departments/`, `/api/doctors/`, `/api/procedure/`
  once (`ensureLoaded()`, cached), and exposes the same shape of lookups the old `Constants.*`
  provided - `departmentNames`, `canonicalDepartment(raw)`, `determineSpecialty(surgeon)`,
  `surgeryMapForDepartment(dept)` - plus two new ones the old data model couldn't support:
  `procedureForCode(code)` and `departmentsForCode(code)`, a *global* code lookup independent
  of department, which is what actually fixes issue #8 (see below).
- **`SchedulerInput.dart`**: `_canonicalDepartment`/`determineSpecialty` now delegate to the
  service. Removed the dormant, never-wired-up `_loadDoctorSpecialties()` /
  `_doctorSpecialtyMap` (it read a bundled copy of the doctor roster Excel but nothing actually
  called it - dead code left over from the reverted PR discussed earlier in this session).
  `_dataService.ensureLoaded()` is kicked off in `initState()` and awaited again (cheap no-op
  if already loaded) at the top of `_pickFile()`, since `generateSurgeryExcel()` needs the data
  synchronously per-row.
- **`ListConfirmation.dart`**: `specialityList` now populated from `_dataService.departmentNames`
  after `_loadData()` awaits `ensureLoaded()`. `_getSurgeryMap()` kept its name/signature (many
  call sites) but now delegates to `_dataService.surgeryMapForDepartment()`. `_canonicalizeSurgery()`
  was restructured to be **code-first**: if the row already has a surgery code (from the
  backend's DB-backed matcher), it now resolves the procedure *globally* via
  `procedureForCode()`/`departmentsForCode()` and corrects `row.speciality` if the code's true
  department differs from what the row was tagged with - only falling back to the old
  department-scoped name/code matching when there's no code yet. This is the actual issue #8
  fix landing in the UI.
- **Scope found mid-migration**: a fourth screen, `frontend/lib/TimeMonitoring/DetailsConfirmation.dart`
  (a separate Time Monitoring feature, not part of the OT-scheduling upload/confirm flow this
  doc has been tracking), also depends on `Constants.departmentList` and `Constants.surgeryMap`
  (the `Map<String, List<String>>` shape, different from the per-department `Map<String,String>`
  lookups `ListConfirmation.dart` used). It was **not migrated** - out of scope for the bug this
  doc tracks - so `departmentList`, `surgeryMap`, and all ~30 individual per-department
  `List<String>` constants (which `surgeryMap`'s definition depends on as values) were **kept**
  in `constants.dart` rather than deleted, to avoid breaking that screen.
- **`constants.dart` cleanup (partial 4.5)**: verified via a script checking every
  `Constants.*` symbol against the rest of `lib/` before deleting anything. Removed only what's
  genuinely orphaned now: `doctorSpecialtyMap`, `ambiguousDoctorNames`, and all ~30
  per-department `Map<String, String>` lookup maps (`plasticSurgeryMap` through
  `vascularEndovascularProceduresMap`) - these were only ever read by the old
  `ListConfirmation._getSurgeryMap` switch, now replaced. File shrank from 7,532 to 3,648
  lines. `baseURL`, `anesthesiaTypes`, `surgeryTypes`, `departmentList`, `surgeryMap`, the ~30
  individual department `List<String>` constants, and `otList` were all kept - still genuinely
  used elsewhere. `dart analyze` across the full `lib/` tree: clean, no errors.

### Next: Phase 5

Frontend and backend are both wired up. Phase 5 (validation & rollout) is the actual testing
pass: re-run `input-sheet-30062026.xlsx` (and any further sheets collected) through the real
app end-to-end and confirm the 8 previously-broken dropdown cases in this doc are now fixed,
before deciding this is done. `DetailsConfirmation.dart`'s migration, and identifying further
multi-department procedures beyond the two already known, remain as explicit follow-ups outside
this doc's original scope.
