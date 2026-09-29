import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/grievance_model.dart';
import '../services/grievance_service.dart';

class TeacherGrievanceScreen extends StatefulWidget {
  const TeacherGrievanceScreen({super.key});

  @override
  State<TeacherGrievanceScreen> createState() => _TeacherGrievanceScreenState();
}

class _TeacherGrievanceScreenState extends State<TeacherGrievanceScreen> {
  String _filter = 'ALL'; // 'ALL', 'PENDING', 'REPLIED', 'RESOLVED'

  void _openRespondDialog(GrievanceModel g) {
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
            children: [
              const Icon(Icons.reply_all_rounded, color: AppColors.secondary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reply to Ticket: ${g.subject}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student: ${g.studentName} (${g.enrollmentNo} • ${g.branch})',
                            style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            g.description,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Information Note
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E1065).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA78BFA).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline_rounded, color: Color(0xFFA78BFA), size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your response will be delivered to the student. As per campus rules, the grievance will be closed once the student confirms satisfaction.',
                              style: TextStyle(color: Color(0xFFA78BFA), fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: responseController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Official response text required' : null,
                      decoration: InputDecoration(
                        labelText: 'Faculty Official Response / Action Taken *',
                        hintText: 'e.g. Discussed with Transport Incharge. Bus 4 route rescheduled from Monday...',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 11),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSubmitting = true);

                      final user = FirebaseAuth.instance.currentUser;
                      String responder = 'Faculty Administration';
                      if (user != null) {
                        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                        if (doc.exists) {
                          responder = '${doc.data()?['title'] ?? 'Prof.'} ${doc.data()?['name'] ?? 'Faculty'}';
                        }
                      }

                      await GrievanceService.replyGrievance(
                        grievanceId: g.id,
                        responseText: responseController.text.trim(),
                        responderName: responder,
                        responderUid: user?.uid ?? '',
                        responderRole: 'faculty',
                      );

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Response delivered to student. Awaiting student confirmation.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
              child: Text(
                isSubmitting ? 'Sending...' : 'Send Response',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Student Grievance Cell',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            child: Row(
              children: [
                _filterChip('ALL', 'All'),
                const SizedBox(width: 8),
                _filterChip('PENDING', 'Pending Action'),
                const SizedBox(width: 8),
                _filterChip('REPLIED', 'Replied (Awaiting Student)'),
                const SizedBox(width: 8),
                _filterChip('RESOLVED', 'Resolved'),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<GrievanceModel>>(
              stream: GrievanceService.getAllGrievances(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
                }

                var list = snapshot.data ?? [];

                if (_filter == 'PENDING') {
                  list = list.where((g) => g.status == 'OPEN' || g.status == 'STUDENT_REPLIED').toList();
                } else if (_filter == 'REPLIED') {
                  list = list.where((g) => g.status == 'FACULTY_REPLIED').toList();
                } else if (_filter == 'RESOLVED') {
                  list = list.where((g) => g.isResolved).toList();
                }

                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.mark_email_read_rounded, color: AppColors.secondary, size: 50),
                          SizedBox(height: 16),
                          Text('No Grievance Tickets',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text('No student grievances matching the selected filter.',
                            style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final g = list[index];
                    final formattedDate = DateFormat('dd MMM, yyyy').format(g.createdAt);

                    Color statusColor = AppColors.warning;
                    String statusLabel = 'NEEDS ATTENTION';
                    if (g.status == 'FACULTY_REPLIED') {
                      statusColor = const Color(0xFFA78BFA);
                      statusLabel = 'AWAITING STUDENT CONFIRMATION';
                    } else if (g.status == 'STUDENT_REPLIED') {
                      statusColor = AppColors.info;
                      statusLabel = 'STUDENT SENT FOLLOW-UP';
                    } else if (g.isResolved) {
                      statusColor = AppColors.success;
                      statusLabel = 'RESOLVED BY STUDENT ✓';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: statusColor.withOpacity(0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  statusLabel,
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

                          Row(
                            children: [
                              const Icon(Icons.person_rounded, size: 14, color: AppColors.secondary),
                              const SizedBox(width: 4),
                              Text(
                                '${g.studentName} (${g.enrollmentNo} • ${g.branch})',
                                style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Text(
                                'Filed: $formattedDate',
                                style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                              ),
                            ],
                          ),

                          // Conversation Thread Preview
                          if (g.thread.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(color: Colors.white10),
                            const SizedBox(height: 6),
                            const Text('Thread History:',
                              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            ...g.thread.map((m) {
                              final isFaculty = m.senderRole == 'faculty' || m.senderRole == 'admin';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isFaculty ? const Color(0xFF2E1065).withOpacity(0.3) : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${m.senderName}: ',
                                      style: TextStyle(
                                        color: isFaculty ? const Color(0xFFA78BFA) : AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        m.message,
                                        style: const TextStyle(color: Colors.white, fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],

                          const SizedBox(height: 12),

                          // Action Button: Faculty Reply
                          if (!g.isResolved)
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () => _openRespondDialog(g),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                icon: const Icon(Icons.reply_rounded, size: 16, color: AppColors.secondary),
                                label: Text(
                                  g.status == 'FACULTY_REPLIED' ? 'Send Further Reply' : 'Reply with Solution',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Student has confirmed satisfaction. Ticket closed.',
                                    style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
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

  Widget _filterChip(String filterVal, String label) {
    final isSelected = _filter == filterVal;
    return GestureDetector(
      onTap: () => setState(() => _filter = filterVal),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
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
