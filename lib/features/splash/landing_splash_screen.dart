import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/services/document_download_service.dart';
import '../../providers/campus_provider.dart';
import '../shell/main_screen.dart';
import '../lifecycle/edit_profile_screen.dart';

/// Next-Generation Digital Campus Gateway & Portal Switcher Screen
class LandingSplashScreen extends StatefulWidget {
  const LandingSplashScreen({super.key});

  @override
  State<LandingSplashScreen> createState() => _LandingSplashScreenState();
}

class _LandingSplashScreenState extends State<LandingSplashScreen>
    with SingleTickerProviderStateMixin {
  String _selectedTenant = AppConstants.institutionName;
  UserRole _selectedRole = UserRole.student;

  void _navigateToMain(BuildContext context, [UserRole? role]) {
    HapticFeedback.mediumImpact();
    final roleToLaunch = role ?? _selectedRole;
    Provider.of<CampusProvider>(context, listen: false).switchRole(roleToLaunch);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return const Color(0xFF2563EB); // Royal Blue
      case UserRole.faculty:
        return const Color(0xFF7C3AED); // Modern Violet
      case UserRole.parent:
        return const Color(0xFF0D9488); // Emerald Teal
      case UserRole.admin:
        return const Color(0xFFD97706); // Amber Gold
    }
  }

  String _getRoleTitle(UserRole role) {
    switch (role) {
      case UserRole.student:
        return "Student Portal";
      case UserRole.faculty:
        return "Faculty & Teacher";
      case UserRole.parent:
        return "Parent & Guardian";
      case UserRole.admin:
        return "Admin & Registrar";
    }
  }

  String _getRoleTagline(UserRole role) {
    switch (role) {
      case UserRole.student:
        return "Courses, Attendance, AI Tutor & Smart ID";
      case UserRole.faculty:
        return "RFID Attendance, Live Streams & Rubrics";
      case UserRole.parent:
        return "Ward Attendance, Bus GPS & Instant Fees";
      case UserRole.admin:
        return "University Governance, Risk AI & ERP Ledger";
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school_rounded;
      case UserRole.faculty:
        return Icons.psychology_rounded;
      case UserRole.parent:
        return Icons.family_restroom_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<CampusProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Top Navigation & Brand Header ────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BrandLogo.banner(size: 36),
                    // Campus Tenant Switcher Pill
                    InkWell(
                      onTap: () => _showTenantPickerModal(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.account_balance_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 130),
                              child: Text(
                                _selectedTenant,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.unfold_more_rounded, size: 14, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Hero Banner ──────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt_rounded, size: 12, color: Color(0xFFFFBE0B)),
                                SizedBox(width: 4),
                                Text(
                                  "AUTONOMOUS CAMPUS ERP",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                                SizedBox(width: 4),
                                Text(
                                  "Live Cloud Node",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Welcome to Digital Campus",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Select your authorized portal to launch your personalized academic, grading, or administrative workspace.",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withOpacity(0.85),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Section Title: Select Portal Gateway ─────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "PORTAL GATEWAYS",
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      "Tap to Switch Role",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getRoleColor(_selectedRole),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── 4 Interactive Role Selection Cards ───────────────────────
                _buildRoleSelectionCard(
                  context,
                  role: UserRole.student,
                  title: "Student Portal",
                  subtitle: "Live Classes, Attendance, AI Tutor, PVC ID & Fee Dues",
                  tag: "${prov.student.name} • Roll: ${prov.student.rollNumber}",
                  icon: Icons.school_rounded,
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(height: 10),

                _buildRoleSelectionCard(
                  context,
                  role: UserRole.faculty,
                  title: "Faculty & Teacher",
                  subtitle: "Smart Attendance, Stream Live Class & Rubrics Grading",
                  tag: "Dr. Mohit Donawat • HOD Computer Science",
                  icon: Icons.psychology_rounded,
                  color: const Color(0xFF7C3AED),
                ),
                const SizedBox(height: 10),

                _buildRoleSelectionCard(
                  context,
                  role: UserRole.parent,
                  title: "Parent & Guardian",
                  subtitle: "Ward Attendance Alerts, Bus GPS Tracking & Instant Fees",
                  tag: "Suresh Sharma • Linked: Rahul Sharma",
                  icon: Icons.family_restroom_rounded,
                  color: const Color(0xFF0D9488),
                ),
                const SizedBox(height: 10),

                _buildRoleSelectionCard(
                  context,
                  role: UserRole.admin,
                  title: "Admin & Registrar",
                  subtitle: "University Governance, AI Drop-out Risk & Financial Ledger",
                  tag: "Dr. R.K. Saxena • Registrar & Exam Controller",
                  icon: Icons.admin_panel_settings_rounded,
                  color: const Color(0xFFD97706),
                ),

                const SizedBox(height: 18),

                // ── Active Persona Details Box ───────────────────────────────
                _buildActivePersonaBox(context, prov),

                const SizedBox(height: 20),

                // ── Primary Launch CTA Button ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToMain(context, _selectedRole),
                    icon: Icon(_getRoleIcon(_selectedRole), size: 20),
                    label: Text(
                      "Launch ${_getRoleTitle(_selectedRole)} ➔",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getRoleColor(_selectedRole),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: _getRoleColor(_selectedRole).withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Section 2: Official Institutional Documents ──────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "OFFICIAL DOWNLOADS",
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "100% Certified PDFs",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildDownloadItem(
                  context,
                  title: "Student PVC Smart ID Card",
                  subtitle: "Download official encrypted digital PVC ID credential",
                  icon: Icons.badge_rounded,
                  iconColor: const Color(0xFFD97706),
                  onDownload: () {
                    final student = Provider.of<CampusProvider>(context, listen: false).student;
                    DocumentDownloadService.downloadPvcIdCardPdf(context, student);
                  },
                ),
                const SizedBox(height: 8),

                _buildDownloadItem(
                  context,
                  title: "Academic Calendar 2026-27",
                  subtitle: "Semester schedules, examination dates & gazetted holidays",
                  icon: Icons.calendar_month_rounded,
                  iconColor: const Color(0xFF2563EB),
                  onDownload: () => DocumentDownloadService.downloadAcademicCalendarPdf(context),
                ),
                const SizedBox(height: 8),

                _buildDownloadItem(
                  context,
                  title: "University Prospectus & Curriculum",
                  subtitle: "Degree programs, AICTE seat matrix & syllabus overview",
                  icon: Icons.menu_book_rounded,
                  iconColor: const Color(0xFF059669),
                  onDownload: () => DocumentDownloadService.downloadProspectusPdf(context),
                ),

                const SizedBox(height: 24),

                // ── Platform Footer ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user_rounded, size: 13, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text(
                      "Digital Campus Enterprise v2.5.0 • Powered by Cloud SaaS",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Role Selection Card Widget ─────────────────────────────────────────────
  Widget _buildRoleSelectionCard(
    BuildContext context, {
    required UserRole role,
    required String title,
    required String subtitle,
    required String tag,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedRole = role;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.borderLight,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withOpacity(0.12) : Colors.black.withOpacity(0.02),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Role Icon with Accent Background
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? color : AppColors.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "ACTIVE",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.25),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 12, color: isSelected ? color : AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? color : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Selection Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : AppColors.borderLight,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Dynamic Active Persona Details Box ────────────────────────────────────
  Widget _buildActivePersonaBox(BuildContext context, CampusProvider prov) {
    final roleColor = _getRoleColor(_selectedRole);

    switch (_selectedRole) {
      case UserRole.student:
        final student = prov.student;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: roleColor.withOpacity(0.3), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: roleColor.withOpacity(0.06),
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
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.badge_rounded, color: roleColor, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "STUDENT PROFILE RECORD",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: roleColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_rounded, size: 12, color: roleColor),
                          const SizedBox(width: 4),
                          Text(
                            "Edit Details",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: roleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Enrollment: ${student.enrollmentNumber} • Roll: ${student.rollNumber}",
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(
                        "Sem ${student.semester} • ${student.section}",
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case UserRole.faculty:
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: roleColor.withOpacity(0.3), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.school_rounded, color: roleColor, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "FACULTY CREDENTIALS",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Dr. Mohit Donawat • HOD Computer Science & Eng.",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 2),
              const Text(
                "Teaching: Distributed Systems (CS-601), Machine Learning (CS-602)\nAccess: Smart RFID Attendance, Live Broadcasts, Assignment Rubrics",
                style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.3),
              ),
            ],
          ),
        );

      case UserRole.parent:
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: roleColor.withOpacity(0.3), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.verified_user_rounded, color: roleColor, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "PARENT / GUARDIAN ACCOUNT",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Suresh Sharma • Father & Registered Guardian",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 2),
              const Text(
                "Ward: Rahul Sharma (Enrollment: 0103CS211048)\nAccess: Ward Attendance Alerts, Bus Route #04 Live GPS, Fee Payments",
                style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.3),
              ),
            ],
          ),
        );

      case UserRole.admin:
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: roleColor.withOpacity(0.3), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shield_rounded, color: roleColor, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "REGISTRAR & ADMINISTRATIVE DESK",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Dr. R.K. Saxena • Registrar & Controller of Examinations",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 2),
              Text(
                "Active Tenant: $_selectedTenant • Autonomous Tier-1\nAccess: 4,280 Student DB, Financial Ledger, Faculty Allocations, NAAC",
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.3),
              ),
            ],
          ),
        );
    }
  }

  // ── Download Item Widget ───────────────────────────────────────────────────
  Widget _buildDownloadItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onDownload,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onDownload,
            icon: const Icon(Icons.download_rounded, size: 14),
            label: const Text("PDF", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceSubtle,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              side: const BorderSide(color: AppColors.borderLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Multi-Tenant College Picker Modal ──────────────────────────────────────
  void _showTenantPickerModal(BuildContext context) {
    final colleges = Provider.of<CampusProvider>(context, listen: false).colleges;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Cloud Institution Tenants",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${colleges.length} Active Nodes",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Select client campus to switch multi-tenant context:",
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              ...colleges.map((tenant) {
                final isSelected = tenant.name == _selectedTenant;
                final isApproved = tenant.status.toLowerCase() == "active";
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderLight,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance_rounded,
                        size: 20,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            tenant.name,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isApproved ? AppColors.success.withOpacity(0.12) : AppColors.warning.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tenant.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isApproved ? AppColors.success : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      "${tenant.city}, ${tenant.state} • ${tenant.studentCount} Students • ${tenant.affiliation}",
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedTenant = tenant.name;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Switched institution tenant to $_selectedTenant!"),
                          backgroundColor: AppColors.primary,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
