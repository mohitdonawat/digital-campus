import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assignment_model.dart';

class AssignmentService {
  static final _firestore = FirebaseFirestore.instance;
  static final _assignmentsCol = _firestore.collection('assignments');
  static final _submissionsCol = _firestore.collection('assignment_submissions');

  static Future<String> createAssignment(AssignmentModel assignment) async {
    final ref = await _assignmentsCol.add(assignment.toMap());
    return ref.id;
  }

  /// Teacher assignments stream - preserves records up to 6 months
  static Stream<List<AssignmentModel>> getTeacherAssignments(
    String teacherUid, {
    bool filterLastSixMonths = false,
  }) {
    return _assignmentsCol
        .where('teacherUid', isEqualTo: teacherUid)
        .snapshots()
        .map((snap) {
      final now = DateTime.now();
      final sixMonthsAgo = now.subtract(const Duration(days: 180));

      final list = snap.docs
          .map((d) => AssignmentModel.fromMap(d.data(), d.id))
          .where((a) {
        if (filterLastSixMonths) {
          return a.createdAt.isAfter(sixMonthsAgo);
        }
        return true;
      }).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Student assignments matching their specific Branch, Year, Semester and Section
  static Stream<List<AssignmentModel>> getStudentAssignments({
    required String branch,
    required String year,
    String semester = 'ALL',
    String section = 'ALL',
  }) {
    return _assignmentsCol.snapshots().map((snap) {
      final all = snap.docs.map((d) => AssignmentModel.fromMap(d.data(), d.id)).toList();
      final filtered = all.where((a) {
        final matchesBranch = a.targetBranch == 'ALL' ||
            a.targetBranch.toLowerCase().trim() == branch.toLowerCase().trim() ||
            branch.toLowerCase().contains(a.targetBranch.toLowerCase());

        final matchesYear = a.targetYear == 'ALL' ||
            a.targetYear.toLowerCase().trim() == year.toLowerCase().trim();

        final matchesSemester = a.targetSemester == 'ALL' ||
            semester == 'ALL' ||
            a.targetSemester.toLowerCase().trim() == semester.toLowerCase().trim();

        final matchesSection = a.targetSection == 'ALL' ||
            section == 'ALL' ||
            a.targetSection.toUpperCase().trim() == section.toUpperCase().trim();

        return matchesBranch && matchesYear && matchesSemester && matchesSection;
      }).toList();

      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered;
    });
  }

  /// Submit assignment by student
  static Future<void> submitAssignment(AssignmentSubmissionModel sub) async {
    // Check if student already submitted for this assignment
    final existing = await _submissionsCol
        .where('assignmentId', isEqualTo: sub.assignmentId)
        .where('studentUid', isEqualTo: sub.studentUid)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      // Update existing submission
      await existing.docs.first.reference.update(sub.toMap());
    } else {
      // Create new submission
      await _submissionsCol.add(sub.toMap());
    }
  }

  /// Submissions stream for a specific assignment (for teacher review)
  static Stream<List<AssignmentSubmissionModel>> getAssignmentSubmissions(String assignmentId) {
    return _submissionsCol
        .where('assignmentId', isEqualTo: assignmentId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => AssignmentSubmissionModel.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return list;
    });
  }

  /// Submissions stream for a student (to check dues, submitted, graded status)
  static Stream<List<AssignmentSubmissionModel>> getStudentSubmissions(String studentUid) {
    return _submissionsCol
        .where('studentUid', isEqualTo: studentUid)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => AssignmentSubmissionModel.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return list;
    });
  }

  /// Grade and review a student submission (Grade is flexible: e.g. A+, O, 9/10, 18/20, etc.)
  static Future<void> gradeAndReviewSubmission({
    required String submissionId,
    required String grade,
    dynamic marksAwarded,
    required String feedback,
  }) async {
    await _submissionsCol.doc(submissionId).update({
      'grade': grade.trim(),
      if (marksAwarded != null) 'marksAwarded': marksAwarded,
      'feedback': feedback.trim(),
      'status': 'GRADED',
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }
}
