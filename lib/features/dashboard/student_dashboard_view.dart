import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/campus_models.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/campus_provider.dart';
import '../attendance/attendance_screen.dart';
import '../timetable/timetable_screen.dart';
import '../fees/fee_payment_screen.dart';
import '../certificates/digital_certificates_screen.dart';
import '../study_assistant/ai_tutor_vision_studio_screen.dart';
import '../helpdesk/helpdesk_screen.dart';
import '../account/professional_account_screen.dart';
import '../registration/semester_registration_screen.dart';
import '../hostel/hostel_screen.dart';
import '../transport/transport_screen.dart';
import '../ai_analytics/predictive_performance_screen.dart';

/// Ultra-Clean, Uncluttered Student Dashboard
class StudentDashboardView extends StatelessWidget {
  const StudentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final student = provider.student;
    final overallAtt = provider.overallAttendance;
    final totalDues = provider.totalDues;
    final reg = provider.currentStudentRegistration;

    return RefreshIndicator(
      color: AppColors.primary,
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
            // ── 1. WELCOME HERO CARD ──────────────────────────────────────────
            _buildCleanHero(context, student),

            const SizedBox(height: 12),

            // ── 🎓 SEMESTER 6 REGISTRATION LIVE STATUS BANNER ─────────────────
            _buildRegistrationBanner(context, reg),

            const SizedBox(height: 14),

            // ── 2. THREE KEY VITALS ───────────────────────────────────────────
            _buildVitalsRow(context, overallAtt, totalDues, student.currentCgpa),

            const SizedBox(height: 18),

            // ── 3. ACTIVE / NEXT CLASS TODAY ──────────────────────────────────
            _buildSectionTitle("TODAY'S SCHEDULE"),
            const SizedBox(height: 8),
            _buildNextClassCard(context),

            const SizedBox(height: 18),

            // ── 4. QUICK CAMPUS ACTIONS ───────────────────────────────────────
            _buildSectionTitle("QUICK SERVICES"),
            const SizedBox(height: 8),
            _buildQuickServicesGrid(context),

            const SizedBox(height: 18),

            // ── 5. GRIEVANCE TRACKER ──────────────────────────────────────────
            _buildSectionTitle("MY GRIEVANCES"),
            const SizedBox(height: 8),
            GrievanceSummaryCard(role: UserRole.student),

            const SizedBox(height: 18),

            // ── 6. IMPORTANT CAMPUS NOTICE ────────────────────────────────────
            _buildSectionTitle("CAMPUS BULLETIN"),
            const SizedBox(height: 8),
            _buildNoticeCard(
              tag: "EXAMINATION",
              tagColor: AppColors.primary,
              title: "RGPV Semester 6 Examination Verification",
              subtitle: "Form verification is active. Ensure zero fee dues before the deadline.",
              date: "Today • Dean Office",
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── 1. Clean Hero Greeting ──────────────────────────────────────────────────
  Widget _buildCleanHero(BuildContext context, dynamic student) {
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
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.2),
            ),
            child: Center(
              child: Text(
                student.name.isNotEmpty ? student.name[0] : 'S',
                style: const TextStyle(
                  fontSize: 20,
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
                    Flexible(
                      child: Text(
                        "Welcome, ${student.name.split(' ').first} 👋",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Sem 6",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "${student.branch} • Roll: ${student.rollNumber}",
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            tooltip: "View Profile",
          ),
        ],
      ),
    );
  }

  // ── 2. Three Key Vitals ─────────────────────────────────────────────────────
  Widget _buildVitalsRow(BuildContext context, double attendance, double dues, double cgpa) {
    return Row(
      children: [
        // Attendance
        Expanded(
          child: _buildVitalTile(
            label: "Attendance",
            value: "${attendance.toStringAsFixed(1)}%",
            status: attendance >= 75 ? "Safe (≥75%)" : "Low",
            icon: Icons.how_to_reg_rounded,
            color: attendance >= 75 ? AppColors.success : AppColors.error,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
            },
          ),
        ),
        const SizedBox(width: 10),
        // CGPA
        Expanded(
          child: _buildVitalTile(
            label: "Current CGPA",
            value: cgpa.toStringAsFixed(2),
            status: "Top 5% Rank",
            icon: Icons.school_rounded,
            color: AppColors.primary,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen()));
            },
          ),
        ),
        const SizedBox(width: 10),
        // Fees
        Expanded(
          child: _buildVitalTile(
            label: "Fee Ledger",
            value: dues == 0 ? "₹ 0" : "₹${(dues / 1000).toStringAsFixed(1)}k",
            status: dues == 0 ? "Cleared" : "Pending",
            icon: Icons.account_balance_wallet_rounded,
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

  // ── 3. Next Class Card ──────────────────────────────────────────────────────
  Widget _buildNextClassCard(BuildContext context) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "CS-601: Machine Learning",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  "09:30 AM • Lecture Hall 302 • Dr. Mohit Donawat",
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen()));
            },
            child: const Text("Schedule", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Semester Registration Status Banner ────────────────────────────────────
  Widget _buildRegistrationBanner(BuildContext context, SemesterRegistration reg) {
    Color bg;
    Color border;
    Color textCol;
    IconData icon;
    String title;
    String subtitle;

    if (reg.status == RegistrationStatus.approved) {
      bg = const Color(0xFFF0FDF4);
      border = const Color(0xFF86EFAC);
      textCol = const Color(0xFF15803D);
      icon = Icons.verified_rounded;
      title = "Semester 6 Registration: Approved & Enrolled ✅";
      subtitle = "Verified by Dr. Mohit Donawat • Tap to view official slip";
    } else if (reg.status == RegistrationStatus.rejected) {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFFCA5A5);
      textCol = const Color(0xFFB91C1C);
      icon = Icons.error_outline_rounded;
      title = "Semester 6 Registration: Rejected by Faculty ❌";
      subtitle = "${reg.rejectionReason ?? 'Correction required'} • Tap to rectify & resubmit";
    } else {
      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFFDE68A);
      textCol = const Color(0xFFB45309);
      icon = Icons.hourglass_top_rounded;
      title = "Semester 6 Course Registration: In Verification ⏳";
      subtitle = "Submitted to Faculty Advisor Dr. Mohit Donawat • Tap to view form";
    }

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SemesterRegistrationScreen())),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, color: textCol, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textCol)),
                  const SizedBox(height: 1),
                  Text(subtitle, style: TextStyle(fontSize: 10.5, color: textCol.withOpacity(0.85)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: textCol),
          ],
        ),
      ),
    );
  }

  // ── 4. Quick Services Grid ──────────────────────────────────────────────────
  Widget _buildQuickServicesGrid(BuildContext context) {
    final services = [
      _ServiceItem("Registration", Icons.app_registration_rounded, const Color(0xFF6366F1), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SemesterRegistrationScreen()));
      }),
      _ServiceItem("Attendance", Icons.how_to_reg_rounded, const Color(0xFF059669), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
      }),
      _ServiceItem("Timetable", Icons.calendar_month_rounded, const Color(0xFF2563EB), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen()));
      }),
      _ServiceItem("AI Tutor", Icons.psychology_rounded, const Color(0xFF7C3AED), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AiTutorVisionStudioScreen()));
      }),
      _ServiceItem("Fee Portal", Icons.account_balance_wallet_rounded, const Color(0xFF0284C7), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FeePaymentScreen()));
      }),
      _ServiceItem("Certificates", Icons.verified_rounded, const Color(0xFFD97706), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DigitalCertificatesScreen()));
      }),
      _ServiceItem("Hostel & Mess", Icons.hotel_rounded, const Color(0xFF6366F1), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HostelScreen()));
      }),
      _ServiceItem("Campus Bus", Icons.directions_bus_rounded, const Color(0xFF0D9488), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportScreen()));
      }),
      _ServiceItem("AI Analytics", Icons.auto_graph_rounded, const Color(0xFFE11D48), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PredictivePerformanceScreen()));
      }),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemCount: services.length,
      itemBuilder: (_, index) {
        final item = services[index];
        return InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── 5. Clean Notice Card ────────────────────────────────────────────────────
  Widget _buildNoticeCard({
    required String tag,
    required Color tagColor,
    required String title,
    required String subtitle,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: tagColor),
                ),
              ),
              Text(date, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
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

class _ServiceItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _ServiceItem(this.title, this.icon, this.color, this.onTap);
}
