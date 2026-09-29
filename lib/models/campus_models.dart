import 'package:flutter/material.dart';

// -------------------------------------------------------------
// 1. Student Profile & Lifecycle
// -------------------------------------------------------------
class StudentProfile {
  final String id;
  final String name;
  final String rollNumber;
  final String enrollmentNumber;
  final String branch;
  final int semester;
  final String section;
  final double currentCgpa;
  final double attendancePercentage;
  final String hostelBlock;
  final String roomNumber;
  final String busRouteNumber;
  final String mentorName;
  final String mentorContact;
  final String parentName;
  final String parentPhone;
  final String lifecycleStage; // "Admitted", "Foundation", "Specialization", "Placement", "Graduated"
  final String email;
  final String phone;
  final String bloodGroup;
  final String address;
  final String emergencyContact;
  // Professional & Career Portfolio
  final String headline;
  final String bio;
  final String githubUrl;
  final String linkedinUrl;
  final String portfolioUrl;
  final String leetcodeHandle;
  // National Regulatory Credentials (Govt of India NEP 2020)
  final String apaarId;
  final String abcId;
  final bool isDigiLockerSynced;
  final String digiLockerAadhaarMasked;
  // Skills, Badges & Certifications
  final List<String> skills;
  final List<String> certifications;
  final double placementReadinessScore;
  final int projectsCount;
  final int hackathonsWon;
  // Security & Preferences
  final bool biometricLoginEnabled;
  final bool twoFactorEnabled;

  const StudentProfile({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.enrollmentNumber,
    required this.branch,
    required this.semester,
    required this.section,
    required this.currentCgpa,
    required this.attendancePercentage,
    required this.hostelBlock,
    required this.roomNumber,
    required this.busRouteNumber,
    required this.mentorName,
    required this.mentorContact,
    required this.parentName,
    required this.parentPhone,
    required this.lifecycleStage,
    this.email = "rahul.sharma@campus.edu.in",
    this.phone = "+91 98930 44556",
    this.bloodGroup = "B+ Positive",
    this.address = "Plot 42, Gulmohar Colony, Bhopal, MP",
    this.emergencyContact = "+91 94250 88991",
    this.headline = "Full-Stack AI Developer • Pre-Placement Scholar",
    this.bio = "Passionate computer science undergrad specializing in distributed systems, Flutter, and applied machine learning. Winner of Smart India Hackathon 2025.",
    this.githubUrl = "github.com/rahulsharma-dev",
    this.linkedinUrl = "linkedin.com/in/rahulsharma-cs",
    this.portfolioUrl = "https://rahulsharma.dev",
    this.leetcodeHandle = "rahul_coder_45",
    this.apaarId = "9842-1082-9901-4456",
    this.abcId = "ABC-662-901-442",
    this.isDigiLockerSynced = true,
    this.digiLockerAadhaarMasked = "XXXX-XXXX-8921",
    this.skills = const ["Flutter", "Dart", "Python", "PyTorch", "Docker", "Go", "PostgreSQL", "System Design"],
    this.certifications = const [
      "AWS Certified Cloud Practitioner",
      "NPTEL Deep Learning (Top 1% Elite)",
      "Google Cloud Associate Engineer",
    ],
    this.placementReadinessScore = 92.5,
    this.projectsCount = 8,
    this.hackathonsWon = 3,
    this.biometricLoginEnabled = true,
    this.twoFactorEnabled = true,
  });

  StudentProfile copyWith({
    String? id,
    String? name,
    String? rollNumber,
    String? enrollmentNumber,
    String? branch,
    int? semester,
    String? section,
    double? currentCgpa,
    double? attendancePercentage,
    String? hostelBlock,
    String? roomNumber,
    String? busRouteNumber,
    String? mentorName,
    String? mentorContact,
    String? parentName,
    String? parentPhone,
    String? lifecycleStage,
    String? email,
    String? phone,
    String? bloodGroup,
    String? address,
    String? emergencyContact,
    String? headline,
    String? bio,
    String? githubUrl,
    String? linkedinUrl,
    String? portfolioUrl,
    String? leetcodeHandle,
    String? apaarId,
    String? abcId,
    bool? isDigiLockerSynced,
    String? digiLockerAadhaarMasked,
    List<String>? skills,
    List<String>? certifications,
    double? placementReadinessScore,
    int? projectsCount,
    int? hackathonsWon,
    bool? biometricLoginEnabled,
    bool? twoFactorEnabled,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      section: section ?? this.section,
      currentCgpa: currentCgpa ?? this.currentCgpa,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      hostelBlock: hostelBlock ?? this.hostelBlock,
      roomNumber: roomNumber ?? this.roomNumber,
      busRouteNumber: busRouteNumber ?? this.busRouteNumber,
      mentorName: mentorName ?? this.mentorName,
      mentorContact: mentorContact ?? this.mentorContact,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      lifecycleStage: lifecycleStage ?? this.lifecycleStage,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      headline: headline ?? this.headline,
      bio: bio ?? this.bio,
      githubUrl: githubUrl ?? this.githubUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      leetcodeHandle: leetcodeHandle ?? this.leetcodeHandle,
      apaarId: apaarId ?? this.apaarId,
      abcId: abcId ?? this.abcId,
      isDigiLockerSynced: isDigiLockerSynced ?? this.isDigiLockerSynced,
      digiLockerAadhaarMasked: digiLockerAadhaarMasked ?? this.digiLockerAadhaarMasked,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      placementReadinessScore: placementReadinessScore ?? this.placementReadinessScore,
      projectsCount: projectsCount ?? this.projectsCount,
      hackathonsWon: hackathonsWon ?? this.hackathonsWon,
      biometricLoginEnabled: biometricLoginEnabled ?? this.biometricLoginEnabled,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    );
  }
}

// -------------------------------------------------------------
// 2. Attendance Model
// -------------------------------------------------------------
class SubjectAttendance {
  final String subjectCode;
  final String subjectName;
  final int attendedClasses;
  final int totalClasses;
  final String facultyName;

  const SubjectAttendance({
    required this.subjectCode,
    required this.subjectName,
    required this.attendedClasses,
    required this.totalClasses,
    required this.facultyName,
  });

  double get percentage => (totalClasses == 0) ? 0.0 : (attendedClasses / totalClasses) * 100;
  bool get isSafe => percentage >= 75.0;
  int get safeBunksPossible {
    // formula: (attended / (total + x)) >= 0.75 => x <= (attended / 0.75) - total
    final maxTotal = attendedClasses / 0.75;
    final diff = (maxTotal - totalClasses).floor();
    return diff > 0 ? diff : 0;
  }
  int get classesNeededFor75 {
    // formula: ((attended + y) / (total + y)) >= 0.75 => y >= (0.75*total - attended)/0.25
    if (percentage >= 75.0) return 0;
    final req = ((0.75 * totalClasses - attendedClasses) / 0.25).ceil();
    return req > 0 ? req : 0;
  }
}

// -------------------------------------------------------------
// 3. Timetable Model
// -------------------------------------------------------------
class TimetablePeriod {
  final String id;
  final String day;
  final String startTime;
  final String endTime;
  final String subjectName;
  final String subjectCode;
  final String roomNumber;
  final String facultyName;
  final bool isSubstitute;
  final String? originalFacultyName;
  final String? substituteReason;

  const TimetablePeriod({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.subjectName,
    required this.subjectCode,
    required this.roomNumber,
    required this.facultyName,
    this.isSubstitute = false,
    this.originalFacultyName,
    this.substituteReason,
  });
}

// -------------------------------------------------------------
// 4. Digital Certificate Model (Verifiable Credentials)
// -------------------------------------------------------------
class DigitalCertificate {
  final String id;
  final String title;
  final String type; // "Bonafide", "Marksheet", "Character", "Course Completion"
  final String issueDate;
  final String issuedTo;
  final String rollNumber;
  final String sha256Hash;
  final String verificationUrl;
  final bool isAttested;
  final String attestedBy;

  const DigitalCertificate({
    required this.id,
    required this.title,
    required this.type,
    required this.issueDate,
    required this.issuedTo,
    required this.rollNumber,
    required this.sha256Hash,
    required this.verificationUrl,
    required this.isAttested,
    required this.attestedBy,
  });
}

// -------------------------------------------------------------
// 5. Fee Ledger & Payment Model
// -------------------------------------------------------------
class FeeItem {
  final String id;
  final String title;
  final double amount;
  final String dueDate;
  final bool isPaid;
  final String? paidDate;
  final String? transactionId;
  final String? receiptNumber;

  const FeeItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    this.paidDate,
    this.transactionId,
    this.receiptNumber,
  });
}

// -------------------------------------------------------------
// 6. Hostel & E-Gate Pass Model
// -------------------------------------------------------------
class HostelDetails {
  final String blockName;
  final String roomNumber;
  final int floor;
  final String wardenName;
  final String wardenPhone;
  final List<String> roommates;

  const HostelDetails({
    required this.blockName,
    required this.roomNumber,
    required this.floor,
    required this.wardenName,
    required this.wardenPhone,
    required this.roommates,
  });
}

class GatePass {
  final String id;
  final String reason;
  final String destination;
  final String outDateTime;
  final String expectedInDateTime;
  final String status; // "Approved", "Pending", "Exited", "Closed"
  final String? approvedBy;
  final String qrPayload;

  const GatePass({
    required this.id,
    required this.reason,
    required this.destination,
    required this.outDateTime,
    required this.expectedInDateTime,
    required this.status,
    this.approvedBy,
    required this.qrPayload,
  });
}

// -------------------------------------------------------------
// 7. Transport & Live Bus Tracking Model
// -------------------------------------------------------------
class BusRoute {
  final String routeNumber;
  final String routeName;
  final String busPlateNumber;
  final String driverName;
  final String driverPhone;
  final String currentStop;
  final String nextStop;
  final int etaMinutes;
  final double speedKmph;
  final List<String> stopList;

  const BusRoute({
    required this.routeNumber,
    required this.routeName,
    required this.busPlateNumber,
    required this.driverName,
    required this.driverPhone,
    required this.currentStop,
    required this.nextStop,
    required this.etaMinutes,
    required this.speedKmph,
    required this.stopList,
  });
}

// -------------------------------------------------------------
// 8. Student Helpdesk & Grievance Model
// -------------------------------------------------------------
class GrievanceTicket {
  final String id;
  final String category; // "Academic", "Hostel", "Fee", "Anti-Ragging", "Transport"
  final String subject;
  final String description;
  final String createdAt;
  final String status; // "In Progress", "Resolved", "Escalated"
  final String priority; // "Low", "Medium", "High", "Critical"
  final int remainingSlaHours;
  final String assignedOfficer;

  const GrievanceTicket({
    required this.id,
    required this.category,
    required this.subject,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.priority,
    required this.remainingSlaHours,
    required this.assignedOfficer,
  });
}

// -------------------------------------------------------------
// 9. AI Features Models: Voice, Performance, Dropout, Learning
// -------------------------------------------------------------
class AiChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? spokenAudioUrl;
  final List<String>? actionSuggestions;

  AiChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.spokenAudioUrl,
    this.actionSuggestions,
  });
}

class DropoutRiskAnalysis {
  final double riskScore; // 0 - 100%
  final String riskTier; // "Low Risk", "Moderate Attention", "Critical Danger"
  final double attendanceSlope; // e.g. -4.5% last 30 days
  final int academicBacklogs;
  final int feeDefaultDays;
  final double lmsEngagementScore; // 0 - 100
  final List<String> primaryRiskFactors;
  final List<String> recommendedInterventions;

  const DropoutRiskAnalysis({
    required this.riskScore,
    required this.riskTier,
    required this.attendanceSlope,
    required this.academicBacklogs,
    required this.feeDefaultDays,
    required this.lmsEngagementScore,
    required this.primaryRiskFactors,
    required this.recommendedInterventions,
  });
}

class PredictivePerformance {
  final double predictedSgpa; // e.g. 8.45
  final double lowerConfidenceBound; // 8.15
  final double upperConfidenceBound; // 8.75
  final String trajectory; // "Improving", "Stable", "Declining"
  final Map<String, double> subjectRiskScores; // Subject -> Expected Score
  final List<String> highLeverageActions;

  const PredictivePerformance({
    required this.predictedSgpa,
    required this.lowerConfidenceBound,
    required this.upperConfidenceBound,
    required this.trajectory,
    required this.subjectRiskScores,
    required this.highLeverageActions,
  });
}

class LearningRecommendation {
  final String id;
  final String subject;
  final String topic;
  final String reason; // e.g., "Identified weakness in Mid-Term Exam (42% accuracy)"
  final String resourceType; // "Video Lecture", "Handout Notes", "Adaptive Quiz"
  final String durationOrPages;
  final String difficulty;
  final VoidCallback? onLaunch;

  const LearningRecommendation({
    required this.id,
    required this.subject,
    required this.topic,
    required this.reason,
    required this.resourceType,
    required this.durationOrPages,
    required this.difficulty,
    this.onLaunch,
  });
}

// -------------------------------------------------------------
// 12. B2B Multi-Tenant College / University Model
// -------------------------------------------------------------
class CollegeTenant {
  final String id;
  final String name;
  final String code; // e.g. "APEX-0103"
  final String city;
  final String state;
  final String affiliation; // "Autonomous RGPV", "AICTE Tier-1", "State Govt"
  final String status; // "Active", "Pending Approval", "Suspended"
  final String adminEmail;
  final String adminPassword;
  final String adminName;
  final int studentCount;
  final int facultyCount;
  final String licensePlan; // "Starter", "Enterprise Cloud", "Autonomous University Tier-1"
  final DateTime registeredDate;

  const CollegeTenant({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
    required this.state,
    required this.affiliation,
    required this.status,
    required this.adminEmail,
    required this.adminPassword,
    required this.adminName,
    required this.studentCount,
    required this.facultyCount,
    required this.licensePlan,
    required this.registeredDate,
  });

  factory CollegeTenant.fromJson(Map<String, dynamic> json) {
    return CollegeTenant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      affiliation: json['affiliation']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      adminEmail: json['admin_email']?.toString() ?? '',
      adminPassword: json['admin_password']?.toString() ?? '',
      adminName: json['admin_name']?.toString() ?? '',
      studentCount: (json['student_count'] is num) ? (json['student_count'] as num).toInt() : 0,
      facultyCount: (json['faculty_count'] is num) ? (json['faculty_count'] as num).toInt() : 0,
      licensePlan: json['license_plan']?.toString() ?? 'Standard',
      registeredDate: DateTime.tryParse(json['registered_date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'city': city,
      'state': state,
      'affiliation': affiliation,
      'status': status,
      'admin_email': adminEmail,
      'admin_password': adminPassword,
      'admin_name': adminName,
      'student_count': studentCount,
      'faculty_count': facultyCount,
      'license_plan': licensePlan,
      'registered_date': registeredDate.toIso8601String(),
    };
  }

  CollegeTenant copyWith({
    String? status,
    String? licensePlan,
    String? adminPassword,
    int? studentCount,
    int? facultyCount,
    DateTime? registeredDate,
  }) {
    return CollegeTenant(
      id: id,
      name: name,
      code: code,
      city: city,
      state: state,
      affiliation: affiliation,
      status: status ?? this.status,
      adminEmail: adminEmail,
      adminPassword: adminPassword ?? this.adminPassword,
      adminName: adminName,
      studentCount: studentCount ?? this.studentCount,
      facultyCount: facultyCount ?? this.facultyCount,
      licensePlan: licensePlan ?? this.licensePlan,
      registeredDate: registeredDate ?? this.registeredDate,
    );
  }
}

// -------------------------------------------------------------
// 13. Class-wise Student Attendance Record
// -------------------------------------------------------------
class StudentAttendanceRecord {
  final String studentId;
  final String name;
  final String rollNumber;
  final String branch;
  final int semester;
  final String section;
  final double attendancePercentage;
  final bool isPresentToday;
  final int totalClasses;
  final int attendedClasses;

  const StudentAttendanceRecord({
    required this.studentId,
    required this.name,
    required this.rollNumber,
    required this.branch,
    required this.semester,
    required this.section,
    required this.attendancePercentage,
    required this.isPresentToday,
    required this.totalClasses,
    required this.attendedClasses,
  });

  factory StudentAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceRecord(
      studentId: json['student_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      rollNumber: json['roll_number']?.toString() ?? '',
      branch: json['branch']?.toString() ?? '',
      semester: (json['semester'] is num) ? (json['semester'] as num).toInt() : 0,
      section: json['section']?.toString() ?? '',
      attendancePercentage: (json['attendance_percentage'] is num) ? (json['attendance_percentage'] as num).toDouble() : 0.0,
      isPresentToday: json['is_present_today'] == true,
      totalClasses: (json['total_classes'] is num) ? (json['total_classes'] as num).toInt() : 0,
      attendedClasses: (json['attended_classes'] is num) ? (json['attended_classes'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
      'roll_number': rollNumber,
      'branch': branch,
      'semester': semester,
      'section': section,
      'attendance_percentage': attendancePercentage,
      'is_present_today': isPresentToday,
      'total_classes': totalClasses,
      'attended_classes': attendedClasses,
    };
  }

  StudentAttendanceRecord copyWith({
    bool? isPresentToday,
    double? attendancePercentage,
    int? attendedClasses,
    int? totalClasses,
  }) {
    return StudentAttendanceRecord(
      studentId: studentId,
      name: name,
      rollNumber: rollNumber,
      branch: branch,
      semester: semester,
      section: section,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      isPresentToday: isPresentToday ?? this.isPresentToday,
      totalClasses: totalClasses ?? this.totalClasses,
      attendedClasses: attendedClasses ?? this.attendedClasses,
    );
  }
}

// -------------------------------------------------------------
// 14. Faculty Professional Profile & Research Dossier
// -------------------------------------------------------------
class FacultyProfessionalProfile {
  final String id;
  final String name;
  final String designation;
  final String department;
  final String qualifications;
  final String cabinNumber;
  final String officeHours;
  final String scholarUrl;
  final String researchGateUrl;
  final int papersPublished;
  final int citationsCount;
  final int patentsGranted;
  final List<String> subjectsTaught;
  final List<String> researchDomains;
  final double studentFeedbackRating; // out of 5.0

  const FacultyProfessionalProfile({
    this.id = "FAC-2018-CSE-007",
    this.name = "Dr. Mohit Donawat",
    this.designation = "Associate Professor & Head of Department (H.O.D.)",
    this.department = "Computer Science & Engineering",
    this.qualifications = "Ph.D. (AI & Neural Architectures), M.Tech (CSE - IIT Roorkee)",
    this.cabinNumber = "Cabin 302, Academic Block A",
    this.officeHours = "Mon - Fri, 03:00 PM - 05:00 PM",
    this.scholarUrl = "scholar.google.com/citations?user=mohit_donawat",
    this.researchGateUrl = "researchgate.net/profile/Mohit-Donawat",
    this.papersPublished = 18,
    this.citationsCount = 420,
    this.patentsGranted = 2,
    this.subjectsTaught = const [
      "Machine Learning & Artificial Intelligence",
      "Advanced Compiler Design",
      "Distributed Cloud Architecture",
    ],
    this.researchDomains = const [
      "Edge AI",
      "Federated Learning",
      "Natural Language Processing for Indic Languages",
    ],
    this.studentFeedbackRating = 4.88,
  });
}

// -------------------------------------------------------------
// 15. Admin Registrar Governance Credentials & Compliance
// -------------------------------------------------------------
class AdminProfessionalProfile {
  final String id;
  final String name;
  final String designation;
  final String office;
  final String authorizationLevel;
  final String complianceLevel;
  final String digitalSigningKeyHash;
  final int totalStudentsUnderGovernance;
  final int pendingAuditActions;
  final String naacGrade;
  final String nirfBand;

  const AdminProfessionalProfile({
    this.id = "ADM-REG-001",
    this.name = "Dr. R.K. Saxena",
    this.designation = "Registrar & Chief Controller of Examinations",
    this.office = "Office of Academic Governance & University Affairs",
    this.authorizationLevel = "Tier-1 Chancellor Seal Authority",
    this.complianceLevel = "AICTE • UGC • RGPV Statutory Regulatory Board",
    this.digitalSigningKeyHash = "SHA256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    this.totalStudentsUnderGovernance = 4280,
    this.pendingAuditActions = 4,
    this.naacGrade = "A++ (Score 3.78/4.0)",
    this.nirfBand = "Rank Band 101-150 Engineering",
  });
}

// -------------------------------------------------------------
// 16. Parent Guardian Verification & Ward Oversight
// -------------------------------------------------------------
class ParentProfessionalProfile {
  final String id;
  final String guardianName;
  final String relation;
  final String occupation;
  final String verifiedPhone;
  final String wardName;
  final String wardRoll;
  final String wardBranch;
  final bool isKycVerified;
  final String paymentPreference;

  const ParentProfessionalProfile({
    this.id = "PAR-2022-CS-045",
    this.guardianName = "Suresh Sharma",
    this.relation = "Father / Primary Legal Guardian",
    this.occupation = "Senior Engineer (Central PSUs)",
    this.verifiedPhone = "+91 94250 88991",
    this.wardName = "Rahul Sharma",
    this.wardRoll = "CS22B045",
    this.wardBranch = "B.Tech Computer Science (Sem 6)",
    this.isKycVerified = true,
    this.paymentPreference = "Direct NetBanking / UPI Auto-Debits",
  });
}

// -------------------------------------------------------------
// 17. AI Automated Career & Placement Insight
// -------------------------------------------------------------
class AiCareerInsight {
  final double placementProbability; // 0 - 100
  final String suggestedHeadline;
  final String generatedBio;
  final List<String> recommendedSkills;
  final List<String> topCompanyMatches;
  final String strengthsSummary;
  final String nextActionPlan;

  const AiCareerInsight({
    required this.placementProbability,
    required this.suggestedHeadline,
    required this.generatedBio,
    required this.recommendedSkills,
    required this.topCompanyMatches,
    required this.strengthsSummary,
    required this.nextActionPlan,
  });
}

