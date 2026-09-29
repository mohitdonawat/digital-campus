import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/campus_models.dart';

/// GoBackendService connects the Flutter UI directly to the autonomous single-file Go backend.
/// Handles high-concurrency multi-tenant colleges, class-wise attendance sync, and automation alerts.
class GoBackendService {
  // Base URLs for desktop/web vs Android emulator
  static String get baseUrl {
    if (kIsWeb) return "http://localhost:8080/api";
    // Check if running on Android device or emulator
    if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:8080/api";
    }
    return "http://localhost:8080/api";
  }

  static const Duration _timeout = Duration(milliseconds: 2500);

  /// 1. Health check to determine if the single-file Go server is running
  static Future<Map<String, dynamic>?> checkHealth() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/health")).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      if (kDebugMode) {
        print("[GoBackendService] Go server not reached at $baseUrl ($e). Using local cache.");
      }
    }
    return null;
  }

  /// 2. Fetch all multi-tenant colleges from Go backend
  static Future<List<CollegeTenant>?> fetchTenants() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/tenants")).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["tenants"] is List) {
          final list = (data["tenants"] as List)
              .map((item) => CollegeTenant.fromJson(item as Map<String, dynamic>))
              .toList();
          return list;
        }
      }
    } catch (_) {}
    return null;
  }

  /// 3. Register new college with auto-generated ID & Password
  static Future<CollegeTenant?> registerTenant(CollegeTenant tenant) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/tenants/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": tenant.name,
          "code": tenant.code,
          "city": tenant.city,
          "state": tenant.state,
          "affiliation": tenant.affiliation,
          "admin_name": tenant.adminName,
          "admin_email": tenant.adminEmail,
          "license_plan": tenant.licensePlan,
          "student_count": tenant.studentCount,
          "faculty_count": tenant.facultyCount,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["tenant"] != null) {
          return CollegeTenant.fromJson(data["tenant"] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 4. Approve pending college on Go backend
  static Future<CollegeTenant?> approveTenant(String tenantId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/tenants/approve"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"tenant_id": tenantId}),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["tenant"] != null) {
          return CollegeTenant.fromJson(data["tenant"] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 5. Fetch class-wise attendance records with filters from Go backend
  static Future<List<StudentAttendanceRecord>?> fetchAttendanceRecords({
    String branch = "All",
    int semester = 0,
    String section = "All",
    String status = "All",
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/attendance/records").replace(queryParameters: {
        if (branch != "All") "branch": branch,
        if (semester > 0) "semester": semester.toString(),
        if (section != "All") "section": section,
        if (status.toLowerCase().contains("defaulter")) "status": "defaulters",
        if (status.toLowerCase().contains("safe")) "status": "safe",
      });

      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["records"] is List) {
          return (data["records"] as List)
              .map((item) => StudentAttendanceRecord.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return null;
  }

  /// 6. Toggle individual student attendance on Go backend
  static Future<StudentAttendanceRecord?> toggleAttendance(String studentId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/attendance/toggle"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"student_id": studentId}),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["student"] != null) {
          return StudentAttendanceRecord.fromJson(data["student"] as Map<String, dynamic>);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 7. Bulk mark attendance on Go backend
  static Future<int?> bulkAttendance({
    required String branch,
    required int semester,
    required String section,
    required bool isPresent,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/attendance/bulk"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "branch": branch,
          "semester": semester,
          "section": section,
          "is_present": isPresent,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["affected"] as int?;
      }
    } catch (_) {}
    return null;
  }

  /// 8. Trigger automated SMS/WhatsApp alerts for defaulters on Go backend
  static Future<Map<String, dynamic>?> alertParents() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/attendance/alert-parents"),
        headers: {"Content-Type": "application/json"},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// 9. Fetch background automation logs executed by Go goroutines
  static Future<List<Map<String, dynamic>>?> fetchAutomationLogs() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/automation/logs")).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["logs"] is List) {
          return List<Map<String, dynamic>>.from(data["logs"]);
        }
      }
    } catch (_) {}
    return null;
  }
}
