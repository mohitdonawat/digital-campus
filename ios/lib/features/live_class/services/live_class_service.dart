import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/live_class_model.dart';

class LiveClassService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'live_classes';

  /// Schedule a new live class
  static Future<String> scheduleLiveClass({
    required String title,
    required String subject,
    required String description,
    required String teacherUid,
    required String teacherName,
    String teacherTitle = 'Prof.',
    String teacherDepartment = 'CSE',
    required String platform,
    required String meetingUrl,
    required DateTime scheduledStartTime,
    int durationMinutes = 60,
    String targetBranch = 'ALL',
    String targetYear = 'ALL',
    String targetSemester = 'ALL',
    String targetSection = 'ALL',
  }) async {
    final id = const Uuid().v4();
    final model = LiveClassModel(
      id: id,
      title: title.trim(),
      subject: subject.trim(),
      description: description.trim(),
      teacherUid: teacherUid,
      teacherName: teacherName,
      teacherTitle: teacherTitle,
      teacherDepartment: teacherDepartment,
      platform: platform,
      meetingUrl: meetingUrl.trim(),
      scheduledStartTime: scheduledStartTime,
      durationMinutes: durationMinutes,
      status: 'UPCOMING',
      targetBranch: targetBranch,
      targetYear: targetYear,
      targetSemester: targetSemester,
      targetSection: targetSection,
      createdAt: DateTime.now(),
    );

    await _db.collection(_col).doc(id).set(model.toMap());
    return id;
  }

  /// Update an existing class
  static Future<void> updateLiveClass({
    required String id,
    required String title,
    required String subject,
    required String description,
    required String platform,
    required String meetingUrl,
    required DateTime scheduledStartTime,
    required int durationMinutes,
    required String targetBranch,
    required String targetYear,
    required String targetSemester,
    required String targetSection,
    String? recordingUrl,
  }) async {
    await _db.collection(_col).doc(id).update({
      'title': title.trim(),
      'subject': subject.trim(),
      'description': description.trim(),
      'platform': platform,
      'meetingUrl': meetingUrl.trim(),
      'scheduledStartTime': Timestamp.fromDate(scheduledStartTime),
      'durationMinutes': durationMinutes,
      'targetBranch': targetBranch,
      'targetYear': targetYear,
      'targetSemester': targetSemester,
      'targetSection': targetSection,
      if (recordingUrl != null) 'recordingUrl': recordingUrl.trim(),
    });
  }

  /// Change status: 'UPCOMING' | 'LIVE' | 'COMPLETED' | 'CANCELLED'
  static Future<void> updateClassStatus(String id, String newStatus, {String? recordingUrl}) async {
    final data = <String, dynamic>{
      'status': newStatus,
    };
    if (recordingUrl != null && recordingUrl.trim().isNotEmpty) {
      data['recordingUrl'] = recordingUrl.trim();
    }
    await _db.collection(_col).doc(id).update(data);
  }

  /// Delete a class
  static Future<void> deleteLiveClass(String id) async {
    await _db.collection(_col).doc(id).delete();
  }

  /// Stream of classes created by this teacher (Zero Composite Index Required)
  static Stream<List<LiveClassModel>> getTeacherClasses(String teacherUid) {
    return _db
        .collection(_col)
        .where('teacherUid', isEqualTo: teacherUid)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => LiveClassModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.scheduledStartTime.compareTo(a.scheduledStartTime));
          return list;
        });
  }

  /// Stream of all classes for students, filtered in real-time by their batch (Zero Composite Index Required)
  static Stream<List<LiveClassModel>> getStudentClasses({
    required String branch,
    required String year,
    required String semester,
    required String section,
  }) {
    return _db
        .collection(_col)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => LiveClassModel.fromMap(doc.data(), doc.id))
              .where((c) =>
                  (c.status == 'LIVE' || c.status == 'UPCOMING' || c.status == 'COMPLETED') &&
                  c.isRelevantFor(
                    branch: branch,
                    year: year,
                    semester: semester,
                    section: section,
                  ))
              .toList();
          list.sort((a, b) => b.scheduledStartTime.compareTo(a.scheduledStartTime));
          return list;
        });
  }

  /// Get currently active LIVE classes for a student's batch (for Dashboard banner)
  static Stream<List<LiveClassModel>> getActiveLiveClassesForStudent({
    required String branch,
    required String year,
    required String semester,
    required String section,
  }) {
    return _db
        .collection(_col)
        .where('status', isEqualTo: 'LIVE')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => LiveClassModel.fromMap(doc.data(), doc.id))
              .where((c) => c.isRelevantFor(
                    branch: branch,
                    year: year,
                    semester: semester,
                    section: section,
                  ))
              .toList();
          list.sort((a, b) => b.scheduledStartTime.compareTo(a.scheduledStartTime));
          return list;
        });
  }
}
