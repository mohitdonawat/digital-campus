import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_chip.dart';
import '../../core/services/document_download_service.dart';
import '../../providers/campus_provider.dart';

class SemesterRegistrationScreen extends StatefulWidget {
  const SemesterRegistrationScreen({super.key});

  @override
  State<SemesterRegistrationScreen> createState() => _SemesterRegistrationScreenState();
}

class _SemesterRegistrationScreenState extends State<SemesterRegistrationScreen> {
  final Map<String, bool> _selectedCourses = {
    "CS-601: Machine Learning & Applied AI (Core 4 Credits)": true,
    "CS-602: Computer Networks & Network Security (Core 4 Credits)": true,
    "CS-603: Cloud Computing & DevOps (Core 3 Credits)": true,
    "CS-604: Compiler Design & Automata Theory (Core 4 Credits)": true,
    "CS-605: Mobile Application Development with Flutter (Elective 3 Credits)": true,
    "CS-606: Big Data Analytics & Distributed Systems (Open Elective 3 Credits)": false,
  };

  final bool _isSubmitted = true;
  final String _approvalStatus = "Approved by HOD Dr. Mohit Donawat";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final student = provider.student;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Semester Course Registration"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: CustomChip(
                label: "NEP 2020 Credit System",
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Registration Status Hero Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.how_to_reg_rounded, color: AppColors.success, size: 22),
                          SizedBox(width: 8),
                          Text(
                            "Semester 6 Official Enrollment",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      CustomChip(
                        label: _isSubmitted ? "VERIFIED & ATTESTED" : "DRAFT",
                        color: AppColors.success,
                        isSolid: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Student: ${student.name} • Roll: ${student.rollNumber} • Enrollment: ${student.enrollmentNumber}",
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        "Approval Desk: $_approvalStatus",
                        style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Paperless course enrollment verifies prerequisites, checks CGPA standing, and synchronizes credits directly into RGPV / University examination ledger.",
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Enrolled Subject Credits
            const Text(
              "COURSE & ELECTIVE CREDIT SELECTION",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),

            ..._selectedCourses.entries.map((entry) {
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: CheckboxListTile(
                  value: entry.value,
                  onChanged: (val) {
                    setState(() {
                      _selectedCourses[entry.key] = val ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: entry.value ? AppColors.textDark : AppColors.textMuted,
                    ),
                  ),
                  subtitle: Text(
                    entry.value ? "Enrolled • Attendance & Internal Assessment Tracking Active" : "Audit / Optional",
                    style: TextStyle(
                      fontSize: 11,
                      color: entry.value ? AppColors.success : AppColors.textMuted,
                      fontWeight: entry.value ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 14),

            // Academic Credits Total & Download Slip Action
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Academic Credits: 18 / 22",
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Compliant with AICTE Model Curriculum guidelines",
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      DocumentDownloadService.downloadSemesterRegistrationSlipPdf(
                        context,
                        student,
                        _selectedCourses,
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text(
                      "Download Slip",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
