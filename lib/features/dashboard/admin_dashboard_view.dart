import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/custom_chip.dart';
import '../../models/campus_models.dart';
import '../../providers/campus_provider.dart';
import '../ai_analytics/early_dropout_screen.dart';
import '../helpdesk/helpdesk_screen.dart';
import '../certificates/digital_certificates_screen.dart';
import '../attendance/attendance_screen.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Admin Profile Hero Card ─────────────────────────────────────
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
                    child: Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 28),
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
                              "Dr. R.K. Saxena",
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
                              color: const Color(0xFFFFBE0B),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "SaaS SUPER ADMIN",
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "Multi-Tenant Higher Education Cloud Architecture",
                        style: TextStyle(fontSize: 11.5, color: Color(0xFFCBD5E1)),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Campus Onboarding • Faculty Roster • AICTE Statutory Compliance",
                        style: TextStyle(fontSize: 10.5, color: Color(0xFFE2E8F0)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── ⚡ Go Backend Engine & Automation Status Banner ────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: provider.isGoBackendOnline ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: provider.isGoBackendOnline ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: provider.isGoBackendOnline ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.isGoBackendOnline ? "Go Backend Engine: CONNECTED & AUTOMATING" : "Go Backend Engine: STANDBY (Local Mode)",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: provider.isGoBackendOnline ? const Color(0xFF166534) : const Color(0xFF92400E),
                        ),
                      ),
                      Text(
                        provider.isGoBackendOnline
                            ? "Port 8080 • Single-File Go Server • Automated Defaulter Audits Active"
                            : "Run 'go run backend/main.go' to connect live Go multi-node goroutines",
                        style: TextStyle(
                          fontSize: 10.5,
                          color: provider.isGoBackendOnline ? const Color(0xFF15803D) : const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    await provider.syncWithGoBackend();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.isGoBackendOnline
                              ? "✅ Synced with Go Engine on http://localhost:8080!"
                              : "ℹ️ Go Engine not running on :8080. Using local cache."),
                          duration: const Duration(seconds: 2),
                          backgroundColor: provider.isGoBackendOnline ? const Color(0xFF16A34A) : const Color(0xFF334155),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: provider.isGoBackendOnline ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sync_rounded,
                          size: 13,
                          color: provider.isGoBackendOnline ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Sync",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: provider.isGoBackendOnline ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Segmented Navigation (SaaS Platform vs College Internal) ──────
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              tabs: const [
                Tab(icon: Icon(Icons.hub_rounded, size: 16), text: "SaaS Multi-College Desk"),
                Tab(icon: Icon(Icons.school_rounded, size: 16), text: "College Internal Portal"),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Tab Content
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              if (_tabController.index == 0) {
                return _buildSaasPlatformDesk(context, provider);
              } else {
                return _buildCollegeInternalPortal(context, provider);
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // VIEW 1: SaaS Multi-College Governance (Approve, Add, Password Generate)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSaasPlatformDesk(BuildContext context, CampusProvider provider) {
    final colleges = provider.colleges;
    final activeCount = colleges.where((c) => c.status == "Active").length;
    final pendingCount = colleges.where((c) => c.status.contains("Pending")).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SaaS Metrics Row
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: "Connected Colleges",
                value: "${colleges.length}",
                subtitle: "$activeCount Active • $pendingCount Pending",
                icon: Icons.account_balance_rounded,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: "Platform Students",
                value: "98,780",
                subtitle: "Across All Campuses",
                icon: Icons.groups_rounded,
                iconColor: AppColors.success,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Action Header + Onboard College Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PARTNER COLLEGES DIRECTORY",
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.5),
                ),
                Text(
                  "Approve institutions & generate credentials",
                  style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddCollegeModal(context, provider),
              icon: const Icon(Icons.add_business_rounded, size: 15),
              label: const Text("Onboard College", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Colleges List Cards
        ...colleges.map((college) => _buildCollegeTenantCard(context, provider, college)),
      ],
    );
  }

  Widget _buildCollegeTenantCard(BuildContext context, CampusProvider provider, CollegeTenant college) {
    final isPending = college.status.contains("Pending");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? AppColors.warning : AppColors.borderLight,
          width: isPending ? 1.5 : 1.0,
        ),
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
          // Header: Name & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPending ? AppColors.warningLight : AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_balance_rounded,
                        color: isPending ? AppColors.warning : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            college.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${college.city}, ${college.state} • Code: ${college.code}",
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPending ? AppColors.warningLight : AppColors.successLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  college.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: isPending ? AppColors.warning : AppColors.success,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Details box: Affiliation & Admin Info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Dean / Registrar: ${college.adminName}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    Text(college.licensePlan, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "Enrolled: ${college.studentCount} Students • ${college.facultyCount} Faculty Staff",
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons: Approve / View Credentials
          Row(
            children: [
              if (isPending) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      provider.approveCollegeTenant(college.id);
                      _showCredentialsDialog(context, college);
                    },
                    icon: const Icon(Icons.check_circle_rounded, size: 15),
                    label: const Text("Approve & Provision College", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCredentialsDialog(context, college),
                    icon: const Icon(Icons.vpn_key_rounded, size: 14, color: AppColors.primary),
                    label: const Text("Admin Credentials", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Switched workspace to ${college.name}"), backgroundColor: AppColors.primary),
                      );
                    },
                    icon: const Icon(Icons.launch_rounded, size: 14),
                    label: const Text("Open Console", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // VIEW 2: College Internal Portal (Teachers Portal & Student Portal)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCollegeInternalPortal(BuildContext context, CampusProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. Teachers & Faculty Management Section ─────────────────────────
        _buildSectionHeader("COLLEGE TEACHERS PORTAL", "Faculty Allocations & Logs"),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology_rounded, color: Color(0xFF7C3AED), size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Department Faculty Registry",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text("210 Faculty Staff", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Manage professor assignments, lecture hall allocations, and track biometric class attendance marking logs in real-time.",
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
                      },
                      icon: const Icon(Icons.fact_check_rounded, size: 14),
                      label: const Text("View Class Register", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Faculty appointment & class assignment modal initialized!"), backgroundColor: Color(0xFF7C3AED)),
                        );
                      },
                      icon: const Icon(Icons.person_add_rounded, size: 14, color: Color(0xFF7C3AED)),
                      label: const Text("Assign Teacher", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7C3AED)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── 2. Student & Admission Desk Section ──────────────────────────────
        _buildSectionHeader("STUDENTS & ADMISSION DESK", "Enrollment & Hall Tickets"),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Admit Cards & Detention Audit",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text("RGPV Criteria", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Audit student eligibility across all 6 semesters. 92 students flagged below 75% attendance criteria require waiver approvals.",
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Admit cards batch generated for 4,188 eligible students!"), backgroundColor: AppColors.success),
                        );
                      },
                      icon: const Icon(Icons.print_rounded, size: 14),
                      label: const Text("Batch Hall Tickets", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DigitalCertificatesScreen()));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderLight),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Certificates Desk", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── 3. Multi-Channel Circular Push ───────────────────────────────────
        _buildSectionHeader("CIRCULAR DISPATCH", "Instant Mobile & Web Push"),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.campaign_rounded, color: AppColors.accent, size: 20),
                  SizedBox(width: 8),
                  Text("Official Institutional Circular", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Broadcast official semester schedules, holiday notifications, and exam fee notices across Student Apps and Parent WhatsApp simultaneously.",
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Circular dispatch modal launched!"), backgroundColor: AppColors.primary),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 14, color: AppColors.primary),
                  label: const Text("Draft & Broadcast Circular", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // MODAL: Onboard New College (Name Chadaye, Password & UserID Generate)
  // ──────────────────────────────────────────────────────────────────────────
  void _showAddCollegeModal(BuildContext context, CampusProvider provider) {
    final nameCtrl = TextEditingController();
    final cityCtrl = TextEditingController(text: "Bhopal");
    final codeCtrl = TextEditingController(text: "IES-0105");
    final adminCtrl = TextEditingController(text: "Dr. Alok Verma");
    final emailCtrl = TextEditingController(text: "registrar@newcollege.ac.in");
    String generatedPassword = "Campus@${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}#";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Onboard New College / University",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Text(
                    "Provision tenant database, assign institutional code & generate credentials",
                    style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),

                  // College Name Input
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: "College / University Name",
                      hintText: "e.g. Sagar Institute of Science & Technology",
                      filled: true,
                      fillColor: AppColors.surfaceSubtle,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // City & Code
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityCtrl,
                          decoration: InputDecoration(
                            labelText: "City & State",
                            filled: true,
                            fillColor: AppColors.surfaceSubtle,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: codeCtrl,
                          decoration: InputDecoration(
                            labelText: "Campus Code",
                            filled: true,
                            fillColor: AppColors.surfaceSubtle,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Admin Name & Official Email
                  TextField(
                    controller: adminCtrl,
                    decoration: InputDecoration(
                      labelText: "Dean / Registrar Incharge",
                      filled: true,
                      fillColor: AppColors.surfaceSubtle,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: "Official Admin User ID / Email",
                      filled: true,
                      fillColor: AppColors.surfaceSubtle,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Auto-Generated Password Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Auto-Generated Secure Password:", style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(generatedPassword, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20),
                          onPressed: () {
                            setModalState(() {
                              generatedPassword = "Campus@${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}#";
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) return;
                        final newCollege = CollegeTenant(
                          id: "COL-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                          name: nameCtrl.text.trim(),
                          code: codeCtrl.text.trim(),
                          city: cityCtrl.text.trim(),
                          state: "Madhya Pradesh",
                          affiliation: "AICTE Approved • Autonomous RGPV",
                          status: "Active",
                          adminEmail: emailCtrl.text.trim(),
                          adminPassword: generatedPassword,
                          adminName: adminCtrl.text.trim(),
                          studentCount: 3200,
                          facultyCount: 160,
                          licensePlan: "Enterprise Cloud Tier-1",
                          registeredDate: DateTime.now(),
                        );
                        provider.addCollegeTenant(newCollege);
                        Navigator.pop(ctx);
                        _showCredentialsDialog(context, newCollege);
                      },
                      icon: const Icon(Icons.cloud_done_rounded, size: 18),
                      label: const Text("Save & Provision College", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DIALOG: View & Copy Generated College Credentials
  // ──────────────────────────────────────────────────────────────────────────
  void _showCredentialsDialog(BuildContext context, CollegeTenant college) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
              child: const Icon(Icons.vpn_key_rounded, color: AppColors.success, size: 20),
            ),
            const SizedBox(width: 10),
            const Text("College Admin Access", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tenant: ${college.name}", style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text("Institutional Code: ${college.code}", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 14),

            _credentialRow("Admin User ID / Email", college.adminEmail),
            const SizedBox(height: 8),
            _credentialRow("Temporary Password", college.adminPassword),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(8)),
              child: const Text(
                "These credentials grant full administrative control over this college's internal teacher assignments and student rosters.",
                style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, height: 1.3),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: "User: ${college.adminEmail}\nPassword: ${college.adminPassword}"));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Credentials copied to clipboard!"), backgroundColor: AppColors.success),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 14),
            label: const Text("Copy Credentials", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _credentialRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
              Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            ],
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
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.textMuted),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
      ],
    );
  }
}
