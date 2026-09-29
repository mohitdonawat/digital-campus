import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../features/announcements/screens/announcements_feed_screen.dart';
import '../../features/attendance/admin/admin_attendance_report_screen.dart';
import '../../features/chat/models/chat_group_model.dart';
import '../../features/chat/services/chat_service.dart';
import '../../features/chat/screens/group_chat_room_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _teacherData;
  int _pendingStudentsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final pendingSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('isApproved', isEqualTo: false)
        .get();

    if (mounted) {
      setState(() {
        _teacherData = doc.data();
        _pendingStudentsCount = pendingSnap.docs.length;
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
          const AdminAttendanceReportScreen(),
          const AnnouncementsFeedScreen(isFaculty: true),
          _buildTeacherProfileTab(),
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
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4), width: 0.8),
                    ),
                    child: const Text(
                      'FACULTY OS',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'IES University • Faculty Management',
                style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.55), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.aboutDeveloper),
              icon: const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 21),
              tooltip: 'About Developer',
            ),
            IconButton(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 21),
              tooltip: 'Logout',
            ),
            const SizedBox(width: 6),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // 1. Hero Faculty Identity Card
              _buildFacultyIdentityCard(),

              const SizedBox(height: 16),

              // 2. Pending students alert banner
              if (_pendingStudentsCount > 0) ...[
                _pendingAlert(),
                const SizedBox(height: 16),
              ],

              // 3. Smart 4-Column Faculty Services Hub
              _buildFacultyServicesHub(),

              const SizedBox(height: 22),

              // 4. Live Class Discussion Groups Box
              _buildClassGroupsBox(),

              const SizedBox(height: 22),

              // Approve students section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Approve Students',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.teacherApproveStudents),
                    child: const Text('View All', style: TextStyle(color: AppColors.secondary)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _buildPendingStudentsList(),

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

  Widget _pendingAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.pending_actions_rounded, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_pendingStudentsCount Student${_pendingStudentsCount > 1 ? 's' : ''} Pending Approval',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const Text('Tap to review and approve', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.teacherApproveStudents),
            child: const Text('Review', style: TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }

  Widget _buildClassGroupsBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('💬 Class Discussion Groups',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.secondary, size: 20),
                  tooltip: 'Create Group',
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.createChatGroup),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.discussionGroups, arguments: true),
                  child: const Text('View All', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<ChatGroupModel>>(
          stream: ChatService.getAllGroups(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppColors.secondary),
                ),
              );
            }
            final groups = snapshot.data ?? [];
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
                    const Icon(Icons.forum_outlined, color: AppColors.secondary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('No Class Groups Created',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(height: 2),
                          Text('Create a group for your branch to answer doubts.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.createChatGroup),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('+ Create', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: groups.take(3).map((g) {
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
                          : g.targetBadge,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textHint),
                    onTap: () {
                      final name = _teacherData?['name'] ?? 'Faculty';
                      final title = _teacherData?['title'] ?? 'Prof';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupChatRoomScreen(
                            group: g,
                            currentUserRole: 'teacher',
                            currentUserName: name,
                            currentUserTitle: title,
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

  Widget _buildPendingStudentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('isApproved', isEqualTo: false)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('No pending students', style: TextStyle(color: AppColors.textHint)),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.warning.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(
                      (data['name'] ?? 'S').substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['name'] ?? 'Unknown',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                        Text('${data['branch'] ?? ''} • ${data['year'] ?? ''} • Roll: ${data['rollNo'] ?? ''}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _approveStudent(doc.id),
                    icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                  ),
                  IconButton(
                    onPressed: () => _rejectStudent(doc.id),
                    icon: const Icon(Icons.cancel_rounded, color: AppColors.error),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _approveStudent(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'isApproved': true});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student approved! ✅'), backgroundColor: AppColors.success),
      );
      _loadData();
    }
  }

  Future<void> _rejectStudent(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student rejected'), backgroundColor: AppColors.error),
      );
      _loadData();
    }
  }

  Widget _buildFacultyIdentityCard() {
    final name = _teacherData?['name'] ?? 'Faculty';
    final designation = _teacherData?['designation'] ?? 'Assistant Professor';
    final department = _teacherData?['department'] ?? 'CSE';
    final facultyId = _teacherData?['facultyId'] ?? 'FAC-IES';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF78350F), Color(0xFF451A03), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4), width: 1.2),
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
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.8),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.surface,
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'T',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
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
                            'Prof. $name 👨‍🏫',
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
                        const Icon(Icons.verified_rounded, color: Color(0xFFF59E0B), size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$designation • $department',
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
            ],
          ),

          const SizedBox(height: 14),

          Container(height: 1, color: Colors.white.withOpacity(0.1)),

          const SizedBox(height: 12),

          Row(
            children: [
              _facultyMetricPill(
                icon: Icons.badge_rounded,
                label: 'Faculty ID',
                value: facultyId.toString(),
              ),
              const SizedBox(width: 8),
              _facultyMetricPill(
                icon: Icons.account_balance_rounded,
                label: 'Institute',
                value: 'IES Bhopal',
              ),
              const SizedBox(width: 8),
              _facultyMetricPill(
                icon: Icons.people_alt_rounded,
                label: 'Pending',
                value: '$_pendingStudentsCount Students',
                isHighlight: _pendingStudentsCount > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _facultyMetricPill({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    final color = isHighlight ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isHighlight ? color.withOpacity(0.15) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(isHighlight ? 0.4 : 0.15), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 8.5, color: Colors.white.withOpacity(0.55)),
                    maxLines: 1,
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isHighlight ? color : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyServicesHub() {
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
              const Text('Faculty Services Hub',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('14 Tools',
                  style: TextStyle(fontSize: 10, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
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
              _facultyServiceItem(
                label: 'Sem Register',
                icon: Icons.how_to_reg_rounded,
                color: const Color(0xFF818CF8),
                isHot: true,
                onTap: () => Navigator.pushNamed(context, AppRoutes.teacherSemesterRegistrations),
              ),
              _facultyServiceItem(
                label: 'Go Live',
                icon: Icons.podcasts_rounded,
                color: const Color(0xFFEF4444),
                isHot: true,
                onTap: () => Navigator.pushNamed(context, AppRoutes.teacherLiveClasses),
              ),
              _facultyServiceItem(
                label: 'Attendance',
                icon: Icons.fact_check_rounded,
                color: const Color(0xFF10B981),
                onTap: () => Navigator.pushNamed(context, AppRoutes.teacherMarkAttendance),
              ),
              _facultyServiceItem(
                label: 'Timetable',
                icon: Icons.calendar_month_rounded,
                color: const Color(0xFFEC4899),
                onTap: () => Navigator.pushNamed(context, AppRoutes.teacherSendTimetable),
              ),
              _facultyServiceItem(
                label: 'Class Groups',
                icon: Icons.forum_rounded,
                color: const Color(0xFF34D399),
                isHot: true,
                onTap: () => Navigator.pushNamed(context, AppRoutes.discussionGroups, arguments: true),
              ),
              _facultyServiceItem(
                label: 'Notices',
                icon: Icons.campaign_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () => setState(() => _selectedIndex = 2),
              ),
              _facultyServiceItem(
                label: 'Upload Notes',
                icon: Icons.upload_file_rounded,
                color: const Color(0xFF06B6D4),
                onTap: () => Navigator.pushNamed(context, AppRoutes.teacherLibraryUpload),
              ),
              _facultyServiceItem(
                label: 'Quizzes',
                icon: Icons.quiz_rounded,
                color: AppColors.secondary,
                onTap: () => Navigator.pushNamed(context, AppRoutes.teacherQuizList),
              ),
              _facultyServiceItem(
                label: 'Assignments',
                icon: Icons.assignment_outlined,
                color: const Color(0xFFF59E0B),
                onTap: () => Navigator.pushNamed(context, AppRoutes.teacherViewSubmissions),
              ),
              _facultyServiceItem(
                label: 'Bonafide',
                icon: Icons.card_membership_rounded,
                color: const Color(0xFF8B5CF6),
                onTap: () => Navigator.pushNamed(context, AppRoutes.teacherApproveBonafide),
              ),
              _facultyServiceItem(
                label: 'Grievance',
                icon: Icons.support_agent_rounded,
                color: const Color(0xFFF43F5E),
                onTap: () => Navigator.pushNamed(context, AppRoutes.teacherGrievance),
              ),
              _facultyServiceItem(
                label: 'Lookup',
                icon: Icons.person_search_rounded,
                color: const Color(0xFF38BDF8),
                onTap: () => Navigator.pushNamed(context, AppRoutes.studentAttendanceLookup),
              ),
              _facultyServiceItem(
                label: 'Reports',
                icon: Icons.analytics_rounded,
                color: const Color(0xFF10B981),
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _facultyServiceItem(
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

  Widget _facultyServiceItem({
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

  Widget _buildTeacherProfileTab() {
    final name = _teacherData?['name'] ?? 'Faculty';
    final email = _teacherData?['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
    final dept = _teacherData?['department'] ?? 'Computer Science & Engineering';
    final designation = _teacherData?['designation'] ?? 'Professor / Faculty';
    final title = _teacherData?['title'] ?? 'Prof.';
    final empId = _teacherData?['employeeId'] ?? _teacherData?['facultyId'] ?? 'IES-FAC-01';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Faculty Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
            // Faculty Avatar & Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A2000), Color(0xFF92400E), Color(0xFF1A3C6E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.secondary.withOpacity(0.2),
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'T',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$title $name', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Verified Faculty', style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Designation & Department Card
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
                  const Text('Faculty Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const Divider(color: Colors.white10, height: 20),
                  _profileInfoRow('Designation', designation, Icons.badge_rounded),
                  _profileInfoRow('Department', dept, Icons.business_rounded),
                  _profileInfoRow('Faculty ID', empId.toString(), Icons.numbers_rounded),
                  _profileInfoRow('Pending Approvals', '$_pendingStudentsCount Students', Icons.pending_actions_rounded),
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
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
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
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textHint))),
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
