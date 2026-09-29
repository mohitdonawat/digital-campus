import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/quiz_model.dart';
import '../models/quiz_submission_model.dart';
import '../services/quiz_service.dart';

class QuizLeaderboardScreen extends StatefulWidget {
  final QuizModel quiz;
  final bool isTeacher;

  const QuizLeaderboardScreen({
    super.key,
    required this.quiz,
    this.isTeacher = false,
  });

  @override
  State<QuizLeaderboardScreen> createState() => _QuizLeaderboardScreenState();
}

class _QuizLeaderboardScreenState extends State<QuizLeaderboardScreen> {
  int _eligibleCount = 0;
  bool _loadingAnalytics = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final count = await QuizService.getEligibleStudentsCount(
      targetBranch: widget.quiz.targetBranch,
      targetYear: widget.quiz.targetYear,
    );
    if (mounted) {
      setState(() {
        _eligibleCount = count;
        _loadingAnalytics = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Batch Leaderboard & Ranks',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            Text(
              '${widget.quiz.title} (${widget.quiz.targetBranch} • ${widget.quiz.targetYear})',
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
        stream: QuizService.getQuizLeaderboard(widget.quiz.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          }

          final submissions = snapshot.data ?? [];

          if (submissions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.leaderboard_rounded, color: AppColors.secondary, size: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text('No Submissions Yet',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      'Targeted students (${widget.quiz.targetBranch} - ${widget.quiz.targetYear}) have not attempted this quiz yet.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textHint, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teacher / General Analytics Banner
                _buildAnalyticsCard(submissions),

                const SizedBox(height: 20),

                // Top 3 Podium
                if (submissions.isNotEmpty) ...[
                  const Text('Top Performers 🏆',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildPodium(submissions),
                  const SizedBox(height: 24),
                ],

                // Complete Top-to-Bottom Rank Table
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Full Batch Ranking (${submissions.length})',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text('Sorted: Score ↓ / Time ↑',
                      style: TextStyle(color: AppColors.textHint, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 12),

                _buildRankList(submissions),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsCard(List<QuizSubmissionModel> submissions) {
    final int submitted = submissions.length;
    final int eligible = _eligibleCount > submitted ? _eligibleCount : submitted;
    final double participationRate = eligible > 0 ? (submitted / eligible) * 100 : 100.0;

    double avgScore = 0;
    int passCount = 0;
    if (submitted > 0) {
      final totalScore = submissions.fold<double>(0.0, (sum, s) => sum + s.score);
      avgScore = totalScore / submitted;
      passCount = submissions.where((s) => s.percentage >= 40.0).length;
    }
    final double passRate = submitted > 0 ? (passCount / submitted) * 100 : 0.0;

    final topStudent = submissions.isNotEmpty ? submissions.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.analytics_rounded, color: AppColors.secondary, size: 20),
              SizedBox(width: 8),
              Text('Target Batch Performance & Participation',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('$submitted / $eligible', 'Submitted', AppColors.info),
              _statItem('${participationRate.toStringAsFixed(0)}%', 'Turnout', AppColors.secondary),
              _statItem('${avgScore.toStringAsFixed(1)} / ${widget.quiz.totalMarks}', 'Avg Score', AppColors.warning),
              _statItem('${passRate.toStringAsFixed(0)}%', 'Pass Rate', AppColors.success),
            ],
          ),

          if (topStudent != null) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                      children: [
                        const TextSpan(text: 'Current #1 Top Scorer: ', style: TextStyle(color: AppColors.textSecondary)),
                        TextSpan(text: topStudent.studentName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                        TextSpan(text: ' (${topStudent.enrollmentNo}) - ${topStudent.score}/${topStudent.totalMarks} in ${(topStudent.timeTakenSeconds / 60).floor()}m ${topStudent.timeTakenSeconds % 60}s', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
      ],
    );
  }

  Widget _buildPodium(List<QuizSubmissionModel> submissions) {
    final rank1 = submissions.isNotEmpty ? submissions[0] : null;
    final rank2 = submissions.length > 1 ? submissions[1] : null;
    final rank3 = submissions.length > 2 ? submissions[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Rank 2 (Silver)
        Expanded(
          child: rank2 != null
              ? _podiumCard(
                  rank2,
                  2,
                  '🥈',
                  const Color(0xFFC0C0C0),
                  140,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 8),

        // Rank 1 (Gold)
        Expanded(
          child: rank1 != null
              ? _podiumCard(
                  rank1,
                  1,
                  '🥇',
                  const Color(0xFFFFD700),
                  165,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 8),

        // Rank 3 (Bronze)
        Expanded(
          child: rank3 != null
              ? _podiumCard(
                  rank3,
                  3,
                  '🥉',
                  const Color(0xFFCD7F32),
                  125,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _podiumCard(
    QuizSubmissionModel sub,
    int rank,
    String medal,
    Color medalColor,
    double height,
  ) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: medalColor.withOpacity(0.6), width: rank == 1 ? 2 : 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(medal, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            sub.studentName.split(' ').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            sub.enrollmentNo.length > 8 ? sub.enrollmentNo.substring(sub.enrollmentNo.length - 8) : sub.enrollmentNo,
            style: const TextStyle(color: AppColors.textHint, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: medalColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${sub.score} / ${sub.totalMarks}',
              style: TextStyle(color: medalColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${(sub.timeTakenSeconds / 60).floor()}m ${sub.timeTakenSeconds % 60}s',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildRankList(List<QuizSubmissionModel> submissions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: submissions.length,
      itemBuilder: (context, idx) {
        final sub = submissions[idx];
        final rank = idx + 1;

        Color rankColor = Colors.white70;
        Widget rankWidget = Text(
          '#$rank',
          style: TextStyle(color: rankColor, fontWeight: FontWeight.bold, fontSize: 14),
        );

        if (rank == 1) {
          rankColor = const Color(0xFFFFD700);
          rankWidget = const Text('🥇 #1', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14));
        } else if (rank == 2) {
          rankColor = const Color(0xFFC0C0C0);
          rankWidget = const Text('🥈 #2', style: TextStyle(color: Color(0xFFC0C0C0), fontWeight: FontWeight.bold, fontSize: 14));
        } else if (rank == 3) {
          rankColor = const Color(0xFFCD7F32);
          rankWidget = const Text('🥉 #3', style: TextStyle(color: Color(0xFFCD7F32), fontWeight: FontWeight.bold, fontSize: 14));
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: rank <= 3 ? rankColor.withOpacity(0.3) : Colors.white.withOpacity(0.05),
              width: rank <= 3 ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 50, child: rankWidget),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.studentName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sub.enrollmentNo} • ${sub.branch}',
                      style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${sub.score} / ${sub.totalMarks} (${sub.percentage.toStringAsFixed(0)}%)',
                    style: TextStyle(
                      color: rank <= 3 ? rankColor : AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 11, color: AppColors.textHint),
                      const SizedBox(width: 3),
                      Text(
                        '${(sub.timeTakenSeconds / 60).floor()}m ${sub.timeTakenSeconds % 60}s',
                        style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
