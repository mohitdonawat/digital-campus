import 'package:cloud_firestore/cloud_firestore.dart';

class BonafideModel {
  final String id;
  final String studentUid;
  final String studentName;
  final String enrollmentNo;
  final String rollNo;
  final String branch;
  final String year;
  final String semester;
  final String section;
  final String academicSession;
  final String purpose;
  final String college;
  final String university;
  final String refNo;
  final DateTime issuedAt;
  final String fatherName;
  final String profileImageUrl;

  BonafideModel({
    required this.id,
    required this.studentUid,
    required this.studentName,
    required this.enrollmentNo,
    required this.rollNo,
    required this.branch,
    required this.year,
    required this.semester,
    required this.section,
    required this.academicSession,
    required this.purpose,
    this.college = 'IES College of Technology, Bhopal',
    this.university = 'Rajiv Gandhi Proudyogiki Vishwavidyalaya (RGPV)',
    required this.refNo,
    required this.issuedAt,
    this.fatherName = '',
    this.profileImageUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentUid': studentUid,
      'studentName': studentName,
      'enrollmentNo': enrollmentNo,
      'rollNo': rollNo,
      'branch': branch,
      'year': year,
      'semester': semester,
      'section': section,
      'academicSession': academicSession,
      'purpose': purpose,
      'college': college,
      'university': university,
      'refNo': refNo,
      'issuedAt': Timestamp.fromDate(issuedAt),
      'fatherName': fatherName,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory BonafideModel.fromMap(Map<String, dynamic> map, String docId) {
    return BonafideModel(
      id: docId,
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? '',
      enrollmentNo: map['enrollmentNo'] ?? '',
      rollNo: map['rollNo'] ?? '',
      branch: map['branch'] ?? '',
      year: map['year'] ?? '',
      semester: map['semester'] ?? '',
      section: map['section'] ?? '',
      academicSession: map['academicSession'] ?? '2025-2026',
      purpose: map['purpose'] ?? 'General Academic',
      college: map['college'] ?? 'IES College of Technology, Bhopal',
      university: map['university'] ?? 'RGPV',
      refNo: map['refNo'] ?? 'IES/BONA/2026/001',
      issuedAt: (map['issuedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fatherName: map['fatherName'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }
}

class TeacherBonafideModel {
  final String id;
  final String teacherUid;
  final String teacherName;
  final String employeeId;
  final String designation;
  final String departments;
  final String college;
  final String academicSession;
  final String purpose;
  final String refNo;
  final DateTime issuedAt;
  final String dateOfJoining;
  final String employmentType;
  final String profileImageUrl;
  final String phone;

  TeacherBonafideModel({
    required this.id,
    required this.teacherUid,
    required this.teacherName,
    required this.employeeId,
    required this.designation,
    required this.departments,
    this.college = 'IES College of Technology, Bhopal',
    required this.academicSession,
    required this.purpose,
    required this.refNo,
    required this.issuedAt,
    this.dateOfJoining = '01 August, 2021',
    this.employmentType = 'Regular & Full-Time Faculty',
    this.profileImageUrl = '',
    this.phone = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherUid': teacherUid,
      'teacherName': teacherName,
      'employeeId': employeeId,
      'designation': designation,
      'departments': departments,
      'college': college,
      'academicSession': academicSession,
      'purpose': purpose,
      'refNo': refNo,
      'issuedAt': Timestamp.fromDate(issuedAt),
      'dateOfJoining': dateOfJoining,
      'employmentType': employmentType,
      'profileImageUrl': profileImageUrl,
      'phone': phone,
    };
  }

  factory TeacherBonafideModel.fromMap(Map<String, dynamic> map, String docId) {
    return TeacherBonafideModel(
      id: docId,
      teacherUid: map['teacherUid'] ?? '',
      teacherName: map['teacherName'] ?? '',
      employeeId: map['employeeId'] ?? '',
      designation: map['designation'] ?? 'Assistant Professor',
      departments: map['departments'] ?? 'Computer Science & Engineering',
      college: map['college'] ?? 'IES College of Technology, Bhopal',
      academicSession: map['academicSession'] ?? '2025-2026',
      purpose: map['purpose'] ?? 'Proof of Employment / Service Verification',
      refNo: map['refNo'] ?? 'IES/ESTB/FAC/2026/001',
      issuedAt: (map['issuedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateOfJoining: map['dateOfJoining'] ?? '01 August, 2021',
      employmentType: map['employmentType'] ?? 'Regular & Full-Time Faculty',
      profileImageUrl: map['profileImageUrl'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}
