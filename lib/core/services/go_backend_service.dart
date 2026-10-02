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

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏨 SMART HOSTEL REST APIS (Autonomous Go Backend on Port :8080)
  // ═══════════════════════════════════════════════════════════════════════════

  /// 10. Fetch total 450-bed occupancy matrix & blocks from Go backend
  static Future<Map<String, dynamic>?> fetchHostelOverview() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/hostel/overview")).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// 11. Fetch digital gate passes from Go backend
  static Future<List<dynamic>?> fetchHostelGatePasses() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/hostel/gatepasses")).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["passes"] is List) {
          return data["passes"] as List<dynamic>;
        }
      }
    } catch (_) {}
    return null;
  }

  /// 12. Apply for digital gate pass on Go backend
  static Future<Map<String, dynamic>?> applyGatePass({
    required String studentName,
    required String rollNumber,
    required String reason,
    required String destination,
    required String outDateTime,
    required String expectedInDateTime,
    required String parentPhone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/hostel/gatepass/apply"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_name": studentName,
          "roll_number": rollNumber,
          "reason": reason,
          "destination": destination,
          "out_time": outDateTime,
          "expected_in": expectedInDateTime,
          "parent_phone": parentPhone,
        }),
      ).timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// 13. Simulate biometric/QR turnstile gate punch on Go backend
  static Future<Map<String, dynamic>?> simulateTurnstileScan({
    required String passId,
    required String gateLocation,
    required String action,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/hostel/turnstile/scan"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pass_id": passId,
          "gate_location": gateLocation,
          "action": action,
        }),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// 14. Fetch 24h SLA room maintenance tickets from Go backend
  static Future<List<dynamic>?> fetchHostelMaintenance() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/hostel/maintenance")).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["tickets"] is List) {
          return data["tickets"] as List<dynamic>;
        }
      }
    } catch (_) {}
    return null;
  }

  /// 15. Submit room maintenance issue on Go backend
  static Future<Map<String, dynamic>?> createHostelMaintenance({
    required String roomNumber,
    required String studentName,
    required String rollNumber,
    required String category,
    required String description,
    required String urgency,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/hostel/maintenance/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "room_number": roomNumber,
          "student_name": studentName,
          "roll_number": rollNumber,
          "category": category,
          "description": description,
          "urgency": urgency,
        }),
      ).timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// 16. Submit 5-star student meal rating on Go backend
  static Future<Map<String, dynamic>?> rateHostelMeal({
    required String mealType,
    required int rating,
    required String comment,
    required String studentRoll,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/hostel/mess/rate"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "meal_type": mealType,
          "rating": rating,
          "comment": comment,
          "student_roll": studentRoll,
        }),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// 17. Trigger emergency red SOS panic beacon on Go backend
  static Future<Map<String, dynamic>?> triggerEmergencySos({
    required String studentName,
    required String rollNumber,
    required String blockName,
    required String roomNumber,
    required String emergencyType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/hostel/sos/trigger"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_name": studentName,
          "roll_number": rollNumber,
          "block_name": blockName,
          "room_number": roomNumber,
          "emergency_type": emergencyType,
        }),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  // ============================================================================
  // 🚀 6 ULTRA-SMART INNOVATION CLIENT METHODS (Go Backend :8080)
  // ============================================================================

  /// 18. Submit roommate lifestyle quiz for Gale-Shapley matching
  static Future<Map<String, dynamic>?> submitRoommateQuiz(RoommateQuizProfile quiz) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/hostel/roommate/quiz"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "roll_number": quiz.rollNumber,
          "student_name": quiz.studentName,
          "branch": quiz.branch,
          "sleep_cycle": quiz.sleepCycle,
          "study_environment": quiz.studyEnvironment,
          "ac_preference": quiz.acPreference,
          "cleanliness": quiz.cleanliness,
          "interests": quiz.interests,
          "compatibility_score": quiz.compatibilityScore,
        }),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// 19. Run Gale-Shapley Stable Marriage Roommate Matchmaker
  static Future<Map<String, dynamic>?> runGaleShapleyMatch() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/hostel/roommate/match"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// 20. Submit daily dining intent (Before 06:00 PM)
  static Future<Map<String, dynamic>?> submitDiningIntent({
    required String studentRoll,
    required String studentName,
    required String mealType,
    required String intent,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/hostel/mess/dining-intent"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_roll": studentRoll,
          "student_name": studentName,
          "meal_type": mealType,
          "intent": intent,
        }),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// 21. Trigger secret anti-ragging silent duress PIN (9999)
  static Future<Map<String, dynamic>?> triggerSilentDuress({
    required String enteredPin,
    required String studentRoll,
    required String studentName,
    required String roomNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/hostel/duress/alarm"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "entered_pin": enteredPin,
          "student_roll": studentRoll,
          "student_name": studentName,
          "room_number": roomNumber,
        }),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// 22. Request curfew extension with 1-click parent consent dispatch
  static Future<Map<String, dynamic>?> requestCurfewExtension({
    required String gatePassId,
    required String studentRoll,
    required String studentName,
    required String roomNumber,
    required int extensionMinutes,
    required String reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/hostel/curfew/extension"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "gate_pass_id": gatePassId,
          "student_roll": studentRoll,
          "student_name": studentName,
          "room_number": roomNumber,
          "extension_minutes": extensionMinutes,
          "reason": reason,
        }),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// 23. Submit parent 1-click curfew approval / rejection
  static Future<Map<String, dynamic>?> submitParentCurfewConsent({
    required String extensionId,
    required String decision,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/hostel/curfew/extension/parent-consent"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "extension_id": extensionId,
          "decision": decision,
        }),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}

