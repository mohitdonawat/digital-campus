import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  Map<String, dynamic>? _studentData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted && doc.exists) {
      setState(() {
        _studentData = doc.data();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📊 My Attendance Report'),
        backgroundColor: AppColors.surface,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondary))
          : _buildAttendanceContent(),
    );
  }

  Widget _buildAttendanceContent() {
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final enroll = _studentData?['enrollmentNo']?.toString() ?? '';
    final roll = _studentData?['rollNo']?.toString() ?? '';
    final branch = _studentData?['branch'] ?? '';
    final year = _studentData?['year'] ?? '';
    final semester = _studentData?['semester'] ?? '1st Sem';
    final section = _studentData?['section'] ?? '';

    return StreamBuilder<List<AttendanceRecordModel>>(
      stream: AttendanceService.getStudentAttendanceHistory(
        studentUid: myUid,
        studentEnrollment: enroll,
        studentRollNo: roll,
        branch: branch,
        year: year,
        semester: semester,
        section: section,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary));
        }

        final records = snapshot.data ?? [];

        // Calculate student's overall attendance
        int myTotalClasses = 0;
        int myPresentClasses = 0;
        final Map<String, List<String>> subjectStatusMap = {};

        for (final r in records) {
          String? status;

          // 1. Check direct UID
          if (r.statusMap.containsKey(myUid)) {
            status = r.statusMap[myUid];
          }
          // 2. Check by enrollment or roll number in studentDetails
          else if (r.studentDetails.isNotEmpty) {
            for (final entry in r.studentDetails.entries) {
              final dEnroll = entry.value['enrollmentNo'] ?? '';
              final dRoll = entry.value['rollNo'] ?? '';
              if ((enroll.isNotEmpty && dEnroll.toLowerCase() == enroll.toLowerCase()) ||
                  (roll.isNotEmpty && dRoll.toLowerCase() == roll.toLowerCase())) {
                status = r.statusMap[entry.key];
                break;
              }
            }
          }

          // 3. Fallback: if student is in this class section
          if (status == null && r.statusMap.isNotEmpty) {
            status = r.statusMap.values.first; // Default to class participation
          }

          if (status != null) {
            myTotalClasses++;
            if (status == 'P') myPresentClasses++;

            subjectStatusMap.putIfAbsent(r.subject, () => []);
            subjectStatusMap[r.subject]!.add(status);
          }
        }

        final double overallPercentage = myTotalClasses > 0
            ? (myPresentClasses / myTotalClasses) * 100
            : 0.0;
        final bool isSafe = overallPercentage >= 75.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Attendance Circular Progress Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSafe
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.error.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 54.0,
                      lineWidth: 10.0,
                      animation: true,
                      percent: (overallPercentage / 100).clamp(0.0, 1.0),
                      center: Text(
                        '${overallPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isSafe ? AppColors.success : AppColors.error,
                        ),
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor:
                          isSafe ? AppColors.success : AppColors.error,
                      backgroundColor: AppColors.surfaceVariant,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSafe ? 'Good Standing 🎉' : 'Attendance Alert! ⚠️',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSafe ? AppColors.success : AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSafe
                                ? 'You meet the 75% RGPV criteria.'
                                : 'Attendance is below 75%. Attend remaining classes to sit in exams.',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _miniStat('Total', '$myTotalClasses'),
                              const SizedBox(width: 12),
                              _miniStat('Present', '$myPresentClasses',
                                  AppColors.success),
                              const SizedBox(width: 12),
                              _miniStat('Absent',
                                  '${myTotalClasses - myPresentClasses}',
                                  AppColors.error),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Subject-wise Breakdown
              const Text(
                'Subject-wise Breakdown',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              const SizedBox(height: 12),

              if (subjectStatusMap.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'No classes recorded yet for your current semester.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textHint, fontSize: 13),
                    ),
                  ),
                )
              else
                Column(
                  children: subjectStatusMap.entries.map((entry) {
                    final sub = entry.key;
                    final list = entry.value;
                    final total = list.length;
                    final present = list.where((s) => s == 'P').length;
                    final pct = total > 0 ? (present / total) * 100 : 0.0;
                    final subSafe = pct >= 75.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: subSafe
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.error.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  sub,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                              ),
                              Text(
                                '${pct.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: subSafe
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: (pct / 100).clamp(0.0, 1.0),
                            backgroundColor: AppColors.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                subSafe ? AppColors.success : AppColors.error),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$present attended out of $total classes',
                            style: const TextStyle(
                                color: AppColors.textHint, fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 24),

              // Recent Class Sessions Log
              const Text(
                'Recent Class Sessions',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              const SizedBox(height: 12),

              if (records.isEmpty)
                const SizedBox()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.take(15).length,
                  itemBuilder: (ctx, i) {
                    final rec = records[i];
                    final myStatus = rec.statusMap[myUid] ?? 'N/A';
                    final isP = myStatus == 'P';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isP
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isP
                                  ? AppColors.success.withOpacity(0.15)
                                  : AppColors.error.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isP ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: isP ? AppColors.success : AppColors.error,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rec.subject,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                                Text(
                                  '${rec.teacherTitle} ${rec.teacherName} • ${rec.period.split(' ').first}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isP ? 'PRESENT' : 'ABSENT',
                                style: TextStyle(
                                  color: isP ? AppColors.success : AppColors.error,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                DateFormat('dd MMM').format(rec.date),
                                style: const TextStyle(
                                    color: AppColors.textHint, fontSize: 10),
                              ),
                            ],
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

  Widget _miniStat(String label, String value, [Color? color]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color ?? Colors.white)),
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
      ],
    );
  }
}
