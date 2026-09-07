import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/config/constants.dart';

/// A canonical OT/surgical department, loaded from `GET /api/departments/`.
class DepartmentInfo {
  final int id;
  final String name;
  final List<String> aliases;

  DepartmentInfo({required this.id, required this.name, required this.aliases});

  factory DepartmentInfo.fromJson(Map<String, dynamic> json) => DepartmentInfo(
        id: json['id'] as int,
        name: json['name'] as String,
        aliases: (json['aliases'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
}

/// A doctor from the roster, loaded from `GET /api/doctors/`.
class DoctorInfo {
  final int doctorId;
  final String name;
  final String? empId;
  final List<int> departmentIds;

  DoctorInfo({required this.doctorId, required this.name, required this.empId, required this.departmentIds});

  factory DoctorInfo.fromJson(Map<String, dynamic> json) => DoctorInfo(
        doctorId: json['doctor_id'] as int,
        name: (json['doctor_name'] as String?) ?? '',
        empId: json['emp_id'] as String?,
        departmentIds: (json['departments'] as List?)?.map((e) => e as int).toList() ?? [],
      );
}

/// A procedure from the reconciled master list, loaded from `GET /api/procedure/`.
class ProcedureInfo {
  final int procedureId;
  final String name;
  final String? code;
  final List<int> departmentIds;
  final double? durationHours;

  ProcedureInfo({
    required this.procedureId,
    required this.name,
    required this.code,
    required this.departmentIds,
    required this.durationHours,
  });

  factory ProcedureInfo.fromJson(Map<String, dynamic> json) => ProcedureInfo(
        procedureId: json['procedure_id'] as int,
        name: (json['procedure_name'] as String?) ?? '',
        code: json['code'] as String?,
        departmentIds: (json['departments'] as List?)?.map((e) => e as int).toList() ?? [],
        durationHours: (json['estimated_duration'] as num?)?.toDouble(),
      );
}

/// Single in-memory cache of departments/doctors/procedures, fetched once from the backend
/// (see backend/OT_Scheduling/models.py: Department, Doctors, Procedures) instead of the
/// hardcoded Constants.departmentList / Constants.doctorSpecialtyMap / Constants.<dept>Map
/// pairs. See docs/confirmation-screen-population-issues.md for why: those hardcoded copies
/// drifted from each other and from the backend's own reference data (issues #1, #6, #8).
class DepartmentDataService {
  DepartmentDataService._internal();
  static final DepartmentDataService instance = DepartmentDataService._internal();

  List<DepartmentInfo> _departments = [];
  List<DoctorInfo> _doctors = [];
  List<ProcedureInfo> _procedures = [];
  Future<void>? _loadFuture;

  bool get isLoaded => _departments.isNotEmpty;

  /// Fetches all three endpoints once and caches the result. Safe to call repeatedly -
  /// concurrent/subsequent calls await the same in-flight (or already-completed) load.
  Future<void> ensureLoaded() {
    return _loadFuture ??= _loadAll();
  }

  Future<void> _loadAll() async {
    final results = await Future.wait([
      http.get(Uri.parse('${Constants.baseURL}/departments/')),
      http.get(Uri.parse('${Constants.baseURL}/doctors/')),
      http.get(Uri.parse('${Constants.baseURL}/procedure/')),
    ]);

    for (final r in results) {
      if (r.statusCode != 200) {
        throw Exception('Failed to load reference data (${r.request?.url}): HTTP ${r.statusCode}');
      }
    }

    _departments = (jsonDecode(results[0].body) as List)
        .map((e) => DepartmentInfo.fromJson(e as Map<String, dynamic>))
        .toList();
    _doctors = (jsonDecode(results[1].body) as List)
        .map((e) => DoctorInfo.fromJson(e as Map<String, dynamic>))
        .toList();
    _procedures = (jsonDecode(results[2].body) as List)
        .map((e) => ProcedureInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Forces the next ensureLoaded() to re-fetch (e.g. after data is edited in Django admin).
  void invalidate() {
    _loadFuture = null;
  }

  List<String> get departmentNames => _departments.map((d) => d.name).toList();

  String? _departmentName(int id) {
    for (final d in _departments) {
      if (d.id == id) return d.name;
    }
    return null;
  }

  static String _normalize(String s) {
    var n = s.trim().toLowerCase().replaceAll('&', ' and ');
    n = n.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    n = n.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (n.length > 1 && n.endsWith('s')) n = n.substring(0, n.length - 1);
    return n;
  }

  /// Matches raw department text (e.g. from an uploaded Excel) against the canonical
  /// department list and each department's known aliases - tolerant of case, whitespace,
  /// punctuation, '&' vs 'and', and a simple trailing-'s' plural. Returns the canonical name,
  /// or null if nothing matches.
  String? canonicalDepartment(String raw) {
    if (raw.trim().isEmpty) return null;
    final target = _normalize(raw);
    for (final dept in _departments) {
      if (_normalize(dept.name) == target) return dept.name;
      for (final alias in dept.aliases) {
        if (_normalize(alias) == target) return dept.name;
      }
    }
    return null;
  }

  static String _normalizeDoctorName(String raw) {
    String doctor = raw.toLowerCase().trim();
    doctor = doctor.replaceAll(RegExp(r'^dr\.?\s*'), '').replaceAll(RegExp(r'\(prof\)\s*'), '').trim();
    doctor = doctor.replaceAll(RegExp(r'\s+dr\.?\s*'), ' ');
    doctor = doctor.replaceAll(RegExp(r'\s+'), ' ');
    return doctor;
  }

  /// Looks up a single doctor's department by name. Unlike the old hardcoded
  /// Constants.ambiguousDoctorNames set, ambiguity is detected live from the roster: if two+
  /// doctors share this name AND have different departments (e.g. two different "Sachin
  /// Gupta"s - see docs/confirmation-screen-population-issues.md), this returns null rather
  /// than guessing, since a name alone can't tell them apart.
  String? departmentForDoctorName(String rawName) {
    final target = _normalizeDoctorName(rawName);
    if (target.isEmpty) return null;

    final matches = _doctors.where((d) => _normalizeDoctorName(d.name) == target).toList();
    if (matches.isEmpty) return null;

    final deptNamesPerDoctor = matches
        .map((d) => d.departmentIds.map(_departmentName).whereType<String>().toSet())
        .where((s) => s.isNotEmpty)
        .toList();
    if (deptNamesPerDoctor.isEmpty) return null;

    final allDeptNames = deptNamesPerDoctor.expand((s) => s).toSet();
    if (allDeptNames.length > 1) {
      print("doctor lookup key: '$rawName' is ambiguous (${matches.length} doctors share this name, departments: $allDeptNames); refusing to guess");
      return null;
    }
    return allDeptNames.first;
  }

  /// Looks up a doctor's specialty, handling a "/"-separated multi-doctor surgeon field (e.g.
  /// "Dr.Tarun Suri/Dr.Archit Goyal") by trying each name in turn and returning the first
  /// resolvable one.
  String determineSpecialty(String surgeon) {
    final names = surgeon.contains('/') ? surgeon.split('/').map((s) => s.trim()) : [surgeon];
    for (final name in names) {
      final dept = departmentForDoctorName(name);
      if (dept != null && dept.isNotEmpty) return dept;
    }
    return '';
  }

  /// code -> name map for procedures belonging to [departmentName] - replaces the old
  /// per-department Constants.<dept>Map switch in ListConfirmation.dart.
  Map<String, String> surgeryMapForDepartment(String departmentName) {
    final dept = _departments.firstWhere(
      (d) => d.name == departmentName,
      orElse: () => DepartmentInfo(id: -1, name: '', aliases: []),
    );
    if (dept.id == -1) return {};
    final map = <String, String>{};
    for (final p in _procedures) {
      if (p.code != null && p.code!.isNotEmpty && p.departmentIds.contains(dept.id)) {
        map[p.code!] = p.name;
      }
    }
    return map;
  }

  /// Global code -> ProcedureInfo lookup, independent of any one department. This is the fix
  /// for issue #8: a procedure's department(s) now travel with the code itself instead of
  /// depending on whichever department a row happens to be tagged with.
  ProcedureInfo? procedureForCode(String code) {
    if (code.isEmpty) return null;
    for (final p in _procedures) {
      if (p.code == code) return p;
    }
    return null;
  }

  /// The canonical department name(s) that actually own [code], per the backend's reconciled
  /// data - may be more than one for a procedure performed across multiple departments (e.g.
  /// Laparoscopic Cholecystectomy, A.V. Fistula).
  List<String> departmentsForCode(String code) {
    final proc = procedureForCode(code);
    if (proc == null) return [];
    return proc.departmentIds.map(_departmentName).whereType<String>().toList();
  }
}
