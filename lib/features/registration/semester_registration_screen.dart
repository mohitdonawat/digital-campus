import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/campus_models.dart';
import '../../providers/campus_provider.dart';

/// Professional University Semester Course & Academic Registration Screen
class SemesterRegistrationScreen extends StatefulWidget {
  const SemesterRegistrationScreen({super.key});

  @override
  State<SemesterRegistrationScreen> createState() => _SemesterRegistrationScreenState();
}

class _SemesterRegistrationScreenState extends State<SemesterRegistrationScreen> {
  // Elective Selection
  String _selectedElectiveCode = "CS604E-1";
  String _selectedOpenElectiveCode = "OE601-1";

  // Editable Form Controllers
  late TextEditingController _phoneController;
  late TextEditingController _parentPhoneController;
  late TextEditingController _feeReceiptController;
  String _residenceType = "Hostel (Block B - R204)";

  // Declarations
  bool _attendancePledge = true;
  bool _antiRaggingPledge = true;
  bool _isEditing = false;

  final List<SemesterRegistrationCourse> _availableElectives = const [
    SemesterRegistrationCourse(
      courseCode: "CS604E-1",
      courseName: "Deep Learning & Neural Networks",
      credits: 3.0,
      category: "Professional Elective",
    ),
    SemesterRegistrationCourse(
      courseCode: "CS604E-2",
      courseName: "Blockchain & Smart Contracts",
      credits: 3.0,
      category: "Professional Elective",
    ),
    SemesterRegistrationCourse(
      courseCode: "CS604E-3",
      courseName: "Full-Stack Microservices Architecture",
      credits: 3.0,
      category: "Professional Elective",
    ),
  ];

  final List<SemesterRegistrationCourse> _availableOpenElectives = const [
    SemesterRegistrationCourse(
      courseCode: "OE601-1",
      courseName: "Technology Entrepreneurship & Venture Finance",
      credits: 2.0,
      category: "Open Elective",
    ),
    SemesterRegistrationCourse(
      courseCode: "OE601-2",
      courseName: "Intellectual Property Rights & Cyber Laws",
      credits: 2.0,
      category: "Open Elective",
    ),
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CampusProvider>(context, listen: false);
    final reg = provider.currentStudentRegistration;
    _phoneController = TextEditingController(text: reg.studentPhone);
    _parentPhoneController = TextEditingController(text: reg.parentPhone);
    _feeReceiptController = TextEditingController(text: reg.feeReceiptNo);
    _selectedElectiveCode = reg.selectedElective.courseCode;
    _selectedOpenElectiveCode = reg.selectedOpenElective.courseCode;
    _residenceType = reg.hostelOrDayScholar;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _parentPhoneController.dispose();
    _feeReceiptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final registration = provider.currentStudentRegistration;
    final isSubmitted = registration.status != RegistrationStatus.rejected || !_isEditing;

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
              "Semester Registration",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            Text(
              "Session 2026-27 • Semester 6 Enrollment",
              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: registration.status.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: registration.status.color, width: 1.2),
            ),
            child: Row(
              children: [
                Icon(registration.status.icon, size: 13, color: registration.status.color),
                const SizedBox(width: 4),
                Text(
                  registration.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: registration.status.color,
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
            // ── 1. Top Status Banner ─────────────────────────────────────────
            _buildStatusHeaderCard(context, registration),

            const SizedBox(height: 16),

            // ── 2. Institution Brand Header ──────────────────────────────────
            _buildInstitutionHeader(),

            const SizedBox(height: 16),

            // ── 3. Section I: Student Particulars ────────────────────────────
            _buildSectionHeader(Icons.person_rounded, "SECTION I: CANDIDATE IDENTITY"),
            const SizedBox(height: 10),
            _buildCandidateIdentityCard(registration),

            const SizedBox(height: 16),

            // ── 4. Section II: Prior Academic Eligibility ────────────────────
            _buildSectionHeader(Icons.military_tech_rounded, "SECTION II: PRIOR ACADEMIC RECORD"),
            const SizedBox(height: 10),
            _buildAcademicStandingCard(registration),

            const SizedBox(height: 16),

            // ── 5. Section III: Course Registration (Core & Electives) ───────
            _buildSectionHeader(Icons.menu_book_rounded, "SECTION III: COURSE REGISTRATION & CREDITS"),
            const SizedBox(height: 10),
            _buildCourseSelectionCard(registration),

            const SizedBox(height: 16),

            // ── 6. Section IV: Fee Clearance ─────────────────────────────────
            _buildSectionHeader(Icons.receipt_long_rounded, "SECTION IV: TUITION CLEARANCE"),
            const SizedBox(height: 10),
            _buildFeeClearanceCard(registration),

            const SizedBox(height: 16),

            // ── 7. Section V: Undertaking & Declaration ──────────────────────
            _buildSectionHeader(Icons.verified_user_rounded, "SECTION V: FORMAL UNDERTAKING"),
            const SizedBox(height: 10),
            _buildUndertakingCard(),

            const SizedBox(height: 24),

            // ── 8. Form Actions ──────────────────────────────────────────────
            _buildActionButtons(context, provider, registration),
          ],
        ),
      ),
    );
  }

  // ── Status Header ──────────────────────────────────────────────────────────
  Widget _buildStatusHeaderCard(BuildContext context, SemesterRegistration reg) {
    if (reg.status == RegistrationStatus.approved) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Registration Approved & Enrolled",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF15803D)),
                      ),
                      Text(
                        "Verified by Faculty Advisor • Digital Enrollment Slip Active",
                        style: TextStyle(fontSize: 11, color: Color(0xFF166534)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (reg.facultyRemarks != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded, size: 16, color: Color(0xFF16A34A)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Faculty Remarks (${reg.reviewedByFaculty}): ${reg.facultyRemarks}",
                        style: const TextStyle(fontSize: 11, color: Color(0xFF14532D), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showOfficialSlipModal(context, reg),
                icon: const Icon(Icons.print_rounded, size: 15),
                label: const Text("View Official Registration Slip", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (reg.status == RegistrationStatus.rejected) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Registration Form Rejected",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFB91C1C)),
                      ),
                      Text(
                        "Faculty returned form for correction. Update details & resubmit.",
                        style: TextStyle(fontSize: 11, color: Color(0xFF991B1B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "FACULTY REJECTION REASON:",
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFB91C1C)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    reg.rejectionReason ?? "Please check with Department Faculty Advisor.",
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF7F1D1D), height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Default: Pending Verification
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFD97706),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Awaiting Faculty Verification",
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                ),
                SizedBox(height: 2),
                Text(
                  "Form submitted to Dr. Mohit Donawat (Faculty Advisor). You will be notified once reviewed.",
                  style: TextStyle(fontSize: 10.5, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Institution Header ─────────────────────────────────────────────────────
  Widget _buildInstitutionHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                "assets/images/college_logo.png",
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "APEX INSTITUTE OF TECHNOLOGY",
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 0.3),
                ),
                Text(
                  "Autonomous Institution • Affiliated to RGPV Bhopal",
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
                SizedBox(height: 2),
                Text(
                  "FORM NO: REG-2026-601 • SEMESTER 6 (EVEN TERM)",
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Candidate Identity Card ────────────────────────────────────────────────
  Widget _buildCandidateIdentityCard(SemesterRegistration reg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildInfoRow("Student Full Name", reg.studentName),
          const Divider(height: 14),
          _buildInfoRow("Roll / Reg No", "${reg.rollNumber} (${reg.enrollmentNumber})"),
          const Divider(height: 14),
          _buildInfoRow("Degree & Department", "B.Tech ${reg.branch}"),
          const Divider(height: 14),
          _buildInfoRow("Semester & Section", "Semester ${reg.semester} • ${reg.section}"),
          const Divider(height: 14),
          _buildEditablePhoneRow("Student Mobile", _phoneController),
          const Divider(height: 14),
          _buildEditablePhoneRow("Parent / Guardian Phone", _parentPhoneController),
          const Divider(height: 14),
          _buildInfoRow("Hostel / Day Scholar", _residenceType),
        ],
      ),
    );
  }

  // ── Prior Academic Record Card ─────────────────────────────────────────────
  Widget _buildAcademicStandingCard(SemesterRegistration reg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricTile("Previous Sem SGPA", reg.previousSgpa.toString(), const Color(0xFF2563EB)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile("Cumulative CGPA", reg.currentCgpa.toString(), const Color(0xFF7C3AED)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile("Active Backlogs", "${reg.activeBacklogs} Backlogs", AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_rounded, size: 14, color: Color(0xFF16A34A)),
                SizedBox(width: 6),
                Text(
                  "Academic Eligibility: Cleared for Regular 6th Semester Enrollment",
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Course Selection Card ──────────────────────────────────────────────────
  Widget _buildCourseSelectionCard(SemesterRegistration reg) {
    final canEdit = reg.status != RegistrationStatus.approved;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Core Courses Sub-heading
          const Text(
            "1. MANDATORY CORE THEORY COURSES (11.0 Credits)",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 6),
          ...reg.coreCourses.map((c) => _buildCourseRow(c.courseCode, c.courseName, "${c.credits} Cr")),

          const SizedBox(height: 14),

          // Professional Elective Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "2. PROFESSIONAL ELECTIVE (Select 1 • 3.0 Cr)",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text("Choice 1 of 3", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._availableElectives.map((elec) {
            final isSelected = _selectedElectiveCode == elec.courseCode;
            return InkWell(
              onTap: canEdit ? () => setState(() => _selectedElectiveCode = elec.courseCode) : null,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2563EB) : AppColors.borderLight,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      size: 16,
                      color: isSelected ? const Color(0xFF2563EB) : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(elec.courseName, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: AppColors.textDark)),
                          Text("${elec.courseCode} • 3.0 Credits", style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 14),

          // Open Elective Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "3. OPEN ELECTIVE / HUMANITIES (Select 1 • 2.0 Cr)",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF0D9488).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text("Choice 1 of 2", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF0D9488))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._availableOpenElectives.map((elec) {
            final isSelected = _selectedOpenElectiveCode == elec.courseCode;
            return InkWell(
              onTap: canEdit ? () => setState(() => _selectedOpenElectiveCode = elec.courseCode) : null,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF0FDFA) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0D9488) : AppColors.borderLight,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      size: 16,
                      color: isSelected ? const Color(0xFF0D9488) : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(elec.courseName, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: AppColors.textDark)),
                          Text("${elec.courseCode} • 2.0 Credits", style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 14),

          // Laboratory & Project Courses
          const Text(
            "4. PRACTICALS & CAPSTONE LABS (5.0 Credits)",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 6),
          ...reg.labCourses.map((c) => _buildCourseRow(c.courseCode, c.courseName, "${c.credits} Cr")),

          const SizedBox(height: 14),

          // Total Credits Highlight Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "TOTAL REGISTERED CREDITS",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                Text(
                  "21.0 / 24.0 Credits ✅",
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF93C5FD)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Fee Clearance Card ─────────────────────────────────────────────────────
  Widget _buildFeeClearanceCard(SemesterRegistration reg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tuition Fee Clearance", style: TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: const Text("Verified & Paid", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
              ),
            ],
          ),
          const Divider(height: 16),
          _buildInfoRow("Fee Receipt Number", reg.feeReceiptNo),
          const Divider(height: 16),
          _buildInfoRow("Library & Hostel Clearance", "No Dues Pending (Cleared on 28 Sep)"),
        ],
      ),
    );
  }

  // ── Undertaking & Declarations ─────────────────────────────────────────────
  Widget _buildUndertakingCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: _attendancePledge,
            onChanged: (val) => setState(() => _attendancePledge = val ?? false),
            dense: true,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              "75% Minimum Attendance Commitment: I pledge to maintain ≥75% attendance in all theory & lab courses to avoid university detention.",
              style: TextStyle(fontSize: 11, color: AppColors.textDark, height: 1.3),
            ),
          ),
          const SizedBox(height: 6),
          CheckboxListTile(
            value: _antiRaggingPledge,
            onChanged: (val) => setState(() => _antiRaggingPledge = val ?? false),
            dense: true,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              "Anti-Ragging & Code of Conduct: I accept all Autonomous University ordinances, disciplinary policies, and academic integrity regulations.",
              style: TextStyle(fontSize: 11, color: AppColors.textDark, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context, CampusProvider provider, SemesterRegistration reg) {
    if (reg.status == RegistrationStatus.approved) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showOfficialSlipModal(context, reg),
          icon: const Icon(Icons.download_rounded, size: 16),
          label: const Text("Download Registration Slip (PDF)", style: TextStyle(fontWeight: FontWeight.w800)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (!_attendancePledge || !_antiRaggingPledge)
                ? null
                : () {
                    HapticFeedback.heavyImpact();
                    _submitForm(context, provider, reg);
                  },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: Text(
              reg.status == RegistrationStatus.rejected ? "Resubmit Form to Faculty Advisor" : "Submit Semester Registration",
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm(BuildContext context, CampusProvider provider, SemesterRegistration existing) {
    final chosenElective = _availableElectives.firstWhere(
      (e) => e.courseCode == _selectedElectiveCode,
      orElse: () => _availableElectives.first,
    );
    final chosenOpenElective = _availableOpenElectives.firstWhere(
      (e) => e.courseCode == _selectedOpenElectiveCode,
      orElse: () => _availableOpenElectives.first,
    );

    final updated = existing.copyWith(
      selectedElective: chosenElective,
      selectedOpenElective: chosenOpenElective,
      studentPhone: _phoneController.text.trim(),
      parentPhone: _parentPhoneController.text.trim(),
      status: RegistrationStatus.pending,
      rejectionReason: null,
      facultyRemarks: null,
    );

    provider.submitSemesterRegistration(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Semester Registration Form submitted! Dispatched to Faculty Advisor for verification."),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // ── Official Registration Slip Modal ───────────────────────────────────────
  void _showOfficialSlipModal(BuildContext context, SemesterRegistration reg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Official Enrollment Slip", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            const Text("APEX INSTITUTE OF TECHNOLOGY • AUTONOMOUS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                            const Text("ACADEMIC ENROLLMENT SLIP • EVEN TERM 2026-27", style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            const SizedBox(height: 10),
                            _buildInfoRow("Student Name", reg.studentName),
                            _buildInfoRow("Roll Number", reg.rollNumber),
                            _buildInfoRow("Enrollment No", reg.enrollmentNumber),
                            _buildInfoRow("Program", "B.Tech Computer Science & Engg"),
                            _buildInfoRow("Semester & Sec", "Semester ${reg.semester} • ${reg.section}"),
                            _buildInfoRow("Approved By", reg.reviewedByFaculty ?? "Faculty Advisor"),
                            _buildInfoRow("Verification Status", "APPROVED & ENROLLED ✅"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text("REGISTERED COURSES & CREDITS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      ...reg.coreCourses.map((c) => _buildCourseRow(c.courseCode, c.courseName, "${c.credits} Cr")),
                      _buildCourseRow(reg.selectedElective.courseCode, reg.selectedElective.courseName, "${reg.selectedElective.credits} Cr"),
                      _buildCourseRow(reg.selectedOpenElective.courseCode, reg.selectedOpenElective.courseName, "${reg.selectedOpenElective.credits} Cr"),
                      ...reg.labCourses.map((c) => _buildCourseRow(c.courseCode, c.courseName, "${c.credits} Cr")),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.qr_code_2_rounded, size: 40, color: Color(0xFF15803D)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Digital Signature Hash: 0x9b42...a98f12\nTamper-proof academic registration record generated on DigiLocker / ABC network.",
                                style: TextStyle(fontSize: 9.5, color: Color(0xFF166534), height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Enrollment Slip PDF downloaded to local documents!"), backgroundColor: AppColors.success),
                    );
                  },
                  icon: const Icon(Icons.file_download_outlined, size: 16),
                  label: const Text("Save Official PDF Copy"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Helper UI Widgets ──────────────────────────────────────────────────────
  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: 0.4),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditablePhoneRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
          const Spacer(),
          SizedBox(
            width: 140,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildCourseRow(String code, String name, String credits) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
      ),
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
