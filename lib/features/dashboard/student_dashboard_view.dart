import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/campus_provider.dart';
import '../attendance/attendance_screen.dart';
import '../timetable/timetable_screen.dart';
import '../fees/fee_payment_screen.dart';
import '../certificates/digital_certificates_screen.dart';
import '../ai_analytics/predictive_performance_screen.dart';
import '../ai_analytics/early_dropout_screen.dart';
import '../ai_assistant/ai_voice_assistant_screen.dart';
import '../study_assistant/vernacular_study_assistant_screen.dart';
import '../hostel/hostel_screen.dart';
import '../transport/transport_screen.dart';
import '../helpdesk/helpdesk_screen.dart';
import '../lifecycle/student_lifecycle_screen.dart';
import '../lifecycle/edit_profile_screen.dart';
import '../semester_registration/semester_registration_screen.dart';
import '../account/professional_account_screen.dart';

class StudentDashboardView extends StatelessWidget {
  const StudentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final student = provider.student;
    final overallAtt = provider.overallAttendance;
    final totalDues = provider.totalDues;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Colors.white,
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. SMART AI SEARCH & QUERY BAR ────────────────────────────
            _buildSmartSearchBar(context),

            const SizedBox(height: 14),

            // ── 2. STUDENT HERO & SMART PVC BADGE ─────────────────────────
            _buildStudentHeroCard(context, student),

            const SizedBox(height: 14),

            // ── 3. SMART GLANCE METRICS (CIRCULAR RINGS & METRICS) ────────
            _buildSmartGlanceHub(context, overallAtt, totalDues, student.currentCgpa),

            const SizedBox(height: 16),

            // ── 4. 🔴 TODAY'S SCHEDULE & LIVE STREAM GLANCE ───────────────
            _buildLiveClassroomGlance(context),

            const SizedBox(height: 18),

            // ── 5. CORE 8 ERP SERVICES (CLEAN 2-ROW GRID, ZERO CLUTTER) ──
            _buildSectionHeader("CAMPUS SERVICES", "All 8 Subsystems"),
            const SizedBox(height: 10),
            _buildCleanServicesGrid(context, provider),

            const SizedBox(height: 18),

            // ── 6. 🤖 SMART AI & MULTILINGUAL SUITE (POORA SAJA) ──────────
            _buildSectionHeader("CAMPUS AI COPILOT", "Voice • Bhashini • ML"),
            const SizedBox(height: 10),
            _buildSmartAiCopilotBanner(context, provider),

            const SizedBox(height: 18),

            // ── 7. OFFICIAL CAMPUS NOTICES & CIRCULARS ────────────────────
            _buildSectionHeader("LATEST NOTICES", "RGPV & Dean Office"),
            const SizedBox(height: 10),
            _buildNoticeTile(
              tag: "EXAM",
              title: "RGPV Sem 6 Examination Form Verification",
              subtitle: "Verification portal closes 28th Sep. Ensure zero fee dues.",
              date: "Today",
              tagColor: AppColors.primary,
            ),
            const SizedBox(height: 8),
            _buildNoticeTile(
              tag: "SUBSTITUTION",
              title: "Faculty Substitution: Computer Networks",
              subtitle: "Prof. Vikram Sen substituting for Prof. Priya Verma in LH-302.",
              date: "10:30 AM",
              tagColor: AppColors.warning,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── 1. SMART AI SEARCH & QUICK COMMAND BAR ──────────────────────────────
  Widget _buildSmartSearchBar(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiVoiceAssistantScreen()),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "Search courses, fee dues, attendance, or ask AI...",
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. STUDENT HERO CARD WITH SMART PVC ID ACTION ───────────────────────
  Widget _buildStudentHeroCard(BuildContext context, dynamic student) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Student Avatar (Tappable to Professional Account)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfessionalAccountScreen()),
              );
            },
            child: Stack(
              children: [
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
                      student.name.split(" ").map((e) => e[0]).take(2).join(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Name & Details
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfessionalAccountScreen()),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "Sem 6",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${student.rollNumber} • ${student.branch}",
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actions Row: Professional Account Dossier & PVC ID
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfessionalAccountScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.0),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.badge_rounded, color: AppColors.primary, size: 16),
                      SizedBox(width: 3),
                      Text(
                        "Dossier",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentLifecycleScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight, width: 1.0),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.badge_rounded, color: AppColors.primary, size: 16),
                      SizedBox(width: 3),
                      Text(
                        "PVC ID",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 3. SMART GLANCE HUB (CIRCULAR RINGS & CLEAN METRICS) ────────────────
  Widget _buildSmartGlanceHub(BuildContext context, double attendance, double dues, double cgpa) {
    return Row(
      children: [
        // Attendance Ring Card
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight, width: 1.0),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Attendance",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                      ),
                      Icon(
                        attendance >= 75 ? Icons.check_circle_rounded : Icons.warning_rounded,
                        size: 14,
                        color: attendance >= 75 ? AppColors.success : AppColors.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Progress Ring Mini
                      SizedBox(
                        width: 34,
                        height: 34,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: attendance / 100,
                              strokeWidth: 3.5,
                              backgroundColor: AppColors.surfaceSubtle,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                attendance >= 75 ? AppColors.success : AppColors.error,
                              ),
                            ),
                            Text(
                              "${attendance.toInt()}%",
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${attendance.toStringAsFixed(1)}%",
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.textDark),
                            ),
                            Text(
                              attendance >= 75 ? "Safe (≥75%)" : "At Risk",
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: attendance >= 75 ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // CGPA Card
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PredictivePerformanceScreen()));
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight, width: 1.0),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Current CGPA",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                      ),
                      Icon(Icons.school_rounded, size: 14, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cgpa.toStringAsFixed(2),
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.textDark),
                            ),
                            const Text(
                              "Rank #4 in CSE",
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Fee Dues Card
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FeePaymentScreen()));
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight, width: 1.0),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Fee Ledger",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                      ),
                      Icon(Icons.account_balance_wallet_rounded, size: 14, color: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: dues == 0 ? AppColors.successLight : AppColors.warningLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          dues == 0 ? Icons.check_circle_outline_rounded : Icons.pending_rounded,
                          color: dues == 0 ? AppColors.success : AppColors.warning,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dues == 0 ? "₹ 0" : "₹${(dues / 1000).toStringAsFixed(1)}k",
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.textDark),
                            ),
                            Text(
                              dues == 0 ? "All Cleared" : "Due Oct 15",
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: dues == 0 ? AppColors.success : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 4. 🔴 TODAY'S SCHEDULE & LIVE STREAM GLANCE ─────────────────────────
  Widget _buildLiveClassroomGlance(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top live badge & time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "LIVE CLASSROOM NOW",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.error,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const Text(
                "09:30 - 10:30 AM • LH-302",
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Subject & Teacher
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sensors_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Machine Learning & AI (CS-601)",
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    Text(
                      "Dr. Mohit Donawat • Hybrid Classroom Stream",
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              // Stream join button
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TimetableScreen()),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white),
                label: const Text("Join Stream", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 5. CORE 8 ERP SERVICES GRID (CLEAN 2-ROW GRID, ZERO CLUTTER) ────────
  Widget _buildCleanServicesGrid(BuildContext context, CampusProvider provider) {
    final items = [
      _CleanServiceItem(
        title: "Attendance",
        icon: Icons.how_to_reg_rounded,
        color: const Color(0xFF059669),
        bgColor: const Color(0xFFECFDF5),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen())),
      ),
      _CleanServiceItem(
        title: "Timetable",
        icon: Icons.calendar_month_rounded,
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen())),
      ),
      _CleanServiceItem(
        title: "Fee Portal",
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF0284C7),
        bgColor: const Color(0xFFF0F9FF),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeePaymentScreen())),
      ),
      _CleanServiceItem(
        title: "Certificates",
        icon: Icons.verified_rounded,
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFFFBEB),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DigitalCertificatesScreen())),
      ),
      _CleanServiceItem(
        title: "Course Reg.",
        icon: Icons.app_registration_rounded,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SemesterRegistrationScreen())),
      ),
      _CleanServiceItem(
        title: "Hostel & Mess",
        icon: Icons.apartment_rounded,
        color: const Color(0xFFDB2777),
        bgColor: const Color(0xFFFDF2F8),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostelScreen())),
      ),
      _CleanServiceItem(
        title: "Transit Bus",
        icon: Icons.directions_bus_rounded,
        color: const Color(0xFF0D9488),
        bgColor: const Color(0xFFF0FDFA),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportScreen())),
      ),
      _CleanServiceItem(
        title: "Helpdesk",
        icon: Icons.support_agent_rounded,
        color: const Color(0xFFEA580C),
        bgColor: const Color(0xFFFFF7ED),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpdeskScreen())),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
          childAspectRatio: 0.88,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              item.onTap();
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── 6. SMART AI COPILOT SUITE (POORA SAJA, COMPACT & RICH) ──────────────
  Widget _buildSmartAiCopilotBanner(BuildContext context, CampusProvider provider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Live Voice Assistant Tap Strip
          InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiVoiceAssistantScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE), width: 1.0),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Talk to Campus Voice AI",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                            ),
                            SizedBox(width: 6),
                            Text("🔴 LIVE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.error)),
                          ],
                        ),
                        SizedBox(height: 1),
                        Text(
                          "Instant speech answers on attendance, GPA, bus & fees",
                          style: TextStyle(fontSize: 10.5, color: Color(0xFF1E3A8A)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Two Quick AI Cards: Vernacular Audio Bot & Predicted SGPA
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VernacularStudyAssistantScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.record_voice_over_rounded, color: Color(0xFF059669), size: 18),
                        SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("7-Bhasha Audio Bot", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF065F46))),
                              Text("Hindi/Telugu explanations", style: TextStyle(fontSize: 8.5, color: Color(0xFF047857))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PredictivePerformanceScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE9D5FF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.psychology_rounded, color: Color(0xFF7C3AED), size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Predicted SGPA: ${provider.predictivePerformance.predictedSgpa}", style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF581C87))),
                              const Text("What-If Grade Simulator", style: TextStyle(fontSize: 8.5, color: Color(0xFF6B21A8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 7. OFFICIAL CAMPUS NOTICES & CIRCULARS ──────────────────────────────
  Widget _buildNoticeTile({
    required String tag,
    required String title,
    required String subtitle,
    required String date,
    required Color tagColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tag,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: tagColor),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(date, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
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
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
            color: AppColors.textDark,
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

class _CleanServiceItem {
  final String title;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _CleanServiceItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}
