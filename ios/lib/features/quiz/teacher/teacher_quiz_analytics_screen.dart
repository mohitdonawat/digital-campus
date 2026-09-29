import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/quiz_model.dart';
import '../models/quiz_submission_model.dart';
import '../services/quiz_service.dart';

class TeacherQuizAnalyticsScreen extends StatelessWidget {
  final QuizModel quiz;

  const TeacherQuizAnalyticsScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Analytics: ${quiz.title}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${quiz.subject} • Dept: ${quiz.targetBranch} • Year: ${quiz.targetYear}',
              style: const TextStyle(fontSize: 11, color: AppColors.secondary),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<QuizSubmissionModel>>(
        stream: QuizService.getQuizLeaderboard(quiz.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          }

          final submissions = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Metrics Grid
                _buildMetricsGrid(submissions),
                const SizedBox(height: 20),

                // Question Analysis Header
                Row(
                  children: [
                    const Icon(Icons.analytics_rounded, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Question-by-Question Performance',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Question Cards
                if (quiz.questions.isEmpty)
                  const Text('No questions recorded for this quiz.', style: TextStyle(color: AppColors.textHint))
                else
                  ...quiz.questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final q = entry.value;
                    return _buildQuestionAnalyticsCard(index, q, submissions);
                  }),

                const SizedBox(height: 24),

                // Student Submissions Ranking List
                Row(
                  children: [
                    const Icon(Icons.leaderboard_rounded, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Student Score Breakdown (${submissions.length})',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (submissions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'No student submissions yet for this quiz.',
                        style: TextStyle(color: AppColors.textHint, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: submissions.length,
                    itemBuilder: (context, idx) {
                      final s = submissions[idx];
                      return _buildStudentRankCard(idx + 1, s);
                    },
                  ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricsGrid(List<QuizSubmissionModel> submissions) {
    final count = submissions.length;
    double avgScore = 0;
    double highestScore = 0;
    double lowestScore = 0;
    double totalNegPenalty = 0;

    if (count > 0) {
      final scores = submissions.map((s) => s.score).toList()..sort();
      lowestScore = scores.first;
      highestScore = scores.last;
      final sum = scores.fold<double>(0, (a, b) => a + b);
      avgScore = sum / count;
      totalNegPenalty = submissions.fold<double>(0, (a, b) => a + b.negativePenalty);
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard('Total Attempts', '$count Students', Icons.group_rounded, AppColors.info),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                'Class Average',
                '${avgScore.toStringAsFixed(1)} / ${quiz.totalMarks}',
                Icons.calculate_rounded,
                AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard('Highest Score', '${highestScore.toStringAsFixed(1)} M', Icons.military_tech_rounded, AppColors.success),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard('Penalty Incurred', '-${totalNegPenalty.toStringAsFixed(1)} M', Icons.warning_amber_rounded, AppColors.error),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 2),
                Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionAnalyticsCard(int index, QuizQuestion q, List<QuizSubmissionModel> submissions) {
    int totalAnswered = 0;
    int correctCount = 0;
    int wrongCount = 0;
    final optionPicks = [0, 0, 0, 0];

    for (final s in submissions) {
      final chosen = s.answers[q.id] ?? s.answers[index.toString()];
      if (chosen != null && chosen >= 0 && chosen < 4) {
        totalAnswered++;
        optionPicks[chosen]++;
        if (chosen == q.correctOptionIndex) {
          correctCount++;
        } else {
          wrongCount++;
        }
      }
    }

    final accuracy = totalAnswered > 0 ? (correctCount / totalAnswered) * 100 : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accuracy >= 60 ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.secondary.withOpacity(0.2),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  q.questionText,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (accuracy >= 60 ? AppColors.success : AppColors.error).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${accuracy.toStringAsFixed(0)}% Accuracy',
                  style: TextStyle(
                    color: accuracy >= 60 ? AppColors.success : AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Options Breakdown
          ...q.options.asMap().entries.map((optEntry) {
            final optIdx = optEntry.key;
            final optText = optEntry.value;
            final isCorrect = optIdx == q.correctOptionIndex;
            final count = optionPicks[optIdx];
            final percent = totalAnswered > 0 ? (count / totalAnswered) : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isCorrect ? AppColors.success : Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + optIdx),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: Text(
                      optText,
                      style: TextStyle(
                        color: isCorrect ? AppColors.success : Colors.white70,
                        fontSize: 12,
                        fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCorrect ? AppColors.success : AppColors.secondary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count picks',
                    style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Marking: +${q.positiveMarks} / -${q.negativeMarks}',
                style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                'Attempts: $correctCount Correct • $wrongCount Wrong',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRankCard(int rank, QuizSubmissionModel s) {
    Color rankColor = Colors.white70;
    if (rank == 1) rankColor = const Color(0xFFFFD700);
    if (rank == 2) rankColor = const Color(0xFFC0C0C0);
    if (rank == 3) rankColor = const Color(0xFFCD7F32);

    final formattedDate = DateFormat('dd MMM, hh:mm a').format(s.submittedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rank <= 3 ? rankColor.withOpacity(0.5) : Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? rankColor.withOpacity(0.2) : Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(color: rankColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.studentName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '${s.enrollmentNo} • ${s.branch} • $formattedDate',
                  style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${s.score.toStringAsFixed(1)} / ${s.totalMarks}',
                style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Row(
                children: [
                  Text('+${s.positiveScore.toStringAsFixed(1)}',
                      style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  if (s.negativePenalty > 0)
                    Text('-${s.negativePenalty.toStringAsFixed(1)}',
                        style: const TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
