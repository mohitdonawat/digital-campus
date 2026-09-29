import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../services/notification_service.dart';

class NotificationFeedModal extends StatelessWidget {
  final String studentUid;
  final String branch;
  final String year;

  const NotificationFeedModal({
    super.key,
    required this.studentUid,
    required this.branch,
    required this.year,
  });

  static void show(BuildContext context, {required String studentUid, required String branch, required String year}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => NotificationFeedModal(
        studentUid: studentUid,
        branch: branch,
        year: year,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF334155))),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active_rounded, color: AppColors.secondary, size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campus Alerts & Updates',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Audio alerts enabled for quizzes, timetable & replies',
                      style: TextStyle(color: AppColors.textHint, fontSize: 11),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10),

          // Stream of Notifications
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: NotificationService.streamStudentNotifications(
                studentUid: studentUid,
                branch: branch,
                year: year,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
                }

                final notifications = snapshot.data ?? [];
                if (notifications.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.notifications_off_rounded, color: Colors.white24, size: 48),
                          SizedBox(height: 14),
                          Text(
                            'No New Notifications',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'You are all caught up! New announcements, test alerts, or faculty replies will pop up here with audio sound.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textHint, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, idx) {
                    final n = notifications[idx];
                    final title = n['title'] ?? 'Notice';
                    final body = n['body'] ?? '';
                    final category = n['category'] ?? 'General';
                    final ts = n['createdAt'] as Timestamp?;
                    final dateStr = ts != null
                        ? DateFormat('dd MMM, hh:mm a').format(ts.toDate())
                        : 'Recent';

                    IconData catIcon = Icons.notifications_rounded;
                    Color catColor = AppColors.secondary;

                    if (category == 'Quiz') {
                      catIcon = Icons.quiz_rounded;
                      catColor = AppColors.warning;
                    } else if (category == 'Timetable') {
                      catIcon = Icons.calendar_today_rounded;
                      catColor = AppColors.info;
                    } else if (category == 'Grievance') {
                      catIcon = Icons.support_agent_rounded;
                      catColor = const Color(0xFFA78BFA);
                    } else if (category == 'Assignment') {
                      catIcon = Icons.assignment_rounded;
                      catColor = AppColors.success;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: catColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: catColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(catIcon, color: catColor, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: catColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        category.toUpperCase(),
                                        style: TextStyle(color: catColor, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      dateStr,
                                      style: const TextStyle(color: AppColors.textHint, fontSize: 10),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  title,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  body,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
