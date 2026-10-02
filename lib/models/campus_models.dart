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
// Live Class & Lecture Session Model
// -------------------------------------------------------------
enum LiveClassStatus {
  live,
  scheduled,
  completed,
}

enum MeetingPlatform {
  jitsi,
  googleMeet,
  zoom,
  custom,
}

extension MeetingPlatformExtension on MeetingPlatform {
  String get displayName {
    switch (this) {
      case MeetingPlatform.jitsi:
        return "Jitsi Meet (Instant / Free)";
      case MeetingPlatform.googleMeet:
        return "Google Meet";
      case MeetingPlatform.zoom:
        return "Zoom Meeting";
      case MeetingPlatform.custom:
        return "Custom Video Link";
    }
  }

  String get shortName {
    switch (this) {
      case MeetingPlatform.jitsi:
        return "Jitsi";
      case MeetingPlatform.googleMeet:
        return "G-Meet";
      case MeetingPlatform.zoom:
        return "Zoom";
      case MeetingPlatform.custom:
        return "Link";
    }
  }
}

class LiveClassSession {
  final String id;
  final String title;
  final String subjectCode;
  final String instructorName;
  final String topic;
  final String room;
  final DateTime scheduledAt;
  final String durationText;
  final LiveClassStatus status;
  final MeetingPlatform platform;
  final String meetingUrl;
  final int attendeesCount;
  final String? recordingUrl;
  final String? aiSummary;

  const LiveClassSession({
    required this.id,
    required this.title,
    required this.subjectCode,
    required this.instructorName,
    required this.topic,
    required this.room,
    required this.scheduledAt,
    required this.durationText,
    required this.status,
    required this.platform,
    required this.meetingUrl,
    this.attendeesCount = 0,
    this.recordingUrl,
    this.aiSummary,
  });

  LiveClassSession copyWith({
    String? id,
    String? title,
    String? subjectCode,
    String? instructorName,
    String? topic,
    String? room,
    DateTime? scheduledAt,
    String? durationText,
    LiveClassStatus? status,
    MeetingPlatform? platform,
    String? meetingUrl,
    int? attendeesCount,
    String? recordingUrl,
    String? aiSummary,
  }) {
    return LiveClassSession(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectCode: subjectCode ?? this.subjectCode,
      instructorName: instructorName ?? this.instructorName,
      topic: topic ?? this.topic,
      room: room ?? this.room,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationText: durationText ?? this.durationText,
      status: status ?? this.status,
      platform: platform ?? this.platform,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      aiSummary: aiSummary ?? this.aiSummary,
    );
  }
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
  final String status; // "Approved", "Pending", "Out of Campus", "Closed", "Rejected"
  final String? approvedBy;
  final String qrPayload;
  final String studentName;
  final String rollNumber;
  final String parentPhone;
  final bool isCurfewBreached;

  const GatePass({
    required this.id,
    required this.reason,
    required this.destination,
    required this.outDateTime,
    required this.expectedInDateTime,
    required this.status,
    this.approvedBy,
    required this.qrPayload,
    this.studentName = "Rahul Sharma",
    this.rollNumber = "CS22B045",
    this.parentPhone = "+91 98260 11400",
    this.isCurfewBreached = false,
  });

  GatePass copyWith({
    String? id,
    String? reason,
    String? destination,
    String? outDateTime,
    String? expectedInDateTime,
    String? status,
    String? approvedBy,
    String? qrPayload,
    String? studentName,
    String? rollNumber,
    String? parentPhone,
    bool? isCurfewBreached,
  }) {
    return GatePass(
      id: id ?? this.id,
      reason: reason ?? this.reason,
      destination: destination ?? this.destination,
      outDateTime: outDateTime ?? this.outDateTime,
      expectedInDateTime: expectedInDateTime ?? this.expectedInDateTime,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      qrPayload: qrPayload ?? this.qrPayload,
      studentName: studentName ?? this.studentName,
      rollNumber: rollNumber ?? this.rollNumber,
      parentPhone: parentPhone ?? this.parentPhone,
      isCurfewBreached: isCurfewBreached ?? this.isCurfewBreached,
    );
  }
}

class HostelMaintenanceTicket {
  final String id;
  final String roomNumber;
  final String studentName;
  final String rollNumber;
  final String category; // "Electrical", "Plumbing", "Wi-Fi / LAN", "Housekeeping"
  final String description;
  final String urgency; // "Normal", "Critical"
  final String status; // "Reported", "Assigned", "Resolved"
  final String assignedStaff;
  final String reportedAt;
  final String? resolvedAt;

  const HostelMaintenanceTicket({
    required this.id,
    required this.roomNumber,
    required this.studentName,
    required this.rollNumber,
    required this.category,
    required this.description,
    this.urgency = "Normal",
    this.status = "Reported",
    this.assignedStaff = "Pending Assignment",
    required this.reportedAt,
    this.resolvedAt,
  });

  HostelMaintenanceTicket copyWith({
    String? id,
    String? roomNumber,
    String? studentName,
    String? rollNumber,
    String? category,
    String? description,
    String? urgency,
    String? status,
    String? assignedStaff,
    String? reportedAt,
    String? resolvedAt,
  }) {
    return HostelMaintenanceTicket(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      studentName: studentName ?? this.studentName,
      rollNumber: rollNumber ?? this.rollNumber,
      category: category ?? this.category,
      description: description ?? this.description,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      assignedStaff: assignedStaff ?? this.assignedStaff,
      reportedAt: reportedAt ?? this.reportedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

class MessMealFeedback {
  final String id;
  final String mealType; // "Breakfast", "Lunch", "Snacks", "Dinner"
  final int rating; // 1 to 5
  final String comment;
  final String timestamp;

  const MessMealFeedback({
    required this.id,
    required this.mealType,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });
}

class MessRebateClaim {
  final String id;
  final String studentName;
  final String rollNumber;
  final String startDate;
  final String endDate;
  final int days;
  final double rebateAmount;
  final String reason;
  final String status; // "Approved", "Credited"

  const MessRebateClaim({
    required this.id,
    required this.studentName,
    required this.rollNumber,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.rebateAmount,
    required this.reason,
    this.status = "Approved",
  });

  MessRebateClaim copyWith({
    String? id,
    String? studentName,
    String? rollNumber,
    String? startDate,
    String? endDate,
    int? days,
    double? rebateAmount,
    String? reason,
    String? status,
  }) {
    return MessRebateClaim(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      rollNumber: rollNumber ?? this.rollNumber,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      days: days ?? this.days,
      rebateAmount: rebateAmount ?? this.rebateAmount,
      reason: reason ?? this.reason,
      status: status ?? this.status,
    );
  }
}

class HostelBlockOccupancy {
  final String blockId;
  final String blockName;
  final String type; // "Boys", "Girls"
  final int totalCapacity;
  final int occupiedBeds;
  final int vacantBeds;
  final String wardenName;
  final String wardenPhone;

  const HostelBlockOccupancy({
    required this.blockId,
    required this.blockName,
    required this.type,
    required this.totalCapacity,
    required this.occupiedBeds,
    required this.vacantBeds,
    required this.wardenName,
    required this.wardenPhone,
  });
}

class HostelFeePolicy {
  final double singleRoomAcRent;
  final double doubleRoomAcRent;
  final double tripleRoomAcRent;
  final double nonAcRoomRent;
  final double messDailyRate;
  final double messRebatePerDay;
  final int minLeaveDaysForRebate;
  final double cautionDeposit;
  final double wifiAndAmenitiesFee;
  final int freeElectricityUnits;
  final double electricityUnitRate;
  final String curfewTime;
  final double curfewViolationFine;

  const HostelFeePolicy({
    this.singleRoomAcRent = 48000.0,
    this.doubleRoomAcRent = 38000.0,
    this.tripleRoomAcRent = 16000.0,
    this.nonAcRoomRent = 12000.0,
    this.messDailyRate = 120.0,
    this.messRebatePerDay = 120.0,
    this.minLeaveDaysForRebate = 3,
    this.cautionDeposit = 5000.0,
    this.wifiAndAmenitiesFee = 1600.0,
    this.freeElectricityUnits = 100,
    this.electricityUnitRate = 8.0,
    this.curfewTime = "08:30 PM",
    this.curfewViolationFine = 250.0,
  });

  HostelFeePolicy copyWith({
    double? singleRoomAcRent,
    double? doubleRoomAcRent,
    double? tripleRoomAcRent,
    double? nonAcRoomRent,
    double? messDailyRate,
    double? messRebatePerDay,
    int? minLeaveDaysForRebate,
    double? cautionDeposit,
    double? wifiAndAmenitiesFee,
    int? freeElectricityUnits,
    double? electricityUnitRate,
    String? curfewTime,
    double? curfewViolationFine,
  }) {
    return HostelFeePolicy(
      singleRoomAcRent: singleRoomAcRent ?? this.singleRoomAcRent,
      doubleRoomAcRent: doubleRoomAcRent ?? this.doubleRoomAcRent,
      tripleRoomAcRent: tripleRoomAcRent ?? this.tripleRoomAcRent,
      nonAcRoomRent: nonAcRoomRent ?? this.nonAcRoomRent,
      messDailyRate: messDailyRate ?? this.messDailyRate,
      messRebatePerDay: messRebatePerDay ?? this.messRebatePerDay,
      minLeaveDaysForRebate: minLeaveDaysForRebate ?? this.minLeaveDaysForRebate,
      cautionDeposit: cautionDeposit ?? this.cautionDeposit,
      wifiAndAmenitiesFee: wifiAndAmenitiesFee ?? this.wifiAndAmenitiesFee,
      freeElectricityUnits: freeElectricityUnits ?? this.freeElectricityUnits,
      electricityUnitRate: electricityUnitRate ?? this.electricityUnitRate,
      curfewTime: curfewTime ?? this.curfewTime,
      curfewViolationFine: curfewViolationFine ?? this.curfewViolationFine,
    );
  }
}

class RoomSwapRequest {
  final String id;
  final String requesterStudentName;
  final String requesterRoll;
  final String currentRoom;
  final String targetStudentName;
  final String targetRoll;
  final String targetRoom;
  final String reason;
  final String status; // "Peer Approved", "Warden Approved", "Pending", "Rejected"
  final String timestamp;

  const RoomSwapRequest({
    required this.id,
    required this.requesterStudentName,
    required this.requesterRoll,
    required this.currentRoom,
    required this.targetStudentName,
    required this.targetRoll,
    required this.targetRoom,
    required this.reason,
    required this.status,
    required this.timestamp,
  });

  RoomSwapRequest copyWith({
    String? id,
    String? requesterStudentName,
    String? requesterRoll,
    String? currentRoom,
    String? targetStudentName,
    String? targetRoll,
    String? targetRoom,
    String? reason,
    String? status,
    String? timestamp,
  }) {
    return RoomSwapRequest(
      id: id ?? this.id,
      requesterStudentName: requesterStudentName ?? this.requesterStudentName,
      requesterRoll: requesterRoll ?? this.requesterRoll,
      currentRoom: currentRoom ?? this.currentRoom,
      targetStudentName: targetStudentName ?? this.targetStudentName,
      targetRoll: targetRoll ?? this.targetRoll,
      targetRoom: targetRoom ?? this.targetRoom,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class HostelFacilitySlot {
  final String id;
  final String facilityName; // "Smart Washing Machine 02", "Quiet Study Pod 04", "Gym Iron Den"
  final String slotTime;
  final String bookedByRoll;
  final String status; // "Available", "Booked", "Active"

  const HostelFacilitySlot({
    required this.id,
    required this.facilityName,
    required this.slotTime,
    required this.bookedByRoll,
    required this.status,
  });

  HostelFacilitySlot copyWith({
    String? id,
    String? facilityName,
    String? slotTime,
    String? bookedByRoll,
    String? status,
  }) {
    return HostelFacilitySlot(
      id: id ?? this.id,
      facilityName: facilityName ?? this.facilityName,
      slotTime: slotTime ?? this.slotTime,
      bookedByRoll: bookedByRoll ?? this.bookedByRoll,
      status: status ?? this.status,
    );
  }
}

class RoommateCompatibilityProfile {
  final String name;
  final String rollNumber;
  final String branch;
  final int compatibilityScore; // e.g. 96%
  final String sleepHabit; // "Early Riser" / "Night Owl"
  final String diet; // "Vegetarian" / "Non-Veg"
  final String studyHabit; // "Silent Study" / "Group Study"

  const RoommateCompatibilityProfile({
    required this.name,
    required this.rollNumber,
    required this.branch,
    required this.compatibilityScore,
    required this.sleepHabit,
    required this.diet,
    required this.studyHabit,
  });
}

class HostelEmergencySosLog {
  final String id;
  final String studentName;
  final String rollNumber;
  final String roomNumber;
  final String block;
  final String triggerTime;
  final String status; // "TRIGGERED", "QRT_DISPATCHED", "RESOLVED"
  final String resolvedBy;

  const HostelEmergencySosLog({
    required this.id,
    required this.studentName,
    required this.rollNumber,
    required this.roomNumber,
    required this.block,
    required this.triggerTime,
    this.status = "TRIGGERED",
    this.resolvedBy = "Campus Quick Response Team (QRT)",
  });

  HostelEmergencySosLog copyWith({
    String? id,
    String? studentName,
    String? rollNumber,
    String? roomNumber,
    String? block,
    String? triggerTime,
    String? status,
    String? resolvedBy,
  }) {
    return HostelEmergencySosLog(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      rollNumber: rollNumber ?? this.rollNumber,
      roomNumber: roomNumber ?? this.roomNumber,
      block: block ?? this.block,
      triggerTime: triggerTime ?? this.triggerTime,
      status: status ?? this.status,
      resolvedBy: resolvedBy ?? this.resolvedBy,
    );
  }
}

class HostelEnergyMeter {
  final String roomNumber;
  final double currentKwhToday;
  final double monthlyKwh;
  final double liveLoadWatts;
  final bool isOverloadAlert; // true if load > 1500W

  const HostelEnergyMeter({
    required this.roomNumber,
    required this.currentKwhToday,
    required this.monthlyKwh,
    required this.liveLoadWatts,
    this.isOverloadAlert = false,
  });

  HostelEnergyMeter copyWith({
    String? roomNumber,
    double? currentKwhToday,
    double? monthlyKwh,
    double? liveLoadWatts,
    bool? isOverloadAlert,
  }) {
    return HostelEnergyMeter(
      roomNumber: roomNumber ?? this.roomNumber,
      currentKwhToday: currentKwhToday ?? this.currentKwhToday,
      monthlyKwh: monthlyKwh ?? this.monthlyKwh,
      liveLoadWatts: liveLoadWatts ?? this.liveLoadWatts,
      isOverloadAlert: isOverloadAlert ?? this.isOverloadAlert,
    );
  }
}

// -------------------------------------------------------------
// 6.1 Ultra-Smart Innovations: AI Stable-Marriage Roommate Matchmaking
// -------------------------------------------------------------
class RoommateQuizProfile {
  final String rollNumber;
  final String studentName;
  final String branch;
  final String sleepCycle; // "Early Bird (05:00 AM)" vs "Night Owl (02:00 AM)"
  final String studyEnvironment; // "Pin-Drop Silence" vs "Background Lo-Fi Music"
  final String acPreference; // "Chiller (18°C)" vs "Moderate (24°C)"
  final String cleanliness; // "Minimalist Clean" vs "Relaxed"
  final List<String> interests;
  final int compatibilityScore; // 0 - 100
  final String? matchedRoommateRoll;
  final String? matchedRoommateName;
  final String? assignedRoom;
  final bool isQuizCompleted;

  const RoommateQuizProfile({
    required this.rollNumber,
    required this.studentName,
    required this.branch,
    required this.sleepCycle,
    required this.studyEnvironment,
    required this.acPreference,
    required this.cleanliness,
    required this.interests,
    this.compatibilityScore = 96,
    this.matchedRoommateRoll,
    this.matchedRoommateName,
    this.assignedRoom,
    this.isQuizCompleted = true,
  });

  RoommateQuizProfile copyWith({
    String? rollNumber,
    String? studentName,
    String? branch,
    String? sleepCycle,
    String? studyEnvironment,
    String? acPreference,
    String? cleanliness,
    List<String>? interests,
    int? compatibilityScore,
    String? matchedRoommateRoll,
    String? matchedRoommateName,
    String? assignedRoom,
    bool? isQuizCompleted,
  }) {
    return RoommateQuizProfile(
      rollNumber: rollNumber ?? this.rollNumber,
      studentName: studentName ?? this.studentName,
      branch: branch ?? this.branch,
      sleepCycle: sleepCycle ?? this.sleepCycle,
      studyEnvironment: studyEnvironment ?? this.studyEnvironment,
      acPreference: acPreference ?? this.acPreference,
      cleanliness: cleanliness ?? this.cleanliness,
      interests: interests ?? this.interests,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      matchedRoommateRoll: matchedRoommateRoll ?? this.matchedRoommateRoll,
      matchedRoommateName: matchedRoommateName ?? this.matchedRoommateName,
      assignedRoom: assignedRoom ?? this.assignedRoom,
      isQuizCompleted: isQuizCompleted ?? this.isQuizCompleted,
    );
  }
}

class RoommateMatchmakerSetting {
  final bool isSelfDiscoveryEnabled; // If true, students can discover & pick roommates directly
  final bool isAutoAllocationActive; // If true, Gale-Shapley auto-runs
  final int totalQuizSubmissions;
  final int matchedPairsCount;
  final double averageMatchScore;

  const RoommateMatchmakerSetting({
    this.isSelfDiscoveryEnabled = true,
    this.isAutoAllocationActive = true,
    this.totalQuizSubmissions = 240,
    this.matchedPairsCount = 112,
    this.averageMatchScore = 93.4,
  });

  RoommateMatchmakerSetting copyWith({
    bool? isSelfDiscoveryEnabled,
    bool? isAutoAllocationActive,
    int? totalQuizSubmissions,
    int? matchedPairsCount,
    double? averageMatchScore,
  }) {
    return RoommateMatchmakerSetting(
      isSelfDiscoveryEnabled: isSelfDiscoveryEnabled ?? this.isSelfDiscoveryEnabled,
      isAutoAllocationActive: isAutoAllocationActive ?? this.isAutoAllocationActive,
      totalQuizSubmissions: totalQuizSubmissions ?? this.totalQuizSubmissions,
      matchedPairsCount: matchedPairsCount ?? this.matchedPairsCount,
      averageMatchScore: averageMatchScore ?? this.averageMatchScore,
    );
  }
}

// -------------------------------------------------------------
// 6.2 Ultra-Smart Innovations: AI Predictive Mess Headcount & Food Waste Minimizer
// -------------------------------------------------------------
class DiningIntentRecord {
  final String id;
  final String studentRoll;
  final String studentName;
  final String date;
  final String mealType; // "Breakfast", "Lunch", "Dinner"
  final String intent; // "ATTENDING", "SKIPPING", "OUT_PASS_AUTO_SKIPPED"
  final String updatedAt;

  const DiningIntentRecord({
    required this.id,
    required this.studentRoll,
    required this.studentName,
    required this.date,
    required this.mealType,
    required this.intent,
    required this.updatedAt,
  });

  DiningIntentRecord copyWith({
    String? id,
    String? studentRoll,
    String? studentName,
    String? date,
    String? mealType,
    String? intent,
    String? updatedAt,
  }) {
    return DiningIntentRecord(
      id: id ?? this.id,
      studentRoll: studentRoll ?? this.studentRoll,
      studentName: studentName ?? this.studentName,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      intent: intent ?? this.intent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MessHeadcountForecast {
  final String date;
  final String mealType;
  final int totalHostellers;
  final int expectedDiningCount;
  final int gatePassOutCount;
  final int voluntarySkippingCount;
  final double recommendedRiceKg;
  final double baselineRiceKg;
  final double foodSavedKg;
  final double dailyRupeesSaved;
  final double annualProjectedSavings;
  final String chefAlertMessage;

  const MessHeadcountForecast({
    required this.date,
    required this.mealType,
    this.totalHostellers = 450,
    this.expectedDiningCount = 284,
    this.gatePassOutCount = 68,
    this.voluntarySkippingCount = 48,
    this.recommendedRiceKg = 35.0,
    this.baselineRiceKg = 50.0,
    this.foodSavedKg = 15.0,
    this.dailyRupeesSaved = 3720.0,
    this.annualProjectedSavings = 680000.0,
    required this.chefAlertMessage,
  });
}

// -------------------------------------------------------------
// 6.3 Ultra-Smart Innovations: Anti-Ragging Silent Duress Secret PIN
// -------------------------------------------------------------
class SilentDuressAlarm {
  final String id;
  final String studentRoll;
  final String studentName;
  final String roomNumber;
  final String blockName;
  final String secretDuressPin;
  final bool isDuressTriggered;
  final String gpsCoordinates;
  final String triggeredAt;
  final String dispatchStatus;

  const SilentDuressAlarm({
    required this.id,
    required this.studentRoll,
    required this.studentName,
    required this.roomNumber,
    required this.blockName,
    this.secretDuressPin = "9999",
    this.isDuressTriggered = false,
    this.gpsCoordinates = "Lat: 23.2599, Long: 77.4126 (Ramanujan Bhawan B-304)",
    required this.triggeredAt,
    this.dispatchStatus = "READY",
  });

  SilentDuressAlarm copyWith({
    String? id,
    String? studentRoll,
    String? studentName,
    String? roomNumber,
    String? blockName,
    String? secretDuressPin,
    bool? isDuressTriggered,
    String? gpsCoordinates,
    String? triggeredAt,
    String? dispatchStatus,
  }) {
    return SilentDuressAlarm(
      id: id ?? this.id,
      studentRoll: studentRoll ?? this.studentRoll,
      studentName: studentName ?? this.studentName,
      roomNumber: roomNumber ?? this.roomNumber,
      blockName: blockName ?? this.blockName,
      secretDuressPin: secretDuressPin ?? this.secretDuressPin,
      isDuressTriggered: isDuressTriggered ?? this.isDuressTriggered,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      dispatchStatus: dispatchStatus ?? this.dispatchStatus,
    );
  }
}

// -------------------------------------------------------------
// 6.4 Ultra-Smart Innovations: AI Computer Vision Room Damage & Caution Deposit Audit
// -------------------------------------------------------------
class RoomAssetInspection {
  final String id;
  final String roomNumber;
  final String assetName;
  final String checkInDate;
  final String checkInCondition;
  final String checkInSha256Hash;
  final String? checkOutDate;
  final String? checkOutCondition;
  final String? checkOutSha256Hash;
  final double damageScore; // 0.0 to 1.0 (AI differential)
  final double cautionDeduction; // ₹0.00
  final String auditStatus; // "VERIFIED_SAFE", "DISPUTED", "REFUND_APPROVED"

  const RoomAssetInspection({
    required this.id,
    required this.roomNumber,
    required this.assetName,
    required this.checkInDate,
    required this.checkInCondition,
    required this.checkInSha256Hash,
    this.checkOutDate,
    this.checkOutCondition,
    this.checkOutSha256Hash,
    this.damageScore = 0.0,
    this.cautionDeduction = 0.0,
    this.auditStatus = "VERIFIED_SAFE",
  });

  RoomAssetInspection copyWith({
    String? id,
    String? roomNumber,
    String? assetName,
    String? checkInDate,
    String? checkInCondition,
    String? checkInSha256Hash,
    String? checkOutDate,
    String? checkOutCondition,
    String? checkOutSha256Hash,
    double? damageScore,
    double? cautionDeduction,
    String? auditStatus,
  }) {
    return RoomAssetInspection(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      assetName: assetName ?? this.assetName,
      checkInDate: checkInDate ?? this.checkInDate,
      checkInCondition: checkInCondition ?? this.checkInCondition,
      checkInSha256Hash: checkInSha256Hash ?? this.checkInSha256Hash,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      checkOutCondition: checkOutCondition ?? this.checkOutCondition,
      checkOutSha256Hash: checkOutSha256Hash ?? this.checkOutSha256Hash,
      damageScore: damageScore ?? this.damageScore,
      cautionDeduction: cautionDeduction ?? this.cautionDeduction,
      auditStatus: auditStatus ?? this.auditStatus,
    );
  }
}

// -------------------------------------------------------------
// 6.5 Ultra-Smart Innovations: Green Dorm IoT Energy Quota & Eco-Credits Leaderboard
// -------------------------------------------------------------
class GreenDormEnergyCredit {
  final String roomNumber;
  final double monthlyQuotaUnits; // 120.0 Units
  final double consumedUnits;
  final double remainingUnits;
  final double liveLoadWatts;
  final int ecoCredits;
  final double co2SavedKg;
  final String wingRank; // "Floor 2 (#1 Eco-Champion Wing)"
  final String perkReward; // "Free Sunday Dessert & 500Mbps High-Speed Wi-Fi"

  const GreenDormEnergyCredit({
    required this.roomNumber,
    this.monthlyQuotaUnits = 120.0,
    this.consumedUnits = 82.4,
    this.remainingUnits = 37.6,
    this.liveLoadWatts = 340.0,
    this.ecoCredits = 450,
    this.co2SavedKg = 28.5,
    this.wingRank = "Floor 2 (#1 Eco-Champion Wing)",
    this.perkReward = "Free Sunday Dessert & 500Mbps Wi-Fi Priority",
  });

  GreenDormEnergyCredit copyWith({
    String? roomNumber,
    double? monthlyQuotaUnits,
    double? consumedUnits,
    double? remainingUnits,
    double? liveLoadWatts,
    int? ecoCredits,
    double? co2SavedKg,
    String? wingRank,
    String? perkReward,
  }) {
    return GreenDormEnergyCredit(
      roomNumber: roomNumber ?? this.roomNumber,
      monthlyQuotaUnits: monthlyQuotaUnits ?? this.monthlyQuotaUnits,
      consumedUnits: consumedUnits ?? this.consumedUnits,
      remainingUnits: remainingUnits ?? this.remainingUnits,
      liveLoadWatts: liveLoadWatts ?? this.liveLoadWatts,
      ecoCredits: ecoCredits ?? this.ecoCredits,
      co2SavedKg: co2SavedKg ?? this.co2SavedKg,
      wingRank: wingRank ?? this.wingRank,
      perkReward: perkReward ?? this.perkReward,
    );
  }
}

// -------------------------------------------------------------
// 6.6 Ultra-Smart Innovations: Curfew Auto-Extension with Parent WhatsApp 1-Click Consent
// -------------------------------------------------------------
class CurfewExtensionRequest {
  final String id;
  final String gatePassId;
  final String studentRoll;
  final String studentName;
  final String roomNumber;
  final String originalCurfewTime;
  final int requestedExtensionMinutes;
  final String extendedCurfewTime;
  final String reason;
  final String parentConsentStatus; // "PENDING", "APPROVED", "REJECTED"
  final String? parentConsentTimestamp;
  final String wardenApprovalStatus; // "AUTO_APPROVED", "PENDING_WARDEN"
  final bool isFineWaived;

  const CurfewExtensionRequest({
    required this.id,
    required this.gatePassId,
    required this.studentRoll,
    required this.studentName,
    required this.roomNumber,
    this.originalCurfewTime = "08:30 PM",
    this.requestedExtensionMinutes = 45,
    this.extendedCurfewTime = "09:15 PM",
    required this.reason,
    this.parentConsentStatus = "PENDING",
    this.parentConsentTimestamp,
    this.wardenApprovalStatus = "AUTO_APPROVED",
    this.isFineWaived = true,
  });

  CurfewExtensionRequest copyWith({
    String? id,
    String? gatePassId,
    String? studentRoll,
    String? studentName,
    String? roomNumber,
    String? originalCurfewTime,
    int? requestedExtensionMinutes,
    String? extendedCurfewTime,
    String? reason,
    String? parentConsentStatus,
    String? parentConsentTimestamp,
    String? wardenApprovalStatus,
    bool? isFineWaived,
  }) {
    return CurfewExtensionRequest(
      id: id ?? this.id,
      gatePassId: gatePassId ?? this.gatePassId,
      studentRoll: studentRoll ?? this.studentRoll,
      studentName: studentName ?? this.studentName,
      roomNumber: roomNumber ?? this.roomNumber,
      originalCurfewTime: originalCurfewTime ?? this.originalCurfewTime,
      requestedExtensionMinutes: requestedExtensionMinutes ?? this.requestedExtensionMinutes,
      extendedCurfewTime: extendedCurfewTime ?? this.extendedCurfewTime,
      reason: reason ?? this.reason,
      parentConsentStatus: parentConsentStatus ?? this.parentConsentStatus,
      parentConsentTimestamp: parentConsentTimestamp ?? this.parentConsentTimestamp,
      wardenApprovalStatus: wardenApprovalStatus ?? this.wardenApprovalStatus,
      isFineWaived: isFineWaived ?? this.isFineWaived,
    );
  }
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

  String get busNumber => busPlateNumber;
  String get currentStatus => currentStop;
  double get currentSpeed => speedKmph;
  String get nextStoppage => nextStop;
  String get estimatedArrivalNext => "$etaMinutes mins";
}

// -------------------------------------------------------------
// 8. Multi-Universe Helpdesk & Statutory Grievance Models (UGC 48h SLA)
// -------------------------------------------------------------
class GrievanceResponse {
  final String id;
  final String authorRole; // "student", "parent", "faculty", "admin"
  final String authorName;
  final String message;
  final String timestamp;
  final bool isOfficialResolution;

  const GrievanceResponse({
    required this.id,
    required this.authorRole,
    required this.authorName,
    required this.message,
    required this.timestamp,
    this.isOfficialResolution = false,
  });
}

class GrievanceTicket {
  final String id;
  final String category; // "Academic & Marks", "Hostel & Mess", "Fee & Finance", "Anti-Ragging", "Transport", "Lab Infrastructure", "Faculty & Workload"
  final String subject;
  final String description;
  final String createdAt;
  final String status; // "In Progress", "Under Review", "Escalated", "Resolved"
  final String priority; // "Low", "Medium", "High", "Critical"
  final int remainingSlaHours;
  final String assignedOfficer;
  final String raisedByRole; // "student", "parent", "faculty", "admin"
  final String raisedByName;
  final String targetRole; // "faculty", "admin"
  final String targetName;
  final String? studentRoll;
  final List<GrievanceResponse> responses;
  final bool isEscalated;
  final String? resolutionSummary;

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
    this.raisedByRole = "student",
    this.raisedByName = "Student (CS22B045)",
    this.targetRole = "admin",
    this.targetName = "Academic Administration",
    this.studentRoll = "CS22B045",
    this.responses = const [],
    this.isEscalated = false,
    this.resolutionSummary,
  });

  GrievanceTicket copyWith({
    String? id,
    String? category,
    String? subject,
    String? description,
    String? createdAt,
    String? status,
    String? priority,
    int? remainingSlaHours,
    String? assignedOfficer,
    String? raisedByRole,
    String? raisedByName,
    String? targetRole,
    String? targetName,
    String? studentRoll,
    List<GrievanceResponse>? responses,
    bool? isEscalated,
    String? resolutionSummary,
  }) {
    return GrievanceTicket(
      id: id ?? this.id,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      remainingSlaHours: remainingSlaHours ?? this.remainingSlaHours,
      assignedOfficer: assignedOfficer ?? this.assignedOfficer,
      raisedByRole: raisedByRole ?? this.raisedByRole,
      raisedByName: raisedByName ?? this.raisedByName,
      targetRole: targetRole ?? this.targetRole,
      targetName: targetName ?? this.targetName,
      studentRoll: studentRoll ?? this.studentRoll,
      responses: responses ?? this.responses,
      isEscalated: isEscalated ?? this.isEscalated,
      resolutionSummary: resolutionSummary ?? this.resolutionSummary,
    );
  }
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

  String get overallRiskLevel => riskTier;
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

  double get predictedFinalCgpa => predictedSgpa;
  double get confidenceScore => 0.92;
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
  final double cgpa;
  final String parentPhone;
  final Map<String, double> subjectAttendance;
  final String registrationStatus; // "Approved", "Pending", "Rejected", "Not Registered"

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
    this.cgpa = 8.20,
    this.parentPhone = "+91 94250 88991",
    this.subjectAttendance = const {
      "CS601 Compiler Design": 84.5,
      "CS602 Computer Networks": 81.0,
      "CS603 Cloud Architecture": 78.5,
      "CS604 Networks Lab": 90.0,
      "CS605 Compiler Lab": 88.0,
    },
    this.registrationStatus = "Approved",
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
      cgpa: (json['cgpa'] is num) ? (json['cgpa'] as num).toDouble() : 8.20,
      parentPhone: json['parent_phone']?.toString() ?? "+91 94250 88991",
      registrationStatus: json['registration_status']?.toString() ?? "Approved",
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
      'cgpa': cgpa,
      'parent_phone': parentPhone,
      'registration_status': registrationStatus,
    };
  }

  StudentAttendanceRecord copyWith({
    bool? isPresentToday,
    double? attendancePercentage,
    int? attendedClasses,
    int? totalClasses,
    double? cgpa,
    String? parentPhone,
    Map<String, double>? subjectAttendance,
    String? registrationStatus,
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
      cgpa: cgpa ?? this.cgpa,
      parentPhone: parentPhone ?? this.parentPhone,
      subjectAttendance: subjectAttendance ?? this.subjectAttendance,
      registrationStatus: registrationStatus ?? this.registrationStatus,
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
  final String phone;
  final String email;
  final String bio;
  final String scholarUrl;
  final String researchGateUrl;
  final int papersPublished;
  final int citationsCount;
  final int hIndex;
  final int i10Index;
  final int patentsGranted;
  final int experienceYears;
  final List<String> subjectsTaught;
  final List<String> researchDomains;
  final List<String> professionalSkills;
  final List<String> awards;
  final List<String> patentsList;
  final List<String> publicationsList;
  final List<String> grantsList;
  final double studentFeedbackRating; // out of 5.0

  const FacultyProfessionalProfile({
    this.id = "FAC-2018-CSE-007",
    this.name = "Dr. Mohit Donawat",
    this.designation = "Associate Professor & Head of Department (H.O.D.)",
    this.department = "Computer Science & Engineering",
    this.qualifications = "Ph.D. (AI & Neural Architectures), M.Tech (CSE - IIT Roorkee)",
    this.cabinNumber = "Cabin 302, Academic Block A",
    this.officeHours = "Mon - Fri, 03:00 PM - 05:00 PM",
    this.phone = "+91 98290 12345",
    this.email = "m.donawat@digitalcampus.edu.in",
    this.bio = "Academician & Systems Researcher focusing on Sovereign AI, Distributed Cloud Architectures, and Compiler Optimizations. Committed to high-throughput systems research and academic excellence.",
    this.scholarUrl = "scholar.google.com/citations?user=mohit_donawat",
    this.researchGateUrl = "researchgate.net/profile/Mohit-Donawat",
    this.papersPublished = 18,
    this.citationsCount = 420,
    this.hIndex = 14,
    this.i10Index = 18,
    this.patentsGranted = 2,
    this.experienceYears = 12,
    this.subjectsTaught = const [
      "Machine Learning & Artificial Intelligence",
      "Advanced Compiler Design",
      "Distributed Cloud Architecture",
    ],
    this.researchDomains = const [
      "Edge AI & Embedded Inference",
      "Federated Optimization",
      "Natural Language Processing for Indic Languages",
      "Zero-Trust Academic Security",
    ],
    this.professionalSkills = const [
      "Deep Learning",
      "Distributed Systems",
      "Compiler Optimization",
      "PyTorch",
      "High-Performance Computing",
      "Linux Kernel",
      "Edge AI",
      "System Verilog",
      "Rust & WebAssembly",
      "Zero-Knowledge Proofs",
    ],
    this.awards = const [
      "Best Researcher Award 2024 - AICTE National Board",
      "Outstanding Faculty Excellence Award - University Academic Senate",
      "Top Cited Author 2023 - IEEE Transactions on Computers",
    ],
    this.patentsList = const [
      "Indian Patent #428901: Low-Latency Real-Time Edge AI Speech Translation System (Granted 2024)",
      "Indian Patent #481902: Cryptographic Privacy-Preserving Student Biometric Attendance Protocol (Granted 2023)",
    ],
    this.publicationsList = const [
      "M. Donawat et al., 'Sub-Millisecond On-Device Transformer Inference for Edge Devices', IEEE Trans. Computers, Vol. 73, Issue 4, pp. 812-824, 2024. [Citations: 142]",
      "M. Donawat & A. Sharma, 'Federated Optimization in Low-Bandwidth Campus Networks', ACM Trans. Embedded Systems, Vol. 22, Issue 2, 2023. [Citations: 98]",
      "M. Donawat, 'Deterministic Nonce Protocol for Academic Biometric Spoof Mitigation', Springer LNCS, Vol. 13890, pp. 201-215, 2023. [Citations: 86]",
      "M. Donawat et al., 'Zero-Trust Role-Based Access Framework for Higher Education ERPs', Elsevier Computers & Security, 2022. [Citations: 94]",
    ],
    this.grantsList = const [
      "DST-SERB Core Research Grant (CRG/2023/004812): Edge AI Accelerator for Precision Campus Operations • Outlay: ₹38.5 Lakhs (PI)",
      "AICTE Research Promotion Scheme (RPS-2022-819): Zero-Trust Sovereign Campus Cryptographic Engine • Outlay: ₹14.0 Lakhs (PI)",
    ],
    this.studentFeedbackRating = 4.88,
  });

  String get cabin => cabinNumber;

  FacultyProfessionalProfile copyWith({
    String? id,
    String? name,
    String? designation,
    String? department,
    String? qualifications,
    String? cabinNumber,
    String? officeHours,
    String? phone,
    String? email,
    String? bio,
    String? scholarUrl,
    String? researchGateUrl,
    int? papersPublished,
    int? citationsCount,
    int? hIndex,
    int? i10Index,
    int? patentsGranted,
    int? experienceYears,
    List<String>? subjectsTaught,
    List<String>? researchDomains,
    List<String>? professionalSkills,
    List<String>? awards,
    List<String>? patentsList,
    List<String>? publicationsList,
    List<String>? grantsList,
    double? studentFeedbackRating,
  }) {
    return FacultyProfessionalProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      qualifications: qualifications ?? this.qualifications,
      cabinNumber: cabinNumber ?? this.cabinNumber,
      officeHours: officeHours ?? this.officeHours,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      scholarUrl: scholarUrl ?? this.scholarUrl,
      researchGateUrl: researchGateUrl ?? this.researchGateUrl,
      papersPublished: papersPublished ?? this.papersPublished,
      citationsCount: citationsCount ?? this.citationsCount,
      hIndex: hIndex ?? this.hIndex,
      i10Index: i10Index ?? this.i10Index,
      patentsGranted: patentsGranted ?? this.patentsGranted,
      experienceYears: experienceYears ?? this.experienceYears,
      subjectsTaught: subjectsTaught ?? this.subjectsTaught,
      researchDomains: researchDomains ?? this.researchDomains,
      professionalSkills: professionalSkills ?? this.professionalSkills,
      awards: awards ?? this.awards,
      patentsList: patentsList ?? this.patentsList,
      publicationsList: publicationsList ?? this.publicationsList,
      grantsList: grantsList ?? this.grantsList,
      studentFeedbackRating: studentFeedbackRating ?? this.studentFeedbackRating,
    );
  }
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
    this.id = "ADM-DIR-001",
    this.name = "Mr. Shridhar Donawat",
    this.designation = "Dean & Director",
    this.office = "Directorate & Office of University Governance",
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

  String get name => guardianName;
  String get relationship => relation;
  String get wardRollNumber => wardRoll;
  int get wardSemester => 6;
  String get studentName => wardName;
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

// -------------------------------------------------------------
// 18. Semester Course & Academic Registration
// -------------------------------------------------------------
enum RegistrationStatus {
  pending,
  approved,
  rejected,
}

extension RegistrationStatusExtension on RegistrationStatus {
  String get label {
    switch (this) {
      case RegistrationStatus.pending:
        return "Pending Approval";
      case RegistrationStatus.approved:
        return "Approved";
      case RegistrationStatus.rejected:
        return "Rejected";
    }
  }

  Color get color {
    switch (this) {
      case RegistrationStatus.pending:
        return const Color(0xFFD97706); // Amber
      case RegistrationStatus.approved:
        return const Color(0xFF16A34A); // Green
      case RegistrationStatus.rejected:
        return const Color(0xFFDC2626); // Red
    }
  }

  IconData get icon {
    switch (this) {
      case RegistrationStatus.pending:
        return Icons.pending_actions_rounded;
      case RegistrationStatus.approved:
        return Icons.check_circle_rounded;
      case RegistrationStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}

class SemesterRegistrationCourse {
  final String courseCode;
  final String courseName;
  final double credits;
  final String category; // "Core Theory", "Professional Elective", "Open Elective", "Practical / Lab"

  const SemesterRegistrationCourse({
    required this.courseCode,
    required this.courseName,
    required this.credits,
    required this.category,
  });
}

class SemesterRegistration {
  final String id;
  final String studentId;
  final String studentName;
  final String rollNumber;
  final String enrollmentNumber;
  final String branch;
  final int semester;
  final String academicYear;
  final String section;
  final String studentPhone;
  final String parentPhone;
  final double previousSgpa;
  final double currentCgpa;
  final int activeBacklogs;
  final List<SemesterRegistrationCourse> coreCourses;
  final SemesterRegistrationCourse selectedElective;
  final SemesterRegistrationCourse selectedOpenElective;
  final List<SemesterRegistrationCourse> labCourses;
  final double totalCredits;
  final String feeReceiptNo;
  final bool feeCleared;
  final String hostelOrDayScholar;
  final bool antiRaggingAccepted;
  final RegistrationStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedByFaculty;
  final String? rejectionReason;
  final String? facultyRemarks;

  const SemesterRegistration({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.enrollmentNumber,
    required this.branch,
    required this.semester,
    required this.academicYear,
    required this.section,
    required this.studentPhone,
    required this.parentPhone,
    required this.previousSgpa,
    required this.currentCgpa,
    required this.activeBacklogs,
    required this.coreCourses,
    required this.selectedElective,
    required this.selectedOpenElective,
    required this.labCourses,
    required this.totalCredits,
    required this.feeReceiptNo,
    required this.feeCleared,
    required this.hostelOrDayScholar,
    required this.antiRaggingAccepted,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedByFaculty,
    this.rejectionReason,
    this.facultyRemarks,
  });

  SemesterRegistration copyWith({
    RegistrationStatus? status,
    DateTime? reviewedAt,
    String? reviewedByFaculty,
    String? rejectionReason,
    String? facultyRemarks,
    SemesterRegistrationCourse? selectedElective,
    SemesterRegistrationCourse? selectedOpenElective,
    String? feeReceiptNo,
    bool? feeCleared,
    String? studentPhone,
    String? parentPhone,
    double? totalCredits,
  }) {
    return SemesterRegistration(
      id: id,
      studentId: studentId,
      studentName: studentName,
      rollNumber: rollNumber,
      enrollmentNumber: enrollmentNumber,
      branch: branch,
      semester: semester,
      academicYear: academicYear,
      section: section,
      studentPhone: studentPhone ?? this.studentPhone,
      parentPhone: parentPhone ?? this.parentPhone,
      previousSgpa: previousSgpa,
      currentCgpa: currentCgpa,
      activeBacklogs: activeBacklogs,
      coreCourses: coreCourses,
      selectedElective: selectedElective ?? this.selectedElective,
      selectedOpenElective: selectedOpenElective ?? this.selectedOpenElective,
      labCourses: labCourses,
      totalCredits: totalCredits ?? this.totalCredits,
      feeReceiptNo: feeReceiptNo ?? this.feeReceiptNo,
      feeCleared: feeCleared ?? this.feeCleared,
      hostelOrDayScholar: hostelOrDayScholar,
      antiRaggingAccepted: antiRaggingAccepted,
      status: status ?? this.status,
      submittedAt: submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedByFaculty: reviewedByFaculty ?? this.reviewedByFaculty,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      facultyRemarks: facultyRemarks ?? this.facultyRemarks,
    );
  }
}

// -------------------------------------------------------------
// 19. Campus Live Notifications & Alerts
// -------------------------------------------------------------
class CampusNotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type; // "registration", "attendance", "fee", "academic", "security"
  final bool isRead;
  final String? actionRoute;

  const CampusNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.actionRoute,
  });

  CampusNotificationItem copyWith({
    bool? isRead,
  }) {
    return CampusNotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      type: type,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute,
    );
  }
}


