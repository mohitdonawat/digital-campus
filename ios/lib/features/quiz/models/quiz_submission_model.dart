import 'package:cloud_firestore/cloud_firestore.dart';

class QuizSubmissionModel {
  final String id;
  final String quizId;
  final String studentUid;
  final String studentName;
  final String enrollmentNo;
  final String rollNo;
  final String branch;
  final String year;
  final String semester;
  final double score; // Net score = positiveScore - negativePenalty
  final double positiveScore;
  final double negativePenalty;
  final int correctCount;
  final int wrongCount;
  final int unattemptedCount;
  final double totalMarks;
  final double percentage;
  final int timeTakenSeconds;
  final DateTime submittedAt;
  final Map<String, int> answers; // Question ID or index -> chosen option index

  QuizSubmissionModel({
    required this.id,
    required this.quizId,
    required this.studentUid,
    required this.studentName,
    required this.enrollmentNo,
    required this.rollNo,
    required this.branch,
    required this.year,
    required this.semester,
    required this.score,
    this.positiveScore = 0.0,
    this.negativePenalty = 0.0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.unattemptedCount = 0,
    required this.totalMarks,
    required this.percentage,
    required this.timeTakenSeconds,
    required this.submittedAt,
    required this.answers,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'studentUid': studentUid,
      'studentName': studentName,
      'enrollmentNo': enrollmentNo,
      'rollNo': rollNo,
      'branch': branch,
      'year': year,
      'semester': semester,
      'score': score,
      'positiveScore': positiveScore,
      'negativePenalty': negativePenalty,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'unattemptedCount': unattemptedCount,
      'totalMarks': totalMarks,
      'percentage': percentage,
      'timeTakenSeconds': timeTakenSeconds,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'answers': answers,
    };
  }

  factory QuizSubmissionModel.fromMap(Map<String, dynamic> map, String docId) {
    return QuizSubmissionModel(
      id: docId,
      quizId: map['quizId'] ?? '',
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? '',
      enrollmentNo: map['enrollmentNo'] ?? '',
      rollNo: map['rollNo'] ?? '',
      branch: map['branch'] ?? '',
      year: map['year'] ?? '',
      semester: map['semester'] ?? '',
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      positiveScore: (map['positiveScore'] as num?)?.toDouble() ?? (map['score'] as num?)?.toDouble() ?? 0.0,
      negativePenalty: (map['negativePenalty'] as num?)?.toDouble() ?? 0.0,
      correctCount: map['correctCount'] ?? 0,
      wrongCount: map['wrongCount'] ?? 0,
      unattemptedCount: map['unattemptedCount'] ?? 0,
      totalMarks: (map['totalMarks'] as num?)?.toDouble() ?? 0.0,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
      timeTakenSeconds: map['timeTakenSeconds'] ?? 0,
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      answers: Map<String, int>.from(map['answers'] ?? {}),
    );
  }
}
