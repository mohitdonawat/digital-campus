import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../models/quiz_submission_model.dart';

class QuizService {
  static final _firestore = FirebaseFirestore.instance;
  static final _quizzesCol = _firestore.collection('quizzes');
  static final _submissionsCol = _firestore.collection('quiz_submissions');

  /// Create a new targeted quiz
  static Future<String> createQuiz(QuizModel quiz) async {
    final docRef = await _quizzesCol.add(quiz.toMap());
    return docRef.id;
  }

  /// Quizzes created by a teacher
  static Stream<List<QuizModel>> getTeacherQuizzes(String teacherUid) {
    return _quizzesCol
        .where('teacherUid', isEqualTo: teacherUid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => QuizModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Target-filtered stream of quizzes for a specific student
  static Stream<List<QuizModel>> getStudentQuizzes({
    required String branch,
    required String year,
    required String semester,
  }) {
    return _quizzesCol
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final all = snap.docs.map((d) => QuizModel.fromMap(d.data(), d.id)).toList();

      // Precise targeting filter
      final filtered = all.where((q) {
        final matchesBranch = q.targetBranch == 'ALL' ||
            q.targetBranch.toLowerCase().trim() == branch.toLowerCase().trim() ||
            branch.toLowerCase().contains(q.targetBranch.toLowerCase()) ||
            q.targetBranch.toLowerCase().contains(branch.toLowerCase());

        final matchesYear = q.targetYear == 'ALL' ||
            q.targetYear.toLowerCase().trim() == year.toLowerCase().trim();

        final matchesSem = q.targetSemester == 'ALL' ||
            q.targetSemester.toLowerCase().trim() == semester.toLowerCase().trim();

        return matchesBranch && matchesYear && matchesSem;
      }).toList();

      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered;
    });
  }

  /// Submit an attempted quiz
  static Future<void> submitQuiz(QuizSubmissionModel submission) async {
    await _submissionsCol.add(submission.toMap());
  }

  /// Check if student has already attempted this quiz
  static Future<QuizSubmissionModel?> getStudentSubmission(String quizId, String studentUid) async {
    final snap = await _submissionsCol
        .where('quizId', isEqualTo: quizId)
        .where('studentUid', isEqualTo: studentUid)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return QuizSubmissionModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  /// Stream of student submission for reactive UI
  static Stream<QuizSubmissionModel?> streamStudentSubmission(String quizId, String studentUid) {
    return _submissionsCol
        .where('quizId', isEqualTo: quizId)
        .where('studentUid', isEqualTo: studentUid)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return QuizSubmissionModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
    });
  }

  /// Universal top-to-bottom leaderboard for a quiz
  static Stream<List<QuizSubmissionModel>> getQuizLeaderboard(String quizId) {
    return _submissionsCol
        .where('quizId', isEqualTo: quizId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => QuizSubmissionModel.fromMap(d.data(), d.id))
          .toList();

      // Top-to-Bottom Rank: Score DESC, then timeTakenSeconds ASC
      list.sort((a, b) {
        if (b.score != a.score) {
          return b.score.compareTo(a.score);
        }
        return a.timeTakenSeconds.compareTo(b.timeTakenSeconds);
      });

      return list;
    });
  }

  /// Get total eligible students count for target batch
  static Future<int> getEligibleStudentsCount({
    required String targetBranch,
    required String targetYear,
  }) async {
    try {
      Query query = _firestore.collection('users').where('role', isEqualTo: 'student');
      if (targetBranch != 'ALL') {
        query = query.where('branch', isEqualTo: targetBranch);
      }
      if (targetYear != 'ALL') {
        query = query.where('year', isEqualTo: targetYear);
      }
      final snap = await query.get();
      return snap.size;
    } catch (_) {
      return 0;
    }
  }
}
