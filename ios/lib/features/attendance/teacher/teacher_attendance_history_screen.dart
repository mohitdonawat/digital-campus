import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class TeacherAttendanceHistoryScreen extends StatefulWidget {
  const TeacherAttendanceHistoryScreen({super.key});

  @override
  State<TeacherAttendanceHistoryScreen> createState() =>
      _TeacherAttendanceHistoryScreenState();
}

class _TeacherAttendanceHistoryScreenState
    extends State<TeacherAttendanceHistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📋 My Classes Taken & Headcount'),
        backgroundColor: AppColors.surface,
      ),
      body: StreamBuilder<List<AttendanceRecordModel>>(
        stream: AttendanceService.getTeacherAttendance(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          final records = snapshot.data ?? [];

          // Calculate summary for Today & Lifetime
          final now = DateTime.now();
          final todayRecords = records.where((r) =>
              r.date.year == now.year &&
              r.date.month == now.month &&
              r.date.day == now.day).toList();

          int todayClasses = todayRecords.length;
          int todayTotalStudents = 0;
          int todayPresentStudents = 0;

          for (final r in todayRecords) {
            todayTotalStudents += r.totalStudents;
            todayPresentStudents += r.presentCount;
          }

          int totalLifetimeClasses = records.length;
          int totalLifetimeStudents = 0;
          int totalLifetimePresent = 0;

          for (final r in records) {
            totalLifetimeStudents += r.totalStudents;
            totalLifetimePresent += r.presentCount;
          }

          final double lifetimePct = totalLifetimeStudents > 0
              ? (totalLifetimePresent / totalLifetimeStudents) * 100
              : 0.0;

          final query = _searchController.text.trim().toLowerCase();
          final filtered = records.where((r) {
            if (query.isEmpty) return true;
            return r.subject.toLowerCase().contains(query) ||
                r.branch.toLowerCase().contains(query) ||
                r.semester.toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
              // Teacher Stats Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A2000), Color(0xFF1E2D40)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricItem('Today Classes', '$todayClasses',
                            Icons.today_rounded, AppColors.secondary),
                        _metricItem('Students Today', '$todayPresentStudents / $todayTotalStudents',
                            Icons.groups_rounded, AppColors.success),
                        _metricItem('Total Classes', '$totalLifetimeClasses',
                            Icons.history_edu_rounded, AppColors.info),
                        _metricItem('Avg Attendance',
                            '${lifetimePct.toStringAsFixed(0)}%',
                            Icons.insights_rounded,
                            lifetimePct >= 75 ? AppColors.success : AppColors.warning),
                      ],
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search my classes by subject or branch...',
                    hintStyle:
                        const TextStyle(color: AppColors.textHint, fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.secondary, size: 18),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MY ATTENDANCE SESSIONS (${filtered.length})',
                      style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                    const Text(
                      'TAP CARD TO EXPAND DETAILS',
                      style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),

              // Classes List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          records.isEmpty
                              ? 'You have not marked any class attendance yet.'
                              : 'No classes matched your search.',
                          style: const TextStyle(color: AppColors.textHint),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final r = filtered[i];
                          final isToday = r.date.year == now.year &&
                              r.date.month == now.month &&
                              r.date.day == now.day;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              gradient: AppColors.cardGradient,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isToday
                                    ? AppColors.secondary.withOpacity(0.5)
                                    : AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              collapsedIconColor: AppColors.secondary,
                              iconColor: AppColors.secondary,
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? AppColors.secondary.withOpacity(0.2)
                                          : AppColors.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      r.branch,
                                      style: TextStyle(
                                          color: isToday
                                              ? AppColors.secondary
                                              : AppColors.info,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      r.subject,
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
                                child: Text(
                                  '${DateFormat('dd MMM yyyy').format(r.date)} • ${r.period.split(' ').first} • Sec ${r.section}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11),
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${r.presentCount}/${r.totalStudents} P',
                                    style: TextStyle(
                                      color: r.percentage >= 75
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '${r.absentCount} Absent',
                                    style: const TextStyle(
                                        color: AppColors.error, fontSize: 10),
                                  ),
                                ],
                              ),
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  color: AppColors.background.withOpacity(0.6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Class: ${r.year} (${r.semester}) - Sec ${r.section} • Period: ${r.period}',
                                        style: const TextStyle(
                                            color: Colors.white70, fontSize: 12),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'STUDENT ROSTER & STATUS:',
                                        style: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: r.statusMap.entries.map((e) {
                                          final uid = e.key;
                                          final status = e.value;
                                          final details =
                                              r.studentDetails[uid] ?? {};
                                          final name =
                                              details['name'] ?? 'Student';
                                          final roll = details['rollNo'] ?? '';
                                          final isP = status == 'P';

                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isP
                                                  ? AppColors.success
                                                      .withOpacity(0.15)
                                                  : AppColors.error
                                                      .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: isP
                                                      ? AppColors.success
                                                          .withOpacity(0.3)
                                                      : AppColors.error
                                                          .withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              '$name ($roll): $status',
                                              style: TextStyle(
                                                color: isP
                                                    ? AppColors.success
                                                    : AppColors.error,
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
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _metricItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14)),
        Text(label,
            style: const TextStyle(color: AppColors.textHint, fontSize: 9)),
      ],
    );
  }
}
