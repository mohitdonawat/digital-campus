import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/custom_chip.dart';
import '../../providers/campus_provider.dart';
import '../attendance/attendance_screen.dart';
import '../fees/fee_payment_screen.dart';
import '../ai_analytics/predictive_performance_screen.dart';
import '../transport/transport_screen.dart';
import '../hostel/hostel_screen.dart';

class ParentDashboardView extends StatelessWidget {
  const ParentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final student = provider.student;
    final overallAtt = provider.overallAttendance;
    final dues = provider.totalDues;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Parent & Ward Hero Banner ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F766E).withOpacity(0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.family_restroom_rounded, color: Color(0xFF0F766E), size: 28),
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
                              "Parent Portal",
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
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFBF1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "VERIFIED GUARDIAN",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Guardian: ${student.parentName} (${student.parentPhone})",
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFFE2E8F0)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Ward: ${student.name} • ${student.branch} (Sem ${student.semester})",
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Ward's Real-Time Standing ──────────────────────────────────────
          _buildSectionHeader("WARD'S ACADEMIC HEALTH", "Real-time Telemetry"),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: "Live Attendance",
                  value: "${overallAtt.toStringAsFixed(1)}%",
                  subtitle: overallAtt >= 75 ? "Compliant" : "Low Attendance",
                  icon: Icons.how_to_reg_rounded,
                  iconColor: overallAtt >= 75 ? AppColors.success : AppColors.error,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: "Current CGPA",
                  value: "${student.currentCgpa}",
                  subtitle: "Top 15% in Branch",
                  icon: Icons.school_rounded,
                  iconColor: AppColors.primary,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PredictivePerformanceScreen()));
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
                  label: "Pending Fee Dues",
                  value: dues > 0 ? "₹${(dues / 1000).toStringAsFixed(1)}k" : "CLEARED",
                  subtitle: dues > 0 ? "Due Oct 15" : "No Pending Dues",
                  icon: Icons.receipt_long_rounded,
                  iconColor: dues > 0 ? AppColors.warning : AppColors.success,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FeePaymentScreen()));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: "Hostel Status",
                  value: "IN CAMPUS",
                  subtitle: "Gate Log: 08:15 PM",
                  icon: Icons.hotel_rounded,
                  iconColor: AppColors.accent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Faculty Mentor Hotline ─────────────────────────────────────────
          _buildSectionHeader("MENTOR HOTLINE", "Direct Academic Liaison"),
          const SizedBox(height: 10),

          GlassCard(
            borderColor: AppColors.primary.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Direct Faculty Mentor Connect",
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Available Today",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.success),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Assigned Mentor: ${student.mentorName} (${student.mentorContact})",
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Discuss semester attendance, midterm marks, lab performance, and career advice directly.",
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Calling ${student.mentorName} (${student.mentorContact})..."),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.call_rounded, size: 16),
                        label: const Text("Call Mentor"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("WhatsApp conversation opened with Mentor."),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_rounded, size: 16, color: AppColors.success),
                        label: const Text("WhatsApp", style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.success, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Subject-Wise Attendance Summary ────────────────────────────────
          _buildSectionHeader("SUBJECT-WISE ATTENDANCE", "RGPV 75% Radar"),
          const SizedBox(height: 10),

          GlassCard(
            borderColor: AppColors.borderLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...provider.attendance.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                s.subjectName,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "${s.percentage.toStringAsFixed(1)}% (${s.attendedClasses}/${s.totalClasses})",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: s.isSafe ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: s.percentage / 100,
                            backgroundColor: AppColors.surfaceSubtle,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              s.isSafe ? AppColors.success : AppColors.error,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Ward's Live Bus Tracking ───────────────────────────────────────
          _buildSectionHeader("TRANSIT & GPS TRACKING", "Route 04 Active"),
          const SizedBox(height: 10),

          GlassCard(
            borderColor: AppColors.accent.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.directions_bus_rounded, color: AppColors.accent, size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Ward's Transit Bus Route 04",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "LIVE GPS",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Vehicle MP-04-HE-7821 currently at ${provider.busRoute.currentStop} running at ${provider.busRoute.speedKmph} km/h.",
                  style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  "Next Stop: ${provider.busRoute.nextStop} (ETA ${provider.busRoute.etaMinutes} mins) • Driver: ${provider.busRoute.driverName} (${provider.busRoute.driverPhone})",
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportScreen()));
                    },
                    icon: const Icon(Icons.navigation_rounded, size: 16),
                    label: const Text("Track Bus on Live Radar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
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
}
