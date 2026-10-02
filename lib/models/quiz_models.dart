import 'package:flutter/material.dart';

/// Bloom's Taxonomy Cognitive Hierarchy Levels
enum BloomsLevel {
  remember("L1: Remember", Color(0xFF64748B)),
  understand("L2: Understand", Color(0xFF0284C7)),
  apply("L3: Apply", Color(0xFF16A34A)),
  analyze("L4: Analyze", Color(0xFFD97706)),
  evaluate("L5: Evaluate", Color(0xFF9333EA)),
  create("L6: Create", Color(0xFFE11D48));

  final String label;
  final Color color;
  const BloomsLevel(this.label, this.color);
}

/// Status of the Quiz
enum QuizStatus {
  active("Active Live", Color(0xFF16A34A)),
  scheduled("Scheduled", Color(0xFFD97706)),
  completed("Completed", Color(0xFF64748B));

  final String label;
  final Color color;
  const QuizStatus(this.label, this.color);
}

/// A Single Assessment Question with Textbook Citations
class QuizQuestion {
  final String id;
  final String questionText;
  final List<String> options; // 2 options (True/False) or 4 options (MCQ)
  final int correctOptionIndex;
  final String explanation;
  final String textbookCitation; // e.g. "Silberschatz & Galvin (10th Ed), Ch 7, p. 328"
  final BloomsLevel bloomsLevel;

  const QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.textbookCitation,
    this.bloomsLevel = BloomsLevel.understand,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
      'textbookCitation': textbookCitation,
      'bloomsLevel': bloomsLevel.name,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? '',
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
      explanation: map['explanation'] ?? '',
      textbookCitation: map['textbookCitation'] ?? '',
      bloomsLevel: BloomsLevel.values.firstWhere(
        (b) => b.name == map['bloomsLevel'],
        orElse: () => BloomsLevel.understand,
      ),
    );
  }
}

/// A Full Academic Quiz configured by Faculty
class CampusQuiz {
  final String id;
  final String title;
  final String subjectCode;
  final String subjectName;
  final String targetBranch; // "CSE", "IT", "ECE", "ME", "Civil", "All"
  final int targetSemester; // 1 to 8
  final int targetYear; // 1 to 4
  final int durationMinutes;
  final double marksPerQuestion;
  final bool hasNegativeMarking;
  final double negativePenalty;
  final List<QuizQuestion> questions;
  final String createdByFaculty;
  final DateTime createdAt;
  final QuizStatus status;
  final int totalSubmissions;
  final double classAverageScore;
  final double highestScore;

  const CampusQuiz({
    required this.id,
    required this.title,
    required this.subjectCode,
    required this.subjectName,
    required this.targetBranch,
    required this.targetSemester,
    required this.targetYear,
    required this.durationMinutes,
    required this.marksPerQuestion,
    required this.hasNegativeMarking,
    required this.negativePenalty,
    required this.questions,
    required this.createdByFaculty,
    required this.createdAt,
    this.status = QuizStatus.active,
    this.totalSubmissions = 0,
    this.classAverageScore = 0.0,
    this.highestScore = 0.0,
  });

  double get totalPossibleMarks => questions.length * marksPerQuestion;

  CampusQuiz copyWith({
    String? id,
    String? title,
    String? subjectCode,
    String? subjectName,
    String? targetBranch,
    int? targetSemester,
    int? targetYear,
    int? durationMinutes,
    double? marksPerQuestion,
    bool? hasNegativeMarking,
    double? negativePenalty,
    List<QuizQuestion>? questions,
    String? createdByFaculty,
    DateTime? createdAt,
    QuizStatus? status,
    int? totalSubmissions,
    double? classAverageScore,
    double? highestScore,
  }) {
    return CampusQuiz(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectCode: subjectCode ?? this.subjectCode,
      subjectName: subjectName ?? this.subjectName,
      targetBranch: targetBranch ?? this.targetBranch,
      targetSemester: targetSemester ?? this.targetSemester,
      targetYear: targetYear ?? this.targetYear,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      marksPerQuestion: marksPerQuestion ?? this.marksPerQuestion,
      hasNegativeMarking: hasNegativeMarking ?? this.hasNegativeMarking,
      negativePenalty: negativePenalty ?? this.negativePenalty,
      questions: questions ?? this.questions,
      createdByFaculty: createdByFaculty ?? this.createdByFaculty,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      totalSubmissions: totalSubmissions ?? this.totalSubmissions,
      classAverageScore: classAverageScore ?? this.classAverageScore,
      highestScore: highestScore ?? this.highestScore,
    );
  }
}

/// A Student's Submission for a Quiz
class QuizSubmission {
  final String id;
  final String quizId;
  final String studentId;
  final String studentName;
  final String rollNumber;
  final String branch;
  final int semester;
  final double score;
  final double totalPossibleMarks;
  final int correctAnswersCount;
  final int wrongAnswersCount;
  final int unansweredCount;
  final int timeTakenSeconds;
  final DateTime submittedAt;
  final Map<int, int> selectedAnswers; // questionIndex -> selectedOptionIndex
  final bool isAutoSubmitted;

  const QuizSubmission({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.branch,
    required this.semester,
    required this.score,
    required this.totalPossibleMarks,
    required this.correctAnswersCount,
    required this.wrongAnswersCount,
    required this.unansweredCount,
    required this.timeTakenSeconds,
    required this.submittedAt,
    required this.selectedAnswers,
    this.isAutoSubmitted = false,
  });

  double get accuracyPercentage {
    final attempted = correctAnswersCount + wrongAnswersCount;
    if (attempted == 0) return 0.0;
    return (correctAnswersCount / attempted) * 100.0;
  }

  String get timeFormatted {
    final mins = timeTakenSeconds ~/ 60;
    final secs = timeTakenSeconds % 60;
    return "${mins.toString().padLeft(2, '0')}m ${secs.toString().padLeft(2, '0')}s";
  }
}

/// Real-Time Competitive Leaderboard Entry
class LeaderboardEntry {
  final int rank;
  final String studentName;
  final String rollNumber;
  final String branch;
  final int semester;
  final double score;
  final double totalMarks;
  final int timeTakenSeconds;
  final double accuracy;
  final bool isCurrentStudent;

  const LeaderboardEntry({
    required this.rank,
    required this.studentName,
    required this.rollNumber,
    required this.branch,
    required this.semester,
    required this.score,
    required this.totalMarks,
    required this.timeTakenSeconds,
    required this.accuracy,
    this.isCurrentStudent = false,
  });

  String get timeFormatted {
    final mins = timeTakenSeconds ~/ 60;
    final secs = timeTakenSeconds % 60;
    return "${mins.toString().padLeft(2, '0')}m ${secs.toString().padLeft(2, '0')}s";
  }
}
