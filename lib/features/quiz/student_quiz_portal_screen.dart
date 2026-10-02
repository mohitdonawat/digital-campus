import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/quiz_models.dart';
import '../../providers/campus_provider.dart';
import 'proctored_quiz_screen.dart';
import 'quiz_review_screen.dart';
import 'quiz_leaderboard_screen.dart';

/// 🎓 Student Quiz & Assessment Portal
/// Shows targeted quizzes matching student's branch & semester,
/// allows entering proctored test sandbox, and reviewing past scorecards.
class StudentQuizPortalScreen extends StatelessWidget {
  const StudentQuizPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final student = provider.student;
    final allQuizzes = provider.quizzes;

    // Filter quizzes targeted for this student's branch & semester
    final myTargetedQuizzes = allQuizzes.where((q) {
      final branchMatch = q.targetBranch == "All" || q.targetBranch == student.branch || student.branch.contains(q.targetBranch);
      final semMatch = q.targetSemester == student.semester;
      return branchMatch && semMatch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Assessment & Quiz Portal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(
              "${student.name} • ${student.branch} Sem ${student.semester}",
              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.quiz_rounded, color: Color(0xFFA5B4FC), size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Targeted Academic Assessments",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "Quizzes prepared by your faculty from curriculum textbooks. Proctored environment with instant solutions.",
                        style: TextStyle(fontSize: 11, color: Color(0xFFC7D2FE), height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ACTIVE TESTS FOR YOUR BATCH (${myTargetedQuizzes.length})",
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${student.branch} • Sem ${student.semester}",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Quizzes List
          if (myTargetedQuizzes.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Center(
                child: Text("No active quizzes scheduled for your branch at this moment.", style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ...myTargetedQuizzes.map((quiz) {
              final submission = provider.getStudentSubmission(quiz.id, student.id);
              final isAttempted = submission != null;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isAttempted ? const Color(0xFF10B981) : AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: isAttempted ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isAttempted ? "SUBMITTED" : "READY TO START",
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isAttempted ? const Color(0xFF047857) : const Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.alarm_rounded, size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text("${quiz.durationMinutes} Mins", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quiz.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${quiz.subjectName} (${quiz.subjectCode}) • ${quiz.questions.length} Questions",
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),

                    // Rules badges
                    Row(
                      children: [
                        _pill("+${quiz.marksPerQuestion.toStringAsFixed(1)} Marks/Q", AppColors.success),
                        const SizedBox(width: 6),
                        if (quiz.hasNegativeMarking)
                          _pill("Negative -${quiz.negativePenalty}", AppColors.error)
                        else
                          _pill("No Negative Marking", AppColors.textMuted),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(color: AppColors.borderLight, height: 1),
                    const SizedBox(height: 10),

                    // Action buttons
                    if (isAttempted)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Score: ${submission.score.toStringAsFixed(1)} / ${quiz.totalPossibleMarks.toStringAsFixed(0)}",
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF047857)),
                              ),
                              Text(
                                "Accuracy: ${submission.accuracyPercentage.toStringAsFixed(0)}% • ${submission.timeFormatted}",
                                style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuizLeaderboardScreen(quiz: quiz, isFacultyView: false),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  side: const BorderSide(color: AppColors.primary),
                                ),
                                child: const Text("Ranks", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuizReviewScreen(quiz: quiz, submission: submission),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                                child: const Text("Review", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            _showStartExamWarningDialog(context, quiz);
                          },
                          icon: const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                          label: const Text(
                            "Start Proctored Test Now",
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showStartExamWarningDialog(BuildContext context, CampusQuiz quiz) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text("Proctored Exam Instructions", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            _instructionRow("⏱️ Duration:", "${quiz.durationMinutes} Minutes strictly timed."),
            _instructionRow("🔒 Anti-Cheat:", "Window exit & app switching is strictly monitored. 2 exits will auto-submit!"),
            _instructionRow("🚫 Copy-Paste:", "Question text is locked and cannot be copied."),
            _instructionRow("📊 Marking:", "+${quiz.marksPerQuestion.toStringAsFixed(1)} for correct, ${quiz.hasNegativeMarking ? '-${quiz.negativePenalty}' : '0'} for incorrect."),
            const SizedBox(height: 8),
            const Text(
              "Are you ready to begin? Ensure you have stable focus.",
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Not Now"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProctoredQuizScreen(quiz: quiz),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            child: const Text("Enter Proctored Test", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _instructionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(width: 6),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
