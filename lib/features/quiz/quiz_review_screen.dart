import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/quiz_models.dart';
import 'quiz_leaderboard_screen.dart';

/// 📝 Post-Exam Review & Scorecard Screen
/// Displays student score, accuracy percentage, time taken,
/// followed by question-by-question review with official textbook citations.
class QuizReviewScreen extends StatelessWidget {
  final CampusQuiz quiz;
  final QuizSubmission submission;

  const QuizReviewScreen({
    super.key,
    required this.quiz,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    final questions = quiz.questions;
    final totalMarks = quiz.totalPossibleMarks;
    final score = submission.score;
    final pct = totalMarks > 0 ? (score / totalMarks) * 100 : 0.0;
    final isPassed = pct >= 50.0;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Exam Results & Textbook Review", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: "Close",
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Scorecard Summary Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPassed
                    ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
                    : [const Color(0xFF7F1D1D), const Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: (isPassed ? Colors.green : Colors.red).withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPassed ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPassed ? "PASSED" : "REMEDIAL NEEDED",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isPassed ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    Text(
                      " / ${totalMarks.toStringAsFixed(1)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white60),
                    ),
                  ],
                ),
                Text(
                  "${pct.toStringAsFixed(1)}% Score Achieved",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF93C5FD)),
                ),
                const SizedBox(height: 16),

                // Metrics Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricItem("✅ Correct", "${submission.correctAnswersCount}", Colors.greenAccent),
                    _metricItem("❌ Wrong", "${submission.wrongAnswersCount}", Colors.redAccent),
                    _metricItem("⏳ Time Taken", submission.timeFormatted, Colors.amberAccent),
                    _metricItem("🎯 Accuracy", "${submission.accuracyPercentage.toStringAsFixed(0)}%", Colors.cyanAccent),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Action Button: View Live Class Leaderboard
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizLeaderboardScreen(
                      quiz: quiz,
                      isFacultyView: false,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.leaderboard_rounded, size: 16, color: Colors.white),
              label: const Text(
                "View Live Class Leaderboard & Rankings",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Header
          const Row(
            children: [
              Icon(Icons.assignment_turned_in_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                "DETAILED QUESTION-BY-QUESTION REVIEW",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Questions Review List
          ...questions.asMap().entries.map((entry) {
            final idx = entry.key;
            final q = entry.value;
            final hasAnswered = submission.selectedAnswers.containsKey(idx);
            final chosenOpt = hasAnswered ? submission.selectedAnswers[idx]! : -1;
            final isCorrect = hasAnswered && chosenOpt == q.correctOptionIndex;

            Color statusColor = AppColors.textMuted;
            String statusText = "Skipped (0 Marks)";
            IconData statusIcon = Icons.remove_circle_outline_rounded;

            if (hasAnswered) {
              if (isCorrect) {
                statusColor = AppColors.success;
                statusText = "Correct (+${quiz.marksPerQuestion})";
                statusIcon = Icons.check_circle_rounded;
              } else {
                statusColor = AppColors.error;
                statusText = "Incorrect (${quiz.hasNegativeMarking ? '-${quiz.negativePenalty}' : '0 Marks'})";
                statusIcon = Icons.cancel_rounded;
              }
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: statusColor.withOpacity(0.4), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question ${idx + 1}",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                      Row(
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    q.questionText,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.35),
                  ),
                  const SizedBox(height: 10),

                  // Options review
                  ...q.options.asMap().entries.map((optEntry) {
                    final oIdx = optEntry.key;
                    final oText = optEntry.value;
                    final isStudentChoice = oIdx == chosenOpt;
                    final isRightChoice = oIdx == q.correctOptionIndex;

                    Color optBg = AppColors.surfaceSubtle;
                    Color optBorder = AppColors.borderLight;
                    Color optText = AppColors.textDark;

                    if (isRightChoice) {
                      optBg = const Color(0xFF16A34A).withOpacity(0.1);
                      optBorder = const Color(0xFF16A34A);
                      optText = const Color(0xFF16A34A);
                    } else if (isStudentChoice && !isCorrect) {
                      optBg = const Color(0xFFDC2626).withOpacity(0.08);
                      optBorder = const Color(0xFFDC2626);
                      optText = const Color(0xFFDC2626);
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: optBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: optBorder),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "${String.fromCharCode(65 + oIdx)}. ",
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: optText),
                          ),
                          Expanded(
                            child: Text(
                              oText,
                              style: TextStyle(fontSize: 12, fontWeight: isRightChoice || isStudentChoice ? FontWeight.w700 : FontWeight.w500, color: optText),
                            ),
                          ),
                          if (isStudentChoice && !isCorrect)
                            const Text(" (Your Choice)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.red)),
                          if (isRightChoice)
                            const Text(" ✓ Verified", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 10),

                  // Textbook Citation Box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.menu_book_rounded, size: 12, color: AppColors.primary),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "Textbook Citation: ${q.textbookCitation}",
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          q.explanation,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                        ),
                      ],
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

  Widget _metricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white60)),
      ],
    );
  }
}
