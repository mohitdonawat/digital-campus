import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_group_model.dart';
import '../models/chat_message_model.dart';

class ChatService {
  static final _db = FirebaseFirestore.instance;
  static const _groupsCol = 'chat_groups';

  // In-memory cache to guarantee zero-latency & prevent groups from vanishing
  static final List<ChatGroupModel> _localGroupsCache = [];
  static bool _seeded = false;

  /// Canonical branch identifier to resolve differences like 'CSE' vs 'Computer Science & Engineering'
  static String canonicalBranch(String? b) {
    if (b == null || b.trim().isEmpty) return 'all';
    final n = b.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (n == 'all' || n.contains('alldept') || n.contains('alldepartment')) return 'all';
    if (n.contains('cse') || n.contains('computer') || n.contains('software')) return 'cse';
    if (n.contains('civil') || n == 'ce') return 'civil';
    if (n.contains('mech') || n == 'me') return 'me';
    if (n.contains('ece') || n.contains('communication')) return 'ece';
    if (n.contains('electrical') || n.contains('eex') || n.contains('ex') || n == 'ee') return 'ex';
    if (n.contains('firstyear') || n.contains('fy') || n.contains('foundation')) return 'fy';
    return n;
  }

  /// Canonical year resolver: '3rd Year' -> '3'
  static String canonicalYear(String? y) {
    if (y == null || y.trim().isEmpty) return 'all';
    final n = y.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (n == 'all' || n.contains('allyear')) return 'all';
    if (n.contains('1') || n.contains('first')) return '1';
    if (n.contains('2') || n.contains('second')) return '2';
    if (n.contains('3') || n.contains('third')) return '3';
    if (n.contains('4') || n.contains('fourth') || n.contains('final')) return '4';
    return n;
  }

  /// Canonical semester resolver: '5th Sem' -> '5'
  static String canonicalSemester(String? s) {
    if (s == null || s.trim().isEmpty) return 'all';
    final n = s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (n == 'all' || n.contains('allsem')) return 'all';
    for (int i = 1; i <= 8; i++) {
      if (n == '$i' ||
          n.contains('${i}st') ||
          n.contains('${i}nd') ||
          n.contains('${i}rd') ||
          n.contains('${i}th')) {
        return '$i';
      }
    }
    return n;
  }

  /// Canonical section resolver: 'Section A' / 'A' -> 'a'
  static String canonicalSection(String? sec) {
    if (sec == null || sec.trim().isEmpty) return 'all';
    final n = sec.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (n == 'all' || n.contains('allsec')) return 'all';
    if (n.contains('a')) return 'a';
    if (n.contains('b')) return 'b';
    if (n.contains('c')) return 'c';
    if (n.contains('d')) return 'd';
    return n;
  }

  /// Check whether a group is relevant for a given student credentials
  static bool isGroupMatchingStudent({
    required ChatGroupModel group,
    required String department,
    required String year,
    required String semester,
    required String section,
  }) {
    final gBranch = canonicalBranch(group.department);
    final sBranch = canonicalBranch(department);
    final bMatch = gBranch == 'all' || sBranch == 'all' || gBranch == sBranch;

    final gYear = canonicalYear(group.year);
    final sYear = canonicalYear(year);
    final yMatch = gYear == 'all' || sYear == 'all' || gYear == sYear;

    final gSem = canonicalSemester(group.semester);
    final sSem = canonicalSemester(semester);
    final semMatch = gSem == 'all' || sSem == 'all' || gSem == sSem;

    final gSec = canonicalSection(group.section);
    final sSec = canonicalSection(section);
    final secMatch = gSec == 'all' || sSec == 'all' || gSec == sSec;

    return bMatch && yMatch && semMatch && secMatch;
  }

  /// Ensure default departmental & general discussion groups exist so users are never greeted with an empty void
  static Future<void> ensureDefaultGroupsExist() async {
    if (_seeded) return;
    _seeded = true;

    try {
      final snap = await _db.collection(_groupsCol).limit(1).get();
      if (snap.docs.isEmpty) {
        final defaults = [
          ChatGroupModel(
            id: 'group_ies_general',
            title: '🏛️ IES Campus General Discussion & Doubts',
            description: 'Official college-wide community for queries, general notices, and student helpdesk.',
            createdByUid: 'system_admin',
            createdByName: 'IES Administration',
            createdByTitle: 'Admin',
            createdByRole: 'admin',
            department: 'ALL',
            year: 'ALL',
            semester: 'ALL',
            section: 'ALL',
            lastMessage: 'Welcome to the official IES E-Campus discussion forum! Ask your academic queries here.',
            lastMessageSender: 'IES Admin',
            lastMessageTime: DateTime.now(),
            createdAt: DateTime.now(),
            isActive: true,
          ),
          ChatGroupModel(
            id: 'group_cse_official',
            title: '💻 Computer Science & Engg (CSE) Forum',
            description: 'Departmental discussions, coding queries, lab notes, and syllabus coverage.',
            createdByUid: 'system_admin',
            createdByName: 'HOD CSE',
            createdByTitle: 'Prof.',
            createdByRole: 'teacher',
            department: 'Computer Science & Engineering',
            year: 'ALL',
            semester: 'ALL',
            section: 'ALL',
            lastMessage: 'Feel free to discuss programming, OS, DBMS and lab assignments here.',
            lastMessageSender: 'Prof. Mohit Donawat',
            lastMessageTime: DateTime.now(),
            createdAt: DateTime.now(),
            isActive: true,
          ),
          ChatGroupModel(
            id: 'group_me_official',
            title: '⚙️ Mechanical Engineering (ME) Forum',
            description: 'Mechanical engineering discussions, CAD/CAM labs, workshops, and project ideas.',
            createdByUid: 'system_admin',
            createdByName: 'HOD ME',
            createdByTitle: 'Prof.',
            createdByRole: 'teacher',
            department: 'Mechanical Engineering',
            year: 'ALL',
            semester: 'ALL',
            section: 'ALL',
            lastMessage: 'Class notes and workshop schedules will be discussed here.',
            lastMessageSender: 'Prof. Sharma',
            lastMessageTime: DateTime.now(),
            createdAt: DateTime.now(),
            isActive: true,
          ),
          ChatGroupModel(
            id: 'group_civil_official',
            title: '🏗️ Civil Engineering Forum',
            description: 'Civil engineering structural analysis, surveying labs, and project guidance.',
            createdByUid: 'system_admin',
            createdByName: 'HOD Civil',
            createdByTitle: 'Prof.',
            createdByRole: 'teacher',
            department: 'Civil Engineering',
            year: 'ALL',
            semester: 'ALL',
            section: 'ALL',
            lastMessage: 'Surveying camp details and site visit reports will be coordinated here.',
            lastMessageSender: 'Prof. Verma',
            lastMessageTime: DateTime.now(),
            createdAt: DateTime.now(),
            isActive: true,
          ),
        ];

        for (final g in defaults) {
          _localGroupsCache.add(g);
          await _db.collection(_groupsCol).doc(g.id).set(g.toMap(), SetOptions(merge: true));
        }
      }
    } catch (e) {
      debugPrint('Default groups initialization note: $e');
    }
  }

  /// Create a new discussion group (Faculty & Admin)
  static Future<String> createGroup({
    required String title,
    required String description,
    required String createdByUid,
    required String createdByName,
    required String createdByTitle,
    required String createdByRole,
    required String department,
    required String year,
    required String semester,
    String section = 'ALL',
  }) async {
    final groupId = const Uuid().v4();
    final group = ChatGroupModel(
      id: groupId,
      title: title,
      description: description,
      createdByUid: createdByUid,
      createdByName: createdByName,
      createdByTitle: createdByTitle,
      createdByRole: createdByRole,
      department: department,
      year: year,
      semester: semester,
      section: section,
      createdAt: DateTime.now(),
      isActive: true,
    );

    // 1. Immediately cache in memory so it appears for all participants instantly
    _localGroupsCache.removeWhere((g) => g.id == groupId);
    _localGroupsCache.insert(0, group);

    // 2. Persist to Firestore with merge
    try {
      await _db.collection(_groupsCol).doc(groupId).set(group.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore create group notice: $e');
    }

    return groupId;
  }

  /// Stream of groups visible to a specific student with bulletproof matching
  static Stream<List<ChatGroupModel>> getGroupsForStudent({
    required String department,
    required String year,
    required String semester,
    required String section,
  }) {
    // Seed defaults in background if needed
    ensureDefaultGroupsExist();

    return _db.collection(_groupsCol).snapshots().map((snap) {
      final Map<String, ChatGroupModel> map = {};

      // 1. Load from local memory cache
      for (final g in _localGroupsCache) {
        if (g.isActive) map[g.id] = g;
      }

      // 2. Load / merge from Firestore
      for (final doc in snap.docs) {
        try {
          final g = ChatGroupModel.fromMap(doc.data(), doc.id);
          if (g.isActive) map[doc.id] = g;
        } catch (_) {}
      }

      final allActive = map.values.toList();

      // Filter groups matching the student's credentials
      final filtered = allActive.where((g) {
        return isGroupMatchingStudent(
          group: g,
          department: department,
          year: year,
          semester: semester,
          section: section,
        );
      }).toList();

      // Fallback: If no targeted groups matched, show general/all active groups so student is NEVER locked out
      final result = filtered.isNotEmpty ? filtered : allActive;

      // Sort with latest message or latest created first
      result.sort((a, b) {
        final tA = a.lastMessageTime ?? a.createdAt;
        final tB = b.lastMessageTime ?? b.createdAt;
        return tB.compareTo(tA);
      });

      return result;
    });
  }

  /// Stream of all active groups for Teachers and Admin
  static Stream<List<ChatGroupModel>> getAllGroups() {
    ensureDefaultGroupsExist();

    return _db.collection(_groupsCol).snapshots().map((snap) {
      final Map<String, ChatGroupModel> map = {};

      // 1. Local memory cache
      for (final g in _localGroupsCache) {
        if (g.isActive) map[g.id] = g;
      }

      // 2. Firestore records
      for (final doc in snap.docs) {
        try {
          final g = ChatGroupModel.fromMap(doc.data(), doc.id);
          if (g.isActive) map[doc.id] = g;
        } catch (_) {}
      }

      final list = map.values.toList();
      list.sort((a, b) {
        final tA = a.lastMessageTime ?? a.createdAt;
        final tB = b.lastMessageTime ?? b.createdAt;
        return tB.compareTo(tA);
      });
      return list;
    });
  }

  /// Send a message inside a group
  static Future<bool> sendMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String senderRole,
    String senderTitle = '',
    required String text,
    String? replyToMessageId,
    String? replyToSenderName,
    String? replyToText,
  }) async {
    final msgId = const Uuid().v4();
    final now = DateTime.now();

    final msg = ChatMessageModel(
      id: msgId,
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      senderTitle: senderTitle,
      text: text,
      replyToMessageId: replyToMessageId,
      replyToSenderName: replyToSenderName,
      replyToText: replyToText,
      createdAt: now,
    );

    // Update group in local cache
    for (int i = 0; i < _localGroupsCache.length; i++) {
      if (_localGroupsCache[i].id == groupId) {
        final old = _localGroupsCache[i];
        _localGroupsCache[i] = ChatGroupModel(
          id: old.id,
          title: old.title,
          description: old.description,
          createdByUid: old.createdByUid,
          createdByName: old.createdByName,
          createdByTitle: old.createdByTitle,
          createdByRole: old.createdByRole,
          department: old.department,
          year: old.year,
          semester: old.semester,
          section: old.section,
          lastMessage: text,
          lastMessageSender: senderName,
          lastMessageTime: now,
          createdAt: old.createdAt,
          isActive: old.isActive,
        );
        break;
      }
    }

    try {
      // 1. Write message into subcollection
      await _db
          .collection(_groupsCol)
          .doc(groupId)
          .collection('messages')
          .doc(msgId)
          .set(msg.toMap(), SetOptions(merge: true));

      // 2. Update group's last message with merge to prevent NOT_FOUND exceptions
      await _db.collection(_groupsCol).doc(groupId).set({
        'lastMessage': text,
        'lastMessageSender': senderName,
        'lastMessageTime': Timestamp.fromDate(now),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint('Firestore send message error: $e');
      return false;
    }
  }

  /// Edit a message within 60 seconds of sending
  static Future<bool> editMessage({
    required String groupId,
    required String messageId,
    required String newText,
    required String currentUserId,
  }) async {
    try {
      final docRef = _db
          .collection(_groupsCol)
          .doc(groupId)
          .collection('messages')
          .doc(messageId);

      final snap = await docRef.get();
      if (!snap.exists) return false;

      final msg = ChatMessageModel.fromMap(snap.data()!, snap.id);
      if (!msg.canEdit(currentUserId)) {
        return false; // 60 seconds passed or not owner!
      }

      await docRef.update({
        'text': newText,
        'isEdited': true,
        'editedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      debugPrint('Firestore edit message error: $e');
      return false;
    }
  }

  /// Stream of messages in a group
  static Stream<List<ChatMessageModel>> getGroupMessages(String groupId) {
    return _db
        .collection(_groupsCol)
        .doc(groupId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) {
              try {
                return ChatMessageModel.fromMap(d.data(), d.id);
              } catch (_) {
                return null;
              }
            })
            .whereType<ChatMessageModel>()
            .toList());
  }
}
