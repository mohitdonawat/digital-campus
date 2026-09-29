import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/custom_chip.dart';
import '../../providers/campus_provider.dart';
import '../ai_analytics/early_dropout_screen.dart';
import '../timetable/timetable_screen.dart';
import '../helpdesk/helpdesk_screen.dart';
import '../attendance/attendance_screen.dart';

class FacultyDashboardView extends StatelessWidget {
  const FacultyDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Faculty Profile Hero Card ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withOpacity(0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "MD",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Flexible(
                            child: Text(
                              "Dr. Mohit Donawat",
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFBE0B),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "HOD • CSE",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "Computer Science & Engineering • Dean Liaison",
                        style: TextStyle(fontSize: 11.5, color: Color(0xFFE2E8F0)),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Faculty ID: FAC-CSE-019 • 14 Years Academic Tenure",
                        style: TextStyle(fontSize: 10.5, color: Color(0xFFCBD5E1)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Faculty Key Metrics ───────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: "Today's Lectures",
                  value: "3 Sessions",
                  subtitle: "LH-302 & Lab 3",
                  icon: Icons.calendar_today_rounded,
                  iconColor: AppColors.primary,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen()));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: "At-Risk Students",
                  value: "3 Flagged",
                  subtitle: "<75% Attendance",
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppColors.error,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EarlyDropoutScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: "Class Attendance Avg",
                  value: "84.2%",
                  subtitle: "+3.1% vs last month",
                  icon: Icons.people_alt_rounded,
                  iconColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: "Pending Approvals",
                  value: "4 Bonafides",
                  subtitle: "Semester Reg Desk",
                  icon: Icons.assignment_turned_in_rounded,
                  iconColor: AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Live Lecture & Smart QR Attendance Launcher ───────────────────
          _buildSectionHeader("LIVE ACADEMIC CONTROLS", "Section A • CS-601"),
          const SizedBox(height: 10),

          GlassCard(
            borderColor: AppColors.primary.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Mark Lecture Attendance",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: const Text(
                        "LIVE NOW",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Machine Learning & AI (Section A - 62 Enrolled). Tap below to broadcast dynamic anti-proxy QR code for real-time check-in.",
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          provider.simulateAttendanceCheckIn("CS-601");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Dynamic Anti-Proxy QR Active! Attendance synced in real-time."),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        icon: const Icon(Icons.bolt_rounded, size: 18),
                        label: const Text("Launch Dynamic QR"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen()));
                      },
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.warning),
                      label: const Text("Substitute", style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.warning, width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
                    },
                    icon: const Icon(Icons.fact_check_rounded, size: 16, color: AppColors.primary),
                    label: const Text(
                      "Open Class Register & Smart Filters",
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.2),
                      backgroundColor: AppColors.primary.withOpacity(0.04),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Early Dropout Warning & Student Counseling ────────────────────
          _buildSectionHeader("AT-RISK INTERVENTION RADAR", "Immediate Action Required"),
          const SizedBox(height: 10),

          _buildAtRiskStudentCard(
            context,
            name: "Pooja Deshmukh (CS22B018)",
            attendance: "58.4%",
            predictedGpa: "5.8",
            riskTier: "High Dropout Risk",
            riskColor: AppColors.error,
            reasons: "Missed 6 classes consecutively • Failed Mid-Term 1",
          ),
          const SizedBox(height: 10),
          _buildAtRiskStudentCard(
            context,
            name: "Vikas Patel (CS22B062)",
            attendance: "64.0%",
            predictedGpa: "6.1",
            riskTier: "Warning Zone",
            riskColor: AppColors.warning,
            reasons: "Attendance below 75% statutory radar • Lab absent",
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EarlyDropoutScreen()),
                );
              },
              icon: const Icon(Icons.analytics_rounded, size: 18, color: AppColors.primary),
              label: const Text(
                "Open Comprehensive AI Dropout Radar",
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppColors.textMuted,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildAtRiskStudentCard(
    BuildContext context, {
    required String name,
    required String attendance,
    required String predictedGpa,
    required String riskTier,
    required Color riskColor,
    required String reasons,
  }) {
    return GlassCard(
      borderColor: riskColor.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: riskColor.withOpacity(0.3)),
                ),
                child: Text(
                  riskTier,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: riskColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                "Attendance: $attendance",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: riskColor),
              ),
              const SizedBox(width: 12),
              Text(
                "Predicted GPA: $predictedGpa",
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(reasons, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Counseling session booked for $name with Academic Mentor."),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
                label: const Text("Intervene", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Parent SMS sent for $name regarding attendance threshold."),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 14, color: AppColors.textSecondary),
                label: const Text("Alert Parent", style: TextStyle(fontSize: 11.5, color: AppColors.textDark, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderLight, width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
