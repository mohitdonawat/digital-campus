import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'announcements';

  /// Post a new announcement with optional PDF/file attachment and link
  static Future<String> postAnnouncement({
    required String title,
    required String message,
    String? linkUrl,
    File? attachmentFile,
    String? attachmentOriginalName,
    required String authorUid,
    required String authorName,
    required String authorTitle,
    required String authorRole,
    required String targetBranch,
    required String targetYear,
    required String targetSemester,
    String targetSection = 'ALL',
    String priority = 'NORMAL',
  }) async {
    final id = const Uuid().v4();
    String? uploadedFileUrl;
    String? savedFileName;

    // 100% Free Tier Architecture: Direct Base64 Data URI into Firestore (Zero Storage Bucket required)
    if (attachmentFile != null) {
      final ext = attachmentFile.path.split('.').last.toLowerCase();
      savedFileName = attachmentOriginalName ?? 'document_${DateTime.now().millisecondsSinceEpoch}.$ext';
      try {
        final bytes = await attachmentFile.readAsBytes();
        final mime = ext == 'pdf'
            ? 'application/pdf'
            : (ext == 'png' ? 'image/png' : 'image/jpeg');
        uploadedFileUrl = 'data:$mime;base64,${base64Encode(bytes)}';
      } catch (_) {}
    }

    final announcement = AnnouncementModel(
      id: id,
      title: title,
      message: message,
      linkUrl: linkUrl != null && linkUrl.trim().isNotEmpty ? linkUrl.trim() : null,
      fileUrl: uploadedFileUrl,
      fileName: savedFileName,
      authorUid: authorUid,
      authorName: authorName,
      authorTitle: authorTitle,
      authorRole: authorRole,
      targetBranch: targetBranch,
      targetYear: targetYear,
      targetSemester: targetSemester,
      targetSection: targetSection,
      priority: priority,
      createdAt: DateTime.now(),
    );

    await _db.collection(_col).doc(id).set(announcement.toMap());
    return id;
  }

  /// Stream of announcements for students, filtered by their batch (Zero Composite Index Required)
  static Stream<List<AnnouncementModel>> getStudentAnnouncements({
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
              .map((d) => AnnouncementModel.fromMap(d.data(), d.id))
              .where((a) =>
                  a.isActive &&
                  a.isRelevantFor(
                    branch: branch,
                    year: year,
                    semester: semester,
                    section: section,
                  ))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Stream of all announcements for Teachers and Admins (Zero Composite Index Required)
  static Stream<List<AnnouncementModel>> getAllAnnouncements() {
    return _db
        .collection(_col)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => AnnouncementModel.fromMap(d.data(), d.id))
              .where((a) => a.isActive)
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }
}
