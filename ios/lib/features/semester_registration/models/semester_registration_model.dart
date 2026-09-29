import 'package:cloud_firestore/cloud_firestore.dart';

class SemesterRegistrationModel {
  final String id;
  final String refNo;
  final String studentUid;
  final String studentName;
  final String enrollmentNo;
  final String rollNo;
  final String branch;
  final String currentYear;
  final String currentSemester;
  final String applyingSemester;
  final String academicSession;
  final String section;
  final String fatherName;
  final String phone;
  final String email;
  final String address;
  final String college;
  final String university;
  final String previousSemSgpa;
  final String overallCgpa;
  final bool hasBacklogs;
  final String backlogDetails;
  final String achievements;
  final String electiveSubjects;
  final String feeReceiptNo;
  final String feePaymentStatus;
  final bool studentUndertakingAccepted;
  final String status; // 'PENDING_APPROVAL', 'APPROVED', 'REJECTED'
  final String? hodRemarks;
  final DateTime submittedAt;
  final DateTime? approvedAt;

  SemesterRegistrationModel({
    required this.id,
    required this.refNo,
    required this.studentUid,
    required this.studentName,
    required this.enrollmentNo,
    required this.rollNo,
    required this.branch,
    required this.currentYear,
    required this.currentSemester,
    required this.applyingSemester,
    this.academicSession = '2024 - 2025',
    this.section = 'A',
    this.fatherName = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.college = 'IES College of Technology',
    this.university = 'RGPV Bhopal',
    required this.previousSemSgpa,
    required this.overallCgpa,
    this.hasBacklogs = false,
    this.backlogDetails = 'NIL (All Clear)',
    this.achievements = '',
    this.electiveSubjects = '',
    this.feeReceiptNo = '',
    this.feePaymentStatus = 'PAID',
    this.studentUndertakingAccepted = true,
    this.status = 'PENDING_APPROVAL',
    this.hodRemarks,
    required this.submittedAt,
    this.approvedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'refNo': refNo,
      'studentUid': studentUid,
      'studentName': studentName,
      'enrollmentNo': enrollmentNo,
      'rollNo': rollNo,
      'branch': branch,
      'currentYear': currentYear,
      'currentSemester': currentSemester,
      'applyingSemester': applyingSemester,
      'academicSession': academicSession,
      'section': section,
      'fatherName': fatherName,
      'phone': phone,
      'email': email,
      'address': address,
      'college': college,
      'university': university,
      'previousSemSgpa': previousSemSgpa,
      'overallCgpa': overallCgpa,
      'hasBacklogs': hasBacklogs,
      'backlogDetails': backlogDetails,
      'achievements': achievements,
      'electiveSubjects': electiveSubjects,
      'feeReceiptNo': feeReceiptNo,
      'feePaymentStatus': feePaymentStatus,
      'studentUndertakingAccepted': studentUndertakingAccepted,
      'status': status,
      'hodRemarks': hodRemarks,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }

  factory SemesterRegistrationModel.fromMap(Map<String, dynamic> map, String docId) {
    return SemesterRegistrationModel(
      id: docId,
      refNo: map['refNo'] ?? 'IES/REG/${DateTime.now().year}/$docId',
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? '',
      enrollmentNo: map['enrollmentNo'] ?? '',
      rollNo: map['rollNo'] ?? '',
      branch: map['branch'] ?? '',
      currentYear: map['currentYear'] ?? '',
      currentSemester: map['currentSemester'] ?? '',
      applyingSemester: map['applyingSemester'] ?? '',
      academicSession: map['academicSession'] ?? '2024 - 2025',
      section: map['section'] ?? 'A',
      fatherName: map['fatherName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      college: map['college'] ?? 'IES College of Technology',
      university: map['university'] ?? 'RGPV Bhopal',
      previousSemSgpa: map['previousSemSgpa']?.toString() ?? '0.0',
      overallCgpa: map['overallCgpa']?.toString() ?? '0.0',
      hasBacklogs: map['hasBacklogs'] ?? false,
      backlogDetails: map['backlogDetails'] ?? 'NIL (All Clear)',
      achievements: map['achievements'] ?? '',
      electiveSubjects: map['electiveSubjects'] ?? '',
      feeReceiptNo: map['feeReceiptNo'] ?? '',
      feePaymentStatus: map['feePaymentStatus'] ?? 'PAID',
      studentUndertakingAccepted: map['studentUndertakingAccepted'] ?? true,
      status: map['status'] ?? 'PENDING_APPROVAL',
      hodRemarks: map['hodRemarks'],
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedAt: (map['approvedAt'] as Timestamp?)?.toDate(),
    );
  }
}
