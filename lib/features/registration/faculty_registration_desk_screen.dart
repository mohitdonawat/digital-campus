import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/campus_models.dart';
import '../../providers/campus_provider.dart';

/// Faculty / Teacher Semester Registration Verification & Approval Desk
class FacultyRegistrationDeskScreen extends StatefulWidget {
  const FacultyRegistrationDeskScreen({super.key});

  @override
  State<FacultyRegistrationDeskScreen> createState() => _FacultyRegistrationDeskScreenState();
}

class _FacultyRegistrationDeskScreenState extends State<FacultyRegistrationDeskScreen> {
  String _selectedFilter = "Pending"; // "All", "Pending", "Approved", "Rejected"
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final allList = provider.semesterRegistrations;

    final pendingList = allList.where((r) => r.status == RegistrationStatus.pending).toList();
    final approvedList = allList.where((r) => r.status == RegistrationStatus.approved).toList();
    final rejectedList = allList.where((r) => r.status == RegistrationStatus.rejected).toList();

    List<SemesterRegistration> filtered;
    if (_selectedFilter == "Pending") {
      filtered = pendingList;
    } else if (_selectedFilter == "Approved") {
      filtered = approvedList;
    } else if (_selectedFilter == "Rejected") {
      filtered = rejectedList;
    } else {
      filtered = allList;
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final query = _searchQuery.toLowerCase();
        return r.studentName.toLowerCase().contains(query) ||
            r.rollNumber.toLowerCase().contains(query) ||
            r.enrollmentNumber.toLowerCase().contains(query);
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Semester Registration Desk",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            Text(
              "Faculty Verification & Student Enrollment Approval",
              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: pendingList.isNotEmpty ? AppColors.warning.withOpacity(0.12) : AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: pendingList.isNotEmpty ? AppColors.warning : AppColors.success,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  pendingList.isNotEmpty ? Icons.hourglass_top_rounded : Icons.check_circle_rounded,
                  size: 13,
                  color: pendingList.isNotEmpty ? AppColors.warning : AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  "${pendingList.length} Pending",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: pendingList.isNotEmpty ? AppColors.warning : AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Metrics Overview Row ───────────────────────────────────────
            _buildVitalsRow(allList.length, pendingList.length, approvedList.length, rejectedList.length),

            const SizedBox(height: 14),

            // ── 2. Search & Filter Bar ────────────────────────────────────────
            _buildSearchAndFilters(allList.length, pendingList.length, approvedList.length, rejectedList.length),

            const SizedBox(height: 14),

            // ── 3. List of Student Registration Forms ─────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "STUDENT REGISTRATIONS (${filtered.length})",
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: 0.5),
                ),
                Text(
                  "Faculty Advisor: Dr. Mohit Donawat",
                  style: const TextStyle(fontSize: 10.5, color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.assignment_turned_in_rounded, size: 44, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    Text(
                      "No registrations found in '$_selectedFilter'",
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted),
                    ),
                  ],
                ),
              )
            else
              ...filtered.map((reg) => _buildRegistrationCard(context, provider, reg)),
          ],
        ),
      ),
    );
  }

  // ── Metrics Row ────────────────────────────────────────────────────────────
  Widget _buildVitalsRow(int total, int pending, int approved, int rejected) {
    return Row(
      children: [
        Expanded(child: _buildMetricTile("Total Forms", total.toString(), const Color(0xFF2563EB))),
        const SizedBox(width: 8),
        Expanded(child: _buildMetricTile("Pending", pending.toString(), const Color(0xFFD97706))),
        const SizedBox(width: 8),
        Expanded(child: _buildMetricTile("Approved", approved.toString(), const Color(0xFF16A34A))),
        const SizedBox(width: 8),
        Expanded(child: _buildMetricTile("Rejected", rejected.toString(), const Color(0xFFDC2626))),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  // ── Search & Filter Bar ────────────────────────────────────────────────────
  Widget _buildSearchAndFilters(int total, int pending, int approved, int rejected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // Search Input
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            style: const TextStyle(fontSize: 12.5),
            decoration: InputDecoration(
              isDense: true,
              hintText: "Search by student name or roll number...",
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = "");
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              filled: true,
              fillColor: AppColors.surfaceSubtle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("Pending ($pending)", "Pending"),
                const SizedBox(width: 8),
                _buildFilterChip("Approved ($approved)", "Approved"),
                const SizedBox(width: 8),
                _buildFilterChip("Rejected ($rejected)", "Rejected"),
                const SizedBox(width: 8),
                _buildFilterChip("All ($total)", "All"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String key) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isSelected ? Colors.white : AppColors.textDark,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceSubtle,
      onSelected: (_) => setState(() => _selectedFilter = key),
    );
  }

  // ── Registration Card ──────────────────────────────────────────────────────
  Widget _buildRegistrationCard(BuildContext context, CampusProvider provider, SemesterRegistration reg) {
    final isPending = reg.status == RegistrationStatus.pending;
    final isApproved = reg.status == RegistrationStatus.approved;
    final isRejected = reg.status == RegistrationStatus.rejected;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPending ? AppColors.warning.withOpacity(0.4) : AppColors.borderLight,
          width: isPending ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: reg.status.color.withOpacity(0.12),
                child: Text(
                  reg.studentName[0],
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: reg.status.color),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reg.studentName,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    Text(
                      "${reg.rollNumber} • Sem ${reg.semester} (${reg.section})",
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: reg.status.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: reg.status.color, width: 1.0),
                ),
                child: Row(
                  children: [
                    Icon(reg.status.icon, size: 12, color: reg.status.color),
                    const SizedBox(width: 4),
                    Text(
                      reg.status.label,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: reg.status.color),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Course and Academic details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Elective Selected:", style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                    Text(
                      reg.selectedElective.courseName,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("CGPA / Credits:", style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  Text(
                    "${reg.currentCgpa} • ${reg.totalCredits} Cr",
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Fee: ${reg.feeCleared ? 'Cleared (${reg.feeReceiptNo})' : 'Pending Fee'}",
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: reg.feeCleared ? const Color(0xFF15803D) : AppColors.error,
                ),
              ),
              Text(
                "Backlogs: ${reg.activeBacklogs}",
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: reg.activeBacklogs == 0 ? AppColors.textMuted : AppColors.error,
                ),
              ),
            ],
          ),

          if (isRejected && reg.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Text(
                "Rejection Reason: ${reg.rejectionReason}",
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF991B1B)),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Actions Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showReviewDossierModal(context, provider, reg),
                  icon: const Icon(Icons.description_outlined, size: 14),
                  label: const Text("Full Dossier", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderLight),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              if (isPending) ...[
                // Quick Reject Button
                IconButton(
                  onPressed: () => _promptRejectionReason(context, provider, reg),
                  icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 18),
                  tooltip: "Reject Registration",
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 6),

                // Quick Approve Button
                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    provider.approveSemesterRegistration(
                      reg.id,
                      "Dr. Mohit Donawat",
                      "Verified and Approved. Credits and eligibility cleared.",
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("✅ Registration Approved for ${reg.studentName}! Notification dispatched."),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 14),
                  label: const Text("Accept", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else if (isApproved) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_rounded, size: 14, color: Color(0xFF16A34A)),
                      SizedBox(width: 4),
                      Text("Enrolled", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
                    ],
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    provider.approveSemesterRegistration(
                      reg.id,
                      "Dr. Mohit Donawat",
                      "Re-verified after clarification. Registration APPROVED.",
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("✅ Re-approved registration for ${reg.studentName}."),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Re-Approve", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Prompt Rejection Reason Dialog ─────────────────────────────────────────
  void _promptRejectionReason(BuildContext context, CampusProvider provider, SemesterRegistration reg) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
              const SizedBox(width: 8),
              Text("Reject ${reg.studentName}'s Form", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please specify the exact academic reason for rejection. This remark will be sent directly as a notification message to the student.",
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted, height: 1.3),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                style: const TextStyle(fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: "e.g. Tuition fee dues pending for Semester 5. Clear receipt and resubmit.",
                  hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceSubtle,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderLight)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = controller.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please write a rejection reason")),
                  );
                  return;
                }
                Navigator.pop(ctx);
                HapticFeedback.heavyImpact();
                provider.rejectSemesterRegistration(reg.id, "Dr. Mohit Donawat", reason);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Form rejected. Message dispatched to ${reg.studentName}."),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Confirm Rejection", style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  // ── Complete Review Dossier BottomSheet ─────────────────────────────────────
  void _showReviewDossierModal(BuildContext context, CampusProvider provider, SemesterRegistration reg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reg.studentName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      Text("${reg.rollNumber} • ${reg.enrollmentNumber}", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vitals
                      Row(
                        children: [
                          Expanded(child: _buildModalMetric("Current CGPA", reg.currentCgpa.toString(), const Color(0xFF2563EB))),
                          const SizedBox(width: 8),
                          Expanded(child: _buildModalMetric("Previous SGPA", reg.previousSgpa.toString(), const Color(0xFF7C3AED))),
                          const SizedBox(width: 8),
                          Expanded(child: _buildModalMetric("Backlogs", reg.activeBacklogs.toString(), reg.activeBacklogs == 0 ? AppColors.success : AppColors.error)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Contact info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            _buildModalRow("Student Contact", reg.studentPhone),
                            const Divider(height: 10),
                            _buildModalRow("Parent / Guardian Phone", reg.parentPhone),
                            const Divider(height: 10),
                            _buildModalRow("Residence Type", reg.hostelOrDayScholar),
                            const Divider(height: 10),
                            _buildModalRow("Fee Receipt", "${reg.feeReceiptNo} (${reg.feeCleared ? 'Verified' : 'Pending'})"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text("SELECTED COURSES & CREDITS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      ...reg.coreCourses.map((c) => _buildCourseItem(c.courseCode, c.courseName, "${c.credits} Cr", "Core")),
                      _buildCourseItem(reg.selectedElective.courseCode, reg.selectedElective.courseName, "${reg.selectedElective.credits} Cr", "Professional Elective"),
                      _buildCourseItem(reg.selectedOpenElective.courseCode, reg.selectedOpenElective.courseName, "${reg.selectedOpenElective.credits} Cr", "Open Elective"),
                      ...reg.labCourses.map((c) => _buildCourseItem(c.courseCode, c.courseName, "${c.credits} Cr", "Lab")),

                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Registered Credits:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A))),
                            Text("${reg.totalCredits} Credits (Valid)", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1D4ED8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _promptRejectionReason(context, provider, reg);
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
                      label: const Text("Reject Form", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        HapticFeedback.heavyImpact();
                        provider.approveSemesterRegistration(
                          reg.id,
                          "Dr. Mohit Donawat",
                          "Verified and Approved. Credits and eligibility cleared.",
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("✅ Registration Approved for ${reg.studentName}!"),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                      label: const Text("Accept & Approve", style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildModalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      ],
    );
  }

  Widget _buildCourseItem(String code, String name, String credits, String badge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.borderLight)),
            child: Text(code, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          Text(credits, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
