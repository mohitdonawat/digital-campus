import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../models/quiz_model.dart';
import '../models/quiz_submission_model.dart';
import '../services/quiz_service.dart';

class StudentAttemptQuizScreen extends StatefulWidget {
  final QuizModel quiz;
  final Map<String, dynamic>? studentData;

  const StudentAttemptQuizScreen({
    super.key,
    required this.quiz,
    this.studentData,
  });

  @override
  State<StudentAttemptQuizScreen> createState() => _StudentAttemptQuizScreenState();
}

class _StudentAttemptQuizScreenState extends State<StudentAttemptQuizScreen> {
  late int _remainingSeconds;
  late int _totalDurationSeconds;
  Timer? _timer;

  int _currentQuestionIndex = 0;
  final Map<String, int> _selectedAnswers = {}; // Question ID -> chosen option index

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _totalDurationSeconds = widget.quiz.durationMinutes * 60;
    _remainingSeconds = _totalDurationSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        _autoSubmitOnTimeUp();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String _formatTimer(int totalSecs) {
    final m = (totalSecs / 60).floor();
    final s = totalSecs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _autoSubmitOnTimeUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⏳ Time is up! Submitting your answers automatically...'),
        backgroundColor: AppColors.warning,
      ),
    );
    _performSubmission();
  }

  Future<void> _performSubmission() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _timer?.cancel();

    double positiveScore = 0.0;
    double negativePenalty = 0.0;
    int correctCount = 0;
    int wrongCount = 0;
    int unattemptedCount = 0;

    for (final q in widget.quiz.questions) {
      final chosen = _selectedAnswers[q.id];
      if (chosen == null) {
        unattemptedCount++;
      } else if (chosen == q.correctOptionIndex) {
        positiveScore += q.positiveMarks;
        correctCount++;
      } else {
        negativePenalty += q.negativeMarks;
        wrongCount++;
      }
    }

    double netScore = positiveScore - negativePenalty;
    if (netScore < 0) netScore = 0.0; // Floor at 0 for fair grading

    final totalMarks = widget.quiz.totalMarks > 0
        ? widget.quiz.totalMarks
        : widget.quiz.questions.fold<double>(0, (a, b) => a + b.positiveMarks);

    final percentage = totalMarks > 0 ? (netScore / totalMarks) * 100 : 0.0;
    final timeTakenSeconds = _totalDurationSeconds - _remainingSeconds;

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';
    final name = widget.studentData?['name'] ?? 'Student';
    final enroll = widget.studentData?['enrollmentNo'] ?? '0103CS221001';
    final roll = widget.studentData?['rollNo'] ?? '';
    final branch = widget.studentData?['branch'] ?? 'CSE';
    final year = widget.studentData?['year'] ?? '3rd Year';
    final sem = widget.studentData?['semester'] ?? '5th Sem';

    final submission = QuizSubmissionModel(
      id: '',
      quizId: widget.quiz.id,
      studentUid: uid,
      studentName: name,
      enrollmentNo: enroll,
      rollNo: roll,
      branch: branch,
      year: year,
      semester: sem,
      score: netScore,
      positiveScore: positiveScore,
      negativePenalty: negativePenalty,
      correctCount: correctCount,
      wrongCount: wrongCount,
      unattemptedCount: unattemptedCount,
      totalMarks: totalMarks,
      percentage: percentage,
      timeTakenSeconds: timeTakenSeconds,
      submittedAt: DateTime.now(),
      answers: _selectedAnswers,
    );

    try {
      await QuizService.submitQuiz(submission);

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.studentQuizResult,
        arguments: {
          'quiz': widget.quiz,
          'submission': submission,
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission error: $e'), backgroundColor: AppColors.error),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _confirmSubmitDialog() {
    final answeredCount = _selectedAnswers.length;
    final totalQuestions = widget.quiz.questions.length;
    final unAnswered = totalQuestions - answeredCount;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Final Submission',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Answered: $answeredCount / $totalQuestions',
              style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
            if (unAnswered > 0) ...[
              const SizedBox(height: 6),
              Text('⚠️ You have $unAnswered unanswered question${unAnswered > 1 ? 's' : ''}.',
                style: const TextStyle(color: AppColors.warning, fontSize: 13)),
            ],
            const SizedBox(height: 12),
            const Text(
              'Negative marking applies for wrong choices. Unanswered questions do not incur a penalty.\nAre you sure you want to submit?',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Review Answers', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _performSubmission();
            },
            child: const Text('Submit Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quiz.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Assessment'), backgroundColor: AppColors.surface),
        body: const Center(child: Text('No questions available.', style: TextStyle(color: Colors.white))),
      );
    }

    final currentQ = widget.quiz.questions[_currentQuestionIndex];
    final isLast = _currentQuestionIndex == widget.quiz.questions.length - 1;
    final isUrgentTime = _remainingSeconds < 120; // Less than 2 minutes

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmExitDialog();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.surface,
          title: Text(
            widget.quiz.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            // Live Countdown Timer
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: (isUrgentTime ? AppColors.error : AppColors.secondary).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isUrgentTime ? AppColors.error : AppColors.secondary,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_rounded,
                    color: isUrgentTime ? AppColors.error : AppColors.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTimer(_remainingSeconds),
                    style: TextStyle(
                      color: isUrgentTime ? AppColors.error : AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 4,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Counter & Marking Scheme Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+${currentQ.positiveMarks} Mark',
                                style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (currentQ.negativeMarks > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '-${currentQ.negativeMarks} Penalty',
                                  style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Question Statement
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        currentQ.questionText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text('Select one answer:',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),

                    // 4 Options
                    ...List.generate(currentQ.options.length, (optIdx) {
                      final optionText = currentQ.options[optIdx];
                      final isSelected = _selectedAnswers[currentQ.id] == optIdx;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAnswers[currentQ.id] = optIdx;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.secondary.withOpacity(0.15) : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.secondary : AppColors.primary.withOpacity(0.2),
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.secondary : Colors.white.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  String.fromCharCode(65 + optIdx),
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 20),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom Navigation & Submit Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentQuestionIndex > 0)
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _currentQuestionIndex--),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Previous'),
                    )
                  else
                    const SizedBox.shrink(),

                  if (!isLast)
                    ElevatedButton(
                      onPressed: () => setState(() => _currentQuestionIndex++),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Next →', style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _confirmSubmitDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_circle_outline_rounded),
                      label: Text(
                        _isSubmitting ? 'Submitting...' : 'Submit Assessment',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit Assessment?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'If you exit now, your current answers will be submitted as-is.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Resume Quiz', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              _performSubmission();
            },
            child: const Text('Submit & Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
