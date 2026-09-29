import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../models/assignment_model.dart';
import '../services/assignment_service.dart';

class TeacherAssignmentsScreen extends StatefulWidget {
  const TeacherAssignmentsScreen({super.key});

  @override
  State<TeacherAssignmentsScreen> createState() => _TeacherAssignmentsScreenState();
}

class _TeacherAssignmentsScreenState extends State<TeacherAssignmentsScreen> {
  bool _filterLastSixMonths = false;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Faculty Assignments Portal',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 6-Month Record Filter Action
          IconButton(
            onPressed: () {
              setState(() => _filterLastSixMonths = !_filterLastSixMonths);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_filterLastSixMonths
                      ? 'Showing assignments from past 6 months'
                      : 'Showing all recorded assignments'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(
              _filterLastSixMonths ? Icons.history_toggle_off_rounded : Icons.history_rounded,
              color: _filterLastSixMonths ? AppColors.secondary : Colors.white70,
            ),
            tooltip: '6-Month History Filter',
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.teacherCreateAssignment),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Assignment', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Retention & Status Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surfaceVariant.withOpacity(0.5),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.secondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _filterLastSixMonths
                        ? '6-Month Active Window: Filtered for current academic session'
                        : '6-Month Cloud Retention: All assignment submissions stored securely',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _filterLastSixMonths = !_filterLastSixMonths),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    _filterLastSixMonths ? 'View All' : 'Past 6M',
                    style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<AssignmentModel>>(
              stream: AssignmentService.getTeacherAssignments(uid, filterLastSixMonths: _filterLastSixMonths),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
                }

                final assignments = snapshot.data ?? [];
                if (assignments.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.assignment_add, color: AppColors.secondary, size: 36),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Assignments Found',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Create assignments for your students. You can view submissions, check PDFs/links, and assign grades & reviews.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textHint, fontSize: 12.5),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.teacherCreateAssignment),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Create Assignment Now', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final a = assignments[index];
                    final formattedDue = DateFormat('dd MMM, yyyy').format(a.dueDate);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.assignment_rounded, color: AppColors.secondary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.title,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${a.subject} • ${a.targetBranch} (${a.targetYear}) • Sec ${a.targetSection}',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                                ),
                                child: Text(
                                  'Due $formattedDue',
                                  style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 10.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),

                          if (a.description.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              a.description,
                              style: const TextStyle(color: AppColors.textHint, fontSize: 12.5),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          if (a.attachmentUrl != null && a.attachmentUrl!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _launchExternalUrl(a.attachmentUrl!),
                              child: Row(
                                children: [
                                  const Icon(Icons.attachment_rounded, size: 14, color: AppColors.secondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Question Paper / Resource Link: ${a.attachmentUrl}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppColors.secondary, fontSize: 11.5, decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 6),

                          // Real-time Submissions Stream & Action Button
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('assignment_submissions')
                                .where('assignmentId', isEqualTo: a.id)
                                .snapshots(),
                            builder: (context, subSnap) {
                              final count = subSnap.data?.size ?? 0;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: count > 0 ? AppColors.success.withOpacity(0.15) : Colors.white.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: count > 0 ? AppColors.success.withOpacity(0.4) : Colors.white10,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          count > 0 ? Icons.check_circle_outline_rounded : Icons.pending_actions_rounded,
                                          size: 13,
                                          color: count > 0 ? AppColors.success : AppColors.textHint,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '$count Student${count == 1 ? '' : 's'} Submitted',
                                          style: TextStyle(
                                            color: count > 0 ? AppColors.success : AppColors.textHint,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _showSubmissionsModal(context, a),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.rate_review_rounded, size: 14),
                                    label: const Text('View & Grade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              );
                            },
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

  void _showSubmissionsModal(BuildContext context, AssignmentModel assignment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131B2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => StreamBuilder<List<AssignmentSubmissionModel>>(
          stream: AssignmentService.getAssignmentSubmissions(assignment.id),
          builder: (context, snap) {
            final submissions = snap.data ?? [];
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submissions (${submissions.length})',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            Text(
                              assignment.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.secondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10),
                  if (submissions.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('No students have submitted yet.', style: TextStyle(color: AppColors.textHint)),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: submissions.length,
                        itemBuilder: (context, i) {
                          final s = submissions[i];
                          final timeStr = DateFormat('dd MMM, hh:mm a').format(s.submittedAt);
                          final isGraded = s.status == 'GRADED' && s.grade != null;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isGraded ? AppColors.success.withOpacity(0.4) : Colors.white10,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: AppColors.secondary.withOpacity(0.2),
                                            child: Text(
                                              s.studentName.isNotEmpty ? s.studentName[0].toUpperCase() : 'S',
                                              style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              s.studentName,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isGraded ? AppColors.success.withOpacity(0.2) : const Color(0xFFF59E0B).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isGraded ? AppColors.success : const Color(0xFFF59E0B),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        isGraded ? 'GRADED: ${s.grade}' : 'PENDING REVIEW',
                                        style: TextStyle(
                                          color: isGraded ? AppColors.success : const Color(0xFFF59E0B),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Roll: ${s.rollNo.isNotEmpty ? s.rollNo : "-"} • Enroll: ${s.enrollmentNo} • Sec ${s.section} • $timeStr',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s.submissionText,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                if (s.fileUrl != null && s.fileUrl!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () => _launchExternalUrl(s.fileUrl!),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.picture_as_pdf_rounded, size: 14, color: AppColors.secondary),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Attached File/Link: ${s.fileUrl}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: AppColors.secondary, fontSize: 11, decoration: TextDecoration.underline),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (s.feedback != null && s.feedback!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Review Remarks: ${s.feedback}',
                                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8), fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _openReviewAndGradeDialog(context, s, assignment),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                    ),
                                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                                    label: Text(
                                      isGraded ? 'Update Grade & Review' : 'Grade & Review Now',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openReviewAndGradeDialog(
    BuildContext context,
    AssignmentSubmissionModel submission,
    AssignmentModel assignment,
  ) {
    final gradeController = TextEditingController(text: submission.grade ?? '');
    final feedbackController = TextEditingController(text: submission.feedback ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (dlgCtx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.rate_review_rounded, color: AppColors.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Review: ${submission.studentName}',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${assignment.title} • Max Marks: ${assignment.totalMarks}',
                      style: const TextStyle(color: AppColors.secondary, fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),

                    // Student's answer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Student Submission:', style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(submission.submissionText, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          if (submission.fileUrl != null && submission.fileUrl!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _launchExternalUrl(submission.fileUrl!),
                              child: Row(
                                children: [
                                  const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.secondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Open Attached PDF / Link: ${submission.fileUrl}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppColors.secondary, fontSize: 11, decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Flexible Grade Field (e.g. A+, O, 9/10, 18/20, etc.)
                    TextFormField(
                      controller: gradeController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a grade or marks' : null,
                      decoration: InputDecoration(
                        labelText: 'Enter Grade / Marks (e.g. A+, O, 18/${assignment.totalMarks}, 9/10) *',
                        hintText: 'Flexible: A+, B, 18/${assignment.totalMarks}, Excellent, etc.',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 11.5),
                        prefixIcon: const Icon(Icons.military_tech_rounded, color: AppColors.secondary),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Review & Feedback remarks
                    TextFormField(
                      controller: feedbackController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Teacher Review & Feedback Remarks',
                        hintText: 'e.g. Well written logic, need to improve conclusion...',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 11.5),
                        prefixIcon: const Icon(Icons.comment_rounded, color: AppColors.secondary),
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
              onPressed: () => Navigator.pop(dlgCtx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDlgState(() => isSaving = true);

                      await AssignmentService.gradeAndReviewSubmission(
                        submissionId: submission.id,
                        grade: gradeController.text.trim(),
                        feedback: feedbackController.text.trim(),
                      );

                      if (!dlgCtx.mounted) return;
                      Navigator.pop(dlgCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text('Grade & Review Remarks saved successfully! ✓'),
                        ),
                      );
                    },
              child: Text(isSaving ? 'Saving...' : 'Save Grade & Review', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchExternalUrl(String urlStr) async {
    try {
      final uri = Uri.parse(urlStr.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }
}
