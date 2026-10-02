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
import '../registration/faculty_registration_desk_screen.dart';
import '../../models/campus_models.dart';
import '../study_assistant/vernacular_study_assistant_screen.dart';
import '../study_assistant/ai_tutor_vision_studio_screen.dart';
import '../account/professional_account_screen.dart';
import '../splash/landing_splash_screen.dart';
import '../quiz/teacher_quiz_studio_screen.dart';
import '../quiz/student_quiz_portal_screen.dart';
import '../faculty/faculty_edit_dossier_screen.dart';

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
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          child: _buildBodyForNav(role),
        ),
        bottomNavigationBar: _buildBottomNav(role),
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
      scrolledUnderElevation: 0.5,
      shadowColor: Colors.black.withOpacity(0.08),
      titleSpacing: 0,
      leading: Builder(
        builder: (ctx) => InkWell(
          onTap: () => Scaffold.of(ctx).openDrawer(),
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: BrandLogo.compact(size: 32),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              color: AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: _getRoleColor(role).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  role.displayName.split(' ').first.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: _getRoleColor(role),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  "${AppConstants.institutionShort} • Autonomous",
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Notification bell with live badge & notification inbox
        Consumer<CampusProvider>(
          builder: (context, provider, _) {
            final unreadCount = provider.unreadNotificationsCount;
            return SizedBox(
              width: 38,
              height: 38,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    onPressed: () => _showNotificationsBottomSheet(context, provider),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textDark,
                      size: 22,
                    ),
                    tooltip: "Campus Messages",
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Center(
                          child: Text(
                            unreadCount > 9 ? "9+" : "$unreadCount",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 2),
        // Direct Sign Out / Switch Role button
        SizedBox(
          width: 36,
          height: 36,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            onPressed: () => _confirmLogout(context),
            tooltip: "Switch Persona / Sign Out",
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 4),
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
                border: Border.all(
                  color: _getRoleColor(role).withOpacity(0.55),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  _getRoleAvatarLetter(provider, role),
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


  // ── Role-Specific Bottom Navigation Bar ────────────────────────────────────
  Widget _buildBottomNav(UserRole role) {
    final List<NavigationDestination> destinations;
    switch (role) {
      case UserRole.student:
        destinations = const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary, size: 22),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_reg_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.how_to_reg_rounded, color: AppColors.primary, size: 22),
            label: "Attendance",
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 22),
            label: "AI Suite",
          ),
          NavigationDestination(
            icon: Icon(Icons.widgets_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.widgets_rounded, color: AppColors.primary, size: 22),
            label: "Services",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
            label: "Profile",
          ),
        ];
        break;
      case UserRole.faculty:
        destinations = const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF60A5FA), size: 22),
            label: "Console",
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.calendar_month_rounded, color: Color(0xFF60A5FA), size: 22),
            label: "Timetable",
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.auto_awesome_rounded, color: Color(0xFF60A5FA), size: 22),
            label: "AI Suite",
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_reg_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.how_to_reg_rounded, color: Color(0xFF60A5FA), size: 22),
            label: "Attendance",
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.badge_rounded, color: Color(0xFF60A5FA), size: 22),
            label: "Profile",
          ),
        ];
        break;
      case UserRole.admin:
        destinations = const [
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFFFBE0B), size: 22),
            label: "Command",
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.insights_rounded, color: Color(0xFFFFBE0B), size: 22),
            label: "Analytics",
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFBE0B), size: 22),
            label: "AI Suite",
          ),
          NavigationDestination(
            icon: Icon(Icons.widgets_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.widgets_rounded, color: Color(0xFFFFBE0B), size: 22),
            label: "ERP Hub",
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.account_circle_rounded, color: Color(0xFFFFBE0B), size: 22),
            label: "Profile",
          ),
        ];
        break;
      case UserRole.parent:
        destinations = const [
          NavigationDestination(
            icon: Icon(Icons.family_restroom_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.family_restroom_rounded, color: Color(0xFF34D399), size: 22),
            label: "Ward Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_reg_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.how_to_reg_rounded, color: Color(0xFF34D399), size: 22),
            label: "Attendance",
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.auto_awesome_rounded, color: Color(0xFF34D399), size: 22),
            label: "AI Insights",
          ),
          NavigationDestination(
            icon: Icon(Icons.payment_outlined, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.payment_rounded, color: Color(0xFF34D399), size: 22),
            label: "Fee Pay",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, size: 22, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF34D399), size: 22),
            label: "Profile",
          ),
        ];
        break;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 1.0)),
      ),
      child: NavigationBar(
        selectedIndex: _bottomNavIndex,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          setState(() => _bottomNavIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: _getRoleColor(role).withOpacity(0.14),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: destinations,
      ),
    );
  }

  // ── Role-Isolated Body Router ───────────────────────────────────────────────
  Widget _buildBodyForNav(UserRole role) {
    if (_bottomNavIndex == 4) {
      return const ProfessionalAccountScreen(key: ValueKey('account_nav'));
    }
    switch (role) {
      case UserRole.student:
        switch (_bottomNavIndex) {
          case 1:
            return const AttendanceScreen(key: ValueKey('stu_att'));
          case 2:
            return _buildAiStudioHub(role);
          case 3:
            return _buildServicesHub();
          default:
            return const StudentDashboardView(key: ValueKey('stu_home'));
        }
      case UserRole.faculty:
        switch (_bottomNavIndex) {
          case 1:
            return const TimetableScreen(key: ValueKey('fac_tt'));
          case 2:
            return _buildAiStudioHub(role);
          case 3:
            return const AttendanceScreen(key: ValueKey('fac_att'));
          default:
            return const FacultyDashboardView(key: ValueKey('fac_home'));
        }
      case UserRole.admin:
        switch (_bottomNavIndex) {
          case 1:
            return const EarlyDropoutScreen(key: ValueKey('adm_analytics'));
          case 2:
            return _buildAiStudioHub(role);
          case 3:
            return _buildServicesHub();
          default:
            return const AdminDashboardView(key: ValueKey('adm_home'));
        }
      case UserRole.parent:
        switch (_bottomNavIndex) {
          case 1:
            return const AttendanceScreen(key: ValueKey('par_att'));
          case 2:
            return _buildAiStudioHub(role);
          case 3:
            return const FeePaymentScreen(key: ValueKey('par_fees'));
          default:
            return const ParentDashboardView(key: ValueKey('par_home'));
        }
    }
  }

  // ── Campus Notifications & Messages BottomSheet ────────────────────────────
  void _showNotificationsBottomSheet(BuildContext context, CampusProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final notifs = provider.notifications;
            final role = provider.currentRole;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
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
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text("Campus Messages", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          const SizedBox(width: 8),
                          if (provider.unreadNotificationsCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${provider.unreadNotificationsCount} new",
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.error),
                              ),
                            ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          provider.markAllNotificationsAsRead();
                          setModalState(() {});
                        },
                        child: const Text("Mark All Read", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (notifs.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text("No campus messages yet", style: TextStyle(color: AppColors.textMuted)),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: notifs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final n = notifs[index];
                          Color iconBg = AppColors.primaryLight;
                          Color iconColor = AppColors.primary;
                          IconData icon = Icons.info_outline_rounded;

                          if (n.title.contains("APPROVED") || n.title.contains("Verified")) {
                            iconBg = const Color(0xFFDCFCE7);
                            iconColor = const Color(0xFF15803D);
                            icon = Icons.check_circle_rounded;
                          } else if (n.title.contains("REJECTED")) {
                            iconBg = const Color(0xFFFEE2E2);
                            iconColor = AppColors.error;
                            icon = Icons.cancel_rounded;
                          } else if (n.type == "attendance") {
                            iconBg = const Color(0xFFEFF6FF);
                            iconColor = const Color(0xFF2563EB);
                            icon = Icons.how_to_reg_rounded;
                          }

                          return InkWell(
                            onTap: () {
                              provider.markNotificationAsRead(n.id);
                              Navigator.pop(ctx);
                              if (n.type == "registration") {
                                if (role == UserRole.faculty || role == UserRole.admin) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FacultyRegistrationDeskScreen()));
                                } else {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SemesterRegistrationScreen()));
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                                    child: Icon(icon, size: 16, color: iconColor),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                n.title,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                            ),
                                            if (!n.isRead)
                                              Container(
                                                width: 7,
                                                height: 7,
                                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          n.body,
                                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Tap to view details",
                                          style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Role-Specific AI Studio Hub Router ─────────────────────────────────────
  Widget _buildAiStudioHub(UserRole role) {
    switch (role) {
      case UserRole.student:
        return _buildStudentAiHub();
      case UserRole.faculty:
        return _buildFacultyAiHub();
      case UserRole.admin:
        return _buildAdminAiHub();
      case UserRole.parent:
        return _buildParentAiHub();
    }
  }

  // 1. 🎓 Student AI Suite (Personalized Learning, Careers & Exam Prep)
  Widget _buildStudentAiHub() {
    return SingleChildScrollView(
      key: const ValueKey('ai_student'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.school_rounded, "Student AI Learning Studio",
              badge: "Personalized", badgeColor: AppColors.primary),
          const SizedBox(height: 14),
          _aiCard(
            number: "01",
            title: "Socratic AI Tutor & Vision OCR",
            subtitle: "Feynman concept tutor + Handwritten homework scanner & grading",
            icon: Icons.psychology_rounded,
            color: const Color(0xFF9333EA),
            gradColors: const [Color(0xFF3B0764), Color(0xFF1E1B4B)],
            badge: "MULTIMODAL AI",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AiTutorVisionStudioScreen())),
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "02",
            title: "Personalized 14-Day Exam Roadmap",
            subtitle: "Skill gap analysis + AI adaptive study schedule (Compiler & ML)",
            icon: Icons.auto_graph_rounded,
            color: AppColors.accentPink,
            gradColors: const [Color(0xFF4A0E2E), Color(0xFF1F0A15)],
            badge: "Adaptive Prep",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const PersonalizedLearningScreen())),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _aiMiniCard(
                  number: "03",
                  title: "Vernacular Audio",
                  icon: Icons.translate_rounded,
                  color: const Color(0xFF10B981),
                  badge: "Bhashini AI",
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const VernacularStudyAssistantScreen())),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _aiMiniCard(
                  number: "04",
                  title: "Campus Voice Bot",
                  icon: Icons.mic_rounded,
                  color: const Color(0xFF7C3AED),
                  badge: "Live Speech",
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const AiVoiceAssistantScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "05",
            title: "Predictive CGPA & Result Radar",
            subtitle: "Deep learning models predict university marks & percentile",
            icon: Icons.trending_up_rounded,
            color: AppColors.primaryLight,
            gradColors: const [Color(0xFF1E3A8A), Color(0xFF0F172A)],
            badge: "ML Forecast",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const PredictivePerformanceScreen())),
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "06",
            title: "Live Smart Class & AI Lecture Notes",
            subtitle: "Real-time streaming + AI notes, transcripts & doubts",
            icon: Icons.live_tv_rounded,
            color: const Color(0xFFEF4444),
            gradColors: const [Color(0xFF450A0A), Color(0xFF1C0606)],
            badge: "Smart Stream",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const TimetableScreen())),
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "07",
            title: "Adaptive Bloom's Quizzes & Tests",
            subtitle: "Targeted curriculum assessments, anti-cheat sandbox & class ranks",
            icon: Icons.quiz_rounded,
            color: const Color(0xFFD97706),
            gradColors: const [Color(0xFF451A03), Color(0xFF1F1206)],
            badge: "Proctored Exam",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const StudentQuizPortalScreen())),
          ),
        ],
      ),
    );
  }

  // 2. 👨‍🏫 Faculty AI Suite (Teaching Assistant, Grading, Detention Interventions)
  Widget _buildFacultyAiHub() {
    return SingleChildScrollView(
      key: const ValueKey('ai_faculty'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.psychology_rounded, "Faculty AI Teaching Console",
              badge: "Smart Faculty", badgeColor: const Color(0xFF60A5FA)),
          const SizedBox(height: 14),
          _aiCard(
            number: "01",
            title: "AI Answer Sheet Grader & Vision OCR",
            subtitle: "Multimodal scanner for student test copies + rubric auto-scoring",
            icon: Icons.document_scanner_rounded,
            color: const Color(0xFF3B82F6),
            gradColors: const [Color(0xFF1E3A8A), Color(0xFF0F172A)],
            badge: "Auto Grading",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AiTutorVisionStudioScreen())),
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "02",
            title: "Smart Class Live Studio (Jitsi/Meet/Zoom)",
            subtitle: "Host live hybrid lectures with 1-tap connect & automated attendance",
            icon: Icons.sensors_rounded,
            color: const Color(0xFF8B5CF6),
            gradColors: const [Color(0xFF2E1065), Color(0xFF1E1B4B)],
            badge: "Live Studio",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const TimetableScreen())),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _aiMiniCard(
                  number: "03",
                  title: "Defaulter Radar",
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.error,
                  badge: "Intervention",
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const AttendanceScreen())),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _aiMiniCard(
                  number: "04",
                  title: "Faculty Voice",
                  icon: Icons.mic_rounded,
                  color: const Color(0xFF059669),
                  badge: "Voice ERP",
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const AiVoiceAssistantScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "05",
            title: "Adaptive Teaching & Bloom's Quiz Studio",
            subtitle: "Targeted branch/sem quiz builder, textbook RAG & live leaderboard",
            icon: Icons.quiz_rounded,
            color: const Color(0xFFD97706),
            gradColors: const [Color(0xFF451A03), Color(0xFF1F1206)],
            badge: "Faculty Studio",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const TeacherQuizStudioScreen())),
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "06",
            title: "Dropout Early Warning Radar (EWS)",
            subtitle: "Predictive student detention risks and automated mentor counseling alerts",
            icon: Icons.shield_rounded,
            color: const Color(0xFF10B981),
            gradColors: const [Color(0xFF064E3B), Color(0xFF0A1F18)],
            badge: "EWS Alerts",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const EarlyDropoutScreen())),
          ),
        ],
      ),
    );
  }

  // 3. 🏛️ Admin AI Suite (Institutional Intelligence, Governance & Accreditation)
  Widget _buildAdminAiHub() {
    return SingleChildScrollView(
      key: const ValueKey('ai_admin'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.admin_panel_settings_rounded, "Institutional AI Command",
              badge: "Autonomous ERP", badgeColor: const Color(0xFFFFBE0B)),
          const SizedBox(height: 14),
          _aiCard(
            number: "01",
            title: "AI Dropout & Retention Radar (EWS)",
            subtitle: "Predictive deep learning models flag dropout risks 4 weeks early",
            icon: Icons.shield_rounded,
            color: const Color(0xFFEF4444),
            gradColors: const [Color(0xFF450A0A), Color(0xFF1C0606)],
            badge: "CRITICAL EWS",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const EarlyDropoutScreen())),
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "02",
            title: "Predictive Academic Performance Radar",
            subtitle: "Institutional grade forecasting, rank distribution & department pass rates",
            icon: Icons.insights_rounded,
            color: const Color(0xFFFFBE0B),
            gradColors: const [Color(0xFF451A03), Color(0xFF1F1206)],
            badge: "Rank ML",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const PredictivePerformanceScreen())),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _aiMiniCard(
                  number: "03",
                  title: "Autonomous Voice",
                  icon: Icons.mic_rounded,
                  color: const Color(0xFF8B5CF6),
                  badge: "Executive",
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const AiVoiceAssistantScreen())),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _aiMiniCard(
                  number: "04",
                  title: "Accreditation AI",
                  icon: Icons.verified_rounded,
                  color: const Color(0xFF10B981),
                  badge: "NAAC / NBA",
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const AiTutorVisionStudioScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "05",
            title: "Curriculum & CO-PO Mapping Engine",
            subtitle: "Outcome-based education syllabus tracking & student competency audit",
            icon: Icons.account_tree_rounded,
            color: const Color(0xFF3B82F6),
            gradColors: const [Color(0xFF1E3A8A), Color(0xFF0F172A)],
            badge: "NBA CO-PO",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const PersonalizedLearningScreen())),
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "06",
            title: "Campus Multilingual Broadcast Engine",
            subtitle: "Regional language parent circulars & automated Bhashini AI voice alerts",
            icon: Icons.campaign_rounded,
            color: const Color(0xFF14B8A6),
            gradColors: const [Color(0xFF042F2E), Color(0xFF0A1F18)],
            badge: "Bhashini Voice",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const VernacularStudyAssistantScreen())),
          ),
        ],
      ),
    );
  }

  // 4. 👨‍👩‍👧 Parent AI Suite (Ward Care, Safety & Guidance)
  Widget _buildParentAiHub() {
    return SingleChildScrollView(
      key: const ValueKey('ai_parent'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.family_restroom_rounded, "Parent AI Ward Care Hub",
              badge: "Ward Shield", badgeColor: const Color(0xFF34D399)),
          const SizedBox(height: 14),
          _aiCard(
            number: "01",
            title: "Ward Performance & Exam Predictor",
            subtitle: "AI forecasting of upcoming exam grades, strengths & areas of improvement",
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF10B981),
            gradColors: const [Color(0xFF064E3B), Color(0xFF0A1F18)],
            badge: "Exam Forecast",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const PredictivePerformanceScreen())),
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "02",
            title: "Attendance Safety & Detention Shield",
            subtitle: "Real-time safety alerts before student breaches the 75% university criteria",
            icon: Icons.verified_user_rounded,
            color: const Color(0xFF059669),
            gradColors: const [Color(0xFF065F46), Color(0xFF0F172A)],
            badge: "75% Safety",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AttendanceScreen())),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _aiMiniCard(
                  number: "03",
                  title: "Mother-Tongue AI",
                  icon: Icons.record_voice_over_rounded,
                  color: const Color(0xFF8B5CF6),
                  badge: "Hindi Voice",
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const VernacularStudyAssistantScreen())),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _aiMiniCard(
                  number: "04",
                  title: "Parent Voice Bot",
                  icon: Icons.support_agent_rounded,
                  color: const Color(0xFF2563EB),
                  badge: "24x7 Q&A",
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const AiVoiceAssistantScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "05",
            title: "Personalized Ward Coaching Advisory",
            subtitle: "Tailored AI guidance on subject tutoring & skill gaps for your ward",
            icon: Icons.psychology_rounded,
            color: const Color(0xFFD97706),
            gradColors: const [Color(0xFF451A03), Color(0xFF1F1206)],
            badge: "Coaching Guide",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const PersonalizedLearningScreen())),
          ),
          const SizedBox(height: 10),
          _aiCard(
            number: "06",
            title: "Daily Hybrid Class Recordings & Notes",
            subtitle: "Access verified lecture recordings and AI study notes attended by ward",
            icon: Icons.video_library_rounded,
            color: const Color(0xFF6366F1),
            gradColors: const [Color(0xFF1E1B4B), Color(0xFF0F172A)],
            badge: "Lecture Archive",
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const TimetableScreen())),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Services Hub â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildServicesHub() {
    final items = [
      _Svc("Smart ID Pass", Icons.badge_rounded, const Color(0xFF38BDF8),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentLifecycleScreen()))),
      _Svc("Course Reg", Icons.app_registration_rounded, const Color(0xFF00F5D4), () {
        final r = Provider.of<CampusProvider>(context, listen: false).currentRole;
        if (r == UserRole.faculty || r == UserRole.admin) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FacultyRegistrationDeskScreen()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SemesterRegistrationScreen()));
        }
      }),
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
              childAspectRatio: 0.88,
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
    final role = provider.currentRole;
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
                  const BrandLogo.compact(size: 38),
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
                                color: _getRoleColor(role).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                role.displayName.split(' ').first.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: _getRoleColor(role),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "${AppConstants.institutionShort} • Autonomous University",
                          style: TextStyle(
                            fontSize: 10.5,
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
                  _dSection("ACTIVE UNIVERSE SESSION"),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getRoleColor(role).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getRoleColor(role).withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: _getRoleColor(role),
                          child: Icon(_getRoleIcon(role), color: Colors.white, size: 17),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role.displayName,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: _getRoleColor(role),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                _getRoleGreeting(provider, role),
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                      color: AppColors.borderLight,
                      height: 18,
                      thickness: 0.8),

                  // ── ROLE-SPECIFIC MENU MODULES ──
                  ..._buildRoleDrawerItems(context, provider, role),

                  const Divider(
                      color: AppColors.borderLight,
                      height: 20,
                      thickness: 0.8),
                  _dSection("SESSION CONTROL"),
                  _dTile(
                    Icons.logout_rounded,
                    "Log Out & Switch Persona",
                    color: AppColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      _confirmLogout(context);
                    },
                  ),
                ],
              ),
            ),
            // Drawer Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      Text("Digital Campus Enterprise",
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

  // ── Role Dispatcher for Drawer Navigation ──────────────────────────────────
  List<Widget> _buildRoleDrawerItems(
      BuildContext context, CampusProvider provider, UserRole role) {
    switch (role) {
      case UserRole.faculty:
        return _buildFacultyDrawerItems(context, provider);
      case UserRole.student:
        return _buildStudentDrawerItems(context, provider);
      case UserRole.admin:
        return _buildAdminDrawerItems(context, provider);
      case UserRole.parent:
        return _buildParentDrawerItems(context, provider);
    }
  }

  // ── 👨‍🏫 FACULTY DRAWER ITEMS ───────────────────────────────────────────────
  List<Widget> _buildFacultyDrawerItems(
      BuildContext context, CampusProvider provider) {
    final pendingCount = provider.semesterRegistrations
        .where((r) => r.status == RegistrationStatus.pending)
        .length;
    return [
      _dSection("TEACHING & ACADEMIC GOVERNANCE"),
      _dTile(
        Icons.assignment_turned_in_rounded,
        "Semester Course Registration Desk",
        color: const Color(0xFF2563EB),
        trailing: pendingCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Text(
                  "$pendingCount PENDING",
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.error,
                  ),
                ),
              )
            : null,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const FacultyRegistrationDeskScreen()),
          );
        },
      ),
      _dTile(
        Icons.how_to_reg_rounded,
        "Attendance Radar & Student Records",
        color: const Color(0xFF059669),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AttendanceScreen()),
          );
        },
      ),
      _dTile(
        Icons.calendar_month_rounded,
        "Timetable & Live Hybrid Studio",
        color: const Color(0xFF8B5CF6),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TimetableScreen()),
          );
        },
      ),
      _dTile(
        Icons.document_scanner_rounded,
        "AI Test Copy Grader & Vision OCR",
        color: const Color(0xFFD97706),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AiTutorVisionStudioScreen()),
          );
        },
      ),

      const Divider(color: AppColors.borderLight, height: 18, thickness: 0.8),
      _dSection("FACULTY AI & INTERVENTION"),
      _dTile(
        Icons.shield_rounded,
        "At-Risk Defaulter & Dropout Radar",
        color: AppColors.error,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EarlyDropoutScreen()),
          );
        },
      ),
      _dTile(
        Icons.trending_up_rounded,
        "Predictive Student Batch CGPA",
        color: const Color(0xFF2563EB),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const PredictivePerformanceScreen()),
          );
        },
      ),
      _dTile(
        Icons.mic_rounded,
        "Faculty AI Voice Assistant",
        color: AppColors.accent,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiVoiceAssistantScreen()),
          );
        },
      ),

      const Divider(color: AppColors.borderLight, height: 18, thickness: 0.8),
      _dSection("FACULTY DOSSIER & SERVICES"),
      _dTile(
        Icons.badge_rounded,
        "Official Faculty ID Card & RFID",
        color: const Color(0xFF38BDF8),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudentLifecycleScreen()),
          );
        },
      ),
      _dTile(
        Icons.account_box_rounded,
        "Faculty Profile & Academic Dossier",
        color: const Color(0xFF4F46E5),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ProfessionalAccountScreen()),
          );
        },
      ),
      _dTile(
        Icons.support_agent_rounded,
        "Faculty Desk & Administrative Grievance",
        color: const Color(0xFF0284C7),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpdeskScreen()),
          );
        },
      ),
    ];
  }

  // ── 🎓 STUDENT DRAWER ITEMS ───────────────────────────────────────────────
  List<Widget> _buildStudentDrawerItems(
      BuildContext context, CampusProvider provider) {
    final reg = provider.currentStudentRegistration;
    return [
      _dSection("ACADEMICS & ENROLLMENT"),
      _dTile(
        Icons.school_rounded,
        "Semester Course Registration",
        color: AppColors.primary,
        trailing: reg != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: reg.status.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reg.status.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: reg.status.color,
                  ),
                ),
              )
            : null,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const SemesterRegistrationScreen()),
          );
        },
      ),
      _dTile(
        Icons.how_to_reg_rounded,
        "My Attendance & Radar",
        color: const Color(0xFF059669),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AttendanceScreen()),
          );
        },
      ),
      _dTile(
        Icons.calendar_month_rounded,
        "My Classes & Timetable",
        color: const Color(0xFF8B5CF6),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TimetableScreen()),
          );
        },
      ),
      _dTile(
        Icons.verified_user_rounded,
        "Digital Degree & Certificates",
        color: const Color(0xFFD97706),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const DigitalCertificatesScreen()),
          );
        },
      ),

      const Divider(color: AppColors.borderLight, height: 18, thickness: 0.8),
      _dSection("STUDENT AI STUDY SUITE"),
      _dTile(
        Icons.psychology_rounded,
        "Socratic AI Tutor & Vision OCR",
        color: const Color(0xFF9333EA),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AiTutorVisionStudioScreen()),
          );
        },
      ),
      _dTile(
        Icons.auto_graph_rounded,
        "Personalized 14-Day Roadmap",
        color: AppColors.accentPink,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const PersonalizedLearningScreen()),
          );
        },
      ),
      _dTile(
        Icons.translate_rounded,
        "Vernacular Study Audio (Bhashini)",
        color: const Color(0xFF10B981),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const VernacularStudyAssistantScreen()),
          );
        },
      ),
      _dTile(
        Icons.mic_rounded,
        "Campus AI Voice Bot",
        color: AppColors.accent,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiVoiceAssistantScreen()),
          );
        },
      ),
      _dTile(
        Icons.trending_up_rounded,
        "Predictive CGPA & Result Radar",
        color: const Color(0xFF2563EB),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const PredictivePerformanceScreen()),
          );
        },
      ),

      const Divider(color: AppColors.borderLight, height: 18, thickness: 0.8),
      _dSection("CAMPUS LIFE & STUDENT SERVICES"),
      _dTile(
        Icons.payment_rounded,
        "Fee Payment & Dues Clearance",
        color: const Color(0xFF0D9488),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeePaymentScreen()),
          );
        },
      ),
      _dTile(
        Icons.badge_rounded,
        "Digital PVC Smart ID Card",
        color: const Color(0xFF38BDF8),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudentLifecycleScreen()),
          );
        },
      ),
      _dTile(
        Icons.apartment_rounded,
        "Hostel & Mess Allocation",
        color: const Color(0xFFEA580C),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HostelScreen()),
          );
        },
      ),
      _dTile(
        Icons.directions_bus_rounded,
        "Bus Fleet & Transit GPS",
        color: const Color(0xFF0284C7),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransportScreen()),
          );
        },
      ),
      _dTile(
        Icons.account_box_rounded,
        "Student Profile & Dossier",
        color: const Color(0xFF4F46E5),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ProfessionalAccountScreen()),
          );
        },
      ),
      _dTile(
        Icons.support_agent_rounded,
        "Student Grievance & Helpdesk",
        color: const Color(0xFFE11D48),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpdeskScreen()),
          );
        },
      ),
    ];
  }

  // ── 🏛️ ADMIN DRAWER ITEMS ─────────────────────────────────────────────────
  List<Widget> _buildAdminDrawerItems(
      BuildContext context, CampusProvider provider) {
    final pendingCount = provider.semesterRegistrations
        .where((r) => r.status == RegistrationStatus.pending)
        .length;
    return [
      _dSection("STATUTORY GOVERNANCE & OVERSIGHT"),
      _dTile(
        Icons.assignment_turned_in_rounded,
        "Semester Registrations Desk",
        color: const Color(0xFFFFBE0B),
        trailing: pendingCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$pendingCount PENDING",
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.error,
                  ),
                ),
              )
            : null,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const FacultyRegistrationDeskScreen()),
          );
        },
      ),
      _dTile(
        Icons.verified_user_rounded,
        "Digital Certificate Master Authority",
        color: const Color(0xFF2563EB),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const DigitalCertificatesScreen()),
          );
        },
      ),
      _dTile(
        Icons.how_to_reg_rounded,
        "University Attendance Intelligence",
        color: const Color(0xFF059669),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AttendanceScreen()),
          );
        },
      ),
      _dTile(
        Icons.shield_rounded,
        "Institutional Dropout Analytics",
        color: AppColors.error,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EarlyDropoutScreen()),
          );
        },
      ),

      const Divider(color: AppColors.borderLight, height: 18, thickness: 0.8),
      _dSection("UNIVERSITY INFRASTRUCTURE"),
      _dTile(
        Icons.payment_rounded,
        "Tuition Dues & Statutory Audit",
        color: const Color(0xFF0D9488),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeePaymentScreen()),
          );
        },
      ),
      _dTile(
        Icons.directions_bus_rounded,
        "Campus Fleet Operations",
        color: const Color(0xFF0284C7),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransportScreen()),
          );
        },
      ),
      _dTile(
        Icons.apartment_rounded,
        "Hostel Capacity & Facilities",
        color: const Color(0xFFEA580C),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HostelScreen()),
          );
        },
      ),
      _dTile(
        Icons.badge_rounded,
        "Dean Executive Seal Pass & RFID",
        color: const Color(0xFFD97706),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudentLifecycleScreen()),
          );
        },
      ),
      _dTile(
        Icons.account_box_rounded,
        "Administrator Dossier",
        color: const Color(0xFF4F46E5),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ProfessionalAccountScreen()),
          );
        },
      ),
      _dTile(
        Icons.support_agent_rounded,
        "Executive Helpdesk & Compliance",
        color: const Color(0xFFE11D48),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpdeskScreen()),
          );
        },
      ),
    ];
  }

  // ── 👨‍👩‍👦 PARENT DRAWER ITEMS ───────────────────────────────────────────────
  List<Widget> _buildParentDrawerItems(
      BuildContext context, CampusProvider provider) {
    return [
      _dSection("WARD MONITORING & ACADEMICS"),
      _dTile(
        Icons.how_to_reg_rounded,
        "Ward Attendance & Safe Bunk Radar",
        color: const Color(0xFF059669),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AttendanceScreen()),
          );
        },
      ),
      _dTile(
        Icons.calendar_month_rounded,
        "Ward Class Timetable",
        color: const Color(0xFF8B5CF6),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TimetableScreen()),
          );
        },
      ),
      _dTile(
        Icons.trending_up_rounded,
        "Academic Performance & CGPA",
        color: const Color(0xFF2563EB),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const PredictivePerformanceScreen()),
          );
        },
      ),

      const Divider(color: AppColors.borderLight, height: 18, thickness: 0.8),
      _dSection("FINANCE & SAFETY"),
      _dTile(
        Icons.payment_rounded,
        "Tuition Fee Dues & Receipts",
        color: const Color(0xFF0D9488),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeePaymentScreen()),
          );
        },
      ),
      _dTile(
        Icons.directions_bus_rounded,
        "Live School Bus & Transit GPS",
        color: const Color(0xFF0284C7),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransportScreen()),
          );
        },
      ),
      _dTile(
        Icons.apartment_rounded,
        "Hostel Gate Pass & Mess Meal",
        color: const Color(0xFFEA580C),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HostelScreen()),
          );
        },
      ),
      _dTile(
        Icons.badge_rounded,
        "Guardian Campus Security Gate Pass",
        color: const Color(0xFF059669),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StudentLifecycleScreen()),
          );
        },
      ),
      _dTile(
        Icons.account_box_rounded,
        "Parent Account Profile",
        color: const Color(0xFF4F46E5),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ProfessionalAccountScreen()),
          );
        },
      ),
      _dTile(
        Icons.support_agent_rounded,
        "Faculty Mentor Direct Hotline",
        color: const Color(0xFFE11D48),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpdeskScreen()),
          );
        },
      ),
    ];
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

  Widget _dTile(IconData icon, String title,
      {Color? color, Widget? trailing, required VoidCallback onTap}) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color ?? AppColors.primary, size: 17),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 12.5,
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  // â”€â”€ Role switch bottom sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // ── Logout Confirmation Dialog & Exit ──────────────────────────────────────
  void _confirmLogout(BuildContext context) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text("Confirm Sign Out", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: const Text(
          "Are you sure you want to end your active portal session? You will be safely returned to the Digital Campus Universe Selection Gateway to choose a persona.",
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Stay Logged In", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LandingSplashScreen()),
                (route) => false,
              );
            },
            child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  String _getRoleAvatarLetter(CampusProvider provider, UserRole role) {
    switch (role) {
      case UserRole.student:
        return provider.student.name.isNotEmpty ? provider.student.name[0] : 'S';
      case UserRole.faculty:
        return provider.facultyProfile.name.isNotEmpty ? provider.facultyProfile.name[0] : 'T';
      case UserRole.admin:
        return provider.adminProfile.name.isNotEmpty ? provider.adminProfile.name[0] : 'A';
      case UserRole.parent:
        return provider.parentProfile.guardianName.isNotEmpty ? provider.parentProfile.guardianName[0] : 'P';
    }
  }

  String _getRoleGreeting(CampusProvider provider, UserRole role) {
    switch (role) {
      case UserRole.student:
        return "${provider.student.name} • Roll: ${provider.student.rollNumber}";
      case UserRole.faculty:
        return "${provider.facultyProfile.name} • ${provider.facultyProfile.department}";
      case UserRole.admin:
        return "${provider.adminProfile.name} • ${provider.adminProfile.designation}";
      case UserRole.parent:
        return "${provider.parentProfile.guardianName} • Ward: ${provider.parentProfile.studentName}";
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

