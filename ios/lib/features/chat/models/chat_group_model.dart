import 'package:cloud_firestore/cloud_firestore.dart';

class ChatGroupModel {
  final String id;
  final String title;
  final String description;
  final String createdByUid;
  final String createdByName;
  final String createdByTitle; // Prof / Dr / Mr
  final String createdByRole;  // teacher or admin

  // Target audience
  final String department;
  final String year;
  final String semester;
  final String section; // 'ALL' or specific like 'A'

  final String? lastMessage;
  final String? lastMessageSender;
  final DateTime? lastMessageTime;
  final DateTime createdAt;
  final bool isActive;

  ChatGroupModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.createdByUid,
    required this.createdByName,
    this.createdByTitle = 'Prof',
    this.createdByRole = 'teacher',
    required this.department,
    required this.year,
    required this.semester,
    this.section = 'ALL',
    this.lastMessage,
    this.lastMessageSender,
    this.lastMessageTime,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdByUid': createdByUid,
      'createdByName': createdByName,
      'createdByTitle': createdByTitle,
      'createdByRole': createdByRole,
      'department': department,
      'year': year,
      'semester': semester,
      'section': section,
      'lastMessage': lastMessage,
      'lastMessageSender': lastMessageSender,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    return DateTime.now();
  }

  factory ChatGroupModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChatGroupModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdByUid: map['createdByUid'] ?? '',
      createdByName: map['createdByName'] ?? '',
      createdByTitle: map['createdByTitle'] ?? 'Prof',
      createdByRole: map['createdByRole'] ?? 'teacher',
      department: map['department'] ?? 'ALL',
      year: map['year'] ?? 'ALL',
      semester: map['semester'] ?? 'ALL',
      section: map['section'] ?? 'ALL',
      lastMessage: map['lastMessage'],
      lastMessageSender: map['lastMessageSender'],
      lastMessageTime: map['lastMessageTime'] != null ? _parseDate(map['lastMessageTime']) : null,
      createdAt: _parseDate(map['createdAt']),
      isActive: map['isActive'] ?? true,
    );
  }

  String get targetBadge {
    String t = '$department • $year ($semester)';
    if (section != 'ALL') t += ' - Sec $section';
    return t;
  }
}
