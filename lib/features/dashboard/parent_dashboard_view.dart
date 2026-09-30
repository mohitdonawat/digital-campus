import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/campus_provider.dart';
import '../attendance/attendance_screen.dart';
import '../fees/fee_payment_screen.dart';
import '../ai_analytics/predictive_performance_screen.dart';
import '../transport/transport_screen.dart';
import '../account/professional_account_screen.dart';

/// Ultra-Clean, Uncluttered Parent Dashboard
class ParentDashboardView extends StatelessWidget {
  const ParentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final student = provider.student;
    final overallAtt = provider.overallAttendance;
    final dues = provider.totalDues;

    return RefreshIndicator(
      color: const Color(0xFF0D9488),
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
            // ── 1. PARENT & WARD HERO ─────────────────────────────────────────
            _buildParentHero(context, student),

            const SizedBox(height: 16),

            // ── 2. THREE WARD VITALS ──────────────────────────────────────────
            _buildWardVitalsRow(context, overallAtt, student.currentCgpa, dues),

            const SizedBox(height: 18),

            // ── 3. DIRECT MENTOR HOTLINE ──────────────────────────────────────
            _buildSectionTitle("ASSIGNED FACULTY MENTOR"),
            const SizedBox(height: 8),
            _buildMentorHotlineCard(context, student),

            const SizedBox(height: 18),

            // ── 4. QUICK PARENT TOOLS ─────────────────────────────────────────
            _buildSectionTitle("WARD SERVICES"),
            const SizedBox(height: 8),
            _buildQuickParentGrid(context),

            const SizedBox(height: 18),

            // ── 5. LIVE TRANSIT / BUS GLANCE ──────────────────────────────────
            _buildSectionTitle("LIVE BUS TRANSIT"),
            const SizedBox(height: 8),
            _buildTransitGlanceCard(context, provider),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── 1. Parent & Ward Hero ───────────────────────────────────────────────────
  Widget _buildParentHero(BuildContext context, dynamic student) {
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
              color: const Color(0xFF0D9488).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.25), width: 1.2),
            ),
            child: const Center(
              child: Icon(Icons.family_restroom_rounded, color: Color(0xFF0D9488), size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        "Guardian: ${student.parentName}",
                        style: const TextStyle(
                          fontSize: 15,
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
                const SizedBox(height: 2),
                Text(
                  "Ward: ${student.name} • ${student.branch}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0D9488),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  "Roll: ${student.rollNumber} • Semester 6",
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfessionalAccountScreen()),
              );
            },
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
            tooltip: "Parent Account",
          ),
        ],
      ),
    );
  }

  // ── 2. Three Ward Vitals ────────────────────────────────────────────────────
  Widget _buildWardVitalsRow(BuildContext context, double attendance, double cgpa, double dues) {
    return Row(
      children: [
        Expanded(
          child: _buildVitalTile(
            label: "Attendance",
            value: "${attendance.toStringAsFixed(1)}%",
            status: attendance >= 75 ? "Compliant (≥75%)" : "Low",
            icon: Icons.how_to_reg_rounded,
            color: attendance >= 75 ? AppColors.success : AppColors.error,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildVitalTile(
            label: "Current CGPA",
            value: cgpa.toStringAsFixed(2),
            status: "Top 5% Rank",
            icon: Icons.school_rounded,
            color: const Color(0xFF2563EB),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PredictivePerformanceScreen()));
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildVitalTile(
            label: "Fee Ledger",
            value: dues == 0 ? "₹ 0" : "₹${(dues / 1000).toStringAsFixed(1)}k",
            status: dues == 0 ? "Cleared" : "Pending",
            icon: Icons.receipt_long_rounded,
            color: dues == 0 ? AppColors.success : AppColors.warning,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FeePaymentScreen()));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVitalTile({
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
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Icon(icon, size: 14, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark),
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

  // ── 3. Mentor Hotline Card ──────────────────────────────────────────────────
  Widget _buildMentorHotlineCard(BuildContext context, dynamic student) {
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
              Text(
                "Mentor: ${student.mentorName}",
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "AVAILABLE",
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            "HOD CSE • Direct Contact: ${student.mentorContact}",
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Connecting call to ${student.mentorName}..."),
                        backgroundColor: const Color(0xFF0D9488),
                      ),
                    );
                  },
                  icon: const Icon(Icons.call_rounded, size: 16),
                  label: const Text("Call Mentor"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Opening WhatsApp liaison with Mentor..."),
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
    );
  }

  // ── 4. Quick Parent Grid ────────────────────────────────────────────────────
  Widget _buildQuickParentGrid(BuildContext context) {
    final tools = [
      _ParentTool("Attendance", Icons.how_to_reg_rounded, const Color(0xFF059669), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
      }),
      _ParentTool("Fee Receipts", Icons.account_balance_wallet_rounded, const Color(0xFF0284C7), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FeePaymentScreen()));
      }),
      _ParentTool("Bus Transit", Icons.directions_bus_rounded, const Color(0xFFD97706), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportScreen()));
      }),
      _ParentTool("Performance", Icons.trending_up_rounded, const Color(0xFF7C3AED), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PredictivePerformanceScreen()));
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

  // ── 5. Live Transit Glance ──────────────────────────────────────────────────
  Widget _buildTransitGlanceCard(BuildContext context, CampusProvider provider) {
    final route = provider.busRoute;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_bus_rounded, color: Color(0xFFD97706), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Route 04: Campus Shuttle",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  "At: ${route.currentStop} • Next: ${route.nextStop} (ETA ${route.etaMinutes} mins)",
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportScreen()));
            },
            child: const Text("Track GPS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
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

class _ParentTool {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _ParentTool(this.title, this.icon, this.color, this.onTap);
}
