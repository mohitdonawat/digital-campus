import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/campus_provider.dart';
import '../ai_analytics/early_dropout_screen.dart';
import '../certificates/digital_certificates_screen.dart';
import '../helpdesk/helpdesk_screen.dart';
import '../attendance/attendance_screen.dart';
import '../account/professional_account_screen.dart';

/// Ultra-Clean, Executive University Admin Dashboard
class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);

    return RefreshIndicator(
      color: const Color(0xFFFFBE0B),
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
            // ── 1. ADMIN EXECUTIVE HERO ───────────────────────────────────────
            _buildAdminHero(context, provider),

            const SizedBox(height: 16),

            // ── 2. FOUR UNIVERSITY VITALS ─────────────────────────────────────
            _buildUniversityVitalsGrid(context),

            const SizedBox(height: 18),

            // ── 3. CORE GOVERNANCE MODULES ────────────────────────────────────
            _buildSectionTitle("ADMINISTRATIVE OPERATIONS"),
            const SizedBox(height: 8),
            _buildGovernanceModulesGrid(context),

            const SizedBox(height: 18),

            // ── 4. INSTITUTIONAL AUDIT ACTIVITY ───────────────────────────────
            _buildSectionTitle("RECENT UNIVERSITY ACTIONS"),
            const SizedBox(height: 8),
            _buildAuditActivityCard(
              title: "AICTE Statutory Compliance Audit",
              subtitle: "Faculty-to-student cadre ratio: 1:15 (Fully Compliant)",
              status: "VERIFIED",
              statusColor: AppColors.success,
              icon: Icons.verified_rounded,
            ),
            const SizedBox(height: 10),
            _buildAuditActivityCard(
              title: "Digital Certificate Master Authority",
              subtitle: "Cryptographic SHA-256 seal valid for 2025-26 convocations",
              status: "ACTIVE",
              statusColor: const Color(0xFF2563EB),
              icon: Icons.security_rounded,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── 1. Admin Executive Hero ─────────────────────────────────────────────────
  Widget _buildAdminHero(BuildContext context, CampusProvider provider) {
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
              color: const Color(0xFFFFBE0B).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFBE0B).withOpacity(0.3), width: 1.2),
            ),
            child: const Center(
              child: Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFD97706), size: 24),
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
                        provider.adminProfile.name,
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
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  provider.adminProfile.designation,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFD97706),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  "${provider.adminProfile.office} • Autonomous",
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
            tooltip: "Admin Dossier",
          ),
        ],
      ),
    );
  }

  // ── 2. Four University Vitals ───────────────────────────────────────────────
  Widget _buildUniversityVitalsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.1,
      children: [
        _buildVitalTile(
          label: "Students",
          value: "4,250",
          subtitle: "Across 6 Branches",
          icon: Icons.people_alt_rounded,
          color: const Color(0xFF2563EB),
        ),
        _buildVitalTile(
          label: "Faculty",
          value: "186",
          subtitle: "1:15 Cadre Ratio",
          icon: Icons.school_rounded,
          color: const Color(0xFF059669),
        ),
        _buildVitalTile(
          label: "Fee Realized",
          value: "94.2%",
          subtitle: "Sem 6 Term",
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFFD97706),
        ),
        _buildVitalTile(
          label: "Accreditation",
          value: "NAAC A++",
          subtitle: "NIRF Top 50 Band",
          icon: Icons.verified_rounded,
          color: const Color(0xFF7C3AED),
        ),
      ],
    );
  }

  Widget _buildVitalTile({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
              ),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ── 3. Core Governance Modules ──────────────────────────────────────────────
  Widget _buildGovernanceModulesGrid(BuildContext context) {
    final modules = [
      _AdminModule("Dropout Radar", "At-risk analytics", Icons.analytics_rounded, const Color(0xFF2563EB), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EarlyDropoutScreen()));
      }),
      _AdminModule("Certificates", "DigiLocker issuance", Icons.verified_user_rounded, const Color(0xFFD97706), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DigitalCertificatesScreen()));
      }),
      _AdminModule("Helpdesk", "Campus grievances", Icons.support_agent_rounded, const Color(0xFFE11D48), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpdeskScreen()));
      }),
      _AdminModule("Audit Register", "Daily attendance", Icons.how_to_reg_rounded, const Color(0xFF059669), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
      }),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.1,
      ),
      itemCount: modules.length,
      itemBuilder: (_, index) {
        final m = modules[index];
        return InkWell(
          onTap: m.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    color: m.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(m.icon, color: m.color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        m.title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        m.subtitle,
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── 4. Audit Activity Card ──────────────────────────────────────────────────
  Widget _buildAuditActivityCard({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: statusColor),
            ),
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

class _AdminModule {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _AdminModule(this.title, this.subtitle, this.icon, this.color, this.onTap);
}
