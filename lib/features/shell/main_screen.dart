import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_logo.dart';
import '../../providers/campus_provider.dart';
import '../dashboard/student_dashboard_view.dart';
import '../dashboard/faculty_dashboard_view.dart';
import '../dashboard/admin_dashboard_view.dart';
import '../dashboard/parent_dashboard_view.dart';
import '../ai_assistant/ai_voice_assistant_screen.dart';
import '../ai_analytics/predictive_performance_screen.dart';
import '../ai_analytics/early_dropout_screen.dart';
import '../ai_learning/personalized_learning_screen.dart';
import '../attendance/attendance_screen.dart';
import '../timetable/timetable_screen.dart';
import '../certificates/digital_certificates_screen.dart';
import '../fees/fee_payment_screen.dart';
import '../hostel/hostel_screen.dart';
import '../transport/transport_screen.dart';
import '../helpdesk/helpdesk_screen.dart';
import '../lifecycle/student_lifecycle_screen.dart';
import '../semester_registration/semester_registration_screen.dart';
import '../study_assistant/vernacular_study_assistant_screen.dart';
import '../study_assistant/ai_tutor_vision_studio_screen.dart';
import '../account/professional_account_screen.dart';

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  MainScreen â€” premium redesign
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final role = provider.currentRole;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        appBar: _buildAppBar(context, provider),
        body: Column(
          children: [
            _buildRolePills(provider),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                child: _buildBodyForNav(role),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AiVoiceAssistantScreen(),
                transitionsBuilder: (_, anim, __, child) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: anim, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              ),
            );
          },
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.mic_rounded, color: Colors.white, size: 24),
        ),
        drawer: _buildDrawer(context, provider),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      BuildContext context, CampusProvider provider) {
    final role = provider.currentRole;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      leading: Builder(
        builder: (ctx) => InkWell(
          onTap: () => Scaffold.of(ctx).openDrawer(),
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: BrandLogo.compact(size: 34),
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 0.8),
                  ),
                  child: const Text(
                    "SaaS ERP",
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              "${AppConstants.institutionShort} • Autonomous University",
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      actions: [
        // Notification bell with red dot
        Stack(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.textDark, size: 22),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    color: AppColors.error, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
        // Role pill button
        GestureDetector(
          onTap: () => _showRoleSwitchModal(context, provider),
          child: Container(
            margin:
                const EdgeInsets.only(right: 6, top: 10, bottom: 10),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _getRoleColor(role).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _getRoleColor(role).withOpacity(0.4),
                  width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getRoleIcon(role),
                    size: 13, color: _getRoleColor(role)),
                const SizedBox(width: 5),
                Text(
                  role.displayName.split(' ').first,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _getRoleColor(role),
                  ),
                ),
                const SizedBox(width: 3),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 15, color: _getRoleColor(role)),
              ],
            ),
          ),
        ),
        // Professional Account Avatar Button
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfessionalAccountScreen()),
              );
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _getRoleColor(role).withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: _getRoleColor(role).withOpacity(0.5), width: 1.5),
              ),
              child: Center(
                child: Text(
                  provider.student.name.isNotEmpty ? provider.student.name[0] : 'U',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _getRoleColor(role),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Role pill row ───────────────────────────────────────────────────────────
  Widget _buildRolePills(CampusProvider provider) {
    final currentRole = provider.currentRole;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom:
                BorderSide(color: AppColors.borderLight, width: 1.0)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: UserRole.values.map((role) {
          final isSelected = role == currentRole;
          final color = _getRoleColor(role);
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                provider.switchRole(role);
                setState(() => _bottomNavIndex = 0);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.12)
                      : AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected ? color : AppColors.borderLight,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getRoleIcon(role),
                        size: 13,
                        color: isSelected
                            ? color
                            : AppColors.textMuted),
                    const SizedBox(width: 5),
                    Text(
                      role.displayName
                          .split(' / ')
                          .first
                          .split(' ')
                          .first,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? color
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Bottom Nav ──────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border:
            Border(top: BorderSide(color: AppColors.borderLight, width: 1.0)),
      ),
      child: NavigationBar(
        selectedIndex: _bottomNavIndex,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          setState(() => _bottomNavIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        height: 64,
        labelBehavior:
            NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.dashboard_rounded,
                color: AppColors.primary, size: 22),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_reg_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.how_to_reg_rounded,
                color: AppColors.primary, size: 22),
            label: "Attendance",
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.auto_awesome_rounded,
                color: AppColors.primary, size: 22),
            label: "AI Suite",
          ),
          NavigationDestination(
            icon: Icon(Icons.widgets_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.widgets_rounded,
                color: AppColors.primary, size: 22),
            label: "Services",
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.badge_rounded,
                color: AppColors.primary, size: 22),
            label: "Lifecycle",
          ),
        ],
      ),
    );
  }

  // â”€â”€ Body router â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildBodyForNav(UserRole role) {
    switch (_bottomNavIndex) {
      case 1:
        return const AttendanceScreen(key: ValueKey('att'));
      case 2:
        return _buildAiStudioHub();
      case 3:
        return _buildServicesHub();
      case 4:
        return const StudentLifecycleScreen(key: ValueKey('life'));
      default:
        switch (role) {
          case UserRole.student:
            return const StudentDashboardView(key: ValueKey('stu'));
          case UserRole.faculty:
            return const FacultyDashboardView(key: ValueKey('fac'));
          case UserRole.admin:
            return const AdminDashboardView(key: ValueKey('adm'));
          case UserRole.parent:
            return const ParentDashboardView(key: ValueKey('par'));
        }
    }
  }

  // â”€â”€ AI Studio Hub â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildAiStudioHub() {
    return SingleChildScrollView(
      key: const ValueKey('ai'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.auto_awesome_rounded, "Applied AI Suite",
              badge: "7 Modules", badgeColor: AppColors.accent),
          const SizedBox(height: 14),
          // Featured Card 00: Socratic AI Tutor & Multimodal Vision
          _aiCard(
            number: "00",
            title: "Socratic AI Tutor & Vision OCR",
            subtitle:
                "Feynman mother-tongue tutoring + Handwritten copy grading & Blackboard scanner",
            icon: Icons.psychology_rounded,
            color: const Color(0xFF9333EA),
            gradColors: const [Color(0xFF3B0764), Color(0xFF1E1B4B)],
            badge: "MULTIMODAL AI",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AiTutorVisionStudioScreen())),
          ),
          const SizedBox(height: 10),
          // Card 01 — full width
          _aiCard(
            number: "01",
            title: "Voice & Chat Assistant",
            subtitle:
                "Talk or type — get instant answers on attendance, GPA, bus & fees",
            icon: Icons.mic_rounded,
            color: const Color(0xFF7C3AED),
            gradColors: const [Color(0xFF2E1065), Color(0xFF1E1B4B)],
            badge: "LIVE SPEECH",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AiVoiceAssistantScreen())),
          ),
          const SizedBox(height: 10),
          // Cards 02 & 03 — half width
          Row(
            children: [
              Expanded(
                child: _aiMiniCard(
                  number: "02",
                  title: "Predictive Performance",
                  icon: Icons.trending_up_rounded,
                  color: AppColors.primaryLight,
                  badge: "ML Model",
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const PredictivePerformanceScreen())),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _aiMiniCard(
                  number: "03",
                  title: "Dropout Early Warning",
                  icon: Icons.shield_rounded,
                  color: AppColors.success,
                  badge: "EWS Radar",
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EarlyDropoutScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "04",
            title: "Personalized Learning",
            subtitle:
                "Skill gap detection + 14-day exam roadmap (Compiler Design & ML)",
            icon: Icons.psychology_rounded,
            color: AppColors.accentPink,
            gradColors: const [Color(0xFF4A0E2E), Color(0xFF1F0A15)],
            badge: "Adaptive",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PersonalizedLearningScreen())),
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "05",
            title: "Vernacular Study & Audio",
            subtitle:
                "Mother-tongue translation + Bhashini TTS voice (Hindi/Marathi)",
            icon: Icons.translate_rounded,
            color: const Color(0xFF10B981),
            gradColors: const [Color(0xFF064E3B), Color(0xFF0A1F18)],
            badge: "Bhashini API",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const VernacularStudyAssistantScreen())),
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "06",
            title: "Live Smart Class & AI Notes",
            subtitle:
                "Real-time hybrid streaming + AI lecture transcripts & Q&A doubts",
            icon: Icons.live_tv_rounded,
            color: const Color(0xFFEF4444),
            gradColors: const [Color(0xFF450A0A), Color(0xFF1C0606)],
            badge: "LIVE STREAM",
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TimetableScreen())),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Services Hub â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildServicesHub() {
    final items = [
      _Svc("Lifecycle & ID", Icons.badge_rounded, const Color(0xFF38BDF8),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentLifecycleScreen()))),
      _Svc("Course Reg", Icons.app_registration_rounded, const Color(0xFF00F5D4),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SemesterRegistrationScreen()))),
      _Svc("Attendance", Icons.how_to_reg_rounded, const Color(0xFF06D6A0),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()))),
      _Svc("Timetable", Icons.calendar_month_rounded, const Color(0xFF3A86FF),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen()))),
      _Svc("Certificates", Icons.verified_user_rounded, const Color(0xFFFFBE0B),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DigitalCertificatesScreen()))),
      _Svc("Fee Portal", Icons.payment_rounded, const Color(0xFF10B981),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeePaymentScreen()))),
      _Svc("Hostel & Mess", Icons.apartment_rounded, const Color(0xFFFF006E),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostelScreen()))),
      _Svc("Transit Bus", Icons.directions_bus_rounded, const Color(0xFF6366F1),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportScreen()))),
      _Svc("Helpdesk", Icons.support_agent_rounded, const Color(0xFFF97316),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpdeskScreen()))),
      _Svc("AI Voice Bot", Icons.mic_rounded, const Color(0xFFA855F7),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiVoiceAssistantScreen()))),
    ];

    return SingleChildScrollView(
      key: const ValueKey('svc'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.widgets_rounded, "Campus ERP Services",
              badge: "10 Modules", badgeColor: AppColors.primary),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final s = items[i];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: s.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: s.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(s.icon, color: s.color, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // â”€â”€ Section header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _sectionHeader(IconData icon, String label,
      {String? badge, Color? badgeColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: badgeColor ?? AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (badgeColor ?? AppColors.primary).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: (badgeColor ?? AppColors.primary).withOpacity(0.3)),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: badgeColor ?? AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  // â”€â”€ AI card (full-width) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _aiCard({
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> gradColors,
    required String badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "$number  $title",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
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

  // â”€â”€ AI mini-card (half-width) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _aiMiniCard({
    required String number,
    required String title,
    required IconData icon,
    required Color color,
    required String badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.04),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "$number  $title",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 3),
            const Icon(Icons.arrow_forward_rounded,
                size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Premium Drawer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildDrawer(BuildContext context, CampusProvider provider) {
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  const BrandLogo.compact(size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              AppConstants.appName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "SaaS",
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "${AppConstants.institutionShort} • Autonomous RGPV",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _dSection("SWITCH PORTAL"),
                  ...UserRole.values.map((r) => _roleItem(
                      context, provider, r,
                      isSelected: r == provider.currentRole)),
                  const Divider(
                      color: AppColors.borderLight,
                      height: 20,
                      thickness: 0.8),
                  _dSection("IDENTITY & PROFESSIONAL ACCOUNT"),
                  _dTile(Icons.account_box_rounded, "Professional Account & Dossier",
                      color: AppColors.primary, onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const ProfessionalAccountScreen()));
                  }),
                  _dTile(Icons.badge_rounded, "Digital PVC Smart ID Card",
                      color: const Color(0xFF38BDF8), onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const StudentLifecycleScreen()));
                  }),
                  const Divider(
                      color: AppColors.borderLight,
                      height: 20,
                      thickness: 0.8),
                  _dSection("AI SUITE"),
                  _dTile(Icons.psychology_rounded, "Socratic AI Tutor & Vision OCR",
                      color: const Color(0xFF9333EA), onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const AiTutorVisionStudioScreen()));
                  }),
                  _dTile(Icons.mic_rounded, "Voice Assistant",
                      color: AppColors.accent, onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const AiVoiceAssistantScreen()));
                  }),
                  _dTile(Icons.trending_up_rounded,
                      "Predictive Performance",
                      color: AppColors.primaryLight, onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const PredictivePerformanceScreen()));
                  }),
                  _dTile(Icons.shield_rounded,
                      "Early Dropout Prediction",
                      color: AppColors.success, onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EarlyDropoutScreen()));
                  }),
                  _dTile(Icons.psychology_rounded,
                      "Personalized Learning",
                      color: AppColors.accentPink, onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const PersonalizedLearningScreen()));
                  }),
                  _dTile(Icons.translate_rounded,
                      "Vernacular Study Audio",
                      color: const Color(0xFF10B981), onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const VernacularStudyAssistantScreen()));
                  }),
                  const Divider(
                      color: AppColors.borderLight,
                      height: 20,
                      thickness: 0.8),
                  _dSection("CAMPUS ERP SERVICES"),
                  _dTile(Icons.how_to_reg_rounded, "Attendance Radar",
                      onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AttendanceScreen()));
                  }),
                  _dTile(Icons.calendar_month_rounded, "Timetable & Classes",
                      onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TimetableScreen()));
                  }),
                  _dTile(Icons.verified_user_rounded,
                      "Digital Certificates", onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const DigitalCertificatesScreen()));
                  }),
                  _dTile(Icons.payment_rounded, "Fee Payments",
                      onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FeePaymentScreen()));
                  }),
                  _dTile(Icons.apartment_rounded, "Hostel & Mess",
                      onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HostelScreen()));
                  }),
                  _dTile(Icons.directions_bus_rounded,
                      "Transit Tracking", onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TransportScreen()));
                  }),
                  _dTile(Icons.support_agent_rounded,
                      "Helpdesk & Grievance", onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HelpdeskScreen()));
                  }),
                ],
              ),
            ),
            // Drawer Footer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.surfaceSubtle,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.code_rounded,
                          size: 14, color: AppColors.primary),
                      SizedBox(width: 5),
                      Text("Developed by Mr. Mohit Donawat",
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Text(AppConstants.affiliation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 9.5, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  const Text(AppConstants.appVersion,
                      style: TextStyle(
                          fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dSection(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
        child: Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.primary)),
      );

  Widget _roleItem(BuildContext context, CampusProvider provider,
      UserRole role,
      {required bool isSelected}) {
    final color = _getRoleColor(role);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isSelected ? color.withOpacity(0.3) : Colors.transparent),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(_getRoleIcon(role),
            color: isSelected ? color : AppColors.textMuted, size: 20),
        title: Text(
          role.displayName,
          style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? color : AppColors.textDark),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: color, size: 16)
            : null,
        onTap: () {
          provider.switchRole(role);
          setState(() => _bottomNavIndex = 0);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Switched to ${role.displayName}"),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ));
        },
      ),
    );
  }

  Widget _dTile(IconData icon, String title,
      {Color? color, required VoidCallback onTap}) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color ?? AppColors.textMuted, size: 19),
      title: Text(title,
          style: const TextStyle(
              fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  // â”€â”€ Role switch bottom sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _showRoleSwitchModal(BuildContext context, CampusProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Switch Portal",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...UserRole.values.map((r) {
                final isSelected = r == provider.currentRole;
                final color = _getRoleColor(r);
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getRoleIcon(r), color: color, size: 18),
                  ),
                  title: Text(r.displayName,
                      style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isSelected ? color : AppColors.textDark)),
                  subtitle: Text(r.department,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: color)
                      : const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.textMuted),
                  onTap: () {
                    provider.switchRole(r);
                    setState(() => _bottomNavIndex = 0);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String _getRoleGreeting(UserRole role) {
    switch (role) {
      case UserRole.student:
        return "Welcome, Rahul Sharma ðŸ‘‹";
      case UserRole.faculty:
        return "Dr. Mohit Donawat â€¢ HOD CSE";
      case UserRole.admin:
        return "Dr. R.K. Saxena â€¢ Registrar & COE";
      case UserRole.parent:
        return "Suresh Sharma â€¢ Ward: Rahul";
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppColors.accent;
      case UserRole.faculty:
        return const Color(0xFF60A5FA);
      case UserRole.admin:
        return const Color(0xFFFFBE0B);
      case UserRole.parent:
        return const Color(0xFF34D399);
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school_rounded;
      case UserRole.faculty:
        return Icons.badge_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.parent:
        return Icons.family_restroom_rounded;
    }
  }
}

// â”€â”€ Helper data class â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _Svc {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Svc(this.title, this.icon, this.color, this.onTap);
}

