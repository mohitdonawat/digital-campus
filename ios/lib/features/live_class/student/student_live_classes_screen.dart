import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../models/live_class_model.dart';
import '../services/live_class_service.dart';
import '../widgets/live_class_card.dart';

class StudentLiveClassesScreen extends StatefulWidget {
  const StudentLiveClassesScreen({super.key});

  @override
  State<StudentLiveClassesScreen> createState() => _StudentLiveClassesScreenState();
}

class _StudentLiveClassesScreenState extends State<StudentLiveClassesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _studentData;
  bool _isLoadingProfile = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStudentProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoadingProfile = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted && doc.exists) {
        setState(() {
          _studentData = doc.data();
          _isLoadingProfile = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingProfile = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
      );
    }

    final branch = _studentData?['branch'] ?? 'CSE';
    final year = _studentData?['year'] ?? '3rd Year';
    final semester = _studentData?['semester'] ?? '5th Sem';
    final section = _studentData?['section'] ?? 'A';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.podcasts_rounded, color: Color(0xFFEF4444), size: 20),
                SizedBox(width: 8),
                Text(
                  'Live Classes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            Text(
              'Online Lectures & Real-time Sessions',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFEF4444),
              indicatorWeight: 3,
              labelColor: const Color(0xFFEF4444),
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, color: Color(0xFFEF4444), size: 8),
                      SizedBox(width: 6),
                      Text('LIVE NOW'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule_rounded, size: 14),
                      SizedBox(width: 6),
                      Text('UPCOMING'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline_rounded, size: 14),
                      SizedBox(width: 6),
                      Text('RECORDED'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<LiveClassModel>>(
        stream: LiveClassService.getStudentClasses(
          branch: branch,
          year: year,
          semester: semester,
          section: section,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading live classes: ${snapshot.error}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          final allRelevant = snapshot.data ?? [];
          final filtered = _searchQuery.isEmpty
              ? allRelevant
              : allRelevant.where((c) {
                  final q = _searchQuery.toLowerCase();
                  return c.title.toLowerCase().contains(q) ||
                      c.subject.toLowerCase().contains(q) ||
                      c.teacherName.toLowerCase().contains(q);
                }).toList();

          final liveList = filtered.where((c) => c.isLive).toList();
          final upcomingList = filtered.where((c) => c.isUpcoming).toList();
          final recordedList = filtered.where((c) => c.isCompleted).toList();

          return Column(
            children: [
              // Top Batch Badge Bar & Search
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                color: AppColors.surface.withOpacity(0.5),
                child: Column(
                  children: [
                    // Target Batch Info Pill
                    Row(
                      children: [
                        const Icon(Icons.school_rounded, color: AppColors.secondary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your Batch: $branch • $year ($semester) • Sec $section',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${allRelevant.length} Classes',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Search box
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search by subject, topic or teacher...',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Colors.white60, size: 16),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildClassesList(
                      liveList,
                      emptyTitle: 'No Live Classes Right Now',
                      emptySubtitle:
                          'Teachers haven\'t started any live stream for your batch yet. Check the "UPCOMING" tab for scheduled lectures.',
                      emptyIcon: Icons.podcasts_rounded,
                      isLiveTab: true,
                    ),
                    _buildClassesList(
                      upcomingList,
                      emptyTitle: 'No Upcoming Scheduled Classes',
                      emptySubtitle:
                          'All upcoming classes scheduled by faculty for your branch and semester will be listed here.',
                      emptyIcon: Icons.calendar_today_rounded,
                    ),
                    _buildClassesList(
                      recordedList,
                      emptyTitle: 'No Recorded Classes Yet',
                      emptySubtitle:
                          'Completed classes with recorded video links will appear here so you can re-watch lectures anytime.',
                      emptyIcon: Icons.video_library_rounded,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClassesList(
    List<LiveClassModel> list, {
    required String emptyTitle,
    required String emptySubtitle,
    required IconData emptyIcon,
    bool isLiveTab = false,
  }) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLiveTab ? const Color(0xFFEF4444).withOpacity(0.2) : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Icon(
                  emptyIcon,
                  color: isLiveTab ? const Color(0xFFEF4444).withOpacity(0.6) : AppColors.textSecondary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return LiveClassCard(
          liveClass: list[index],
          isTeacher: false,
        );
      },
    );
  }
}
