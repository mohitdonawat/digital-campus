// ╔══════════════════════════════════════════════════════════════════╗
// ║  DIGITAL CAMPUS — Education SaaS Platform                       ║
// ║  Like Accsoft/ERP for every college: Govt & Private             ║
// ║  Client institution is configured below (demo: Apex Institute)   ║
// ╚══════════════════════════════════════════════════════════════════╝
class AppConstants {
  // ── Product / Brand ────────────────────────────────────────────────
  static const String appName        = "Digital Campus";
  static const String appTagline     = "Education ERP & AI Platform for Every Institution";
  static const String appVersion     = "v2.5.0 Enterprise";
  static const String companyName    = "Digital Campus Technologies Pvt. Ltd.";
  static const String supportEmail   = "support@digitalcampus.in";
  static const String website        = "www.digitalcampus.in";

  // ── Active Client Institution (SaaS Tenant) ────────────────────────
  // Multi-tenant SaaS: Dynamic remote config / client university
  static const String institutionName  = "Apex Institute of Technology";
  static const String institutionCity  = "Bhopal, Madhya Pradesh";
  static const String institutionShort = "Apex Tech";
  static const String affiliation      = "AICTE Approved • Autonomous University • Estd. 1999";
  static const String accreditation    = "NAAC Grade A++ Accredited • Tier-1 Institution";
  static const String logoPath         = "assets/images/digital_campus_logo.png";

  // ── Statutory / Compliance ─────────────────────────────────────────
  static const double minimumAttendancePercentage   = 75.0;
  static const int    grievanceSlaHours             = 48;

  // ── AI Engine Thresholds ───────────────────────────────────────────
  static const double dropoutCriticalRiskThreshold  = 40.0;
  static const double dropoutWarningRiskThreshold   = 20.0;
}

enum UserRole {
  student,
  faculty,
  admin,
  parent,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.student:
        return "Student";
      case UserRole.faculty:
        return "Faculty";
      case UserRole.admin:
        return "Admin / Registrar";
      case UserRole.parent:
        return "Parent Portal";
    }
  }

  String get personaName {
    switch (this) {
      case UserRole.student:
        return "Rahul Sharma (Roll: CS22B045)";
      case UserRole.faculty:
        return "Dr. Mohit Donawat (HOD - CSE)";
      case UserRole.admin:
        return "Mr. Shridhar Donawat (Dean & Director)";
      case UserRole.parent:
        return "Suresh Sharma (Parent of Rahul)";
    }
  }

  String get department {
    switch (this) {
      case UserRole.student:
        return "Computer Science & Engineering • Sem 6";
      case UserRole.faculty:
        return "Dept of Computer Science & Engineering";
      case UserRole.admin:
        return "Directorate & Office of Dean & Director";
      case UserRole.parent:
        return "Ward: Rahul Sharma (B.Tech CSE - Sec A)";
    }
  }
}
