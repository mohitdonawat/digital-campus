import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../models/quiz_model.dart';
import '../models/quiz_submission_model.dart';

class StudentQuizResultScreen extends StatelessWidget {
  final QuizModel quiz;
  final QuizSubmissionModel submission;

  const StudentQuizResultScreen({
    super.key,
    required this.quiz,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    final isPassed = submission.percentage >= 40.0;
    final isHighScorer = submission.percentage >= 80.0;

    final resultColor = isHighScorer
        ? AppColors.secondary
        : isPassed
            ? AppColors.success
            : AppColors.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Assessment Result',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Score Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: resultColor.withOpacity(0.4), width: 1.5),
              ),
              child: Column(
                children: [
                  Icon(
                    isHighScorer
                        ? Icons.emoji_events_rounded
                        : isPassed
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                    color: resultColor,
                    size: 60,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isHighScorer
                        ? 'Outstanding Performance! 🏆'
                        : isPassed
                            ? 'Assessment Completed! 🎉'
                            : 'Assessment Finished',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.title,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Score & Percentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        submission.score.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), ''),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),
                      Text(
                        ' / ${submission.totalMarks.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 22, color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${submission.percentage.toStringAsFixed(1)}% Accuracy',
                    style: TextStyle(
                      color: resultColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),

                  // Breakdown: Positive, Negative, Correct, Wrong
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricBadge('Positive', '+${submission.positiveScore.toStringAsFixed(1)}', AppColors.success),
                      if (submission.negativePenalty > 0)
                        _metricBadge('Penalty', '-${submission.negativePenalty.toStringAsFixed(1)}', AppColors.error),
                      _metricBadge('Correct', '${submission.correctCount}', AppColors.info),
                      _metricBadge('Wrong', '${submission.wrongCount}', AppColors.warning),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons: View Leaderboard
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.leaderboard,
                        arguments: {
                          'quiz': quiz,
                          'isTeacher': false,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.leaderboard_rounded),
                    label: const Text('View Leaderboard & Rank', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Question Review Header
            Row(
              children: const [
                Icon(Icons.fact_check_rounded, color: AppColors.secondary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Detailed Question Review',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Questions list
            ...quiz.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final q = entry.value;
              final chosenIndex = submission.answers[q.id] ?? submission.answers[index.toString()];
              final isCorrect = chosenIndex != null && chosenIndex == q.correctOptionIndex;
              final isUnattempted = chosenIndex == null;

              Color statusColor = isCorrect
                  ? AppColors.success
                  : isUnattempted
                      ? Colors.white38
                      : AppColors.error;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: statusColor.withOpacity(0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: statusColor.withOpacity(0.2),
                          child: Icon(
                            isCorrect
                                ? Icons.check_rounded
                                : isUnattempted
                                    ? Icons.remove_rounded
                                    : Icons.close_rounded,
                            color: statusColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Q${index + 1}. ${q.questionText}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isCorrect
                                ? '+${q.positiveMarks}'
                                : isUnattempted
                                    ? '0 M'
                                    : '-${q.negativeMarks}',
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Options Review
                    ...List.generate(q.options.length, (optIdx) {
                      final optionText = q.options[optIdx];
                      final isSelectedOption = chosenIndex == optIdx;
                      final isCorrectOption = q.correctOptionIndex == optIdx;

                      Color optColor = Colors.white70;
                      Color bgColor = Colors.transparent;

                      if (isCorrectOption) {
                        optColor = AppColors.success;
                        bgColor = AppColors.success.withOpacity(0.12);
                      } else if (isSelectedOption && !isCorrect) {
                        optColor = AppColors.error;
                        bgColor = AppColors.error.withOpacity(0.12);
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCorrectOption
                                ? AppColors.success.withOpacity(0.4)
                                : isSelectedOption
                                    ? AppColors.error.withOpacity(0.4)
                                    : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${String.fromCharCode(65 + optIdx)}. ',
                              style: TextStyle(color: optColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Expanded(
                              child: Text(
                                optionText,
                                style: TextStyle(color: optColor, fontSize: 13),
                              ),
                            ),
                            if (isCorrectOption)
                              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16)
                            else if (isSelectedOption && !isCorrect)
                              const Icon(Icons.cancel_rounded, color: AppColors.error, size: 16),
                          ],
                        ),
                      );
                    }),

                    if (q.explanation.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded, color: AppColors.secondary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Explanation: ${q.explanation}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _metricBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
      ],
    );
  }
}
