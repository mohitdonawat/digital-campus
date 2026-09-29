import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/models/student_model.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class StudentAttendanceLookupScreen extends StatefulWidget {
  final StudentModel? initialStudent;

  const StudentAttendanceLookupScreen({super.key, this.initialStudent});

  @override
  State<StudentAttendanceLookupScreen> createState() =>
      _StudentAttendanceLookupScreenState();
}

class _StudentAttendanceLookupScreenState
    extends State<StudentAttendanceLookupScreen> {
  StudentModel? _selectedStudent;

  // Search & Filters for selecting a student
  final _searchController = TextEditingController();
  String _filterBranch = 'ALL';
  String _filterYear = 'ALL';
  String _filterSemester = 'ALL';

  @override
  void initState() {
    super.initState();
    _selectedStudent = widget.initialStudent;
  }

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
        title: Text(_selectedStudent == null
            ? '🔍 Student Attendance Profile'
            : '${_selectedStudent!.name}\'s Attendance'),
        backgroundColor: AppColors.surface,
        actions: [
          if (_selectedStudent != null)
            IconButton(
              icon: const Icon(Icons.person_search_rounded),
              tooltip: 'Lookup another student',
              onPressed: () => setState(() => _selectedStudent = null),
            ),
        ],
      ),
      body: _selectedStudent == null
          ? _buildStudentSearchDirectory()
          : _buildStudentAttendanceReport(_selectedStudent!),
    );
  }

  // Directory of all students for Teacher / Admin to search & pick
  Widget _buildStudentSearchDirectory() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by student name, roll or enrollment...',
                  hintStyle:
                      const TextStyle(color: AppColors.textHint, fontSize: 13),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.secondary, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 16, color: AppColors.textHint),
                          onPressed: () => setState(() => _searchController.clear()),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              // Branch filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['ALL', ...AppStrings.departments].map((dept) {
                    final isSel = _filterBranch == dept;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(dept == 'ALL' ? 'All Depts' : dept),
                        selected: isSel,
                        onSelected: (val) => setState(() => _filterBranch = dept),
                        selectedColor: AppColors.secondary,
                        labelStyle: TextStyle(
                            fontSize: 11,
                            color: isSel ? Colors.white : AppColors.textSecondary),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Live list of approved students
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'student')
                .where('isApproved', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              final students = docs
                  .map((d) => StudentModel.fromMap(d.data() as Map<String, dynamic>))
                  .toList();

              // Sort A-Z
              students.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

              final q = _searchController.text.trim().toLowerCase();
              final filtered = students.where((s) {
                final bMatch = _filterBranch == 'ALL' || s.branch == _filterBranch;
                final searchMatch = q.isEmpty ||
                    s.name.toLowerCase().contains(q) ||
                    s.rollNo.toLowerCase().contains(q) ||
                    s.enrollmentNo.toLowerCase().contains(q);
                return bMatch && searchMatch;
              }).toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text('No students found.',
                      style: TextStyle(color: AppColors.textHint)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final s = filtered[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: ListTile(
                      onTap: () => setState(() => _selectedStudent = s),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.secondary.withOpacity(0.15),
                        child: Text(
                          s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                          style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      title: Text(s.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      subtitle: Text(
                        '${s.branch} • ${s.year} (${s.semester}) • Roll: ${s.rollNo}',
                        style: const TextStyle(
                            color: AppColors.textHint, fontSize: 11),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.secondary),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Full attendance breakdown for the selected student
  Widget _buildStudentAttendanceReport(StudentModel student) {
    return StreamBuilder<List<AttendanceRecordModel>>(
      stream: AttendanceService.getStudentAttendanceHistory(
        studentUid: student.uid,
        studentEnrollment: student.enrollmentNo,
        studentRollNo: student.rollNo,
        branch: student.branch,
        year: student.year,
        semester: student.semester,
        section: student.section,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          );
        }

        final records = snapshot.data ?? [];
        int total = 0;
        int present = 0;
        final Map<String, List<String>> subjectMap = {};

        for (final r in records) {
          String? st;
          if (r.statusMap.containsKey(student.uid)) {
            st = r.statusMap[student.uid];
          } else if (r.studentDetails.isNotEmpty) {
            for (final entry in r.studentDetails.entries) {
              final dEnroll = entry.value['enrollmentNo'] ?? '';
              final dRoll = entry.value['rollNo'] ?? '';
              if ((student.enrollmentNo.isNotEmpty && dEnroll.toLowerCase() == student.enrollmentNo.toLowerCase()) ||
                  (student.rollNo.isNotEmpty && dRoll.toLowerCase() == student.rollNo.toLowerCase())) {
                st = r.statusMap[entry.key];
                break;
              }
            }
          }
          if (st == null && r.statusMap.isNotEmpty) {
            st = r.statusMap.values.first;
          }

          if (st != null) {
            total++;
            if (st == 'P') present++;
            subjectMap.putIfAbsent(r.subject, () => []);
            subjectMap[r.subject]!.add(st);
          }
        }

        final double pct = total > 0 ? (present / total) * 100 : 0.0;
        final isSafe = pct >= 75.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Info & Big Circular %
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSafe
                        ? AppColors.success.withOpacity(0.4)
                        : AppColors.error.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 46.0,
                      lineWidth: 8.0,
                      percent: (pct / 100).clamp(0.0, 1.0),
                      center: Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isSafe ? AppColors.success : AppColors.error,
                        ),
                      ),
                      progressColor:
                          isSafe ? AppColors.success : AppColors.error,
                      backgroundColor: AppColors.surfaceVariant,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          Text('Roll No: ${student.rollNo} • Enroll: ${student.enrollmentNo}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                          Text(
                              '${student.branch} • ${student.year} (${student.semester}) • Sec ${student.section}',
                              style: const TextStyle(
                                  color: AppColors.secondary, fontSize: 12)),
                          const SizedBox(height: 6),
                          Text(
                            'Status: $present Attended / ${total - present} Absent / $total Total',
                            style: TextStyle(
                                color: isSafe ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text('Subject Breakdown',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 10),

              if (subjectMap.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No attendance entries recorded for this student.',
                        style: TextStyle(color: AppColors.textHint)),
                  ),
                )
              else
                Column(
                  children: subjectMap.entries.map((e) {
                    final sub = e.key;
                    final list = e.value;
                    final sTotal = list.length;
                    final sPresent = list.where((s) => s == 'P').length;
                    final sPct = sTotal > 0 ? (sPresent / sTotal) * 100 : 0.0;
                    final sSafe = sPct >= 75.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: sSafe
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.error.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sub,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                Text('$sPresent / $sTotal classes attended',
                                    style: const TextStyle(
                                        color: AppColors.textHint, fontSize: 11)),
                              ],
                            ),
                          ),
                          Text(
                            '${sPct.toStringAsFixed(0)}%',
                            style: TextStyle(
                                color: sSafe ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.w800,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),

              const Text('Session Logs',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                itemBuilder: (ctx, i) {
                  final rec = records[i];
                  final mySt = rec.statusMap[student.uid] ?? 'A';
                  final isP = mySt == 'P';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rec.subject,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                            Text(
                                '${rec.teacherTitle} ${rec.teacherName} • ${rec.period.split(' ').first}',
                                style: const TextStyle(
                                    color: AppColors.textHint, fontSize: 10)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isP
                                ? AppColors.success.withOpacity(0.15)
                                : AppColors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isP ? 'PRESENT' : 'ABSENT',
                            style: TextStyle(
                              color: isP ? AppColors.success : AppColors.error,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
