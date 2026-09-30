import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/document_download_service.dart';
import '../../models/campus_models.dart';
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
    final role = provider.currentRole;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getHeaderTitle(role),
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _getHeaderSubtitle(role),
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
              color: _getRoleColor(role),
            ),
            tooltip: _showBackSide ? "Show Front Side" : "Flip to Back Side",
          ),
          IconButton(
            onPressed: () {
              DocumentDownloadService.downloadRolePvcIdCardPdf(context, provider);
            },
            icon: Icon(Icons.download_rounded, color: _getRoleColor(role)),
            tooltip: "Download PDF ID Card",
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfessionalAccountScreen()),
              );
            },
            icon: Icon(Icons.account_box_rounded, color: _getRoleColor(role)),
            tooltip: "Open Professional Dossier",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── FLIP TOGGLE BUTTON RIBBON ─────────────────────────────────
            Container(
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
                  _buildSideToggle("FRONT IDENTITY", !_showBackSide, _getRoleColor(role), () {
                    setState(() => _showBackSide = false);
                  }),
                  _buildSideToggle("BACK RULES & RFID", _showBackSide, _getRoleColor(role), () {
                    setState(() => _showBackSide = true);
                  }),
                ],
              ),
            ),

            // ── REALISTIC PVC CARD (FRONT / BACK) ─────────────────────────
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _showBackSide
                      ? _buildCardBack(provider, role)
                      : _buildCardFront(provider, role),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── CARD QUICK ACTIONS ────────────────────────────────────────
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Row(
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
                        foregroundColor: _getRoleColor(role),
                        side: BorderSide(color: _getRoleColor(role).withOpacity(0.4)),
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
                          SnackBar(
                            content: Text(_getShareQrMessage(role)),
                            backgroundColor: _getRoleColor(role),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 16, color: Colors.white),
                      label: const Text(
                        "Share QR Pass",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getRoleColor(role),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── ROLE-SPECIFIC DOSSIER / TIMELINE ──────────────────────────
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getDossierIcon(role), color: _getRoleColor(role), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getDossierTitle(role),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRoleDossier(provider, role),
                ],
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // ── Header Title & Subtitle ─────────────────────────────────────────────
  String _getHeaderTitle(UserRole role) {
    switch (role) {
      case UserRole.faculty:
        return "Official Faculty Credential";
      case UserRole.admin:
        return "Executive Governance Pass";
      case UserRole.parent:
        return "Authorized Guardian Access Pass";
      case UserRole.student:
        return "Digital Student Identity";
    }
  }

  String _getHeaderSubtitle(UserRole role) {
    switch (role) {
      case UserRole.faculty:
        return "Faculty PVC RFID Smart Card • Academic Authority";
      case UserRole.admin:
        return "Chancellor Seal Authority • Master Security RFID";
      case UserRole.parent:
        return "Campus Visitor Security RFID • Ward Gate Pass";
      case UserRole.student:
        return "Smart PVC RFID Card • Academic Lifecycle";
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.faculty:
        return const Color(0xFF2563EB);
      case UserRole.admin:
        return const Color(0xFFD97706);
      case UserRole.parent:
        return const Color(0xFF059669);
      case UserRole.student:
        return AppColors.primary;
    }
  }

  String _getShareQrMessage(UserRole role) {
    switch (role) {
      case UserRole.faculty:
        return "Faculty Staff RFID Credential QR link copied!";
      case UserRole.admin:
        return "Executive Chancellor Authority Seal QR copied!";
      case UserRole.parent:
        return "Guardian Campus Gate Pass (Ward: Rahul Sharma) QR copied!";
      case UserRole.student:
        return "Student RFID Verification link copied!";
    }
  }

  IconData _getDossierIcon(UserRole role) {
    switch (role) {
      case UserRole.faculty:
        return Icons.biotech_rounded;
      case UserRole.admin:
        return Icons.account_balance_rounded;
      case UserRole.parent:
        return Icons.family_restroom_rounded;
      case UserRole.student:
        return Icons.timeline_rounded;
    }
  }

  String _getDossierTitle(UserRole role) {
    switch (role) {
      case UserRole.faculty:
        return "Faculty Teaching & Lab Dossier";
      case UserRole.admin:
        return "Institutional Governance Dossier";
      case UserRole.parent:
        return "Ward Care & Campus Security Dossier";
      case UserRole.student:
        return "Academic Lifecycle Journey";
    }
  }

  Widget _buildSideToggle(String label, bool isSelected, Color activeColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.textMuted,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // ── Dispatcher: Front Card ──────────────────────────────────────────────
  Widget _buildCardFront(CampusProvider provider, UserRole role) {
    switch (role) {
      case UserRole.faculty:
        return _buildFacultyCardFront(provider.facultyProfile);
      case UserRole.admin:
        return _buildAdminCardFront(provider.adminProfile);
      case UserRole.parent:
        return _buildParentCardFront(provider.parentProfile);
      case UserRole.student:
        return _buildStudentCardFront(provider.student);
    }
  }

  // ── Dispatcher: Back Card ───────────────────────────────────────────────
  Widget _buildCardBack(CampusProvider provider, UserRole role) {
    switch (role) {
      case UserRole.faculty:
        return _buildFacultyCardBack(provider.facultyProfile);
      case UserRole.admin:
        return _buildAdminCardBack(provider.adminProfile);
      case UserRole.parent:
        return _buildParentCardBack(provider.parentProfile);
      case UserRole.student:
        return _buildStudentCardBack(provider.student);
    }
  }

  // =========================================================================
  // 1. 🎓 STUDENT PVC CARD (FRONT & BACK)
  // =========================================================================
  Widget _buildStudentCardFront(StudentProfile student) {
    return Container(
      key: const ValueKey("student_front"),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // Top Band
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school_rounded, color: Color(0xFF1E3A8A), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.institutionName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Autonomous University • AICTE Approved",
                          style: TextStyle(fontSize: 8.5, color: Color(0xFF93C5FD)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF22C55E), width: 0.8),
                    ),
                    child: const Text(
                      "ACTIVE",
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF22C55E)),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo & Chip
                  Column(
                    children: [
                      Container(
                        width: 82,
                        height: 98,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF94A3B8), width: 1.2),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(0xFF2563EB),
                                child: Text(
                                  student.name.split(" ").map((e) => e[0]).take(2).join(),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text(
                                  "STUDENT",
                                  style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFD97706), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.nfc_rounded, size: 11, color: Color(0xFFB45309)),
                            SizedBox(width: 3),
                            Text(
                              "RFID / NFC",
                              style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // Data
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name.toUpperCase(),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          student.branch,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        _buildDataRow("ROLL NO", student.rollNumber),
                        _buildDataRow("ENROLL NO", student.enrollmentNumber),
                        _buildDataRow("SEMESTER", "6th Sem • Section A"),
                        _buildDataRow("VALIDITY", "2022 — 2026"),
                        _buildDataRow("DOB", "14-Aug-2003"),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildPvcBadge("BLOOD: B+", const Color(0xFFEF4444)),
                            _buildPvcBadge("STATUS: REGULAR", const Color(0xFF059669)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card Bottom Barcode
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: const Color(0xFFF1F5F9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("DIGITAL PVC SMART ID", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                  Text("MR. SHRIDHAR DONAWAT (DEAN & DIRECTOR)", style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: Colors.blue.shade900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCardBack(StudentProfile student) {
    return Container(
      key: const ValueKey("student_back"),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 36, color: const Color(0xFF0F172A), margin: const EdgeInsets.only(top: 12)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TERMS & REGULATIONS",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "1. This card is non-transferable property of ${AppConstants.institutionName}.\n"
                    "2. Must be presented on demand during examinations, library access, and lab entries.\n"
                    "3. Loss of card must be reported immediately to the Registrar's Office.",
                    style: const TextStyle(fontSize: 8, color: Color(0xFF475569), height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("EMERGENCY & HELPLINE", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        const SizedBox(height: 2),
                        Text(
                          "Proctor Office: +91 755 243 3100 • Emergency: +91 755 243 3102\nCampus Address: ${AppConstants.institutionName}, ${AppConstants.institutionCity}",
                          style: const TextStyle(fontSize: 7.5, color: Color(0xFF64748B), height: 1.25),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              color: const Color(0xFFE2E8F0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("LIBRARY RFID: 0133-2022-LIB", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                  Text("ISO/IEC 7810 ID-1", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 2. 👨‍🏫 TEACHER / FACULTY CARD (FRONT & BACK)
  // =========================================================================
  Widget _buildFacultyCardFront(FacultyProfessionalProfile faculty) {
    return Container(
      key: const ValueKey("faculty_front"),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3B82F6), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.2),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // Top Band
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.psychology_rounded, color: Color(0xFF1D4ED8), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.institutionName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Faculty & Research Council • Academic Senate",
                          style: TextStyle(fontSize: 8.5, color: Color(0xFF93C5FD)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF60A5FA), width: 0.8),
                    ),
                    child: const Text(
                      "FACULTY",
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo & Chip
                  Column(
                    children: [
                      Container(
                        width: 82,
                        height: 98,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF3B82F6), width: 1.2),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 26,
                                backgroundColor: Color(0xFF1D4ED8),
                                child: Text(
                                  "MD",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text(
                                  "HOD / PROF",
                                  style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF3B82F6), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_person_rounded, size: 11, color: Color(0xFF1D4ED8)),
                            SizedBox(width: 3),
                            Text(
                              "STAFF RFID",
                              style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // Data
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          faculty.name.toUpperCase(),
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Associate Professor & HOD",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        _buildDataRow("FACULTY ID", faculty.id),
                        _buildDataRow("DEPARTMENT", faculty.department),
                        _buildDataRow("CABIN", faculty.cabin),
                        _buildDataRow("SPECIALIZATION", "Distributed Systems & AI"),
                        _buildDataRow("CLEARANCE", "Server Room • Lab 3"),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildPvcBadge("BLOOD: O+", const Color(0xFFEF4444)),
                            _buildPvcBadge("STATUS: TENURED", const Color(0xFF059669)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card Bottom Attestation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: const Color(0xFFEFF6FF),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("FACULTY CREDENTIAL", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF1E40AF))),
                  Text("ATTESTED: MR. SHRIDHAR DONAWAT (DEAN & DIRECTOR)", style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyCardBack(FacultyProfessionalProfile faculty) {
    return Container(
      key: const ValueKey("faculty_back"),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3B82F6), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.2),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 36, color: const Color(0xFF1E293B), margin: const EdgeInsets.only(top: 12)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "FACULTY ACADEMIC & RESEARCH AUTHORITY",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    "1. Certified Academic & Research Credential of Apex Institute of Technology.\n"
                    "2. Authorized to conduct university lectures, assign grades, and verify course registrations.\n"
                    "3. Grants 24/7 biometric server room access and high-performance computing cluster control.",
                    style: TextStyle(fontSize: 8, color: Color(0xFF475569), height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("FACULTY EXTENSION & DIRECT CONTACT", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A))),
                        SizedBox(height: 2),
                        Text(
                          "HOD Desk: Ext 4402 • Email: hod.cse@apextech.edu.in\nAttested Authority: Mr. Shridhar Donawat (Dean & Director)",
                          style: TextStyle(fontSize: 7.5, color: Color(0xFF1D4ED8), height: 1.25),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              color: const Color(0xFFDBEAFE),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("FACULTY RFID: FAC-2018-CSE-019", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A))),
                  Text("BIOMETRIC CORE LEVEL-2", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 3. 🏛️ DEAN & DIRECTOR CARD (FRONT & BACK)
  // =========================================================================
  Widget _buildAdminCardFront(AdminProfessionalProfile admin) {
    return Container(
      key: const ValueKey("admin_front"),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD97706), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB45309).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // Top Band
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF18181B), Color(0xFF78350F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: Color(0xFFB45309), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.institutionName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Office of the Dean & Director • Statutory Seal",
                          style: TextStyle(fontSize: 8.5, color: Color(0xFFFDE68A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                    ),
                    child: const Text(
                      "EXECUTIVE",
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFFDE68A)),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo & Chip
                  Column(
                    children: [
                      Container(
                        width: 82,
                        height: 98,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFD97706), width: 1.4),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 26,
                                backgroundColor: Color(0xFF92400E),
                                child: Text(
                                  "SD",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF451A03),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text(
                                  "DEAN & DIR",
                                  style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFD97706), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium_rounded, size: 11, color: Color(0xFFB45309)),
                            SizedBox(width: 3),
                            Text(
                              "MASTER RFID",
                              style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // Data
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          admin.name.toUpperCase(),
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          admin.designation,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        _buildDataRow("EXECUTIVE ID", admin.id),
                        _buildDataRow("OFFICE", "Chancellor Suite, Central Admin"),
                        _buildDataRow("STATUTORY ROLE", "President, Academic Senate"),
                        _buildDataRow("CLEARANCE", "Level-1 Sovereign Key"),
                        _buildDataRow("JURISDICTION", "Apex & 5 Campuses"),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildPvcBadge("SEAL: CHANCELLOR", const Color(0xFFB45309)),
                            _buildPvcBadge("ACCESS: ALL ZONES", const Color(0xFF059669)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card Bottom Attestation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: const Color(0xFFFEF3C7),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("EXECUTIVE CHANCELLOR PASS", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
                  Text("STATUTORY AUTHORITY SEAL", style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: Color(0xFFB45309))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCardBack(AdminProfessionalProfile admin) {
    return Container(
      key: const ValueKey("admin_back"),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD97706), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB45309).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 36, color: const Color(0xFF18181B), margin: const EdgeInsets.only(top: 12)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "STATUTORY GOVERNANCE & CHANCELLOR AUTHORITY",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    "1. Master Executive & Statutory Governance Credential of the University.\n"
                    "2. Sovereign access to all facilities, academic blocks, data centers, and senate chambers.\n"
                    "3. Authorized statutory signatory for degrees, appointments, and AICTE/NAAC disclosures.",
                    style: TextStyle(fontSize: 8, color: Color(0xFF475569), height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("CHANCELLOR EXECUTIVE SECRETARIAT", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF78350F))),
                        SizedBox(height: 2),
                        Text(
                          "Direct Line: +91 755 243 0001 • director@apextech.edu.in\nAttested: Mr. Shridhar Donawat (Dean & Director)",
                          style: TextStyle(fontSize: 7.5, color: Color(0xFF92400E), height: 1.25),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              color: const Color(0xFFFDE68A),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("EXECUTIVE MASTER RFID: DIR-001-GOLD", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF78350F))),
                  Text("SOVEREIGN TIER-1", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFFB45309))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 4. 👨‍👩‍👦 PARENT / GUARDIAN CARD (FRONT & BACK - WITH LINKED WARD LOGIC)
  // =========================================================================
  Widget _buildParentCardFront(ParentProfessionalProfile parent) {
    return Container(
      key: const ValueKey("parent_front"),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF10B981), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.2),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // Top Band
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF064E3B), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.family_restroom_rounded, color: Color(0xFF047857), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.institutionName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Authorized Guardian Pass • Campus Visitor RFID",
                          style: TextStyle(fontSize: 8.5, color: Color(0xFFA7F3D0)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF34D399), width: 0.8),
                    ),
                    child: const Text(
                      "GUARDIAN",
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo & Chip
                  Column(
                    children: [
                      Container(
                        width: 82,
                        height: 98,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF10B981), width: 1.2),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 26,
                                backgroundColor: Color(0xFF059669),
                                child: Text(
                                  "SS",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF065F46),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text(
                                  "PARENT",
                                  style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded, size: 11, color: Color(0xFF059669)),
                            SizedBox(width: 3),
                            Text(
                              "GATE PASS",
                              style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // Data with EXPLICIT LINKED WARD ("parent samjha kiske hain logic ke sath")
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parent.name.toUpperCase(),
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          parent.relationship,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        _buildDataRow("PASS ID", "GRD-PASS-2026-045"),
                        // Highlighted Ward Box
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF6EE7B7)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.link_rounded, size: 12, color: Color(0xFF059669)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "WARD: ${parent.wardName.toUpperCase()}",
                                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Roll: ${parent.wardRollNumber} • ${parent.wardBranch} Sem ${parent.wardSemester}",
                                style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text(
                                "Hostel: Block-3, Room H-204",
                                style: TextStyle(fontSize: 8, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        _buildDataRow("VISITING", "Hostel • Mentor Cabin A-204"),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildPvcBadge("GATE: VERIFIED", const Color(0xFF059669)),
                            _buildPvcBadge("EMERGENCY: PRIMARY", const Color(0xFFDC2626)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card Bottom Attestation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: const Color(0xFFDCFCE7),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("AUTHORIZED GUARDIAN PASS", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF065F46))),
                  Text("ISSUED BY: MR. SHRIDHAR DONAWAT (DEAN & DIRECTOR)", style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: Color(0xFF047857))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentCardBack(ParentProfessionalProfile parent) {
    return Container(
      key: const ValueKey("parent_back"),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF10B981), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.2),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 36, color: const Color(0xFF064E3B), margin: const EdgeInsets.only(top: 12)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "GUARDIAN CAMPUS VISITOR REGULATIONS",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "1. Official Guardian Visitor & Gate Pass for parent of enrolled ward ${parent.wardName} (${parent.wardRollNumber}).\n"
                    "2. Allows campus entry during visitor hours (08:00 AM — 07:00 PM) and emergency hostel access.\n"
                    "3. Allows direct consultation with Academic Mentor Dr. Mohit Donawat and Chief Hostel Warden.",
                    style: const TextStyle(fontSize: 8, color: Color(0xFF475569), height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("CAMPUS GATE-1 SECURITY & PROCTOR HOTLINE", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF065F46))),
                        SizedBox(height: 2),
                        Text(
                          "Gate 1 Security: +91 755 243 3102 • Proctor: +91 755 243 3100\nAttested: Mr. Shridhar Donawat (Dean & Director)",
                          style: TextStyle(fontSize: 7.5, color: Color(0xFF047857), height: 1.25),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              color: const Color(0xFFA7F3D0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("VISITOR GATE RFID: PASS-GRD-8821", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF065F46))),
                  Text("WARD LINKED: CS22B045", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF047857))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Data Rows & Badges ───────────────────────────────────────────
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.5),
      child: Row(
        children: [
          SizedBox(
            width: 72,
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
                fontSize: 9,
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  // =========================================================================
  // 5. ROLE-SPECIFIC DOSSIER BELOW CARD
  // =========================================================================
  Widget _buildRoleDossier(CampusProvider provider, UserRole role) {
    switch (role) {
      case UserRole.faculty:
        return _buildFacultyDossier(provider.facultyProfile);
      case UserRole.admin:
        return _buildAdminDossier(provider.adminProfile);
      case UserRole.parent:
        return _buildParentDossier(provider.parentProfile, provider);
      case UserRole.student:
        return _buildLifecycleTimeline();
    }
  }

  // Faculty Dossier Card
  Widget _buildFacultyDossier(FacultyProfessionalProfile faculty) {
    final items = [
      {"icon": Icons.school_rounded, "title": "Academic Rank", "val": "Associate Professor & HOD CSE"},
      {"icon": Icons.assignment_rounded, "title": "Courses Handled", "val": "Compiler Design (CS-601), Machine Learning (CS-602)"},
      {"icon": Icons.group_rounded, "title": "Active Cohort", "val": "B.Tech CSE 2022-2026 (Sem 6 • 68 Students)"},
      {"icon": Icons.verified_user_rounded, "title": "Statutory Duty", "val": "Semester Course Registration Verification Officer"},
      {"icon": Icons.memory_rounded, "title": "Advanced Lab Access", "val": "GPU High Performance Distributed Lab 3"},
      {"icon": Icons.access_time_rounded, "title": "Office Hours", "val": "Mon–Fri: 02:00 PM – 04:30 PM (Cabin A-204)"},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: items.map((it) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(it["icon"] as IconData, size: 16, color: const Color(0xFF2563EB)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        it["title"] as String,
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        it["val"] as String,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Admin Dossier Card
  Widget _buildAdminDossier(AdminProfessionalProfile admin) {
    final items = [
      {"icon": Icons.account_balance_rounded, "title": "Executive Title", "val": "Dean & Director of Institutional Governance"},
      {"icon": Icons.domain_rounded, "title": "Affiliated Campuses", "val": "Apex Institute & 5 Multi-Tenant Campuses"},
      {"icon": Icons.workspace_premium_rounded, "title": "Accreditation", "val": "NAAC Grade A++ (CGPA 3.82) • NBA Tier-1 Cleared"},
      {"icon": Icons.people_alt_rounded, "title": "Institutional Strength", "val": "5,630 Students • 260 Faculty • 140 Staff"},
      {"icon": Icons.gavel_rounded, "title": "Statutory Authority", "val": "President Academic Senate • Attestor of Digital Degrees"},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: items.map((it) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(it["icon"] as IconData, size: 16, color: const Color(0xFFD97706)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        it["title"] as String,
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        it["val"] as String,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Parent Dossier Card (Explicit Ward Care Logic)
  Widget _buildParentDossier(ParentProfessionalProfile parent, CampusProvider provider) {
    final items = [
      {"icon": Icons.person_rounded, "title": "Enrolled Ward", "val": "${parent.wardName} (Roll: ${parent.wardRollNumber})"},
      {"icon": Icons.how_to_reg_rounded, "title": "Ward Attendance", "val": "81.4% (Good Standing • Safe Bunk Margin)"},
      {"icon": Icons.hotel_rounded, "title": "Hostel Residence", "val": "Block-3, Room H-204 (Warden: Dr. K.S. Verma)"},
      {"icon": Icons.directions_bus_rounded, "title": "Transit Route", "val": "Campus Route 4 (Indrapuri to Campus • Live GPS)"},
      {"icon": Icons.contact_phone_rounded, "title": "Assigned Faculty Mentor", "val": "Dr. Mohit Donawat (HOD CSE • Cabin A-204)"},
      {"icon": Icons.phone_android_rounded, "title": "Registered Phone", "val": "+91 98260 44551 (Primary Emergency SMS Active)"},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: items.map((it) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(it["icon"] as IconData, size: 16, color: const Color(0xFF059669)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        it["title"] as String,
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        it["val"] as String,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Student Academic Timeline
  Widget _buildLifecycleTimeline() {
    final steps = [
      const _LifecycleStep(
        title: "Central Admission & Digital KYC",
        status: "Completed (Aug 2022)",
        desc: "10+2 verified, biometric enrolled, fee cleared, roll number allocated.",
        isDone: true,
        isActive: false,
      ),
      const _LifecycleStep(
        title: "Foundation Academic Years (Sem 1–4)",
        status: "Cleared • CGPA 8.01",
        desc: "Core Engineering fundamentals, lab practicals, all credits cleared.",
        isDone: true,
        isActive: false,
      ),
      const _LifecycleStep(
        title: "Advanced Specialization (Sem 5–6)",
        status: "Active • Current Semester",
        desc: "Machine Learning, Distributed Systems, Compiler Design, Industrial Internship.",
        isDone: false,
        isActive: true,
      ),
      const _LifecycleStep(
        title: "Campus Placements & Capstone (Sem 7–8)",
        status: "Upcoming (2025–2026)",
        desc: "Placement drives, company assessments, final degree project.",
        isDone: false,
        isActive: false,
      ),
      const _LifecycleStep(
        title: "Degree Conferral & Alumni Induction",
        status: "Target (June 2026)",
        desc: "Degree conferral with cryptographically signed verifiable credential.",
        isDone: false,
        isActive: false,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
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
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor.withOpacity(step.isDone || step.isActive ? 0.15 : 0.08),
                    border: Border.all(color: dotColor, width: 1.8),
                  ),
                  child: Icon(
                    step.isDone
                        ? Icons.check_rounded
                        : (step.isActive ? Icons.play_arrow_rounded : Icons.lock_outline_rounded),
                    size: 11,
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
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: step.isActive
                          ? AppColors.primary
                          : (step.isDone ? AppColors.textDark : AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    step.status,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: step.isDone
                          ? AppColors.success
                          : (step.isActive ? AppColors.accent : AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.desc,
                    style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, height: 1.3),
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
