import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/quiz_models.dart';
import '../../providers/campus_provider.dart';
import 'quiz_review_screen.dart';

/// 🛡️ Student Proctored Anti-Cheat Examination Sandbox
/// Features:
/// 1. PopScope back navigation lock.
/// 2. AppLifecycle tab-switch / minimize listener with violation warning popup.
/// 3. Digital countdown timer with auto-submit.
/// 4. Copy-paste prevention.
/// 5. Question navigation grid and instant scoring upon completion.
class ProctoredQuizScreen extends StatefulWidget {
  final CampusQuiz quiz;

  const ProctoredQuizScreen({super.key, required this.quiz});

  @override
  State<ProctoredQuizScreen> createState() => _ProctoredQuizScreenState();
}

class _ProctoredQuizScreenState extends State<ProctoredQuizScreen> with WidgetsBindingObserver {
  late Timer _countdownTimer;
  late int _remainingSeconds;
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // questionIndex -> selectedOptionIndex

  int _violationCount = 0;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remainingSeconds = widget.quiz.durationMinutes * 60;

    // Start 1-second countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isSubmitted) return;
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _countdownTimer.cancel();
        _autoSubmitExam(isTimeout: true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_isSubmitted) return;

    // If student minimizes, switches app, or leaves window
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _violationCount++;
      if (_violationCount >= 2) {
        // Disqualify / Force Submit
        _autoSubmitExam(isDisqualified: true);
      } else {
        // Show violation alert when they refocus
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAntiCheatViolationDialog();
        });
      }
    }
  }

  void _showAntiCheatViolationDialog() {
    if (!mounted || _isSubmitted) return;
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            SizedBox(width: 8),
            Text(
              "Anti-Cheat Violation Alert",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.error),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "⚠️ Violation Detected (#$_violationCount of 2 allowed):",
              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark, fontSize: 13),
            ),
            const SizedBox(height: 6),
            const Text(
              "You minimized or left the secure examination sandbox! Switching to other apps, browsers, or copy-pasting is strictly monitored.\n\n"
              "ONE MORE EXIT will trigger immediate automated disqualification and submit your current paper as final!",
              style: TextStyle(fontSize: 12, height: 1.35, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text("I Understand & Resume Test", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmSubmit() {
    final answered = _selectedAnswers.length;
    final total = widget.quiz.questions.length;
    final unanswered = total - answered;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text("Submit Examination?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("You have answered $answered out of $total questions."),
            if (unanswered > 0) ...[
              const SizedBox(height: 6),
              Text(
                "⚠️ $unanswered questions are still unanswered!",
                style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              "Once submitted, your answers will be evaluated immediately with official textbook citations.",
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Continue Test"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _autoSubmitExam(isTimeout: false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            child: const Text("Confirm & Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _autoSubmitExam({bool isTimeout = false, bool isDisqualified = false}) {
    if (_isSubmitted) return;
    _isSubmitted = true;
    _countdownTimer.cancel();

    final provider = Provider.of<CampusProvider>(context, listen: false);
    final student = provider.student;
    final questions = widget.quiz.questions;

    int correct = 0;
    int wrong = 0;
    int unanswered = 0;
    double rawScore = 0.0;

    for (int i = 0; i < questions.length; i++) {
      if (_selectedAnswers.containsKey(i)) {
        final chosen = _selectedAnswers[i]!;
        if (chosen == questions[i].correctOptionIndex) {
          correct++;
          rawScore += widget.quiz.marksPerQuestion;
        } else {
          wrong++;
          if (widget.quiz.hasNegativeMarking) {
            rawScore -= widget.quiz.negativePenalty;
          }
        }
      } else {
        unanswered++;
      }
    }

    if (rawScore < 0) rawScore = 0.0;
    final finalScore = double.parse(rawScore.toStringAsFixed(1));
    final timeSpentSeconds = (widget.quiz.durationMinutes * 60) - _remainingSeconds;

    final submission = QuizSubmission(
      id: "SUB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
      quizId: widget.quiz.id,
      studentId: student.id,
      studentName: student.name,
      rollNumber: student.rollNumber,
      branch: student.branch,
      semester: student.semester,
      score: finalScore,
      totalPossibleMarks: widget.quiz.totalPossibleMarks,
      correctAnswersCount: correct,
      wrongAnswersCount: wrong,
      unansweredCount: unanswered,
      timeTakenSeconds: timeSpentSeconds > 0 ? timeSpentSeconds : 30,
      submittedAt: DateTime.now(),
      selectedAnswers: Map.from(_selectedAnswers),
      isAutoSubmitted: isTimeout || isDisqualified,
    );

    provider.submitQuiz(submission);
    HapticFeedback.heavyImpact();

    // Replace current screen with Review Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizReviewScreen(
          quiz: widget.quiz,
          submission: submission,
        ),
      ),
    );
  }

  String _formatTimer(int totalSecs) {
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.quiz.questions;
    final currentQ = questions[_currentQuestionIndex];
    final isTimerLow = _remainingSeconds < 120; // less than 2 mins

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🔒 Examination is proctored! Tap 'Submit Paper' to finish your test."),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0F172A),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_rounded, size: 12, color: Color(0xFFEF4444)),
                    SizedBox(width: 4),
                    Text("PROCTORED", style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.quiz.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            // Live Countdown Timer
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isTimerLow ? const Color(0xFF7F1D1D) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isTimerLow ? Colors.redAccent : Colors.white24),
              ),
              child: Row(
                children: [
                  Icon(Icons.alarm_rounded, size: 14, color: isTimerLow ? Colors.redAccent : Colors.amber),
                  const SizedBox(width: 5),
                  Text(
                    _formatTimer(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isTimerLow ? Colors.redAccent : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Question Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "QUESTION ${_currentQuestionIndex + 1} OF ${questions.length}",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                      Text(
                        "Marks: +${widget.quiz.marksPerQuestion.toStringAsFixed(1)}${widget.quiz.hasNegativeMarking ? ' | -${widget.quiz.negativePenalty}' : ''}",
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(questions.length, (idx) {
                        final isAnswered = _selectedAnswers.containsKey(idx);
                        final isCurrent = idx == _currentQuestionIndex;

                        Color bg = Colors.white;
                        Color textC = AppColors.textDark;
                        Color borderC = AppColors.borderLight;

                        if (isCurrent) {
                          borderC = AppColors.primary;
                          bg = AppColors.primary.withOpacity(0.08);
                        }
                        if (isAnswered) {
                          bg = const Color(0xFF16A34A);
                          textC = Colors.white;
                          borderC = const Color(0xFF16A34A);
                        }

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentQuestionIndex = idx;
                            });
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: borderC, width: isCurrent ? 2 : 1),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "${idx + 1}",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textC),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Question Card & Options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: currentQ.bloomsLevel.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  currentQ.bloomsLevel.label,
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: currentQ.bloomsLevel.color),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              const Text("Copy-Protected", style: TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            currentQ.questionText,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Options List
                    ...currentQ.options.asMap().entries.map((entry) {
                      final optIdx = entry.key;
                      final optText = entry.value;
                      final isSelected = _selectedAnswers[_currentQuestionIndex] == optIdx;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedAnswers[_currentQuestionIndex] = optIdx;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.borderLight,
                              width: isSelected ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.surfaceSubtle,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  String.fromCharCode(65 + optIdx),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white : AppColors.textDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  optText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.primary : AppColors.textDark,
                                  ),
                                ),
                              ),
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
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (_currentQuestionIndex > 0)
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentQuestionIndex--;
                          });
                        },
                        icon: const Icon(Icons.arrow_back_ios_rounded, size: 12),
                        label: const Text("Prev", style: TextStyle(fontSize: 12)),
                      ),
                    const SizedBox(width: 8),

                    if (_currentQuestionIndex < questions.length - 1)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _currentQuestionIndex++;
                            });
                          },
                          icon: const Text("Next Question", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
                          label: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        ),
                      )
                    else
                      const Spacer(),

                    const SizedBox(width: 8),

                    ElevatedButton.icon(
                      onPressed: _confirmSubmit,
                      icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                      label: const Text("Submit Paper", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
