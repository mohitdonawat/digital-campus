import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../models/quiz_model.dart';
import '../models/quiz_submission_model.dart';
import '../services/quiz_service.dart';

class StudentQuizzesScreen extends StatefulWidget {
  const StudentQuizzesScreen({super.key});

  @override
  State<StudentQuizzesScreen> createState() => _StudentQuizzesScreenState();
}

class _StudentQuizzesScreenState extends State<StudentQuizzesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStudentData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted) {
        setState(() {
          _studentData = doc.data();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branch = _studentData?['branch'] ?? 'CSE';
    final year = _studentData?['year'] ?? '3rd Year';
    final sem = _studentData?['semester'] ?? '5th Sem';
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Assessments & Quizzes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Available Quizzes'),
            Tab(text: 'Completed & Results'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          : StreamBuilder<List<QuizModel>>(
              stream: QuizService.getStudentQuizzes(
                branch: branch,
                year: year,
                semester: sem,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
                }

                final allQuizzes = snapshot.data ?? [];

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('quiz_submissions')
                      .where('studentUid', isEqualTo: myUid)
                      .snapshots(),
                  builder: (context, subSnap) {
                    final submittedDocs = subSnap.data?.docs ?? [];
                    final submittedMap = <String, QuizSubmissionModel>{};
                    for (final doc in submittedDocs) {
                      final sub = QuizSubmissionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                      submittedMap[sub.quizId] = sub;
                    }

                    final available = allQuizzes.where((q) => !submittedMap.containsKey(q.id)).toList();
                    final completed = allQuizzes.where((q) => submittedMap.containsKey(q.id)).toList();

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAvailableList(available),
                        _buildCompletedList(completed, submittedMap),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildAvailableList(List<QuizModel> quizzes) {
    if (quizzes.isEmpty) {
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
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('All Caught Up! 🎉',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                'No pending quizzes for your batch right now. Check back later when your teachers publish new assessments.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textHint, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.quiz_rounded, color: AppColors.secondary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${quiz.subject} • by ${quiz.teacherName}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (quiz.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  quiz.description,
                  style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _chip(Icons.timer_rounded, '${quiz.durationMinutes} Mins', AppColors.warning),
                  const SizedBox(width: 8),
                  _chip(Icons.help_outline_rounded, '${quiz.questions.length} Questions', AppColors.info),
                  const SizedBox(width: 8),
                  _chip(Icons.stars_rounded, '${quiz.totalMarks} Marks', AppColors.secondary),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _startQuizConfirmation(quiz);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Assessment Now', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedList(List<QuizModel> quizzes, Map<String, QuizSubmissionModel> submissionMap) {
    if (quizzes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.history_edu_rounded, color: AppColors.textHint, size: 48),
              SizedBox(height: 12),
              Text('No Completed Quizzes',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Your attempted assessments and leaderboard ranks will appear here.',
                style: TextStyle(color: AppColors.textHint, fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        final sub = submissionMap[quiz.id]!;

        final isPassed = sub.percentage >= 40.0;
        final color = isPassed ? AppColors.success : AppColors.error;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          quiz.subject,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Text(
                      '${sub.score} / ${sub.totalMarks} (${sub.percentage.toStringAsFixed(0)}%)',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time: ${(sub.timeTakenSeconds / 60).floor()}m ${sub.timeTakenSeconds % 60}s',
                    style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.studentQuizResult,
                            arguments: {
                              'quiz': quiz,
                              'submission': sub,
                            },
                          );
                        },
                        icon: const Icon(Icons.analytics_outlined, size: 16, color: AppColors.secondary),
                        label: const Text('Review', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
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
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        icon: const Icon(Icons.leaderboard_rounded, size: 14, color: AppColors.secondary),
                        label: const Text('Leaderboard', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

  void _startQuizConfirmation(QuizModel quiz) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.timer_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Start Assessment?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quiz: ${quiz.title}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('• Duration: ${quiz.durationMinutes} Minutes (Strict Timer)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text('• Questions: ${quiz.questions.length}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text('• Total Marks: ${quiz.totalMarks}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            const Text(
              '⚠️ Once started, the timer will not pause. The quiz will auto-submit when the countdown expires.',
              style: TextStyle(color: AppColors.warning, fontSize: 12, height: 1.3),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(
                context,
                AppRoutes.studentAttemptQuiz,
                arguments: {
                  'quiz': quiz,
                  'studentData': _studentData,
                },
              );
            },
            child: const Text('Begin Test', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
