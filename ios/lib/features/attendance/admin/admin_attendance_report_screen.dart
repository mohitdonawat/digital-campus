import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ies_e_campus/core/constants/app_colors.dart';
import 'package:ies_e_campus/core/constants/app_routes.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AdminAttendanceReportScreen extends StatefulWidget {
  const AdminAttendanceReportScreen({super.key});

  @override
  State<AdminAttendanceReportScreen> createState() =>
      _AdminAttendanceReportScreenState();
}

class _AdminAttendanceReportScreenState
    extends State<AdminAttendanceReportScreen> {
  String _filterBranch = 'ALL';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🏛️ Admin Attendance Reports'),
        backgroundColor: const Color(0xFF1A0A2E),
        actions: [
          IconButton(
            icon: const Icon(Icons.forum_rounded, color: Color(0xFFA78BFA)),
            tooltip: 'Batch Discussion Groups',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.discussionGroups, arguments: true),
          ),
          IconButton(
            icon: const Icon(Icons.person_search_rounded, color: Color(0xFFA78BFA)),
            tooltip: 'Inspect Student Attendance',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.studentAttendanceLookup),
          ),
        ],
      ),
      body: StreamBuilder<List<AttendanceRecordModel>>(
        stream: AttendanceService.getAllAttendanceForAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
            );
          }

          final allRecords = snapshot.data ?? [];

          // Branch filtering
          final filtered = allRecords.where((r) {
            final branchMatch =
                _filterBranch == 'ALL' || r.branch == _filterBranch;
            final q = _searchController.text.trim().toLowerCase();
            final searchMatch = q.isEmpty ||
                r.teacherName.toLowerCase().contains(q) ||
                r.subject.toLowerCase().contains(q) ||
                r.branch.toLowerCase().contains(q);
            return branchMatch && searchMatch;
          }).toList();

          // Overall Stats
          int totalSessions = allRecords.length;
          int totalStudentHeadcount = 0;
          int totalPresentHeadcount = 0;

          for (final r in allRecords) {
            totalStudentHeadcount += r.totalStudents;
            totalPresentHeadcount += r.presentCount;
          }

          final double avgCollegeAttendance = totalStudentHeadcount > 0
              ? (totalPresentHeadcount / totalStudentHeadcount) * 100
              : 0.0;

          return Column(
            children: [
              // Admin Header Analytics Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2A0845), Color(0xFF1A0A2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _adminStatCard('Classes Taken', '$totalSessions',
                        Icons.class_rounded, const Color(0xFFA78BFA)),
                    _adminStatCard(
                        'Avg Attendance',
                        '${avgCollegeAttendance.toStringAsFixed(1)}%',
                        Icons.insights_rounded,
                        AppColors.success),
                    _adminStatCard('Headcount', '$totalPresentHeadcount',
                        Icons.groups_rounded, AppColors.secondary),
                  ],
                ),
              ),

              // Search & Branch Filter Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search teacher, subject or branch...',
                    hintStyle: const TextStyle(
                        color: AppColors.textHint, fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFFA78BFA), size: 18),
                    filled: true,
                    fillColor: const Color(0xFF1A0A2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),

              // Records Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ATTENDANCE LOGS (${filtered.length})',
                      style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                    const Text(
                      'REALTIME FEED',
                      style: TextStyle(
                          color: Color(0xFFA78BFA),
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),

              // List of attendance sessions
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No attendance records found.',
                          style: TextStyle(color: AppColors.textHint),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final rec = filtered[i];
                          return _buildAdminRecordCard(rec);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdminRecordCard(AttendanceRecordModel rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF130826),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF7C3AED).withOpacity(0.25),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        collapsedIconColor: const Color(0xFFA78BFA),
        iconColor: const Color(0xFFA78BFA),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                rec.branch,
                style: const TextStyle(
                    color: Color(0xFFA78BFA),
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                rec.subject,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                '👨‍🏫 ${rec.teacherTitle} ${rec.teacherName}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text(
                '• ${DateFormat('dd MMM, hh:mm a').format(rec.createdAt)}',
                style:
                    const TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${rec.presentCount}/${rec.totalStudents}',
              style: TextStyle(
                color: rec.percentage >= 75
                    ? AppColors.success
                    : AppColors.error,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            Text(
              '${rec.percentage.toStringAsFixed(0)}%',
              style: const TextStyle(color: AppColors.textHint, fontSize: 10),
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0D051A),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Class: ${rec.year} (${rec.semester}) - Sec ${rec.section}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    Text('Period: ${rec.period}',
                        style: const TextStyle(
                            color: Color(0xFFA78BFA), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('STUDENT BREAKDOWN:',
                    style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: rec.statusMap.entries.map((e) {
                    final uid = e.key;
                    final status = e.value;
                    final details = rec.studentDetails[uid] ?? {};
                    final name = details['name'] ?? 'Student';
                    final roll = details['rollNo'] ?? '';
                    final isP = status == 'P';

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isP
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: isP
                                ? AppColors.success.withOpacity(0.3)
                                : AppColors.error.withOpacity(0.3)),
                      ),
                      child: Text(
                        '$name ($roll): $status',
                        style: TextStyle(
                          color: isP ? AppColors.success : AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminStatCard(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        Text(label,
            style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
      ],
    );
  }
}
