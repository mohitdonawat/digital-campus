import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'teacher', 'student', 'admin'
  final String senderTitle; // 'Prof', 'Mr' etc.
  final String text;

  // Reply info
  final String? replyToMessageId;
  final String? replyToSenderName;
  final String? replyToText;

  // Anti-tamper & strict 1-min edit window
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    this.senderTitle = '',
    required this.text,
    this.replyToMessageId,
    this.replyToSenderName,
    this.replyToText,
    this.isEdited = false,
    this.editedAt,
    required this.createdAt,
  });

  /// Check if this message is still eligible for editing (within 60 seconds of creation)
  bool canEdit(String currentUserId) {
    if (senderId != currentUserId) return false;
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inSeconds <= 60;
  }

  int secondsLeftToEdit() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    final left = 60 - difference.inSeconds;
    return left > 0 ? left : 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'senderTitle': senderTitle,
      'text': text,
      'replyToMessageId': replyToMessageId,
      'replyToSenderName': replyToSenderName,
      'replyToText': replyToText,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    return DateTime.now();
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessageModel(
      id: docId,
      groupId: map['groupId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Anonymous',
      senderRole: map['senderRole'] ?? 'student',
      senderTitle: map['senderTitle'] ?? '',
      text: map['text'] ?? '',
      replyToMessageId: map['replyToMessageId'],
      replyToSenderName: map['replyToSenderName'],
      replyToText: map['replyToText'],
      isEdited: map['isEdited'] ?? false,
      editedAt: map['editedAt'] != null ? _parseDate(map['editedAt']) : null,
      createdAt: _parseDate(map['createdAt']),
    );
  }
}
