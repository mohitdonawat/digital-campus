import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grievance_model.dart';

class GrievanceService {
  static final _col = FirebaseFirestore.instance.collection('grievances');

  /// Submit a new student grievance
  static Future<String> submitGrievance(GrievanceModel g) async {
    final ref = await _col.add(g.toMap());
    return ref.id;
  }

  /// Zero-index stream of grievances lodged by a specific student
  static Stream<List<GrievanceModel>> getStudentGrievances(String studentUid) {
    return _col.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => GrievanceModel.fromMap(d.data(), d.id))
          .where((g) => g.studentUid == studentUid)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Zero-index stream of all campus grievances for Faculty & Admin
  static Stream<List<GrievanceModel>> getAllGrievances() {
    return _col.snapshots().map((snap) {
      final list = snap.docs.map((d) => GrievanceModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Faculty or Admin submits an official response
  /// Crucial rule: Status transitions to FACULTY_REPLIED. It is NOT resolved yet!
  static Future<void> replyGrievance({
    required String grievanceId,
    required String responseText,
    required String responderName,
    required String responderUid,
    required String responderRole,
  }) async {
    final docRef = _col.doc(grievanceId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final currentThread = (doc.data()?['thread'] as List<dynamic>?) ?? [];
    final newMsg = {
      'senderUid': responderUid,
      'senderName': responderName,
      'senderRole': responderRole,
      'message': responseText,
      'timestamp': Timestamp.now(),
    };

    await docRef.update({
      'status': 'FACULTY_REPLIED',
      'response': responseText,
      'respondedBy': responderName,
      'thread': [...currentThread, newMsg],
      'updatedAt': Timestamp.now(),
    });
  }

  /// Student sends a follow-up reply if they need more help
  static Future<void> studentFollowUp({
    required String grievanceId,
    required String followUpText,
    required String studentName,
    required String studentUid,
  }) async {
    final docRef = _col.doc(grievanceId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final currentThread = (doc.data()?['thread'] as List<dynamic>?) ?? [];
    final newMsg = {
      'senderUid': studentUid,
      'senderName': studentName,
      'senderRole': 'student',
      'message': followUpText,
      'timestamp': Timestamp.now(),
    };

    await docRef.update({
      'status': 'STUDENT_REPLIED',
      'thread': [...currentThread, newMsg],
      'updatedAt': Timestamp.now(),
    });
  }

  /// ONLY the student can mark their grievance as resolved when they are satisfied
  static Future<void> resolveByStudent({
    required String grievanceId,
    String? feedback,
  }) async {
    final docRef = _col.doc(grievanceId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final currentThread = (doc.data()?['thread'] as List<dynamic>?) ?? [];
    List<dynamic> updatedThread = List.from(currentThread);

    if (feedback != null && feedback.isNotEmpty) {
      updatedThread.add({
        'senderUid': doc.data()?['studentUid'] ?? '',
        'senderName': doc.data()?['studentName'] ?? 'Student',
        'senderRole': 'student',
        'message': 'Marked Resolved by student. Feedback: $feedback',
        'timestamp': Timestamp.now(),
      });
    }

    await docRef.update({
      'status': 'RESOLVED_BY_STUDENT',
      'isSatisfied': true,
      'thread': updatedThread,
      'resolvedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }
}
