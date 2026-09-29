import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  final String id;
  final String title;
  final String subject;
  final String description;
  final String teacherUid;
  final String teacherName;
  final String targetBranch;
  final String targetYear;
  final String targetSemester;
  final String targetSection;
  final DateTime dueDate;
  final DateTime createdAt;
  final int totalMarks;
  final String? attachmentUrl;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.teacherUid,
    required this.teacherName,
    required this.targetBranch,
    required this.targetYear,
    this.targetSemester = 'ALL',
    this.targetSection = 'ALL',
    required this.dueDate,
    required this.createdAt,
    this.totalMarks = 20,
    this.attachmentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'description': description,
      'teacherUid': teacherUid,
      'teacherName': teacherName,
      'targetBranch': targetBranch,
      'targetYear': targetYear,
      'targetSemester': targetSemester,
      'targetSection': targetSection,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'totalMarks': totalMarks,
      'attachmentUrl': attachmentUrl,
    };
  }

  factory AssignmentModel.fromMap(Map<String, dynamic> map, String docId) {
    return AssignmentModel(
      id: docId,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      description: map['description'] ?? '',
      teacherUid: map['teacherUid'] ?? '',
      teacherName: map['teacherName'] ?? 'Faculty',
      targetBranch: map['targetBranch'] ?? 'ALL',
      targetYear: map['targetYear'] ?? 'ALL',
      targetSemester: map['targetSemester'] ?? 'ALL',
      targetSection: map['targetSection'] ?? 'ALL',
      dueDate: (map['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 7)),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalMarks: map['totalMarks'] ?? 20,
      attachmentUrl: map['attachmentUrl'],
    );
  }
}

class AssignmentSubmissionModel {
  final String id;
  final String assignmentId;
  final String studentUid;
  final String studentName;
  final String enrollmentNo;
  final String rollNo;
  final String branch;
  final String section;
  final String submissionText;
  final String? fileUrl; // PDF link or Drive/Docs link
  final DateTime submittedAt;
  final String? grade; // Flexible grade: e.g. 'A+', 'O', '9/10', '18/20', 'Good'
  final dynamic marksAwarded;
  final String? feedback; // Teacher's review & remarks
  final String status; // 'SUBMITTED', 'GRADED', 'REVIEWED'
  final DateTime? reviewedAt;

  AssignmentSubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentUid,
    required this.studentName,
    required this.enrollmentNo,
    this.rollNo = '',
    required this.branch,
    this.section = 'A',
    required this.submissionText,
    this.fileUrl,
    required this.submittedAt,
    this.grade,
    this.marksAwarded,
    this.feedback,
    this.status = 'SUBMITTED',
    this.reviewedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'studentUid': studentUid,
      'studentName': studentName,
      'enrollmentNo': enrollmentNo,
      'rollNo': rollNo,
      'branch': branch,
      'section': section,
      'submissionText': submissionText,
      'fileUrl': fileUrl,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'grade': grade,
      'marksAwarded': marksAwarded,
      'feedback': feedback,
      'status': status,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
    };
  }

  factory AssignmentSubmissionModel.fromMap(Map<String, dynamic> map, String docId) {
    return AssignmentSubmissionModel(
      id: docId,
      assignmentId: map['assignmentId'] ?? '',
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? '',
      enrollmentNo: map['enrollmentNo'] ?? '',
      rollNo: map['rollNo'] ?? '',
      branch: map['branch'] ?? '',
      section: map['section'] ?? 'A',
      submissionText: map['submissionText'] ?? '',
      fileUrl: map['fileUrl'],
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      grade: map['grade']?.toString(),
      marksAwarded: map['marksAwarded'],
      feedback: map['feedback'],
      status: map['status'] ?? 'SUBMITTED',
      reviewedAt: (map['reviewedAt'] as Timestamp?)?.toDate(),
    );
  }
}
