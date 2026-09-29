import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/notification_feed_modal.dart';
import '../../features/attendance/models/attendance_model.dart';
import '../../features/attendance/services/attendance_service.dart';
import '../../features/announcements/models/announcement_model.dart';
import '../../features/announcements/services/announcement_service.dart';
import '../../features/announcements/screens/announcements_feed_screen.dart';
import '../../features/live_class/models/live_class_model.dart';
import '../../features/live_class/services/live_class_service.dart';
import '../../features/id_card/widgets/student_photo_widget.dart';
import '../../features/chat/models/chat_group_model.dart';
import '../../features/chat/services/chat_service.dart';
import '../../features/chat/screens/group_chat_room_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted) {
      setState(() {
        _studentData = doc.data();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildLeaderboardTab(),
          const AnnouncementsFeedScreen(isFaculty: false),
          _buildStudentProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        // Fixed Clean Pinned AppBar (Never squashes or collides)
        SliverAppBar(
          pinned: true,
          floating: false,
          elevation: 0,
          toolbarHeight: 65,
          backgroundColor: AppColors.surface,
          leadingWidth: 56,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary.withOpacity(0.6), width: 1.5),
                ),
                child: ClipOval(
                  child: Image.asset('assets/logo.webp', fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'IES E-CAMPUS',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.4), width: 0.8),
                    ),
                    child: const Text(
                      'STUDENT OS',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'IES University • Excellence in Education',
                style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.55), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                final branch = _studentData?['branch'] ?? 'CSE';
                final year = _studentData?['year'] ?? '3rd Year';
                NotificationFeedModal.show(context, studentUid: uid, branch: branch, year: year);
              },
              icon: const Icon(Icons.notifications_active_rounded, color: AppColors.secondary, size: 22),
              tooltip: 'Campus Notifications',
            ),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.aboutDeveloper),
              icon: const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 21),
              tooltip: 'About Developer',
            ),
            const SizedBox(width: 6),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // 1. Smart Student Identity Card
              _buildStudentIdentityCard(),

              const SizedBox(height: 16),

              // 2. Real-time Live Class Banner (High Priority)
              _buildActiveLiveClassBanner(),

              const SizedBox(height: 6),

              // 3. Smart Quick Services Hub (4-Column Clean Layout)
              _buildServicesHub(),

              const SizedBox(height: 22),

              // 4. Live Class Discussion Groups Box
              _buildClassGroupsBox(),

              const SizedBox(height: 22),

              // 5. Live Announcements & Notices Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('📢 Latest Announcements',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                  TextButton(
                    onPressed: () => setState(() => _selectedIndex = 2),
                    child: const Text('View All', style: TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),


              // Live Stream of targeted announcements for this student
              StreamBuilder<List<AnnouncementModel>>(
                stream: AnnouncementService.getStudentAnnouncements(
                  branch: _studentData?['branch'] ?? '',
                  year: _studentData?['year'] ?? '',
                  semester: _studentData?['semester'] ?? '1st Sem',
                  section: _studentData?['section'] ?? '',
                ),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: AppColors.secondary),
                      ),
                    );
                  }

                  final notices = snap.data ?? [];
                  if (notices.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text('No announcements published yet.',
                          style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                      ),
                    );
                  }

                  return Column(
                    children: notices.take(3).map((a) {
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.announcements, arguments: false),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: AppColors.cardGradient,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: a.priority == 'URGENT'
                                  ? AppColors.error.withOpacity(0.5)
                                  : AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (a.priority == 'URGENT' ? AppColors.error : AppColors.secondary).withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  a.fileUrl != null ? Icons.picture_as_pdf_rounded : Icons.campaign_rounded,
                                  color: a.priority == 'URGENT' ? AppColors.error : AppColors.secondary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${a.authorDisplay} • ${a.message}',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 12, color: AppColors.textHint),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Developer & Architect Tribute Banner
              _buildDeveloperBanner(),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildClassGroupsBox() {
    final branch = _studentData?['branch'] ?? _studentData?['department'] ?? 'Computer Science & Engineering';
    final year = _studentData?['year'] ?? '1st Year';
    final semester = _studentData?['semester'] ?? '1st Sem';
    final section = _studentData?['section'] ?? 'A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('💬 My Class Groups & Doubts',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.discussionGroups, arguments: false),
              child: const Text('View All', style: TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<ChatGroupModel>>(
          stream: ChatService.getGroupsForStudent(
            department: branch,
            year: year,
            semester: semester,
            section: section,
          ),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppColors.secondary),
                ),
              );
            }

            final groups = snap.data ?? [];
            if (groups.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.forum_outlined, color: AppColors.secondary, size: 26),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('No class group active yet. Tap View All to see college-wide discussion channels.',
                          style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.discussionGroups, arguments: false),
                      child: const Text('Explore', style: TextStyle(color: AppColors.secondary)),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: groups.take(2).map((g) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.groups_rounded, color: AppColors.secondary, size: 20),
                    ),
                    title: Text(
                      g.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      g.lastMessage != null
                          ? '${g.lastMessageSender}: ${g.lastMessage}'
                          : '${g.targetBadge} • Tap to join chat',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textHint),
                    onTap: () {
                      final name = _studentData?['name'] ?? 'Student';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupChatRoomScreen(
                            group: g,
                            currentUserRole: 'student',
                            currentUserName: name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStudentIdentityCard() {
    final name = _studentData?['name'] ?? 'Student';
    final branch = _studentData?['branch'] ?? 'CSE';
    final year = _studentData?['year'] ?? '3rd Year';
    final semester = _studentData?['semester'] ?? '1st Sem';
    final section = _studentData?['section'] ?? 'A';
    final rollNo = _studentData?['rollNo'] ?? '-';
    final enrollNo = _studentData?['enrollmentNo'] ?? '-';

    return StreamBuilder<List<AttendanceRecordModel>>(
      stream: AttendanceService.getStudentAttendanceHistory(
        studentUid: FirebaseAuth.instance.currentUser?.uid,
        studentEnrollment: enrollNo.toString(),
        studentRollNo: rollNo.toString(),
        branch: branch,
        year: year,
        semester: semester,
        section: section,
      ),
      builder: (context, snap) {
        final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        final records = snap.data ?? [];
        int total = 0;
        int present = 0;

        for (final r in records) {
          String? status;
          if (r.statusMap.containsKey(myUid)) {
            status = r.statusMap[myUid];
          } else if (r.studentDetails.isNotEmpty) {
            for (final entry in r.studentDetails.entries) {
              final dEnroll = entry.value['enrollmentNo'] ?? '';
              final dRoll = entry.value['rollNo'] ?? '';
              if ((enrollNo.isNotEmpty && dEnroll.toLowerCase() == enrollNo.toLowerCase()) ||
                  (rollNo.isNotEmpty && dRoll.toLowerCase() == rollNo.toLowerCase())) {
                status = r.statusMap[entry.key];
                break;
              }
            }
          }
          if (status == null && r.statusMap.isNotEmpty) {
            status = r.statusMap.values.first;
          }

          if (status != null) {
            total++;
            if (status == 'P') present++;
          }
        }

        final double pct = total > 0 ? (present / total) * 100 : 0.0;
        final String displayPct = total > 0 ? '${pct.toStringAsFixed(0)}%' : 'N/A';
        final Color attColor = pct >= 75 ? const Color(0xFF10B981) : const Color(0xFFEF4444);

        final photoUrl = _studentData?['profileImageUrl']?.toString() ?? '';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await Navigator.pushNamed(context, AppRoutes.studentIdCard);
              _loadStudentData();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF1E1B4B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary.withOpacity(0.4), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.secondary, width: 1.8),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.surface,
                          child: ClipOval(
                            child: photoUrl.isNotEmpty
                                ? StudentPhotoWidget(
                                    photoUrlOrBase64: photoUrl,
                                    width: 44,
                                    height: 44,
                                    borderRadius: 22,
                                  )
                                : Text(
                                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'S',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded, color: AppColors.secondary, size: 16),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$branch • $year ($semester)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.75),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.secondary.withOpacity(0.35)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.badge_rounded, color: AppColors.secondary, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'ID CARD',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Container(height: 1, color: Colors.white.withOpacity(0.1)),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _metricPill(icon: Icons.tag_rounded, label: 'Roll No', value: rollNo.toString()),
                      const SizedBox(width: 8),
                      _metricPill(icon: Icons.meeting_room_rounded, label: 'Section', value: section.toString()),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.studentAttendance),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: attColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: attColor.withOpacity(0.35), width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.fact_check_rounded, size: 15, color: attColor),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Attendance',
                                          style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.6)), maxLines: 1),
                                      Text(displayPct,
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: attColor)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Lanyard Card Direct Access Strip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: AppColors.secondary, size: 13),
                            const SizedBox(width: 6),
                            Text(
                              'Official Hanging Lanyard ID • Tap to View & Download',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.secondary, size: 11),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _metricPill({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.secondary),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.55)), maxLines: 1),
                  Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesHub() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Campus Services & Hub',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('14 Services',
                  style: TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.88,
            crossAxisSpacing: 8,
            mainAxisSpacing: 14,
            children: [
              _serviceItem(
                label: 'Sem Register',
                icon: Icons.app_registration_rounded,
                color: const Color(0xFF818CF8),
                isHot: true,
                onTap: () => Navigator.pushNamed(context, AppRoutes.studentSemesterRegistration),
              ),
              _serviceItem(
                label: 'Live Class',
                icon: Icons.podcasts_rounded,
                color: const Color(0xFFEF4444),
                isHot: true,
                onTap: () => Navigator.pushNamed(context, AppRoutes.studentLiveClasses),
              ),
              _serviceItem(
                label: 'ID Card',
                icon: Icons.badge_rounded,
                color: const Color(0xFFF59E0B),
                isHot: true,
                onTap: () async {
                  await Navigator.pushNamed(context, AppRoutes.studentIdCard);
                  _loadStudentData();
                },
              ),
              _serviceItem(
                label: 'Timetable',
                icon: Icons.calendar_month_rounded,
                color: const Color(0xFFEC4899),
                onTap: () => Navigator.pushNamed(context, AppRoutes.studentTimetable),
              ),
              _serviceItem(
                label: 'Attendance',
                icon: Icons.fact_check_rounded,
                color: const Color(0xFF10B981),
                onTap: () => Navigator.pushNamed(context, AppRoutes.studentAttendance),
              ),
              _serviceItem(
                label: 'Library',
                icon: Icons.library_books_rounded,
                color: const Color(0xFF06B6D4),
                onTap: () => Navigator.pushNamed(context, AppRoutes.studentLibrary),
              ),
              _serviceItem(
                label: 'Groups',
                icon: Icons.forum_rounded,
                color: const Color(0xFF34D399),
                onTap: () => Navigator.pushNamed(context, AppRoutes.discussionGroups, arguments: false),
              ),
              _serviceItem(
                label: 'Quizzes',
                icon: Icons.quiz_rounded,
                color: AppColors.secondary,
                onTap: () => Navigator.pushNamed(context, AppRoutes.studentQuiz),
              ),
              _serviceItem(
                label: 'Assignments',
                icon: Icons.assignment_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () => Navigator.pushNamed(context, AppRoutes.studentAssignments),
              ),
              _serviceItem(
                label: 'Bonafide',
                icon: Icons.card_membership_rounded,
                color: const Color(0xFF8B5CF6),
                onTap: () => Navigator.pushNamed(context, AppRoutes.studentBonafide),
              ),
              _serviceItem(
                label: 'Grievance',
                icon: Icons.support_agent_rounded,
                color: const Color(0xFFF43F5E),
                onTap: () => Navigator.pushNamed(context, AppRoutes.studentGrievance),
              ),
              _serviceItem(
                label: 'Hall of Fame',
                icon: Icons.emoji_events_rounded,
                color: const Color(0xFFFBBF24),
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _serviceItem(
                label: 'Notices',
                icon: Icons.campaign_rounded,
                color: const Color(0xFF38BDF8),
                onTap: () => setState(() => _selectedIndex = 2),
              ),
              _serviceItem(
                label: 'Developer',
                icon: Icons.code_rounded,
                color: const Color(0xFFA855F7),
                onTap: () => Navigator.pushNamed(context, AppRoutes.aboutDeveloper),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isHot = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: color.withOpacity(0.3), width: 1.2),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              if (isHot)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('LIVE',
                      style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _noticeCard(String title, String desc, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveLiveClassBanner() {
    final branch = _studentData?['branch'] ?? 'CSE';
    final year = _studentData?['year'] ?? '3rd Year';
    final semester = _studentData?['semester'] ?? '1st Sem';
    final section = _studentData?['section'] ?? 'A';

    return StreamBuilder<List<LiveClassModel>>(
      stream: LiveClassService.getActiveLiveClassesForStudent(
        branch: branch,
        year: year,
        semester: semester,
        section: section,
      ),
      builder: (context, snap) {
        final active = snap.data ?? [];
        if (active.isEmpty) return const SizedBox.shrink();

        final current = active.first;
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7F1D1D), Color(0xFF450A0A), Color(0xFF1E1B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 8),
                        SizedBox(width: 6),
                        Text(
                          'LIVE CLASS IN PROGRESS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    current.subject,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                current.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${current.teacherDisplay} • ${current.platformName}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.studentLiveClasses),
                  icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                  label: const Text(
                    'JOIN LIVE CLASS NOW',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeveloperBanner() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.aboutDeveloper),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E1065), Color(0xFF1E1B4B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondary.withOpacity(0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.15),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF6366F1)],
                ),
              ),
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.surface,
                child: Text(
                  'MD',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Mr. Mohit Donawat',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.verified_rounded, color: AppColors.secondary, size: 14),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Solo Founder & CEO • Architect of WILDUS & IES E Campus',
                    style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'IES University • BCA 3rd Sem • Tap to View Profile',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.secondary, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: AppColors.secondary, size: 22),
            SizedBox(width: 8),
            Text('Campus Leaderboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'student')
            .where('isApproved', isEqualTo: true)
            .limit(25)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('No student records found.', style: TextStyle(color: AppColors.textSecondary)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Student';
              final branch = data['branch'] ?? 'CSE';
              final sem = data['semester'] ?? '1st Sem';
              final roll = data['rollNo'] ?? '-';
              final rank = i + 1;

              Color rankColor = Colors.white70;
              IconData? rankIcon;
              if (rank == 1) {
                rankColor = const Color(0xFFF59E0B);
                rankIcon = Icons.military_tech_rounded;
              } else if (rank == 2) {
                rankColor = const Color(0xFF94A3B8);
                rankIcon = Icons.military_tech_rounded;
              } else if (rank == 3) {
                rankColor = const Color(0xFFB45309);
                rankIcon = Icons.military_tech_rounded;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: rank <= 3 ? rankColor.withOpacity(0.4) : Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      alignment: Alignment.center,
                      child: rankIcon != null
                          ? Icon(rankIcon, color: rankColor, size: 24)
                          : Text('#$rank', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: rankColor.withOpacity(0.2),
                      child: Text(
                        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'S',
                        style: TextStyle(color: rankColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('$branch • $sem • Roll: $roll', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Top Rank', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStudentProfileTab() {
    final name = _studentData?['name'] ?? 'Student';
    final email = _studentData?['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
    final branch = _studentData?['branch'] ?? 'CSE';
    final year = _studentData?['year'] ?? '3rd Year';
    final semester = _studentData?['semester'] ?? '1st Sem';
    final section = _studentData?['section'] ?? 'A';
    final rollNo = _studentData?['rollNo'] ?? '-';
    final enrollNo = _studentData?['enrollmentNo'] ?? '-';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar & Name Card with Photo Support
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.secondary.withOpacity(0.2),
                      child: ClipOval(
                        child: (_studentData?['profileImageUrl'] != null &&
                                _studentData!['profileImageUrl'].toString().isNotEmpty)
                            ? StudentPhotoWidget(
                                photoUrlOrBase64: _studentData!['profileImageUrl'],
                                width: 72,
                                height: 72,
                                borderRadius: 36,
                              )
                            : Text(
                                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'S',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.secondary),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Verified Student', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () async {
                                await Navigator.pushNamed(context, AppRoutes.editStudentProfile);
                                _loadStudentData();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.secondary.withOpacity(0.4), width: 0.8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_rounded, color: AppColors.secondary, size: 10),
                                    SizedBox(width: 3),
                                    Text('Edit Photo', style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Official Lanyard Student ID Card Feature Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary.withOpacity(0.5), width: 1.2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.badge_rounded, color: AppColors.secondary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Official Lanyard ID Card',
                          style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Verified Seal Stamp & Registrar Sign • Download High-Res PNG & PDF',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.pushNamed(context, AppRoutes.studentIdCard);
                      _loadStudentData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('View Card', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Semester Registration Form Feature Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.4), width: 1.2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF818CF8).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.app_registration_rounded, color: Color(0xFFA5B4FC), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Semester Registration Form',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Auto-filled Profile • SGPA/CGPA & Achievements • Official RGPV PDF',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.studentSemesterRegistration),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF818CF8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Open Form', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Academic Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Academic & Card Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      IconButton(
                        onPressed: () async {
                          await Navigator.pushNamed(context, AppRoutes.editStudentProfile);
                          _loadStudentData();
                        },
                        icon: const Icon(Icons.edit_note_rounded, color: AppColors.secondary, size: 22),
                        tooltip: 'Edit Profile',
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 16),
                  _profileInfoRow('Roll Number', rollNo.toString(), Icons.numbers_rounded),
                  _profileInfoRow('Enrollment No', enrollNo.toString(), Icons.badge_rounded),
                  _profileInfoRow('Department / Branch', branch, Icons.school_rounded),
                  _profileInfoRow('Year & Semester', '$year • $semester', Icons.calendar_today_rounded),
                  _profileInfoRow('Section', section, Icons.class_rounded),
                  _profileInfoRow('Blood Group', _studentData?['bloodGroup'] ?? 'B+', Icons.bloodtype_rounded),
                  if (_studentData?['dob'] != null && _studentData!['dob'].toString().isNotEmpty)
                    _profileInfoRow('Date of Birth', _studentData!['dob'].toString(), Icons.cake_rounded),
                  if (_studentData?['fatherName'] != null && _studentData!['fatherName'].toString().isNotEmpty)
                    _profileInfoRow("Father's Name", _studentData!['fatherName'].toString(), Icons.family_restroom_rounded),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // About Developer & Architect Navigation Tile
            _buildDeveloperBanner(),

            const SizedBox(height: 16),

            // Logout Action
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: const Text('Logout Account', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _profileInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondary, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.leaderboard_rounded), label: 'Leaderboard'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Notices'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Logout?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textHint)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.roleSelect);
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
