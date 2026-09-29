import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../models/assignment_model.dart';
import '../services/assignment_service.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  const StudentAssignmentsScreen({super.key});

  @override
  State<StudentAssignmentsScreen> createState() => _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState extends State<StudentAssignmentsScreen> {
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;
  int _selectedFilterTab = 0; // 0: All, 1: Pending Dues, 2: Submitted, 3: Graded

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

  void _openSubmitDialog(AssignmentModel assignment, {AssignmentSubmissionModel? existingSubmission}) {
    final submissionController = TextEditingController(text: existingSubmission?.submissionText ?? '');
    final fileUrlController = TextEditingController(text: existingSubmission?.fileUrl ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            existingSubmission != null ? 'Update Submission' : 'Submit: ${assignment.title}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
                      'Subject: ${assignment.subject} (${assignment.totalMarks} Marks)',
                      style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    // Written Solution Field
                    TextFormField(
                      controller: submissionController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your submission text or summary' : null,
                      decoration: InputDecoration(
                        labelText: 'Solution / Assignment Answer *',
                        hintText: 'Enter your answer, summary, or report description...',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // PDF / Document / Cloud Link Field
                    TextFormField(
                      controller: fileUrlController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'PDF / Google Drive / GitHub Link (Optional)',
                        hintText: 'Paste link to PDF, Drive folder, or document...',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                        prefixIcon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.secondary, size: 20),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '💡 Tip: Upload your PDF to Google Drive and paste the shareable link here.',
                      style: TextStyle(fontSize: 10.5, color: Colors.white.withOpacity(0.55)),
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
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSubmitting = true);

                      final user = FirebaseAuth.instance.currentUser;
                      final sub = AssignmentSubmissionModel(
                        id: existingSubmission?.id ?? '',
                        assignmentId: assignment.id,
                        studentUid: user?.uid ?? 'student_uid',
                        studentName: _studentData?['name'] ?? 'Student',
                        enrollmentNo: _studentData?['enrollmentNo'] ?? '0103CS221001',
                        rollNo: _studentData?['rollNo'] ?? '',
                        branch: _studentData?['branch'] ?? 'CSE',
                        section: _studentData?['section'] ?? 'A',
                        submissionText: submissionController.text.trim(),
                        fileUrl: fileUrlController.text.trim().isEmpty ? null : fileUrlController.text.trim(),
                        submittedAt: DateTime.now(),
                      );

                      await AssignmentService.submitAssignment(sub);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Assignment submitted to professor successfully! ✓'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
              child: Text(
                isSubmitting ? 'Submitting...' : 'Submit Now',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final branch = _studentData?['branch'] ?? 'CSE';
    final year = _studentData?['year'] ?? '3rd Year';
    final semester = _studentData?['semester'] ?? 'ALL';
    final section = _studentData?['section'] ?? 'ALL';
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Assignments & Homework',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          : StreamBuilder<List<AssignmentModel>>(
              stream: AssignmentService.getStudentAssignments(
                branch: branch,
                year: year,
                semester: semester,
                section: section,
              ),
              builder: (context, assignmentSnap) {
                if (assignmentSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
                }

                final assignments = assignmentSnap.data ?? [];

                return StreamBuilder<List<AssignmentSubmissionModel>>(
                  stream: AssignmentService.getStudentSubmissions(myUid),
                  builder: (context, subSnap) {
                    final submissions = subSnap.data ?? [];
                    final subMap = {for (var s in submissions) s.assignmentId: s};

                    // Compute statistics
                    final totalAssigned = assignments.length;
                    final totalSubmitted = assignments.where((a) => subMap.containsKey(a.id)).length;
                    final totalDues = totalAssigned - totalSubmitted;
                    final totalGraded = assignments.where((a) {
                      final sub = subMap[a.id];
                      return sub != null && sub.status == 'GRADED';
                    }).length;

                    // Filter list based on selected tab
                    final filteredAssignments = assignments.where((a) {
                      final hasSub = subMap.containsKey(a.id);
                      final sub = subMap[a.id];
                      if (_selectedFilterTab == 1) return !hasSub; // Pending Dues
                      if (_selectedFilterTab == 2) return hasSub; // Submitted
                      if (_selectedFilterTab == 3) return sub != null && sub.status == 'GRADED'; // Graded
                      return true; // All
                    }).toList();

                    return Column(
                      children: [
                        // Top Summary Metrics
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Row(
                            children: [
                              _metricBox('Total Assigned', '$totalAssigned', const Color(0xFF38BDF8), Icons.assignment_rounded),
                              const SizedBox(width: 8),
                              _metricBox('Submitted', '$totalSubmitted', AppColors.success, Icons.check_circle_rounded),
                              const SizedBox(width: 8),
                              _metricBox('Dues / Pending', '$totalDues', totalDues > 0 ? const Color(0xFFEF4444) : Colors.white60, Icons.pending_actions_rounded),
                              const SizedBox(width: 8),
                              _metricBox('Graded', '$totalGraded', const Color(0xFFF59E0B), Icons.military_tech_rounded),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Filter Segment Tabs
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              _filterTab(0, 'All ($totalAssigned)'),
                              const SizedBox(width: 8),
                              _filterTab(1, 'Pending Dues ($totalDues)'),
                              const SizedBox(width: 8),
                              _filterTab(2, 'Submitted ($totalSubmitted)'),
                              const SizedBox(width: 8),
                              _filterTab(3, 'Graded & Reviewed ($totalGraded)'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Assignments List
                        Expanded(
                          child: filteredAssignments.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary.withOpacity(0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.assignment_turned_in_rounded, color: AppColors.secondary, size: 34),
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          _selectedFilterTab == 1 ? 'No Pending Dues! 🎉' : 'No Assignments in this view',
                                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _selectedFilterTab == 1
                                              ? 'Great job! You have completed all assignments assigned to your batch.'
                                              : 'Check back later for updates from your professors.',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                                  itemCount: filteredAssignments.length,
                                  itemBuilder: (context, index) {
                                    final a = filteredAssignments[index];
                                    final sub = subMap[a.id];
                                    final hasSubmitted = sub != null;
                                    final isGraded = sub?.status == 'GRADED' && sub?.grade != null;
                                    final formattedDue = DateFormat('dd MMM, yyyy').format(a.dueDate);
                                    final isOverdue = DateTime.now().isAfter(a.dueDate) && !hasSubmitted;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.cardGradient,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isGraded
                                              ? const Color(0xFFF59E0B).withOpacity(0.5)
                                              : hasSubmitted
                                                  ? AppColors.success.withOpacity(0.4)
                                                  : isOverdue
                                                      ? const Color(0xFFEF4444).withOpacity(0.5)
                                                      : AppColors.primary.withOpacity(0.35),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: (hasSubmitted ? AppColors.success : (isOverdue ? const Color(0xFFEF4444) : const Color(0xFFF59E0B))).withOpacity(0.15),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  hasSubmitted ? Icons.check_circle_rounded : Icons.assignment_rounded,
                                                  color: hasSubmitted ? AppColors.success : (isOverdue ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)),
                                                  size: 20,
                                                ),
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
                                                      '${a.subject} • by ${a.teacherName}',
                                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                                decoration: BoxDecoration(
                                                  color: (hasSubmitted ? AppColors.success : (isOverdue ? const Color(0xFFEF4444) : const Color(0xFFF59E0B))).withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: hasSubmitted ? AppColors.success : (isOverdue ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)),
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Text(
                                                  hasSubmitted ? 'Submitted' : (isOverdue ? 'Overdue ($formattedDue)' : 'Due $formattedDue'),
                                                  style: TextStyle(
                                                    color: hasSubmitted ? AppColors.success : (isOverdue ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)),
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          if (a.description.isNotEmpty) ...[
                                            const SizedBox(height: 10),
                                            Text(
                                              a.description,
                                              style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                                            ),
                                          ],

                                          // Teacher Question Paper Link
                                          if (a.attachmentUrl != null && a.attachmentUrl!.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            InkWell(
                                              onTap: () => _launchExternalUrl(a.attachmentUrl!),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.description_rounded, size: 14, color: AppColors.secondary),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      'Resource / Question Link: ${a.attachmentUrl}',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(color: AppColors.secondary, fontSize: 11, decoration: TextDecoration.underline),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],

                                          // Teacher Review & Grade Callout (If Graded!)
                                          if (isGraded && sub != null) ...[
                                            const SizedBox(height: 12),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF59E0B).withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.military_tech_rounded, color: Color(0xFFFBBF24), size: 18),
                                                          const SizedBox(width: 6),
                                                          Text(
                                                            'GRADE AWARDED: ${sub.grade ?? ""}',
                                                            style: const TextStyle(
                                                              color: Color(0xFFFBBF24),
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w900,
                                                              letterSpacing: 0.5,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        'Max: ${a.totalMarks}',
                                                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                                                      ),
                                                    ],
                                                  ),
                                                  if (sub.feedback != null && sub.feedback!.isNotEmpty) ...[
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      'Teacher Review: "${sub.feedback!}"',
                                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.italic),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ] else if (hasSubmitted) ...[
                                            const SizedBox(height: 10),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.04),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.hourglass_top_rounded, size: 14, color: AppColors.secondary),
                                                  const SizedBox(width: 6),
                                                  const Text(
                                                    'Submission under review by your professor',
                                                    style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],

                                          const SizedBox(height: 12),
                                          const Divider(color: Colors.white10),
                                          const SizedBox(height: 4),

                                          // Bottom action row
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Total Marks: ${a.totalMarks}',
                                                style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.bold),
                                              ),
                                              if (!hasSubmitted)
                                                ElevatedButton.icon(
                                                  onPressed: () => _openSubmitDialog(a),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.secondary,
                                                    foregroundColor: Colors.black,
                                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                    minimumSize: Size.zero,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  icon: const Icon(Icons.upload_rounded, size: 15),
                                                  label: const Text('Submit Assignment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                                )
                                              else
                                                OutlinedButton.icon(
                                                  onPressed: () => _openSubmitDialog(a, existingSubmission: sub),
                                                  style: OutlinedButton.styleFrom(
                                                    side: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                    minimumSize: Size.zero,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  icon: const Icon(Icons.edit_note_rounded, size: 14, color: AppColors.secondary),
                                                  label: const Text('Edit Submission', style: TextStyle(color: AppColors.secondary, fontSize: 11)),
                                                ),
                                            ],
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
                );
              },
            ),
    );
  }

  Widget _metricBox(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterTab(int index, String title) {
    final isActive = _selectedFilterTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilterTab = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.secondary : Colors.white10),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white70,
            fontSize: 11.5,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
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
