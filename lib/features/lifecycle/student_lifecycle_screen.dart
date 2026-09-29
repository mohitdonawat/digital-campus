import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/document_download_service.dart';
import '../../providers/campus_provider.dart';
import '../account/professional_account_screen.dart';

class StudentLifecycleScreen extends StatefulWidget {
  const StudentLifecycleScreen({super.key});

  @override
  State<StudentLifecycleScreen> createState() => _StudentLifecycleScreenState();
}

class _StudentLifecycleScreenState extends State<StudentLifecycleScreen> {
  bool _showBackSide = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final student = provider.student;

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
              "Digital Student Identity",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            Text(
              "Smart PVC RFID Card • Academic Lifecycle",
              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _showBackSide = !_showBackSide;
              });
            },
            icon: Icon(
              _showBackSide ? Icons.flip_to_front_rounded : Icons.flip_to_back_rounded,
              color: AppColors.primary,
            ),
            tooltip: _showBackSide ? "Show Front Side" : "Flip to Back Side",
          ),
          IconButton(
            onPressed: () {
              DocumentDownloadService.downloadPvcIdCardPdf(context, student);
            },
            icon: const Icon(Icons.download_rounded, color: AppColors.primary),
            tooltip: "Download PDF ID Card",
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfessionalAccountScreen()),
              );
            },
            icon: const Icon(Icons.account_box_rounded, color: AppColors.primary),
            tooltip: "Open Professional Dossier & Portfolio",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── FLIP TOGGLE BUTTON RIBBON ─────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight, width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSideToggle("FRONT IDENTITY", !_showBackSide, () {
                      setState(() => _showBackSide = false);
                    }),
                    _buildSideToggle("BACK RULES & RFID", _showBackSide, () {
                      setState(() => _showBackSide = true);
                    }),
                  ],
                ),
              ),
            ),

            // ── REALISTIC PVC CARD (FRONT / BACK) ─────────────────────────
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _showBackSide
                    ? _buildPvcCardBack(student)
                    : _buildPvcCardFront(student),
              ),
            ),

            const SizedBox(height: 24),

            // ── CARD QUICK ACTIONS ────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() => _showBackSide = !_showBackSide);
                    },
                    icon: const Icon(Icons.flip_camera_android_rounded, size: 16),
                    label: Text(
                      _showBackSide ? "Show Front" : "Flip Card",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.borderLight),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("QR Verification Link copied to clipboard!"),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 16, color: Colors.white),
                    label: const Text(
                      "Share QR Pass",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── ACADEMIC LIFECYCLE TIMELINE ───────────────────────────────
            const Row(
              children: [
                Icon(Icons.timeline_rounded, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text(
                  "Academic Lifecycle Journey",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLifecycleTimeline(),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildSideToggle(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.textMuted,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // ── REALISTIC PVC CARD FRONT ────────────────────────────────────────────
  Widget _buildPvcCardFront(dynamic student) {
    return Container(
      key: const ValueKey("front_card"),
      width: 350,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Authentic PVC Pearl White
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // Top Band: Official Deep Navy with College Crest
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AppConstants.logoPath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.school_rounded,
                        color: Color(0xFF1E293B),
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.institutionName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          "${AppConstants.institutionCity.toUpperCase()} • AUTONOMOUS",
                          style: const TextStyle(
                            fontSize: 8.5,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          "Approved by AICTE • Affiliated to RGPV",
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                    ),
                    child: const Text(
                      "NAAC A+",
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFCD34D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Gold separation ribbon
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD97706), Color(0xFFFCD34D), Color(0xFFD97706)],
                ),
              ),
            ),

            // Card Body (Crisp, High-Contrast Light Surface)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              color: const Color(0xFFF8FAFC),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Student Photo Frame & Smart Chip
                  Column(
                    children: [
                      Container(
                        width: 86,
                        height: 104,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    student.name.split(" ").map((e) => e[0]).take(2).join(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text(
                                  "STUDENT",
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Golden Contactless Smart Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFD97706), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.nfc_rounded, size: 12, color: Color(0xFFB45309)),
                            SizedBox(width: 4),
                            Text(
                              "RFID / NFC",
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 14),

                  // Right: Student Academic Credentials
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          student.branch,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPvcDataRow("ROLL NO", student.rollNumber),
                        _buildPvcDataRow("ENROLL NO", student.enrollmentNumber),
                        _buildPvcDataRow("SEMESTER", "6th Sem • Section A"),
                        _buildPvcDataRow("VALIDITY", "2022 — 2026"),
                        _buildPvcDataRow("DOB", "14-Aug-2003"),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildPvcBadge("BLOOD: B+", const Color(0xFFEF4444)),
                            const SizedBox(width: 6),
                            _buildPvcBadge("CATEGORY: GEN", const Color(0xFF059669)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card Bottom Strip: Barcode, QR Code & Registrar Stamp
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: const Color(0xFF0F172A),
              child: Row(
                children: [
                  // Barcode
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "||||||| | |||| ||| ||||||| | |||||",
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.8,
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          "CARD UID: DC-${student.enrollmentNumber}",
                          style: const TextStyle(
                            fontSize: 7.5,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Official Authorized Signature Mock
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Dr. Rajesh Verma",
                        style: TextStyle(
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF93C5FD),
                        ),
                      ),
                      Text(
                        "Registrar / Principal",
                        style: TextStyle(
                          fontSize: 7,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),

                  // QR Code box
                  Container(
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.qr_code_2_rounded, size: 34, color: Colors.black),
                  ),
                ],
              ),
            ),

            // Statutory Security Ribbon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 3),
              color: const Color(0xFF065F46),
              child: const Center(
                child: Text(
                  "SHA-256 DIGITAL CAMPUS SECURE CARD • STATUTORY VERIFICATION",
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFA7F3D0),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── REALISTIC PVC CARD BACK ─────────────────────────────────────────────
  Widget _buildPvcCardBack(dynamic student) {
    return Container(
      key: const ValueKey("back_card"),
      width: 350,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Magnetic Stripe (Real PVC Magnetic Track)
            Container(
              height: 38,
              color: const Color(0xFF0F172A),
              margin: const EdgeInsets.only(top: 14),
            ),
            const SizedBox(height: 10),

            // Card Terms & College Rules
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TERMS & CONDITIONS / CARD REGULATIONS",
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "1. This card is non-transferable and remains the property of ${AppConstants.institutionName}.\n"
                    "2. Must be presented on demand during examinations, library access, and lab entries.\n"
                    "3. Loss of card must be reported immediately to the Registrar's Office.\n"
                    "4. If found, please return to Campus Security or call the helpline below.",
                    style: const TextStyle(
                      fontSize: 8,
                      color: Color(0xFF475569),
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Emergency Details Box
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CAMPUS EMERGENCY & CONTACTS",
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Emergency: +91 755 243 3100 • Proctor: proctor@digitalcampus.in\n"
                          "Campus Address: ${AppConstants.institutionName}, ${AppConstants.institutionCity}",
                          style: TextStyle(
                            fontSize: 7.5,
                            color: Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Bottom Barcode & Library RFID Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFE2E8F0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "LIBRARY RFID: 0133-2022-LIB",
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  Text(
                    "ISO/IEC 7810 ID-1 STANDARD",
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPvcDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const Text(" : ", style: TextStyle(fontSize: 8.5, color: Color(0xFF94A3B8))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPvcBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  // ── Lifecycle Journey Timeline ──────────────────────────────────────────
  Widget _buildLifecycleTimeline() {
    final steps = [
      _LifecycleStep(
        title: "Central Admission & Digital KYC",
        status: "Completed (Aug 2022)",
        desc: "10+2 verified, biometric enrolled, fee cleared, official roll number allocated.",
        isDone: true,
        isActive: false,
      ),
      _LifecycleStep(
        title: "Foundation Academic Years (Sem 1–4)",
        status: "Cleared • CGPA 8.01",
        desc: "Core Engineering fundamentals, lab practicals, all credits cleared with zero backlogs.",
        isDone: true,
        isActive: false,
      ),
      _LifecycleStep(
        title: "Advanced Specialization (Sem 5–6)",
        status: "Active • Current Semester",
        desc: "Machine Learning, Distributed Systems, Compiler Design, Industrial Internship.",
        isDone: false,
        isActive: true,
      ),
      _LifecycleStep(
        title: "Campus Placements & Final Project (Sem 7–8)",
        status: "Upcoming (2025–2026)",
        desc: "Placement drives, capstone project evaluation, company assessments.",
        isDone: false,
        isActive: false,
      ),
      _LifecycleStep(
        title: "Degree Conferral & Alumni Induction",
        status: "Target (June 2026)",
        desc: "Autonomous degree conferral with cryptographically signed verifiable credential.",
        isDone: false,
        isActive: false,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == steps.length - 1;
          return _buildTimelineItem(step, isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineItem(_LifecycleStep step, bool isLast) {
    final dotColor = step.isDone
        ? AppColors.success
        : (step.isActive ? AppColors.primary : AppColors.borderLight);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor.withOpacity(step.isDone || step.isActive ? 0.15 : 0.08),
                    border: Border.all(color: dotColor, width: 2),
                  ),
                  child: Icon(
                    step.isDone
                        ? Icons.check_rounded
                        : (step.isActive ? Icons.play_arrow_rounded : Icons.lock_outline_rounded),
                    size: 12,
                    color: step.isDone || step.isActive ? dotColor : AppColors.textMuted,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: (step.isDone ? AppColors.success : AppColors.borderLight).withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: step.isActive
                              ? AppColors.primary
                              : (step.isDone ? AppColors.textDark : AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: step.isDone
                          ? AppColors.success
                          : (step.isActive ? AppColors.accent : AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    step.desc,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LifecycleStep {
  final String title;
  final String status;
  final String desc;
  final bool isDone;
  final bool isActive;

  const _LifecycleStep({
    required this.title,
    required this.status,
    required this.desc,
    required this.isDone,
    required this.isActive,
  });
}
