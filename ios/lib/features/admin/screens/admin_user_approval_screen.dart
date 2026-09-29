import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Admin User Approval & Directory Screen
/// Allows Admin to inspect, approve, reject, search, email and call
/// both Students and Teachers with live counts and full details.
class AdminUserApprovalScreen extends StatefulWidget {
  const AdminUserApprovalScreen({super.key});

  @override
  State<AdminUserApprovalScreen> createState() =>
      _AdminUserApprovalScreenState();
}

class _AdminUserApprovalScreenState extends State<AdminUserApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Filters
  String _studentFilter = 'PENDING'; // 'ALL', 'PENDING', 'APPROVED'
  String _teacherFilter = 'PENDING'; // 'ALL', 'PENDING', 'APPROVED'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Launch Gmail / Email app directly
  Future<void> _launchEmail(String email, String name) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No email address available for this user'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'IES E Campus Notification - $name',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open email app: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Launch Phone dialer directly
  Future<void> _launchPhone(String phone) async {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No phone number registered for this user'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open phone dialer: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Update approval status in Firestore
  Future<void> _updateApproval(String uid, bool isApproved, String name) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isApproved': isApproved,
        'approvedAt': isApproved ? Timestamp.now() : null,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApproved
                ? '✓ $name has been APPROVED!'
                : '⚠ $name approval has been revoked.',
          ),
          backgroundColor:
              isApproved ? const Color(0xFF10B981) : AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Delete / Reject user
  Future<void> _deleteUser(String uid, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Confirm Deletion',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to permanently delete $name\'s registration?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ $name removed from directory'),
            backgroundColor: AppColors.error,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deletion failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        // Parse Students
        final students = docs.where((d) {
          final data = d.data() as Map<String, dynamic>?;
          return data?['role'] == 'student';
        }).map((d) {
          final m = d.data() as Map<String, dynamic>;
          m['uid'] = d.id;
          return m;
        }).toList();

        // Parse Teachers
        final teachers = docs.where((d) {
          final data = d.data() as Map<String, dynamic>?;
          return data?['role'] == 'teacher' || data?['role'] == 'faculty';
        }).map((d) {
          final m = d.data() as Map<String, dynamic>;
          m['uid'] = d.id;
          return m;
        }).toList();

        // Stats calculation
        final totalUsers = students.length + teachers.length;
        final approvedStudents =
            students.where((s) => s['isApproved'] == true).length;
        final pendingStudents = students.length - approvedStudents;

        final approvedTeachers =
            teachers.where((t) => t['isApproved'] == true).length;
        final pendingTeachers = teachers.length - approvedTeachers;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // Modern Stats Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overall Total Counter Bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFF334155), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
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
                                  color: const Color(0xFF7C3AED).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.groups_rounded,
                                  color: Color(0xFFA78BFA),
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Registered Users',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$totalUsers Users',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Pending Action Tag
                              if (pendingStudents + pendingTeachers > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: const Color(0xFFF59E0B), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.pending_actions_rounded,
                                          color: Color(0xFFF59E0B), size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${pendingStudents + pendingTeachers} Pending',
                                        style: const TextStyle(
                                          color: Color(0xFFF59E0B),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Two Column Stats: Students & Teachers
                        Row(
                          children: [
                            // Student Stats Card
                            Expanded(
                              child: _buildCategoryStatCard(
                                title: 'Students',
                                icon: Icons.school_rounded,
                                iconColor: const Color(0xFF60A5FA),
                                total: students.length,
                                approved: approvedStudents,
                                pending: pendingStudents,
                                gradientColors: [
                                  const Color(0xFF1E3A8A).withOpacity(0.5),
                                  const Color(0xFF0F172A),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Teacher Stats Card
                            Expanded(
                              child: _buildCategoryStatCard(
                                title: 'Teachers',
                                icon: Icons.person_4_rounded,
                                iconColor: AppColors.secondary,
                                total: teachers.length,
                                approved: approvedTeachers,
                                pending: pendingTeachers,
                                gradientColors: [
                                  const Color(0xFF78350F).withOpacity(0.5),
                                  const Color(0xFF0F172A),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFF334155), width: 1),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText:
                                  'Search by name, roll no, enrollment, branch...',
                              hintStyle: const TextStyle(
                                  color: Colors.white38, fontSize: 13),
                              prefixIcon: const Icon(Icons.search_rounded,
                                  color: Colors.white54),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Colors.white54),
                                      onPressed: () => _searchController.clear(),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab Bar Sliver (Pinned)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.secondary,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      labelStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.school_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text('Students (${students.length})'),
                              if (pendingStudents > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF59E0B),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$pendingStudents',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person_4_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text('Teachers (${teachers.length})'),
                              if (pendingTeachers > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF59E0B),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$pendingTeachers',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Students
                _buildStudentsTab(students),
                // Tab 2: Teachers
                _buildTeachersTab(teachers),
              ],
            ),
          ),
        );
      },
    );
  }

  // Category stat card (Students or Teachers)
  Widget _buildCategoryStatCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required int total,
    required int approved,
    required int pending,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Approved badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF10B981), size: 11),
                    const SizedBox(width: 4),
                    Text(
                      '$approved OK',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Pending badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: pending > 0
                      ? const Color(0xFFF59E0B).withOpacity(0.2)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.hourglass_top_rounded,
                      color: pending > 0
                          ? const Color(0xFFF59E0B)
                          : Colors.white38,
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$pending Wait',
                      style: TextStyle(
                        color: pending > 0
                            ? const Color(0xFFF59E0B)
                            : Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STUDENTS TAB
  Widget _buildStudentsTab(List<Map<String, dynamic>> allStudents) {
    // Filter by approval status
    var filtered = allStudents.where((s) {
      final isApproved = s['isApproved'] == true;
      if (_studentFilter == 'PENDING') return !isApproved;
      if (_studentFilter == 'APPROVED') return isApproved;
      return true;
    }).toList();

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((s) {
        final name = (s['name'] ?? '').toString().toLowerCase();
        final rollNo = (s['rollNo'] ?? '').toString().toLowerCase();
        final enrollment = (s['enrollmentNo'] ?? '').toString().toLowerCase();
        final branch = (s['branch'] ?? '').toString().toLowerCase();
        final email = (s['email'] ?? '').toString().toLowerCase();
        return name.contains(_searchQuery) ||
            rollNo.contains(_searchQuery) ||
            enrollment.contains(_searchQuery) ||
            branch.contains(_searchQuery) ||
            email.contains(_searchQuery);
      }).toList();
    }

    return Column(
      children: [
        // Sub-filter chips for students
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              _buildFilterChip(
                label: 'Pending Approval',
                count: allStudents.where((s) => s['isApproved'] != true).length,
                isSelected: _studentFilter == 'PENDING',
                color: const Color(0xFFF59E0B),
                onTap: () => setState(() => _studentFilter = 'PENDING'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Approved',
                count: allStudents.where((s) => s['isApproved'] == true).length,
                isSelected: _studentFilter == 'APPROVED',
                color: const Color(0xFF10B981),
                onTap: () => setState(() => _studentFilter = 'APPROVED'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'All',
                count: allStudents.length,
                isSelected: _studentFilter == 'ALL',
                color: const Color(0xFF60A5FA),
                onTap: () => setState(() => _studentFilter = 'ALL'),
              ),
            ],
          ),
        ),

        // Students list
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(
                  icon: Icons.school_outlined,
                  message: _studentFilter == 'PENDING'
                      ? 'No students pending approval!'
                      : 'No students found matching filters.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final student = filtered[index];
                    return _buildStudentCard(student);
                  },
                ),
        ),
      ],
    );
  }

  // TEACHERS TAB
  Widget _buildTeachersTab(List<Map<String, dynamic>> allTeachers) {
    // Filter by approval status
    var filtered = allTeachers.where((t) {
      final isApproved = t['isApproved'] == true;
      if (_teacherFilter == 'PENDING') return !isApproved;
      if (_teacherFilter == 'APPROVED') return isApproved;
      return true;
    }).toList();

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final name = (t['name'] ?? '').toString().toLowerCase();
        final empId = (t['employeeId'] ?? '').toString().toLowerCase();
        final email = (t['email'] ?? '').toString().toLowerCase();
        final departments = (t['departments'] as List<dynamic>? ?? [])
            .map((e) => e.toString().toLowerCase())
            .join(' ');
        return name.contains(_searchQuery) ||
            empId.contains(_searchQuery) ||
            email.contains(_searchQuery) ||
            departments.contains(_searchQuery);
      }).toList();
    }

    return Column(
      children: [
        // Sub-filter chips for teachers
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              _buildFilterChip(
                label: 'Pending Approval',
                count: allTeachers.where((t) => t['isApproved'] != true).length,
                isSelected: _teacherFilter == 'PENDING',
                color: const Color(0xFFF59E0B),
                onTap: () => setState(() => _teacherFilter = 'PENDING'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Approved',
                count: allTeachers.where((t) => t['isApproved'] == true).length,
                isSelected: _teacherFilter == 'APPROVED',
                color: const Color(0xFF10B981),
                onTap: () => setState(() => _teacherFilter = 'APPROVED'),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'All',
                count: allTeachers.length,
                isSelected: _teacherFilter == 'ALL',
                color: const Color(0xFF60A5FA),
                onTap: () => setState(() => _teacherFilter = 'ALL'),
              ),
            ],
          ),
        ),

        // Teachers list
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(
                  icon: Icons.person_4_outlined,
                  message: _teacherFilter == 'PENDING'
                      ? 'No teachers pending approval!'
                      : 'No teachers found matching filters.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final teacher = filtered[index];
                    return _buildTeacherCard(teacher);
                  },
                ),
        ),
      ],
    );
  }

  // Filter Chip Component
  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF334155),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STUDENT CARD ITEM
  Widget _buildStudentCard(Map<String, dynamic> student) {
    final uid = student['uid'] ?? '';
    final name = student['name'] ?? 'Unnamed Student';
    final email = student['email'] ?? '';
    final phone = student['phone'] ?? '';
    final branch = student['branch'] ?? 'CSE';
    final year = student['year'] ?? '';
    final sem = student['semester'] ?? '';
    final sec = student['section'] ?? '';
    final rollNo = student['rollNo'] ?? 'N/A';
    final enrollment = student['enrollmentNo'] ?? 'N/A';
    final isApproved = student['isApproved'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApproved
              ? const Color(0xFF334155)
              : const Color(0xFFF59E0B).withOpacity(0.4),
          width: isApproved ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showStudentDetailsModal(student),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar + Name + Status
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF1E3A8A),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        color: Color(0xFF93C5FD),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Enrollment: $enrollment',
                          style: const TextStyle(
                            color: Color(0xFFA78BFA),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? const Color(0xFF10B981).withOpacity(0.15)
                          : const Color(0xFFF59E0B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isApproved
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isApproved
                              ? Icons.check_circle_rounded
                              : Icons.hourglass_top_rounded,
                          color: isApproved
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isApproved ? 'Approved' : 'Pending',
                          style: TextStyle(
                            color: isApproved
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Academic Tag Row
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildMiniTag(Icons.account_tree_outlined, branch),
                  if (year.isNotEmpty) _buildMiniTag(Icons.calendar_today, year),
                  if (sem.isNotEmpty) _buildMiniTag(Icons.timeline, sem),
                  if (sec.isNotEmpty) _buildMiniTag(Icons.class_outlined, 'Sec $sec'),
                  _buildMiniTag(Icons.badge_outlined, 'Roll: $rollNo'),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: Color(0xFF334155), height: 1),
              const SizedBox(height: 8),

              // Action Buttons Row: Email, Call, Approve, Details
              Row(
                children: [
                  // 1-Click Gmail Action
                  IconButton(
                    onPressed: () => _launchEmail(email, name),
                    icon: const Icon(Icons.mail_outline_rounded, size: 20),
                    color: const Color(0xFF60A5FA),
                    tooltip: 'Send Email via Gmail',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // 1-Click Phone Dialer Action
                  IconButton(
                    onPressed: () => _launchPhone(phone),
                    icon: const Icon(Icons.phone_outlined, size: 20),
                    color: const Color(0xFF34D399),
                    tooltip: 'Call Student',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF065F46).withOpacity(0.3),
                    ),
                  ),

                  const Spacer(),

                  // Quick Approve / Revoke button
                  if (!isApproved)
                    ElevatedButton.icon(
                      onPressed: () => _updateApproval(uid, true, name),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => _updateApproval(uid, false, name),
                      icon: const Icon(Icons.undo_rounded, size: 16),
                      label: const Text('Revoke'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: const BorderSide(color: AppColors.warning),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                  const SizedBox(width: 6),

                  // 1-Click Delete Account Action
                  IconButton(
                    onPressed: () => _deleteUser(uid, name),
                    icon: const Icon(Icons.delete_forever_rounded, size: 20),
                    color: AppColors.error,
                    tooltip: 'Permanently Delete Student Account',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withOpacity(0.15),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // View All Details
                  IconButton(
                    onPressed: () => _showStudentDetailsModal(student),
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    color: Colors.white54,
                    tooltip: 'View Full Profile',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TEACHER CARD ITEM
  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    final uid = teacher['uid'] ?? '';
    final name = teacher['name'] ?? 'Unnamed Teacher';
    final title = teacher['title'] ?? 'Prof.';
    final email = teacher['email'] ?? '';
    final phone = teacher['phone'] ?? '';
    final empId = teacher['employeeId'] ?? 'N/A';
    final designation = teacher['designation'] ?? 'Faculty';
    final departments = (teacher['departments'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final isApproved = teacher['isApproved'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApproved
              ? const Color(0xFF334155)
              : const Color(0xFFF59E0B).withOpacity(0.4),
          width: isApproved ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showTeacherDetailsModal(teacher),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar + Name + Status
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF78350F),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'T',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$title $name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$designation (ID: $empId)',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? const Color(0xFF10B981).withOpacity(0.15)
                          : const Color(0xFFF59E0B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isApproved
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isApproved
                              ? Icons.check_circle_rounded
                              : Icons.hourglass_top_rounded,
                          color: isApproved
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isApproved ? 'Approved' : 'Pending',
                          style: TextStyle(
                            color: isApproved
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Department tags
              if (departments.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: departments
                      .map((dep) => _buildMiniTag(Icons.business_rounded, dep))
                      .toList(),
                ),

              const SizedBox(height: 12),
              const Divider(color: Color(0xFF334155), height: 1),
              const SizedBox(height: 8),

              // Action Buttons Row: Email, Call, Approve, Details
              Row(
                children: [
                  // 1-Click Gmail Action
                  IconButton(
                    onPressed: () => _launchEmail(email, name),
                    icon: const Icon(Icons.mail_outline_rounded, size: 20),
                    color: const Color(0xFF60A5FA),
                    tooltip: 'Send Email via Gmail',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // 1-Click Phone Dialer Action
                  IconButton(
                    onPressed: () => _launchPhone(phone),
                    icon: const Icon(Icons.phone_outlined, size: 20),
                    color: const Color(0xFF34D399),
                    tooltip: 'Call Teacher',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF065F46).withOpacity(0.3),
                    ),
                  ),

                  const Spacer(),

                  // Quick Approve / Revoke button
                  if (!isApproved)
                    ElevatedButton.icon(
                      onPressed: () => _updateApproval(uid, true, name),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => _updateApproval(uid, false, name),
                      icon: const Icon(Icons.undo_rounded, size: 16),
                      label: const Text('Revoke'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: const BorderSide(color: AppColors.warning),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                  const SizedBox(width: 6),

                  // 1-Click Delete Account Action
                  IconButton(
                    onPressed: () => _deleteUser(uid, name),
                    icon: const Icon(Icons.delete_forever_rounded, size: 20),
                    color: AppColors.error,
                    tooltip: 'Permanently Delete Teacher Account',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withOpacity(0.15),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // View All Details
                  IconButton(
                    onPressed: () => _showTeacherDetailsModal(teacher),
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    color: Colors.white54,
                    tooltip: 'View Full Profile',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mini info pill
  Widget _buildMiniTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF334155), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white54),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // Empty state placeholder
  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // FULL STUDENT DETAILS MODAL SHEET
  void _showStudentDetailsModal(Map<String, dynamic> student) {
    final uid = student['uid'] ?? '';
    final name = student['name'] ?? 'N/A';
    final email = student['email'] ?? 'N/A';
    final phone = student['phone'] ?? 'N/A';
    final branch = student['branch'] ?? 'N/A';
    final year = student['year'] ?? 'N/A';
    final sem = student['semester'] ?? 'N/A';
    final sec = student['section'] ?? 'N/A';
    final rollNo = student['rollNo'] ?? 'N/A';
    final enrollment = student['enrollmentNo'] ?? 'N/A';
    final isApproved = student['isApproved'] == true;
    final college = student['college'] ?? AppStrings.collegeFullName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Student Header with Large Avatar & Status
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: const Color(0xFF1E3A8A),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'S',
                              style: const TextStyle(
                                color: Color(0xFF93C5FD),
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Enrollment: $enrollment',
                                  style: const TextStyle(
                                    color: Color(0xFFA78BFA),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isApproved
                                        ? const Color(0xFF10B981).withOpacity(0.2)
                                        : const Color(0xFFF59E0B).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isApproved
                                        ? '🟢 APPROVED STUDENT'
                                        : '🟠 PENDING APPROVAL',
                                    style: TextStyle(
                                      color: isApproved
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFF59E0B),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFF334155)),
                      const SizedBox(height: 16),

                      // Quick Action Bar: Gmail, Call, Delete
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _launchEmail(email, name),
                              icon: const Icon(Icons.mail_rounded, size: 18),
                              label: const Text('Gmail / Email'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _launchPhone(phone),
                              icon: const Icon(Icons.phone_rounded, size: 18),
                              label: const Text('Call'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF065F46),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Academic Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildDetailRow(Icons.account_tree_rounded, 'Branch', branch),
                      _buildDetailRow(Icons.calendar_today_rounded, 'Year', year),
                      _buildDetailRow(Icons.timeline_rounded, 'Semester', sem),
                      _buildDetailRow(Icons.class_rounded, 'Section', sec),
                      _buildDetailRow(Icons.badge_rounded, 'Roll Number', rollNo),
                      _buildDetailRow(Icons.fingerprint_rounded, 'Enrollment No', enrollment),
                      _buildDetailRow(Icons.apartment_rounded, 'College', college),

                      const SizedBox(height: 20),
                      const Text(
                        'Contact Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildDetailRow(Icons.email_outlined, 'Email Address', email,
                          onTap: () => _launchEmail(email, name)),
                      _buildDetailRow(Icons.phone_outlined, 'Mobile Number', phone,
                          onTap: () => _launchPhone(phone)),

                      const SizedBox(height: 32),

                      // Bottom Approval Action
                      Row(
                        children: [
                          Expanded(
                            child: isApproved
                                ? OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _updateApproval(uid, false, name);
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                    label: const Text('Revoke Approval'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.warning,
                                      side: const BorderSide(color: AppColors.warning),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _updateApproval(uid, true, name);
                                    },
                                    icon: const Icon(Icons.check_circle_rounded),
                                    label: const Text('Approve Student Now'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _deleteUser(uid, name);
                            },
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.error),
                            tooltip: 'Delete User',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.error.withOpacity(0.15),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // FULL TEACHER DETAILS MODAL SHEET
  void _showTeacherDetailsModal(Map<String, dynamic> teacher) {
    final uid = teacher['uid'] ?? '';
    final name = teacher['name'] ?? 'N/A';
    final title = teacher['title'] ?? 'Prof.';
    final email = teacher['email'] ?? 'N/A';
    final phone = teacher['phone'] ?? 'N/A';
    final empId = teacher['employeeId'] ?? 'N/A';
    final designation = teacher['designation'] ?? 'Faculty';
    final departments = (teacher['departments'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .join(', ');
    final years = (teacher['years'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .join(', ');
    final subjects = (teacher['subjects'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .join(', ');
    final isApproved = teacher['isApproved'] == true;
    final college = teacher['college'] ?? AppStrings.collegeFullName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Teacher Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF78350F),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'T',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$title $name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$designation (Emp ID: $empId)',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isApproved
                                    ? const Color(0xFF10B981).withOpacity(0.2)
                                    : const Color(0xFFF59E0B).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isApproved
                                    ? '🟢 APPROVED FACULTY'
                                    : '🟠 PENDING APPROVAL',
                                style: TextStyle(
                                  color: isApproved
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFF334155)),
                  const SizedBox(height: 16),

                  // Quick Action Bar: Gmail, Call
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchEmail(email, name),
                          icon: const Icon(Icons.mail_rounded, size: 18),
                          label: const Text('Gmail / Email'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchPhone(phone),
                          icon: const Icon(Icons.phone_rounded, size: 18),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF065F46),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Faculty Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildDetailRow(Icons.badge_rounded, 'Employee ID', empId),
                  _buildDetailRow(Icons.work_rounded, 'Designation', designation),
                  _buildDetailRow(Icons.business_rounded, 'Departments',
                      departments.isNotEmpty ? departments : 'All Engineering'),
                  _buildDetailRow(Icons.calendar_view_week_rounded,
                      'Years Teaching', years.isNotEmpty ? years : 'All Years'),
                  if (subjects.isNotEmpty)
                    _buildDetailRow(Icons.menu_book_rounded, 'Subjects', subjects),
                  _buildDetailRow(Icons.apartment_rounded, 'College', college),

                  const SizedBox(height: 20),
                  const Text(
                    'Contact Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildDetailRow(Icons.email_outlined, 'Email Address', email,
                      onTap: () => _launchEmail(email, name)),
                  _buildDetailRow(Icons.phone_outlined, 'Mobile Number', phone,
                      onTap: () => _launchPhone(phone)),

                  const SizedBox(height: 32),

                  // Bottom Approval Action
                  Row(
                    children: [
                      Expanded(
                        child: isApproved
                            ? OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _updateApproval(uid, false, name);
                                },
                                icon: const Icon(Icons.close_rounded),
                                label: const Text('Revoke Approval'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.warning,
                                  side: const BorderSide(color: AppColors.warning),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _updateApproval(uid, true, name);
                                },
                                icon: const Icon(Icons.check_circle_rounded),
                                label: const Text('Approve Faculty Now'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _deleteUser(uid, name);
                        },
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.error),
                        tooltip: 'Delete Faculty',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.error.withOpacity(0.15),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper row for modal sheet
  Widget _buildDetailRow(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.white54),
            const SizedBox(width: 12),
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: onTap != null ? const Color(0xFF60A5FA) : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.open_in_new_rounded,
                  size: 14, color: Color(0xFF60A5FA)),
          ],
        ),
      ),
    );
  }
}

// Sliver Persistent Header Delegate for TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
