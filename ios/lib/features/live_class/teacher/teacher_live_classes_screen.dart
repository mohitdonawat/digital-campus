import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../models/live_class_model.dart';
import '../services/live_class_service.dart';
import '../widgets/live_class_card.dart';
import 'teacher_schedule_class_screen.dart';

class TeacherLiveClassesScreen extends StatefulWidget {
  const TeacherLiveClassesScreen({super.key});

  @override
  State<TeacherLiveClassesScreen> createState() => _TeacherLiveClassesScreenState();
}

class _TeacherLiveClassesScreenState extends State<TeacherLiveClassesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openScheduleScreen({LiveClassModel? classToEdit}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherScheduleClassScreen(classToEdit: classToEdit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.podcasts_rounded, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 8),
            Text(
              'Live Class Studio',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _openScheduleScreen(),
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.secondary, size: 24),
            tooltip: 'Schedule New Class',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: '🔴 UPCOMING & LIVE'),
            Tab(text: '📼 COMPLETED HISTORY'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openScheduleScreen(),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Schedule Class', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<LiveClassModel>>(
        stream: LiveClassService.getTeacherClasses(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading classes: ${snapshot.error}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          final all = snapshot.data ?? [];
          final activeClasses = all.where((c) => c.isLive || c.isUpcoming).toList();
          final completedClasses = all.where((c) => c.isCompleted || c.isCancelled).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(activeClasses, isActiveTab: true),
              _buildList(completedClasses, isActiveTab: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<LiveClassModel> list, {required bool isActiveTab}) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Icon(
                  isActiveTab ? Icons.video_call_outlined : Icons.history_rounded,
                  color: AppColors.textSecondary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isActiveTab ? 'No Scheduled or Live Classes' : 'No Completed Classes Yet',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                isActiveTab
                    ? 'Tap the button below to schedule your first live session for students.'
                    : 'Classes you conduct will show up here along with recording links.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
              if (isActiveTab) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _openScheduleScreen(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Schedule Class Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return LiveClassCard(
          liveClass: item,
          isTeacher: true,
          onEdit: () => _openScheduleScreen(classToEdit: item),
        );
      },
    );
  }
}
