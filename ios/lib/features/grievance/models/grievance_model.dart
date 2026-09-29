import 'package:cloud_firestore/cloud_firestore.dart';

class GrievanceMessage {
  final String senderUid;
  final String senderName;
  final String senderRole; // 'student', 'faculty', 'admin'
  final String message;
  final DateTime timestamp;

  GrievanceMessage({
    required this.senderUid,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory GrievanceMessage.fromMap(Map<String, dynamic> map) {
    return GrievanceMessage(
      senderUid: map['senderUid'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? 'faculty',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class GrievanceModel {
  final String id;
  final String studentUid;
  final String studentName;
  final String enrollmentNo;
  final String branch;
  final String year;
  final String category; // 'Academic', 'Fee & Accounts', 'Bus / Transportation', 'Hostel', 'Exam & Results', 'General'
  final String subject;
  final String description;
  final String status; // 'OPEN', 'FACULTY_REPLIED', 'STUDENT_REPLIED', 'RESOLVED_BY_STUDENT'
  final String? response; // Latest official response
  final String? respondedBy;
  final bool isSatisfied; // Only true when student marks satisfied
  final List<GrievanceMessage> thread;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;

  GrievanceModel({
    required this.id,
    required this.studentUid,
    required this.studentName,
    required this.enrollmentNo,
    required this.branch,
    required this.year,
    required this.category,
    required this.subject,
    required this.description,
    this.status = 'OPEN',
    this.response,
    this.respondedBy,
    this.isSatisfied = false,
    this.thread = const [],
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
  });

  bool get isResolved => status == 'RESOLVED_BY_STUDENT' || status == 'RESOLVED';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentUid': studentUid,
      'studentName': studentName,
      'enrollmentNo': enrollmentNo,
      'branch': branch,
      'year': year,
      'category': category,
      'subject': subject,
      'description': description,
      'status': status,
      'response': response,
      'respondedBy': respondedBy,
      'isSatisfied': isSatisfied,
      'thread': thread.map((m) => m.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  factory GrievanceModel.fromMap(Map<String, dynamic> map, String docId) {
    return GrievanceModel(
      id: docId,
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? '',
      enrollmentNo: map['enrollmentNo'] ?? '',
      branch: map['branch'] ?? '',
      year: map['year'] ?? '',
      category: map['category'] ?? 'General',
      subject: map['subject'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'OPEN',
      response: map['response'],
      respondedBy: map['respondedBy'],
      isSatisfied: map['isSatisfied'] ?? (map['status'] == 'RESOLVED'),
      thread: (map['thread'] as List<dynamic>?)
              ?.map((m) => GrievanceMessage.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }
}
