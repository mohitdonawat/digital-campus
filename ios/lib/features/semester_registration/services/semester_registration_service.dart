import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/semester_registration_model.dart';

class SemesterRegistrationService {
  static final _firestore = FirebaseFirestore.instance;
  static final _regCol = _firestore.collection('semester_registrations');

  /// Submit or update semester registration form
  static Future<String> submitRegistration(SemesterRegistrationModel registration) async {
    // Check if student already submitted for this applying semester
    final existing = await _regCol
        .where('studentUid', isEqualTo: registration.studentUid)
        .where('applyingSemester', isEqualTo: registration.applyingSemester)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final docId = existing.docs.first.id;
      await _regCol.doc(docId).set(registration.toMap(), SetOptions(merge: true));
      return docId;
    } else {
      final ref = await _regCol.add(registration.toMap());
      return ref.id;
    }
  }

  /// Stream of registrations submitted by a specific student
  static Stream<List<SemesterRegistrationModel>> getStudentRegistrations(String studentUid) {
    return _regCol
        .where('studentUid', isEqualTo: studentUid)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => SemesterRegistrationModel.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return list;
    });
  }

  /// Stream for Faculty / HOD to review semester registrations
  static Stream<List<SemesterRegistrationModel>> getAllRegistrations({
    String? branch,
    String? semester,
  }) {
    return _regCol.snapshots().map((snap) {
      final all = snap.docs
          .map((d) => SemesterRegistrationModel.fromMap(d.data(), d.id))
          .toList();

      final filtered = all.where((r) {
        if (branch != null && branch != 'ALL') {
          if (!r.branch.toLowerCase().contains(branch.toLowerCase()) &&
              r.branch.toLowerCase() != branch.toLowerCase()) {
            return false;
          }
        }
        if (semester != null && semester != 'ALL') {
          if (r.applyingSemester.toLowerCase() != semester.toLowerCase()) {
            return false;
          }
        }
        return true;
      }).toList();

      filtered.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return filtered;
    });
  }

  /// Approve or Reject Registration with remarks
  static Future<void> updateRegistrationStatus({
    required String regId,
    required String status,
    String? remarks,
  }) async {
    await _regCol.doc(regId).update({
      'status': status,
      if (remarks != null) 'hodRemarks': remarks,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }
}
