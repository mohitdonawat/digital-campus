import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final double positiveMarks;
  final double negativeMarks; // Marks deducted if answer is incorrect (e.g. 0.25, 0.5, 1.0)

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.explanation = '',
    this.positiveMarks = 1.0,
    this.negativeMarks = 0.0,
  });

  // Backward compatibility getter for older code using .marks
  int get marks => positiveMarks.round();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
      'positiveMarks': positiveMarks,
      'negativeMarks': negativeMarks,
      'marks': marks,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? '',
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
      explanation: map['explanation'] ?? '',
      positiveMarks: (map['positiveMarks'] as num?)?.toDouble() ??
          (map['marks'] as num?)?.toDouble() ??
          1.0,
      negativeMarks: (map['negativeMarks'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class QuizModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String teacherUid;
  final String teacherName;
  final String targetBranch;   // Specific branch or 'ALL'
  final String targetYear;     // Specific year or 'ALL'
  final String targetSemester; // Specific semester or 'ALL'
  final int durationMinutes;
  final double totalMarks;
  final List<QuizQuestion> questions;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool isActive;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.teacherUid,
    required this.teacherName,
    required this.targetBranch,
    required this.targetYear,
    this.targetSemester = 'ALL',
    required this.durationMinutes,
    required this.totalMarks,
    required this.questions,
    required this.createdAt,
    this.deadline,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'teacherUid': teacherUid,
      'teacherName': teacherName,
      'targetBranch': targetBranch,
      'targetYear': targetYear,
      'targetSemester': targetSemester,
      'durationMinutes': durationMinutes,
      'totalMarks': totalMarks,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'isActive': isActive,
    };
  }

  factory QuizModel.fromMap(Map<String, dynamic> map, String docId) {
    return QuizModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      teacherUid: map['teacherUid'] ?? '',
      teacherName: map['teacherName'] ?? 'Faculty',
      targetBranch: map['targetBranch'] ?? 'ALL',
      targetYear: map['targetYear'] ?? 'ALL',
      targetSemester: map['targetSemester'] ?? 'ALL',
      durationMinutes: map['durationMinutes'] ?? 15,
      totalMarks: (map['totalMarks'] as num?)?.toDouble() ?? 0.0,
      questions: (map['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deadline: (map['deadline'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
    );
  }
}
