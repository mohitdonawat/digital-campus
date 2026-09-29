import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/grievance_model.dart';
import '../services/grievance_service.dart';

class StudentGrievanceScreen extends StatefulWidget {
  const StudentGrievanceScreen({super.key});

  @override
  State<StudentGrievanceScreen> createState() => _StudentGrievanceScreenState();
}

class _StudentGrievanceScreenState extends State<StudentGrievanceScreen> {
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;

  final List<String> _categories = [
    'Academic & Teaching',
    'Fee & Accounts',
    'Bus & Transportation',
    'Hostel & Mess',
    'Examination & Results',
    'Ragging / Discipline',
    'General Helpdesk',
  ];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted) {
        setState(() {
          _studentData = doc.data();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openLodgeGrievanceDialog() {
    String selectedCat = _categories.first;
    final subjectController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Lodge Official Grievance',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCat,
                      dropdownColor: AppColors.surfaceVariant,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Grievance Category *',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setDialogState(() => selectedCat = v!),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: subjectController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Subject required' : null,
                      decoration: InputDecoration(
                        labelText: 'Subject / Issue Heading *',
                        hintText: 'e.g. Bus Route 4 delayed daily',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: descController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Detailed description required' : null,
                      decoration: InputDecoration(
                        labelText: 'Explain Your Issue in Detail *',
                        hintText: 'Provide specific dates, bus number, or subject details...',
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
                      final studentName = _studentData?['name'] ?? 'Student';
                      final initialMsg = GrievanceMessage(
                        senderUid: user?.uid ?? '',
                        senderName: studentName,
                        senderRole: 'student',
                        message: descController.text.trim(),
                        timestamp: DateTime.now(),
                      );

                      final g = GrievanceModel(
                        id: '',
                        studentUid: user?.uid ?? 'student_uid',
                        studentName: studentName,
                        enrollmentNo: _studentData?['enrollmentNo'] ?? '0103CS221001',
                        branch: _studentData?['branch'] ?? 'CSE',
                        year: _studentData?['year'] ?? '3rd Year',
                        category: selectedCat,
                        subject: subjectController.text.trim(),
                        description: descController.text.trim(),
                        status: 'OPEN',
                        isSatisfied: false,
                        thread: [initialMsg],
                        createdAt: DateTime.now(),
                      );

                      await GrievanceService.submitGrievance(g);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Grievance registered. Administration & Faculty have been notified.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
              child: Text(
                isSubmitting ? 'Submitting...' : 'Submit Grievance',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFollowUpDialog(GrievanceModel g) {
    final replyController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Send Follow-up Reply',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Regarding: ${g.subject}', style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: replyController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your message' : null,
                  decoration: InputDecoration(
                    labelText: 'What is still pending / unresolved? *',
                    hintText: 'Explain why the faculty reply did not fully resolve your issue...',
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
                      await GrievanceService.studentFollowUp(
                        grievanceId: g.id,
                        followUpText: replyController.text.trim(),
                        studentName: _studentData?['name'] ?? 'Student',
                        studentUid: user?.uid ?? '',
                      );

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Follow-up message sent to faculty!'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
              child: Text(isSubmitting ? 'Sending...' : 'Send Message'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResolveDialog(GrievanceModel g) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
            SizedBox(width: 8),
            Text('Confirm Resolution', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you satisfied with the faculty/admin response? Marking this grievance as resolved will close this ticket.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: feedbackController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Satisfaction Feedback (Optional)',
                hintText: 'e.g. Issue resolved satisfactorily, thanks!',
                hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not Yet', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await GrievanceService.resolveByStudent(
                grievanceId: g.id,
                feedback: feedbackController.text.trim(),
              );
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 Grievance closed & marked as Resolved by you!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Yes, Mark Resolved', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Student Grievance Hub',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openLodgeGrievanceDialog,
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('Lodge Grievance', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          : StreamBuilder<List<GrievanceModel>>(
              stream: GrievanceService.getStudentGrievances(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
                }

                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.support_agent_rounded, color: AppColors.error, size: 40),
                          ),
                          const SizedBox(height: 16),
                          const Text('No Grievances Lodged',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          const Text(
                            'Facing any academic, bus, fee, or campus issues? Lodge an official ticket here. You have the final say to mark it resolved once satisfied!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textHint, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _openLodgeGrievanceDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Lodge First Grievance', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final g = list[index];
                    final formattedDate = DateFormat('dd MMM, yyyy').format(g.createdAt);

                    Color statusColor = AppColors.warning;
                    String statusLabel = 'OPEN / IN REVIEW';
                    if (g.status == 'FACULTY_REPLIED') {
                      statusColor = const Color(0xFFA78BFA);
                      statusLabel = 'FACULTY REPLIED (ACTION REQUIRED)';
                    } else if (g.status == 'STUDENT_REPLIED') {
                      statusColor = AppColors.info;
                      statusLabel = 'UNDER REVIEW (FOLLOW-UP SENT)';
                    } else if (g.isResolved) {
                      statusColor = AppColors.success;
                      statusLabel = 'RESOLVED & SATISFIED ✓';
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
                          // Header Category & Status Badge
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
                          Text(
                            'Filed on: $formattedDate',
                            style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                          ),

                          // Conversation Thread (if any)
                          if (g.thread.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(color: Colors.white10),
                            const SizedBox(height: 6),
                            const Text('Conversation History:',
                              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...g.thread.map((msg) {
                              final isStudent = msg.senderRole == 'student';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isStudent ? AppColors.surfaceVariant : const Color(0xFF2E1065).withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isStudent ? Colors.white10 : const Color(0xFFA78BFA).withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isStudent ? Icons.person_rounded : Icons.school_rounded,
                                          size: 13,
                                          color: isStudent ? AppColors.secondary : const Color(0xFFA78BFA),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${msg.senderName} (${msg.senderRole.toUpperCase()}):',
                                          style: TextStyle(
                                            color: isStudent ? AppColors.secondary : const Color(0xFFA78BFA),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          DateFormat('dd MMM, hh:mm a').format(msg.timestamp),
                                          style: const TextStyle(color: AppColors.textHint, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(msg.message, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              );
                            }),
                          ],

                          // Prompt for Student Satisfaction when Faculty Replied
                          if (g.status == 'FACULTY_REPLIED' && !g.isResolved) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1B4B),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFA78BFA).withOpacity(0.4)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.help_outline_rounded, color: Color(0xFFA78BFA), size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Are you satisfied with the faculty solution?',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Faculty has provided an official reply. The ticket remains open until you confirm satisfaction.',
                                    style: TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _confirmResolveDialog(g),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.success,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          icon: const Icon(Icons.check_rounded, size: 16),
                                          label: const Text('I am Satisfied (Resolve)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        onPressed: () => _openFollowUpDialog(g),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(color: Colors.white30),
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        icon: const Icon(Icons.reply_rounded, size: 14),
                                        label: const Text('Need More Help', style: TextStyle(fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (g.isResolved) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'Resolution confirmed and closed by student.',
                                    style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
