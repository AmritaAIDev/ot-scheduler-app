import json
from pathlib import Path

from django.conf import settings
from django.core.management.base import BaseCommand
from django.db import transaction

from OT_Scheduling.models import Department, Doctors, Procedures

RECONCILED_DIR = Path(settings.BASE_DIR) / "OT_Scheduling" / "assets" / "reconciled"


class Command(BaseCommand):
    help = (
        "Seeds Department/Doctors/Procedures from the Phase 2 reconciled dataset "
        "(backend/OT_Scheduling/assets/reconciled/*.json), replacing whatever is "
        "currently in those tables. See docs/confirmation-screen-population-issues.md "
        "for how this data was reconciled from constants.dart, the two legacy Excel "
        "reference sheets, and the doctor roster."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            "--yes", action="store_true",
            help="Skip the confirmation prompt (needed for non-interactive runs).",
        )

    def handle(self, *args, **options):
        departments_path = RECONCILED_DIR / "departments.json"
        procedures_path = RECONCILED_DIR / "procedures.json"
        doctors_path = RECONCILED_DIR / "doctors.json"

        for p in (departments_path, procedures_path, doctors_path):
            if not p.exists():
                self.stderr.write(self.style.ERROR(f"Missing reconciled data file: {p}"))
                return

        existing_doctors = Doctors.objects.count()
        existing_procedures = Procedures.objects.count()
        existing_departments = Department.objects.count()

        if not options["yes"]:
            self.stdout.write(
                f"This will DELETE {existing_doctors} Doctors, {existing_procedures} "
                f"Procedures, and {existing_departments} Departments, and replace them "
                f"with the reconciled dataset. Re-run with --yes to proceed."
            )
            return

        with open(departments_path, encoding="utf-8") as f:
            departments_data = json.load(f)
        with open(procedures_path, encoding="utf-8") as f:
            procedures_data = json.load(f)
        with open(doctors_path, encoding="utf-8") as f:
            doctors_data = json.load(f)

        with transaction.atomic():
            Doctors.objects.all().delete()
            Procedures.objects.all().delete()
            Department.objects.all().delete()

            dept_by_name = {}
            for d in departments_data:
                dept = Department.objects.create(name=d["name"], aliases=d.get("aliases", []))
                dept_by_name[d["name"]] = dept
            self.stdout.write(self.style.SUCCESS(f"Created {len(dept_by_name)} departments"))

            proc_count = 0
            for p in procedures_data:
                proc = Procedures.objects.create(
                    procedure_name=p["name"],
                    code=p["code"],
                    estimated_duration=p.get("duration"),
                )
                depts = [dept_by_name[d] for d in p.get("departments", []) if d in dept_by_name]
                if depts:
                    proc.departments.set(depts)
                proc_count += 1
            self.stdout.write(self.style.SUCCESS(f"Created {proc_count} procedures"))

            doc_count = 0
            linked_count = 0
            for d in doctors_data:
                doc = Doctors.objects.create(
                    doctor_name=d["name"],
                    emp_id=d["emp_id"],
                )
                canon = d.get("department_canonical")
                if canon and canon in dept_by_name:
                    doc.departments.set([dept_by_name[canon]])
                    linked_count += 1
                doc_count += 1
            self.stdout.write(self.style.SUCCESS(
                f"Created {doc_count} doctors ({linked_count} linked to a canonical OT "
                f"department; the rest are non-surgical specialties out of OT-scheduling scope)"
            ))

        self.stdout.write(self.style.SUCCESS("Seed complete."))
