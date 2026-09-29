import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_chip.dart';
import '../../core/services/document_download_service.dart';
import '../../models/campus_models.dart';
import '../../providers/campus_provider.dart';
import '../lifecycle/edit_profile_screen.dart';

class ProfessionalAccountScreen extends StatefulWidget {
  const ProfessionalAccountScreen({super.key});

  @override
  State<ProfessionalAccountScreen> createState() => _ProfessionalAccountScreenState();
}

class _ProfessionalAccountScreenState extends State<ProfessionalAccountScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _skillInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final student = provider.student;
    final role = provider.currentRole;
    final aiInsight = provider.aiCareerInsight;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Professional Account",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Text(
                    "AI Verified",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              "Institutional Identity • Career Dossier • Govt ABC/APAAR Registry",
              style: TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              DocumentDownloadService.downloadProfessionalCvPdf(context, student);
            },
            icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
            tooltip: "Download Verified CV / Dossier PDF",
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.textDark),
            tooltip: "Edit Basic Information",
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 1. Role-Adaptive Master Profile Header
                    _buildHeroIdentityCard(context, provider, role),
                    const SizedBox(height: 14),

                    // 2. AI Placement & Career Radar
                    if (role == UserRole.student)
                      _buildAiCareerCopilotCard(context, provider, aiInsight, student),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMuted,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  tabs: [
                    const Tab(text: "Portfolio"),
                    Tab(text: role == UserRole.student ? "Govt Locker" : "Credentials"),
                    Tab(text: role == UserRole.student ? "Skills & Certs" : "Academic Load"),
                    const Tab(text: "Security"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPortfolioTab(context, provider, student, role),
            _buildGovtLockerTab(context, provider, student, role),
            _buildSkillsTab(context, provider, student, role),
            _buildSecurityTab(context, provider, student),
          ],
        ),
      ),
    );
  }

  // ── 1. Hero Identity Card ──────────────────────────────────────────────────
  Widget _buildHeroIdentityCard(BuildContext context, CampusProvider provider, UserRole role) {
    final student = provider.student;
    final faculty = provider.facultyProfile;
    final admin = provider.adminProfile;
    final parent = provider.parentProfile;

    String name = student.name;
    String designation = "${student.branch} • Sem ${student.semester}";
    String secondaryId = "Roll: ${student.rollNumber} • Enrollment: ${student.enrollmentNumber}";
    IconData roleIcon = Icons.school_rounded;
    Color roleColor = AppColors.primary;

    if (role == UserRole.faculty) {
      name = faculty.name;
      designation = faculty.designation;
      secondaryId = "${faculty.department} • Cabin ${faculty.cabinNumber}";
      roleIcon = Icons.cast_for_education_rounded;
      roleColor = const Color(0xFF7C3AED);
    } else if (role == UserRole.admin) {
      name = admin.name;
      designation = admin.designation;
      secondaryId = admin.office;
      roleIcon = Icons.admin_panel_settings_rounded;
      roleColor = const Color(0xFFD97706);
    } else if (role == UserRole.parent) {
      name = parent.guardianName;
      designation = "${parent.relation} • Ward: ${parent.wardName}";
      secondaryId = "Ward Roll: ${parent.wardRoll} (${parent.wardBranch})";
      roleIcon = Icons.family_restroom_rounded;
      roleColor = const Color(0xFF059669);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with online status
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [roleColor.withOpacity(0.2), roleColor.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: roleColor.withOpacity(0.3), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: roleColor,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      designation,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      secondaryId,
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 10),

          // Role Switcher Preview Ribbon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(roleIcon, size: 16, color: roleColor),
                  const SizedBox(width: 6),
                  Text(
                    "Active Persona: ${role.displayName.split(' ').first}",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: roleColor,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showQuickRoleModal(context, provider),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Row(
                    children: [
                      Text("Switch Role", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                      SizedBox(width: 4),
                      Icon(Icons.swap_horiz_rounded, size: 14),
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

  // ── 2. AI Placement & Career Copilot Card ──────────────────────────────────
  Widget _buildAiCareerCopilotCard(
    BuildContext context,
    CampusProvider provider,
    AiCareerInsight insight,
    StudentProfile student,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.2),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "AI Placement & Career Copilot",
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withOpacity(0.4)),
                ),
                child: Text(
                  "${insight.placementProbability}% Hiring Index",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF34D399),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.strengthsSummary,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFFCBD5E1),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),

          // Action row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    provider.optimizeProfileWithAi();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("✨ AI optimized Headline, Bio & Placement Index successfully!"),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                  label: const Text("AI Optimize Profile", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  DocumentDownloadService.downloadProfessionalCvPdf(context, student);
                },
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text("CV PDF", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.12),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Portfolio & Links ──────────────────────────────────────────────
  Widget _buildPortfolioTab(BuildContext context, CampusProvider provider, StudentProfile student, UserRole role) {
    if (role == UserRole.faculty) {
      return _buildFacultyPortfolioView(context, provider.facultyProfile);
    } else if (role == UserRole.admin) {
      return _buildAdminPortfolioView(context, provider.adminProfile);
    } else if (role == UserRole.parent) {
      return _buildParentPortfolioView(context, provider.parentProfile);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Headline Card
        _buildInfoCard(
          title: "PROFESSIONAL HEADLINE",
          subtitle: "Visible to recruiters & institutional placement office",
          trailingAction: "Edit",
          onAction: () => _showEditHeadlineDialog(context, provider, student),
          child: Text(
            student.headline,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Bio Card
        _buildInfoCard(
          title: "EXECUTIVE BIO",
          subtitle: "AI synthesized summary of academic and engineering focus",
          trailingAction: "Edit",
          onAction: () => _showEditBioDialog(context, provider, student),
          child: Text(
            student.bio,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Links & Repository Handles
        _buildInfoCard(
          title: "DEVELOPER & SOCIAL PROFILES",
          subtitle: "Synchronized with Campus Placement Cell & ATS Portals",
          trailingAction: "Update Links",
          onAction: () => _showEditLinksDialog(context, provider, student),
          child: Column(
            children: [
              _buildLinkRow(Icons.code_rounded, "GitHub", student.githubUrl, "github.com"),
              const Divider(height: 14, color: AppColors.borderLight),
              _buildLinkRow(Icons.business_center_rounded, "LinkedIn", student.linkedinUrl, "linkedin.com"),
              const Divider(height: 14, color: AppColors.borderLight),
              _buildLinkRow(Icons.terminal_rounded, "LeetCode", student.leetcodeHandle, "leetcode.com"),
              const Divider(height: 14, color: AppColors.borderLight),
              _buildLinkRow(Icons.language_rounded, "Portfolio", student.portfolioUrl, "Web Portfolio"),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Quick Stats Row
        Row(
          children: [
            Expanded(
              child: _buildMetricTile("CGPA", "${student.currentCgpa} / 10", "Academic Honor", Icons.grade_rounded, AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile("Projects", "${student.projectsCount} Built", "Git Authenticated", Icons.folder_special_rounded, AppColors.success),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile("Hackathons", "${student.hackathonsWon} Won", "SIH 2025 Gold", Icons.emoji_events_rounded, const Color(0xFFD97706)),
            ),
          ],
        ),
      ],
    );
  }

  // ── Tab 2: Govt Locker & Credentials ──────────────────────────────────────
  Widget _buildGovtLockerTab(BuildContext context, CampusProvider provider, StudentProfile student, UserRole role) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // DigiLocker Status Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "DigiLocker KYC: Authenticated",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF15803D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Linked with Aadhaar (${student.digiLockerAadhaarMasked}) • Real-time Government Ledger Sync",
                      style: const TextStyle(fontSize: 11, color: Color(0xFF166534)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await provider.syncDigiLocker();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("DigiLocker Records re-synced successfully with DigiLocker API!"), backgroundColor: AppColors.success),
                  );
                },
                icon: const Icon(Icons.sync_rounded, color: Color(0xFF15803D)),
                tooltip: "Re-sync DigiLocker",
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // APAAR Card (Automated Permanent Academic Account Registry)
        _buildGovtIdCard(
          title: "APAAR ID (ONE NATION ONE STUDENT ID)",
          idNumber: student.apaarId,
          badge: "MHRD Govt of India",
          badgeColor: AppColors.primary,
          subtitle: "Unique 12-Digit Lifetime Academic Identity for NEP 2020 Credit Mobility",
          icon: Icons.fingerprint_rounded,
        ),
        const SizedBox(height: 14),

        // Academic Bank of Credits (ABC ID)
        _buildGovtIdCard(
          title: "ABC ID (ACADEMIC BANK OF CREDITS)",
          idNumber: student.abcId,
          badge: "UGC Accredited",
          badgeColor: const Color(0xFF7C3AED),
          subtitle: "Digital Ledger of Earned Academic Credits: 132 Credits Verified",
          icon: Icons.account_balance_rounded,
        ),
        const SizedBox(height: 14),

        // Official Academic Documents in Locker
        _buildInfoCard(
          title: "OFFICIAL VERIFIED REPOSITORY",
          subtitle: "Cryptographically Sealed Institutional Records",
          child: Column(
            children: [
              _buildDocItem("Secondary School Certificate (Class 10)", "CBSE Board • 94.6%", Icons.description_rounded),
              const Divider(height: 14, color: AppColors.borderLight),
              _buildDocItem("Senior Secondary Certificate (Class 12)", "CBSE Board • 91.2%", Icons.description_rounded),
              const Divider(height: 14, color: AppColors.borderLight),
              _buildDocItem("B.Tech Semester 1 to 5 Consolidated Marksheets", "RGPV University • CGPA 8.42", Icons.verified_rounded),
              const Divider(height: 14, color: AppColors.borderLight),
              _buildDocItem("Institutional Migration & Character Certificate", "Apex Institute of Tech • Issued", Icons.verified_user_rounded),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tab 3: Skills & Certifications ─────────────────────────────────────────
  Widget _buildSkillsTab(BuildContext context, CampusProvider provider, StudentProfile student, UserRole role) {
    final aiInsight = provider.aiCareerInsight;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Verified Skills Card
        _buildInfoCard(
          title: "VERIFIED TECHNICAL SKILLS (${student.skills.length})",
          subtitle: "Validated through Lab Practical Exams & Coding Contests",
          trailingAction: "+ Add Skill",
          onAction: () => _showAddSkillDialog(context, provider),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: student.skills.map((skill) {
              return Chip(
                label: Text(
                  skill,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                backgroundColor: AppColors.primary.withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                deleteIcon: const Icon(Icons.close_rounded, size: 14),
                onDeleted: () {
                  HapticFeedback.lightImpact();
                  provider.removeSkill(skill);
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // AI Recommended Skills
        _buildInfoCard(
          title: "AI SUGGESTED SKILLS FOR TOP 1% TECH PLACEMENTS",
          subtitle: "Based on Hiring Trends for ${student.branch.split(' ').first}",
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: aiInsight.recommendedSkills.map((rec) {
              final alreadyHas = student.skills.contains(rec);
              return ActionChip(
                avatar: Icon(
                  alreadyHas ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                  size: 15,
                  color: alreadyHas ? AppColors.success : const Color(0xFFD97706),
                ),
                label: Text(
                  rec,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: alreadyHas ? AppColors.success : const Color(0xFFD97706),
                  ),
                ),
                backgroundColor: alreadyHas ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                side: BorderSide(
                  color: alreadyHas ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                ),
                onPressed: alreadyHas
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        provider.addSkill(rec);
                      },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Official Certifications
        _buildInfoCard(
          title: "INDUSTRY CERTIFICATIONS",
          subtitle: "Attested by Campus Registrar & Accredited Exam Bodies",
          child: Column(
            children: student.certifications.map((c) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD97706), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        c,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                    ),
                    const CustomChip(label: "VERIFIED", color: AppColors.success),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Tab 4: Security & App Preferences ──────────────────────────────────────
  Widget _buildSecurityTab(BuildContext context, CampusProvider provider, StudentProfile student) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Biometrics Card
        _buildInfoCard(
          title: "AUTHENTICATION & BIOMETRIC GATE",
          subtitle: "Campus Hardware Security & Token Protection",
          child: Column(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text("Biometric Lock (FaceID / Fingerprint)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                subtitle: const Text("Require biometric authorization on launching app", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                value: student.biometricLoginEnabled,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  HapticFeedback.mediumImpact();
                  provider.toggleBiometrics();
                },
              ),
              const Divider(height: 14, color: AppColors.borderLight),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text("Two-Factor Authentication (2FA)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                subtitle: const Text("Requires 6-digit TOTP code for fee payments & bonafide downloads", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                value: student.twoFactorEnabled,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  HapticFeedback.mediumImpact();
                  provider.toggleTwoFactor();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Active Devices & Sessions
        _buildInfoCard(
          title: "ACTIVE SESSIONS & SIGNED-IN DEVICES",
          subtitle: "Current cryptographic login tokens registered on Firebase Auth",
          child: Column(
            children: [
              _buildSessionItem("OnePlus 11 5G (This Device)", "Bhopal, India • Active Now", Icons.smartphone_rounded, true),
              const Divider(height: 14, color: AppColors.borderLight),
              _buildSessionItem("Campus CS Lab Computer 04", "Academic Block A • 2 hours ago", Icons.computer_rounded, false),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Preferences & Quick Switches
        _buildInfoCard(
          title: "INSTITUTIONAL PREFERENCES",
          subtitle: "Personalize notifications and language interface",
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.translate_rounded, color: AppColors.primary),
                title: const Text("Campus Language Mode", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                subtitle: const Text("English (Default) • Bhashini Hindi & Marathi enabled", style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              const Divider(height: 10, color: AppColors.borderLight),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
                title: const Text("Automated SMS & WhatsApp Alerts", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                subtitle: const Text("Instant push alerts for attendance shortfall & fee due dates", style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Faculty Portfolio View ────────────────────────────────────────────────
  Widget _buildFacultyPortfolioView(BuildContext context, FacultyProfessionalProfile fac) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          title: "ACADEMIC QUALIFICATIONS & DOSSIER",
          subtitle: "Accredited University Credentials",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fac.qualifications, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text("Cabin: ${fac.cabinNumber} • Hours: ${fac.officeHours}", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildMetricTile("Papers", "${fac.papersPublished} Published", "IEEE / Scopus", Icons.article_rounded, AppColors.primary)),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricTile("Citations", "${fac.citationsCount} Citations", "h-index: 12", Icons.format_quote_rounded, const Color(0xFF7C3AED))),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricTile("Rating", "${fac.studentFeedbackRating} / 5.0", "Student Reviews", Icons.star_rounded, const Color(0xFFD97706))),
          ],
        ),
        const SizedBox(height: 14),
        _buildInfoCard(
          title: "CURRENT TEACHING ALLOCATION",
          subtitle: "Semester 6 Academic Load",
          child: Column(
            children: fac.subjectsTaught.map((s) => _buildDocItem(s, "Lead Course Professor", Icons.menu_book_rounded)).toList(),
          ),
        ),
      ],
    );
  }

  // ── Admin Portfolio View ──────────────────────────────────────────────────
  Widget _buildAdminPortfolioView(BuildContext context, AdminProfessionalProfile adm) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          title: "REGULATORY COMPLIANCE STATUS",
          subtitle: "Statutory Approvals & Accreditation Index",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(adm.complianceLevel, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text("NAAC: ${adm.naacGrade} • NIRF: ${adm.nirfBand}", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildMetricTile("Students", "${adm.totalStudentsUnderGovernance}", "Under Governance", Icons.people_alt_rounded, AppColors.primary)),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricTile("Audits", "${adm.pendingAuditActions} Pending", "Detention / Exam", Icons.verified_rounded, const Color(0xFFD97706))),
          ],
        ),
        const SizedBox(height: 14),
        _buildInfoCard(
          title: "DIGITAL SIGNATURE SEAL AUTHORITY",
          subtitle: "Cryptographic Certificate Signing Master Key",
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(10)),
            child: Text(adm.digitalSigningKeyHash, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.textDark)),
          ),
        ),
      ],
    );
  }

  // ── Parent Portfolio View ─────────────────────────────────────────────────
  Widget _buildParentPortfolioView(BuildContext context, ParentProfessionalProfile par) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          title: "WARD ENROLLMENT & GUARDIAN OVERVIEW",
          subtitle: "Legally Linked Student Account",
          child: Column(
            children: [
              _buildDocItem("Ward: ${par.wardName}", "${par.wardBranch} • Roll: ${par.wardRoll}", Icons.person_rounded),
              const Divider(height: 14, color: AppColors.borderLight),
              _buildDocItem("Guardian KYC Status", "Verified via Aadhaar OTP (${par.verifiedPhone})", Icons.verified_user_rounded),
              const Divider(height: 14, color: AppColors.borderLight),
              _buildDocItem("Fee Payment Preference", par.paymentPreference, Icons.account_balance_wallet_rounded),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────────
  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required Widget child,
    String? trailingAction,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.primary)),
              if (trailingAction != null && onAction != null)
                InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(trailingAction, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildGovtIdCard({
    required String title,
    required String idNumber,
    required String badge,
    required Color badgeColor,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(color: badgeColor.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
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
                  Icon(icon, size: 20, color: badgeColor),
                  const SizedBox(width: 8),
                  Text(title, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: badgeColor, letterSpacing: 0.4)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor.withOpacity(0.3)),
                ),
                child: Text(badge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: badgeColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                idNumber,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.textDark),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: idNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$title copied to clipboard!"), backgroundColor: AppColors.primary),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.textMuted),
                tooltip: "Copy ID",
              ),
            ],
          ),
          Text(subtitle, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildLinkRow(IconData icon, String label, String value, String domain) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              Text(value, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.textMuted),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textDark)),
          Text(sub, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted), maxLines: 1),
        ],
      ),
    );
  }

  Widget _buildDocItem(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              Text(subtitle, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionItem(String device, String details, IconData icon, bool isCurrent) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isCurrent ? AppColors.success : AppColors.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(device, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              Text(details, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            ],
          ),
        ),
        if (isCurrent)
          const CustomChip(label: "THIS DEVICE", color: AppColors.success)
        else
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Session revoked successfully!"), backgroundColor: AppColors.success),
              );
            },
            child: const Text("Revoke", style: TextStyle(fontSize: 11, color: AppColors.error)),
          ),
      ],
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────
  void _showEditHeadlineDialog(BuildContext context, CampusProvider provider, StudentProfile student) {
    final controller = TextEditingController(text: student.headline);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Professional Headline"),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(hintText: "Enter your professional headline"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              provider.updateProfessionalDetails(headline: controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showEditBioDialog(BuildContext context, CampusProvider provider, StudentProfile student) {
    final controller = TextEditingController(text: student.bio);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Executive Bio"),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: "Enter your executive bio"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              provider.updateProfessionalDetails(bio: controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showEditLinksDialog(BuildContext context, CampusProvider provider, StudentProfile student) {
    final gh = TextEditingController(text: student.githubUrl);
    final li = TextEditingController(text: student.linkedinUrl);
    final lc = TextEditingController(text: student.leetcodeHandle);
    final pf = TextEditingController(text: student.portfolioUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Update Developer Links"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: gh, decoration: const InputDecoration(labelText: "GitHub URL")),
              TextField(controller: li, decoration: const InputDecoration(labelText: "LinkedIn URL")),
              TextField(controller: lc, decoration: const InputDecoration(labelText: "LeetCode Handle")),
              TextField(controller: pf, decoration: const InputDecoration(labelText: "Portfolio Website")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              provider.updateProfessionalDetails(
                githubUrl: gh.text.trim(),
                linkedinUrl: li.text.trim(),
                leetcodeHandle: lc.text.trim(),
                portfolioUrl: pf.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text("Save Links"),
          ),
        ],
      ),
    );
  }

  void _showAddSkillDialog(BuildContext context, CampusProvider provider) {
    _skillInputController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Technical Competency"),
        content: TextField(
          controller: _skillInputController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "e.g. Kubernetes, React, AWS Lambda"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (_skillInputController.text.trim().isNotEmpty) {
                provider.addSkill(_skillInputController.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showQuickRoleModal(BuildContext context, CampusProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Switch Campus Persona", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              ...UserRole.values.map((r) => ListTile(
                    title: Text(r.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(r.personaName, style: const TextStyle(fontSize: 11)),
                    trailing: r == provider.currentRole ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                    onTap: () {
                      provider.switchRole(r);
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
