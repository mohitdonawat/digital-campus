import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../models/grievance_model.dart';
import '../services/grievance_service.dart';

class AdminGrievanceScreen extends StatefulWidget {
  const AdminGrievanceScreen({super.key});

  @override
  State<AdminGrievanceScreen> createState() => _AdminGrievanceScreenState();
}

class _AdminGrievanceScreenState extends State<AdminGrievanceScreen> {
  String _statusFilter = 'ALL'; // 'ALL', 'PENDING', 'AWAITING_STUDENT', 'RESOLVED'
  String _branchFilter = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _departments = ['ALL', ...AppStrings.departments];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAdminInterventionDialog(GrievanceModel g) {
    final responseController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.admin_panel_settings_rounded, color: AppColors.secondary, size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text('Admin Response / Intervention',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ticket: ${g.subject}', style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
                Text('Student: ${g.studentName} (${g.branch})', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: responseController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Admin note/action required' : null,
                  decoration: InputDecoration(
                    labelText: 'Official College Administrative Note *',
                    hintText: 'Enter formal administration directive or resolution details...',
                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 11),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSubmitting = true);

                      final user = FirebaseAuth.instance.currentUser;
                      await GrievanceService.replyGrievance(
                        grievanceId: g.id,
                        responseText: '[Admin Directive] ${responseController.text.trim()}',
                        responderName: 'Central College Administration',
                        responderUid: user?.uid ?? 'admin',
                        responderRole: 'admin',
                      );

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Administrative response dispatched to student & faculty.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
              child: Text(isSubmitting ? 'Sending...' : 'Dispatch Note'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Filter Bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: const Color(0xFF0F172A),
          child: Column(
            children: [
              // Search Field
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search student, enrollment, subject, or grievance issue...',
                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 11),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondary, size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _statusChip('ALL', 'All Status'),
                    const SizedBox(width: 6),
                    _statusChip('PENDING', 'Pending Review'),
                    const SizedBox(width: 6),
                    _statusChip('AWAITING_STUDENT', 'Awaiting Student Confirmation'),
                    const SizedBox(width: 6),
                    _statusChip('RESOLVED', 'Resolved & Satisfied'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Grievances Stream List
        Expanded(
          child: StreamBuilder<List<GrievanceModel>>(
            stream: GrievanceService.getAllGrievances(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
              }

              var list = snapshot.data ?? [];

              // Status Filter
              if (_statusFilter == 'PENDING') {
                list = list.where((g) => g.status == 'OPEN' || g.status == 'STUDENT_REPLIED').toList();
              } else if (_statusFilter == 'AWAITING_STUDENT') {
                list = list.where((g) => g.status == 'FACULTY_REPLIED' && !g.isResolved).toList();
              } else if (_statusFilter == 'RESOLVED') {
                list = list.where((g) => g.isResolved).toList();
              }

              // Department Filter
              if (_branchFilter != 'ALL') {
                list = list.where((g) => g.branch == _branchFilter).toList();
              }

              // Search Filter
              if (_searchQuery.isNotEmpty) {
                list = list.where((g) {
                  return g.studentName.toLowerCase().contains(_searchQuery) ||
                      g.enrollmentNo.toLowerCase().contains(_searchQuery) ||
                      g.subject.toLowerCase().contains(_searchQuery) ||
                      g.description.toLowerCase().contains(_searchQuery);
                }).toList();
              }

              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.done_all_rounded, color: AppColors.secondary, size: 48),
                        SizedBox(height: 14),
                        Text('No Grievances in this Category',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('All complaints in this section have been attended to.',
                          style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, idx) {
                  final g = list[idx];
                  final formattedDate = DateFormat('dd MMM, yyyy').format(g.createdAt);

                  Color statusColor = AppColors.warning;
                  String statusText = 'PENDING REVIEW';
                  if (g.status == 'FACULTY_REPLIED') {
                    statusColor = const Color(0xFFA78BFA);
                    statusText = 'AWAITING STUDENT CONFIRMATION';
                  } else if (g.status == 'STUDENT_REPLIED') {
                    statusColor = AppColors.info;
                    statusText = 'STUDENT SENT FOLLOW-UP';
                  } else if (g.isResolved) {
                    statusColor = AppColors.success;
                    statusText = 'RESOLVED & SATISFIED ✓';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row: Category & Status Badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                g.category,
                                style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: statusColor.withOpacity(0.4)),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        Text(
                          g.subject,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          g.description,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 8),

                        // Student Metadata Bar
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              '${g.studentName} (${g.enrollmentNo} • ${g.branch})',
                              style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Text(
                              formattedDate,
                              style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                            ),
                          ],
                        ),

                        // Transparent Conversation History (Student replies & Faculty replies)
                        if (g.thread.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 4),
                          const Text('Full Dialogue Thread:',
                            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          ...g.thread.map((m) {
                            final isStudent = m.senderRole == 'student';
                            final isFaculty = m.senderRole == 'faculty';
                            final isAdm = m.senderRole == 'admin';

                            Color roleColor = isStudent
                                ? AppColors.secondary
                                : isFaculty
                                    ? const Color(0xFFA78BFA)
                                    : const Color(0xFF10B981);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: roleColor.withOpacity(0.25)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${m.senderName} (${m.senderRole.toUpperCase()}):',
                                        style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                      const Spacer(),
                                      Text(
                                        DateFormat('dd MMM, hh:mm a').format(m.timestamp),
                                        style: const TextStyle(color: AppColors.textHint, fontSize: 9),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(m.message, style: const TextStyle(color: Colors.white, fontSize: 11)),
                                ],
                              ),
                            );
                          }),
                        ],

                        const SizedBox(height: 10),

                        // Satisfaction Status Indicator
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: g.isSatisfied ? AppColors.success.withOpacity(0.15) : Colors.white10,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                g.isSatisfied
                                    ? '✓ Student Confirmed Satisfied'
                                    : '⏳ Pending Student Confirmation',
                                style: TextStyle(
                                  color: g.isSatisfied ? AppColors.success : Colors.white60,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => _openAdminInterventionDialog(g),
                              icon: const Icon(Icons.reply_rounded, size: 14, color: AppColors.secondary),
                              label: const Text('Admin Reply', style: TextStyle(color: AppColors.secondary, fontSize: 11)),
                            ),
                          ],
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
    );
  }

  Widget _statusChip(String statusVal, String label) {
    final isSelected = _statusFilter == statusVal;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = statusVal),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
