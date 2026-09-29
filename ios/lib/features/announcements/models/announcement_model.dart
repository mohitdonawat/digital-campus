import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String? linkUrl; // Optional website/drive link
  final String? fileUrl; // Firebase Storage URL for PDF/File
  final String? fileName; // Display name of uploaded file

  // Creator Info
  final String authorUid;
  final String authorName;
  final String authorTitle; // Prof, Dr, Mr
  final String authorRole; // teacher or admin

  // Target audience
  final String targetBranch; // 'ALL' or specific dept
  final String targetYear; // 'ALL' or '1st Year' etc.
  final String targetSemester; // 'ALL' or '1st Sem' etc.
  final String targetSection; // 'ALL' or 'A', 'B' etc.

  final String priority; // 'NORMAL', 'IMPORTANT', 'URGENT'
  final DateTime createdAt;
  final bool isActive;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    this.linkUrl,
    this.fileUrl,
    this.fileName,
    required this.authorUid,
    required this.authorName,
    this.authorTitle = 'Prof',
    this.authorRole = 'teacher',
    this.targetBranch = 'ALL',
    this.targetYear = 'ALL',
    this.targetSemester = 'ALL',
    this.targetSection = 'ALL',
    this.priority = 'NORMAL',
    required this.createdAt,
    this.isActive = true,
  });

  /// Check if this announcement belongs to a student
  bool isRelevantFor({
    required String branch,
    required String year,
    required String semester,
    required String section,
  }) {
    final bMatch = targetBranch == 'ALL' || targetBranch == branch;
    final yMatch = targetYear == 'ALL' || targetYear == year;
    final semMatch = targetSemester == 'ALL' || targetSemester == semester;
    final secMatch = targetSection == 'ALL' || targetSection == section;
    return bMatch && yMatch && semMatch && secMatch;
  }

  String get targetBadge {
    if (targetBranch == 'ALL') return '📢 All College';
    String s = targetBranch;
    if (targetYear != 'ALL') s += ' • $targetYear';
    if (targetSemester != 'ALL') s += ' ($targetSemester)';
    if (targetSection != 'ALL') s += ' • Sec $targetSection';
    return s;
  }

  String get authorDisplay {
    if (authorRole == 'admin') return '🛡️ College Administration';
    return '$authorTitle $authorName'.trim();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'linkUrl': linkUrl,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'authorUid': authorUid,
      'authorName': authorName,
      'authorTitle': authorTitle,
      'authorRole': authorRole,
      'targetBranch': targetBranch,
      'targetYear': targetYear,
      'targetSemester': targetSemester,
      'targetSection': targetSection,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String docId) {
    return AnnouncementModel(
      id: docId,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      linkUrl: map['linkUrl'],
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      authorUid: map['authorUid'] ?? '',
      authorName: map['authorName'] ?? 'Faculty',
      authorTitle: map['authorTitle'] ?? 'Prof',
      authorRole: map['authorRole'] ?? 'teacher',
      targetBranch: map['targetBranch'] ?? 'ALL',
      targetYear: map['targetYear'] ?? 'ALL',
      targetSemester: map['targetSemester'] ?? 'ALL',
      targetSection: map['targetSection'] ?? 'ALL',
      priority: map['priority'] ?? 'NORMAL',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }
}
