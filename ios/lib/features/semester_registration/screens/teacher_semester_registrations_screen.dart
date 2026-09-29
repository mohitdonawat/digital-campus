import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../models/semester_registration_model.dart';
import '../services/semester_registration_service.dart';
import '../services/semester_registration_pdf_service.dart';

class TeacherSemesterRegistrationsScreen extends StatefulWidget {
  const TeacherSemesterRegistrationsScreen({super.key});

  @override
  State<TeacherSemesterRegistrationsScreen> createState() => _TeacherSemesterRegistrationsScreenState();
}

class _TeacherSemesterRegistrationsScreenState extends State<TeacherSemesterRegistrationsScreen> {
  String _selectedBranch = 'ALL';
  String _selectedSemester = 'ALL';

  final List<String> _branches = ['ALL', ...AppStrings.departments];
  final List<String> _semesters = [
    'ALL',
    '1st Semester',
    '2nd Semester',
    '3rd Semester',
    '4th Semester',
    '5th Semester',
    '6th Semester',
    '7th Semester',
    '8th Semester',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Semester Registrations Review',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surfaceVariant.withOpacity(0.4),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _selectedBranch,
                    dropdownColor: AppColors.surfaceVariant,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      labelText: 'Filter Branch',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) => setState(() => _selectedBranch = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedSemester,
                    dropdownColor: AppColors.surfaceVariant,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      labelText: 'Semester',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) => setState(() => _selectedSemester = v!),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<SemesterRegistrationModel>>(
              stream: SemesterRegistrationService.getAllRegistrations(
                branch: _selectedBranch,
                semester: _selectedSemester,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
                }

                final registrations = snapshot.data ?? [];
                if (registrations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified_user_rounded, color: AppColors.secondary, size: 36),
                          ),
                          const SizedBox(height: 16),
                          const Text('No Semester Registrations Found',
                              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          const Text(
                            'Student submissions for semester enrollment will appear here for HOD verification and attestation.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textHint, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: registrations.length,
                  itemBuilder: (context, index) {
                    final reg = registrations[index];
                    final dateStr = DateFormat('dd MMM, yyyy').format(reg.submittedAt);
                    final isApproved = reg.status == 'APPROVED';
                    final isRejected = reg.status == 'REJECTED';

                    Color statusColor = const Color(0xFFF59E0B);
                    String statusText = 'PENDING APPROVAL';
                    if (isApproved) {
                      statusColor = AppColors.success;
                      statusText = 'APPROVED & VERIFIED ✓';
                    } else if (isRejected) {
                      statusColor = const Color(0xFFEF4444);
                      statusText = 'REJECTED';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: statusColor.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  reg.studentName.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: statusColor, width: 0.8),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Roll: ${reg.rollNo} • Enroll: ${reg.enrollmentNo} • Sec ${reg.section}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                          ),
                          Text(
                            '${reg.branch} • Applying: ${reg.applyingSemester} • $dateStr',
                            style: TextStyle(color: AppColors.secondary.withOpacity(0.9), fontSize: 11.5),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              _infoPill('Last SGPA', '${reg.previousSemSgpa} / 10'),
                              const SizedBox(width: 8),
                              _infoPill('Overall CGPA', '${reg.overallCgpa} / 10'),
                              const SizedBox(width: 8),
                              _infoPill('Backlogs', reg.hasBacklogs ? reg.backlogDetails : 'NIL (Clear)',
                                  isAlert: reg.hasBacklogs),
                            ],
                          ),

                          if (reg.achievements.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '🏆 Achievements: ${reg.achievements}',
                                style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11),
                              ),
                            ),
                          ],

                          if (reg.electiveSubjects.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Electives: ${reg.electiveSubjects}',
                              style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11),
                            ),
                          ],

                          const SizedBox(height: 12),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // View Official PDF
                              TextButton.icon(
                                onPressed: () async {
                                  final bytes = await SemesterRegistrationPdfService.generateOfficialRegistrationForm(reg);
                                  await Printing.layoutPdf(
                                    name: 'IES_REG_${reg.enrollmentNo}_${reg.applyingSemester}',
                                    onLayout: (_) async => bytes,
                                  );
                                },
                                icon: const Icon(Icons.picture_as_pdf_rounded, size: 16, color: AppColors.secondary),
                                label: const Text('View Official PDF', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                              ),

                              // Actions: Approve / Reject
                              if (!isApproved) ...[
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _confirmApproval(context, reg),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text('Approve ✓', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                const Row(
                                  children: [
                                    Icon(Icons.verified_rounded, color: AppColors.success, size: 14),
                                    SizedBox(width: 4),
                                    Text('Verified by Faculty', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
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
      ),
    );
  }

  void _confirmApproval(BuildContext context, SemesterRegistrationModel reg) {
    final remarksController = TextEditingController(text: 'Verified academic credentials and approved for regular semester promotion.');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Approve ${reg.studentName}?', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registering for: ${reg.applyingSemester}', style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
            Text('CGPA: ${reg.overallCgpa} • SGPA: ${reg.previousSemSgpa}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: remarksController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                labelText: 'HOD / Faculty Remarks',
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              await SemesterRegistrationService.updateRegistrationStatus(
                regId: reg.id,
                status: 'APPROVED',
                remarks: remarksController.text.trim(),
              );
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.success,
                  content: Text('Registration approved for ${reg.studentName}! ✓'),
                ),
              );
            },
            child: const Text('Approve & Verify', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _infoPill(String label, String value, {bool isAlert = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isAlert ? const Color(0xFFEF4444).withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 8.5, color: Colors.white.withOpacity(0.6))),
            const SizedBox(height: 1),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isAlert ? const Color(0xFFEF4444) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
