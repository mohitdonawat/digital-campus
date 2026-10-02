import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/campus_models.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/campus_provider.dart';
import '../ai_analytics/early_dropout_screen.dart';
import '../timetable/timetable_screen.dart';
import '../attendance/attendance_screen.dart';
import '../attendance/dynamic_attendance_qr_modal.dart';
import '../helpdesk/helpdesk_screen.dart';
import '../account/professional_account_screen.dart';
import '../registration/faculty_registration_desk_screen.dart';
import '../faculty/on_screen_grading_screen.dart';
import '../faculty/faculty_edit_dossier_screen.dart';
import '../../core/services/whatsapp_alert_service.dart';

/// Ultra-Clean, Uncluttered Faculty / Teacher Dashboard
class FacultyDashboardView extends StatelessWidget {
  const FacultyDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final pendingRegs = provider.semesterRegistrations.where((r) => r.status == RegistrationStatus.pending).toList();

    return RefreshIndicator(
      color: const Color(0xFF60A5FA),
      backgroundColor: Colors.white,
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 400));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 14.0, bottom: 88.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. FACULTY WELCOME HERO ───────────────────────────────────────
            _buildFacultyHero(context),

            const SizedBox(height: 12),

            // ── 🎓 REGISTRATION VERIFICATION DESK BANNER ─────────────────────
            _buildRegistrationDeskBanner(context, pendingRegs.length),

            const SizedBox(height: 12),

            // ── ✍️ AI ANSWER SHEET GRADER (OSES) BANNER ───────────────────────
            _buildOSESBanner(context),

            const SizedBox(height: 14),

            // ── 2. THREE KEY STATS ────────────────────────────────────────────
            _buildFacultyVitalsRow(context),

            const SizedBox(height: 18),

            // ── 3. LIVE CLASS & ATTENDANCE LAUNCHER ───────────────────────────
            _buildSectionTitle("LIVE CLASSROOM CONTROLS"),
            const SizedBox(height: 8),
            _buildLiveClassControls(context, provider),

            const SizedBox(height: 18),

            // ── 4. QUICK FACULTY TOOLS ────────────────────────────────────────
            _buildSectionTitle("FACULTY SERVICES"),
            const SizedBox(height: 8),
            _buildQuickFacultyGrid(context),

            const SizedBox(height: 18),

            // ── 5. GRIEVANCE INBOX ────────────────────────────────────────────
            _buildSectionTitle("GRIEVANCE INBOX"),
            const SizedBox(height: 8),
            GrievanceSummaryCard(role: UserRole.faculty),

            const SizedBox(height: 18),

            // ── 6. AT-RISK RADAR HIGHLIGHT ────────────────────────────────────
            _buildSectionTitle("AT-RISK STUDENT INTERVENTION"),
            const SizedBox(height: 8),
            _buildAtRiskHighlightCard(context, provider),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── 1. Faculty Welcome Hero ─────────────────────────────────────────────────
  Widget _buildFacultyHero(BuildContext context) {
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2), width: 1.2),
            ),
            child: const Center(
              child: Text(
                "MD",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        "Dr. Mohit Donawat",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  "HOD • Computer Science & Engineering",
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  "ID: FAC-CSE-019 • Room: Block A-204",
                  style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FacultyEditDossierScreen()),
              );
            },
            icon: const Icon(Icons.edit_note_rounded, size: 22, color: Color(0xFF7C3AED)),
            tooltip: "Build & Edit Faculty Dossier",
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfessionalAccountScreen()),
              );
            },
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
            tooltip: "Faculty Dossier",
          ),
        ],
      ),
    );
  }

  // ── 2. Three Key Stats ──────────────────────────────────────────────────────
  Widget _buildFacultyVitalsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            label: "Today's Lectures",
            value: "3 Sessions",
            status: "LH-302 & Lab 3",
            icon: Icons.calendar_today_rounded,
            color: const Color(0xFF2563EB),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen()));
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatTile(
            label: "Class Avg",
            value: "84.2%",
            status: "Compliant",
            icon: Icons.people_alt_rounded,
            color: AppColors.success,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatTile(
            label: "At-Risk Radar",
            value: "2 Flagged",
            status: "<75% Attendance",
            icon: Icons.warning_amber_rounded,
            color: AppColors.error,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EarlyDropoutScreen()));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required String status,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
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
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Icon(icon, size: 14, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textDark),
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. Live Classroom Controls ──────────────────────────────────────────────
  Widget _buildLiveClassControls(BuildContext context, CampusProvider provider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
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
                  Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2563EB), size: 18),
                  SizedBox(width: 8),
                  Text(
                    "CS-601: Machine Learning (Section A)",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "LIVE NOW",
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "62 Students Enrolled • 09:30 AM in Lecture Hall 302",
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    DynamicAttendanceQrModal.show(
                      context,
                      subjectCode: "CS-601",
                      subjectName: "Operating Systems & System Software",
                      room: "LH-302 (Smart Hall)",
                      isFaculty: true,
                    );
                  },
                  icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                  label: const Text("Launch Dynamic QR"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderLight),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Register", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Registration Desk Banner for Faculty ───────────────────────────────────
  Widget _buildRegistrationDeskBanner(BuildContext context, int pendingCount) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FacultyRegistrationDeskScreen())),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: pendingCount > 0 ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: pendingCount > 0 ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: pendingCount > 0 ? const Color(0xFFD97706) : const Color(0xFF16A34A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pendingCount > 0
                        ? "Semester 6 Registration: $pendingCount Forms Pending"
                        : "Semester Registrations: All Caught Up! ✅",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: pendingCount > 0 ? const Color(0xFF92400E) : const Color(0xFF166534),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    pendingCount > 0
                        ? "Student elective choices awaiting your review • Tap to approve"
                        : "All student enrollment forms verified",
                    style: TextStyle(
                      fontSize: 10.5,
                      color: pendingCount > 0 ? const Color(0xFFB45309) : const Color(0xFF15803D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: pendingCount > 0 ? const Color(0xFF92400E) : const Color(0xFF166534),
            ),
          ],
        ),
      ),
    );
  }

  // ── AI Answer Sheet Grader (OSES) Banner ──────────────────────────────────
  Widget _buildOSESBanner(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnScreenGradingScreen())),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4338CA).withOpacity(0.22),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "AI Answer Sheet Grader (OSES)",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(
                          "SOVEREIGN AI",
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    "3 exam copies ready • SymPy Math prover + Red Pen Overlay",
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFFE0E7FF),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // ── 4. Quick Faculty Tools ──────────────────────────────────────────────────
  Widget _buildQuickFacultyGrid(BuildContext context) {
    final tools = [
      _FacultyTool("AI Grader (OSES)", Icons.draw_rounded, const Color(0xFF7C3AED), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OnScreenGradingScreen()));
      }),
      _FacultyTool("Registration Desk", Icons.assignment_turned_in_rounded, const Color(0xFF6366F1), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FacultyRegistrationDeskScreen()));
      }),
      _FacultyTool("Attendance", Icons.how_to_reg_rounded, const Color(0xFF059669), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
      }),
      _FacultyTool("Schedule", Icons.calendar_month_rounded, const Color(0xFF2563EB), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen()));
      }),
      _FacultyTool("Dropout Radar", Icons.analytics_rounded, const Color(0xFFD97706), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EarlyDropoutScreen()));
      }),
      _FacultyTool("Faculty Dossier", Icons.badge_rounded, const Color(0xFF0284C7), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalAccountScreen()));
      }),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: tools.length,
      itemBuilder: (_, index) {
        final t = tools[index];
        return InkWell(
          onTap: t.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight, width: 1.0),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: t.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(t.icon, color: t.color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── 5. At-Risk Student Highlight (100% Dynamic Database Driven) ────────────
  Widget _buildAtRiskHighlightCard(BuildContext context, CampusProvider provider) {
    final defaulters = provider.classAttendanceRecords.where((s) => s.attendancePercentage < 75.0).toList();
    final topDefaulter = defaulters.isNotEmpty ? defaulters.first : null;

    if (topDefaulter == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
            SizedBox(width: 10),
            Text(
              "Zero Attendance Defaulters! All students above 75%.",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
            ),
          ],
        ),
      );
    }

    final deficit = (((0.75 * topDefaulter.totalClasses) - topDefaulter.attendedClasses) / 0.25).ceil().clamp(1, 40);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "${topDefaulter.name} (${topDefaulter.rollNumber})",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${topDefaulter.attendancePercentage}% Attendance",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "Attended ${topDefaulter.attendedClasses}/${topDefaulter.totalClasses} classes • Deficit: $deficit lectures to reach mandatory 75% AICTE rule",
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Real WhatsApp Alert Dispatch Button
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    WhatsAppAlertService.showDispatchBottomSheet(
                      context: context,
                      student: topDefaulter,
                      facultyName: "Dr. Mohit Donawat",
                    );
                  },
                  icon: const Icon(Icons.chat_rounded, size: 15, color: Colors.white),
                  label: const Text(
                    "WhatsApp Parent Alert",
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderLight),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EarlyDropoutScreen()));
                },
                icon: const Icon(Icons.radar_rounded, size: 15, color: Color(0xFFD97706)),
                label: Text(
                  "Radar (${defaulters.length})",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: Color(0xFF64748B),
      ),
    );
  }
}

class _FacultyTool {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _FacultyTool(this.title, this.icon, this.color, this.onTap);
}
