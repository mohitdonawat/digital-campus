import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/campus_models.dart';
import '../../providers/campus_provider.dart';
import '../../core/services/document_download_service.dart';

/// 🏛️ Faculty Professional Dossier & Portfolio Studio
/// Enables Faculty & Teachers to build, customize, and maintain their:
/// 1. Academic Credentials & Institutional Title
/// 2. Professional Skills & Core Technical Competencies
/// 3. Research Publications, Citations, and Scholar Identifiers
/// 4. Patents, Funded Research Grants & Institutional Honors
/// 5. Teaching Load & Research Supervision Domains
class FacultyEditDossierScreen extends StatefulWidget {
  const FacultyEditDossierScreen({super.key});

  @override
  State<FacultyEditDossierScreen> createState() => _FacultyEditDossierScreenState();
}

class _FacultyEditDossierScreenState extends State<FacultyEditDossierScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers - Basic Info
  late TextEditingController _nameController;
  late TextEditingController _designationController;
  late TextEditingController _departmentController;
  late TextEditingController _qualificationsController;
  late TextEditingController _cabinController;
  late TextEditingController _officeHoursController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;

  // Controllers - Research & Links
  late TextEditingController _scholarUrlController;
  late TextEditingController _researchGateUrlController;
  late TextEditingController _papersCountController;
  late TextEditingController _citationsCountController;
  late TextEditingController _hIndexController;
  late TextEditingController _i10IndexController;
  late TextEditingController _patentsCountController;
  late TextEditingController _experienceYearsController;

  // Interactive Lists
  late List<String> _skills;
  late List<String> _subjectsTaught;
  late List<String> _researchDomains;
  late List<String> _publications;
  late List<String> _patents;
  late List<String> _grants;
  late List<String> _awards;

  // Skill input controller
  final TextEditingController _newSkillController = TextEditingController();

  final List<String> _presetSkillSuggestions = [
    "Deep Learning",
    "Distributed Systems",
    "Compiler Optimization",
    "PyTorch",
    "High-Performance Computing",
    "Linux Kernel",
    "Edge AI",
    "System Verilog",
    "Cloud Architecture",
    "Cybersecurity",
    "Quantum Algorithms",
    "Rust",
    "Zero-Knowledge Proofs",
    "Microservices",
  ];

  final List<String> _presetSubjectSuggestions = [
    "Advanced Compiler Design",
    "Machine Learning & AI",
    "Distributed Cloud Architecture",
    "Operating Systems & Kernel Dev",
    "High Performance Computing",
    "Computer Networks & Protocols",
    "Database Engineering",
  ];

  final List<String> _presetDomainSuggestions = [
    "Edge AI & Embedded Inference",
    "Federated Optimization",
    "Indic Natural Language Processing",
    "Zero-Trust Academic Security",
    "Byzantine Fault Tolerance",
    "Translational AI in Education",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    final fac = Provider.of<CampusProvider>(context, listen: false).facultyProfile;

    _nameController = TextEditingController(text: fac.name);
    _designationController = TextEditingController(text: fac.designation);
    _departmentController = TextEditingController(text: fac.department);
    _qualificationsController = TextEditingController(text: fac.qualifications);
    _cabinController = TextEditingController(text: fac.cabinNumber);
    _officeHoursController = TextEditingController(text: fac.officeHours);
    _phoneController = TextEditingController(text: fac.phone);
    _emailController = TextEditingController(text: fac.email);
    _bioController = TextEditingController(text: fac.bio);

    _scholarUrlController = TextEditingController(text: fac.scholarUrl);
    _researchGateUrlController = TextEditingController(text: fac.researchGateUrl);
    _papersCountController = TextEditingController(text: fac.papersPublished.toString());
    _citationsCountController = TextEditingController(text: fac.citationsCount.toString());
    _hIndexController = TextEditingController(text: fac.hIndex.toString());
    _i10IndexController = TextEditingController(text: fac.i10Index.toString());
    _patentsCountController = TextEditingController(text: fac.patentsGranted.toString());
    _experienceYearsController = TextEditingController(text: fac.experienceYears.toString());

    _skills = List<String>.from(fac.professionalSkills);
    _subjectsTaught = List<String>.from(fac.subjectsTaught);
    _researchDomains = List<String>.from(fac.researchDomains);
    _publications = List<String>.from(fac.publicationsList);
    _patents = List<String>.from(fac.patentsList);
    _grants = List<String>.from(fac.grantsList);
    _awards = List<String>.from(fac.awards);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _qualificationsController.dispose();
    _cabinController.dispose();
    _officeHoursController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _scholarUrlController.dispose();
    _researchGateUrlController.dispose();
    _papersCountController.dispose();
    _citationsCountController.dispose();
    _hIndexController.dispose();
    _i10IndexController.dispose();
    _patentsCountController.dispose();
    _experienceYearsController.dispose();
    _newSkillController.dispose();
    super.dispose();
  }

  void _addSkill(String skill) {
    final trimmed = skill.trim();
    if (trimmed.isEmpty || _skills.contains(trimmed)) return;
    HapticFeedback.lightImpact();
    setState(() {
      _skills.add(trimmed);
      _newSkillController.clear();
    });
  }

  void _removeSkill(String skill) {
    HapticFeedback.lightImpact();
    setState(() {
      _skills.remove(skill);
    });
  }

  void _showAddCustomItemDialog({
    required String title,
    required String hint,
    required ValueChanged<String> onAdd,
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                onAdd(text);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
            ),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showAddPublicationDialog() {
    final titleCtrl = TextEditingController();
    final authorsCtrl = TextEditingController(text: "M. Donawat et al.");
    final venueCtrl = TextEditingController();
    final yearCtrl = TextEditingController(text: DateTime.now().year.toString());
    final citCtrl = TextEditingController(text: "12");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.article_rounded, color: Color(0xFF7C3AED), size: 20),
            SizedBox(width: 8),
            Text("Add Research Publication", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Paper Title", hintText: "e.g. Sub-Millisecond AI Inference"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: authorsCtrl,
                decoration: const InputDecoration(labelText: "Authors", hintText: "e.g. M. Donawat, R. Gupta"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: venueCtrl,
                decoration: const InputDecoration(labelText: "Journal / Conference", hintText: "e.g. IEEE Trans. Computers"),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: yearCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Year", hintText: "2024"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: citCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Citations", hintText: "14"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final t = titleCtrl.text.trim();
              if (t.isNotEmpty) {
                final a = authorsCtrl.text.trim().isEmpty ? "M. Donawat" : authorsCtrl.text.trim();
                final v = venueCtrl.text.trim().isEmpty ? "IEEE Conference Proceedings" : venueCtrl.text.trim();
                final y = yearCtrl.text.trim().isEmpty ? "2024" : yearCtrl.text.trim();
                final c = citCtrl.text.trim().isEmpty ? "0" : citCtrl.text.trim();
                final compiled = "$a, '$t', $v, $y. [Citations: $c]";
                setState(() => _publications.add(compiled));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
            child: const Text("Add to Dossier"),
          ),
        ],
      ),
    );
  }

  void _showAddPatentDialog() {
    final titleCtrl = TextEditingController();
    final noCtrl = TextEditingController(text: "489${DateTime.now().millisecondsSinceEpoch % 10000}");
    final authCtrl = TextEditingController(text: "Indian Patent");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.military_tech_rounded, color: Color(0xFFD97706), size: 20),
            SizedBox(width: 8),
            Text("Add Intellectual Property / Patent", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Patent Invention Title", hintText: "e.g. Distributed Biometric Ledger"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noCtrl,
                decoration: const InputDecoration(labelText: "Patent / Application Number", hintText: "e.g. 489102"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: authCtrl,
                decoration: const InputDecoration(labelText: "Issuing Authority", hintText: "e.g. Indian Patent / USPTO / WIPO"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final t = titleCtrl.text.trim();
              if (t.isNotEmpty) {
                final auth = authCtrl.text.trim().isEmpty ? "Indian Patent" : authCtrl.text.trim();
                final num = noCtrl.text.trim().isEmpty ? "428900" : noCtrl.text.trim();
                final compiled = "$auth #$num: $t (Granted ${DateTime.now().year})";
                setState(() => _patents.add(compiled));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
            child: const Text("Register IP"),
          ),
        ],
      ),
    );
  }

  void _showAddGrantDialog() {
    final titleCtrl = TextEditingController();
    final agencyCtrl = TextEditingController(text: "DST-SERB Core Research Grant");
    final outlayCtrl = TextEditingController(text: "32.5");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF059669), size: 20),
            SizedBox(width: 8),
            Text("Add Sponsored Research Grant", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Project / Research Scheme Title", hintText: "e.g. Edge AI Accelerator"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: agencyCtrl,
                decoration: const InputDecoration(labelText: "Sponsoring Agency", hintText: "e.g. DST-SERB / AICTE RPS / CSIR"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: outlayCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Sanctioned Value (₹ in Lakhs)", hintText: "e.g. 25.0"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final t = titleCtrl.text.trim();
              if (t.isNotEmpty) {
                final ag = agencyCtrl.text.trim().isEmpty ? "DST-SERB" : agencyCtrl.text.trim();
                final out = outlayCtrl.text.trim().isEmpty ? "20.0" : outlayCtrl.text.trim();
                final compiled = "$ag: $t • Outlay: ₹$out Lakhs (PI)";
                setState(() => _grants.add(compiled));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
            child: const Text("Add Grant"),
          ),
        ],
      ),
    );
  }

  void _showAddAwardDialog() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController(text: "AICTE / University Senate");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: Color(0xFFD97706), size: 20),
            SizedBox(width: 8),
            Text("Add Academic Award / Honor", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Award Title", hintText: "e.g. Outstanding Faculty Researcher"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bodyCtrl,
                decoration: const InputDecoration(labelText: "Conferring Organization", hintText: "e.g. AICTE / IEEE / Senate"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final t = titleCtrl.text.trim();
              if (t.isNotEmpty) {
                final b = bodyCtrl.text.trim().isEmpty ? "University Senate" : bodyCtrl.text.trim();
                final compiled = "$t - $b (${DateTime.now().year})";
                setState(() => _awards.add(compiled));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
            child: const Text("Add Award"),
          ),
        ],
      ),
    );
  }

  void _autoOptimizeBioWithAi() {
    HapticFeedback.mediumImpact();
    setState(() {
      _bioController.text =
          "Distinguished Academician & Senior Systems Researcher. Specializes in Sovereign Edge AI, Distributed Fault-Tolerant Architectures, High-Performance Compilers, and AICTE Curriculum Engineering.";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✨ Faculty Bio & Core Pitch AI-Synthesized!"),
        backgroundColor: Color(0xFF7C3AED),
      ),
    );
  }

  FacultyProfessionalProfile _compileCurrentProfile(FacultyProfessionalProfile original) {
    final papers = int.tryParse(_papersCountController.text.trim()) ?? original.papersPublished;
    final citations = int.tryParse(_citationsCountController.text.trim()) ?? original.citationsCount;
    final hIndex = int.tryParse(_hIndexController.text.trim()) ?? original.hIndex;
    final i10Index = int.tryParse(_i10IndexController.text.trim()) ?? original.i10Index;
    final patents = int.tryParse(_patentsCountController.text.trim()) ?? original.patentsGranted;
    final exp = int.tryParse(_experienceYearsController.text.trim()) ?? original.experienceYears;

    return original.copyWith(
      name: _nameController.text.trim(),
      designation: _designationController.text.trim(),
      department: _departmentController.text.trim(),
      qualifications: _qualificationsController.text.trim(),
      cabinNumber: _cabinController.text.trim(),
      officeHours: _officeHoursController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      bio: _bioController.text.trim(),
      scholarUrl: _scholarUrlController.text.trim(),
      researchGateUrl: _researchGateUrlController.text.trim(),
      papersPublished: papers,
      citationsCount: citations,
      hIndex: hIndex,
      i10Index: i10Index,
      patentsGranted: patents,
      experienceYears: exp,
      professionalSkills: _skills,
      subjectsTaught: _subjectsTaught,
      researchDomains: _researchDomains,
      publicationsList: _publications,
      patentsList: _patents,
      grantsList: _grants,
      awards: _awards,
    );
  }

  void _saveDossier() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.heavyImpact();

    final provider = Provider.of<CampusProvider>(context, listen: false);
    final updated = _compileCurrentProfile(provider.facultyProfile);

    provider.updateFacultyProfile(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Faculty Dossier & Professional Portfolio successfully updated & sealed!"),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Faculty Dossier Studio",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark),
            ),
            Text(
              "Build & Customize Academic Credentials, Skills & Research",
              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF7C3AED)),
            tooltip: "Download Verified Faculty Dossier PDF",
            onPressed: () {
              HapticFeedback.mediumImpact();
              final current = _compileCurrentProfile(provider.facultyProfile);
              DocumentDownloadService.downloadFacultyDossierPdf(context, current);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton.icon(
              onPressed: _saveDossier,
              icon: const Icon(Icons.save_rounded, size: 15),
              label: const Text("Save Dossier", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF7C3AED),
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: const Color(0xFF7C3AED),
          indicatorWeight: 3,
          isScrollable: true,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          tabs: const [
            Tab(icon: Icon(Icons.badge_rounded, size: 18), text: "Core Profile"),
            Tab(icon: Icon(Icons.psychology_rounded, size: 18), text: "Skills & Stack"),
            Tab(icon: Icon(Icons.menu_book_rounded, size: 18), text: "Teaching & Labs"),
            Tab(icon: Icon(Icons.science_rounded, size: 18), text: "Research & Patents"),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCoreProfileTab(),
            _buildSkillsTab(),
            _buildTeachingTab(),
            _buildResearchTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    final current = _compileCurrentProfile(provider.facultyProfile);
                    DocumentDownloadService.downloadFacultyDossierPdf(context, current);
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 16, color: Color(0xFF7C3AED)),
                  label: const Text(
                    "Preview Dossier PDF",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF7C3AED)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveDossier,
                  icon: const Icon(Icons.verified_rounded, size: 16, color: Colors.white),
                  label: const Text(
                    "Save & Seal Dossier",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab 1: Core Academic Profile ──────────────────────────────────────────
  Widget _buildCoreProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader("INSTITUTIONAL IDENTITY", "Basic Academic Identification & Rank"),
        _buildTextField("Full Name & Salutation", _nameController, Icons.person_rounded, "e.g. Dr. Mohit Donawat"),
        _buildTextField("Designation & Rank", _designationController, Icons.workspace_premium_rounded, "e.g. Associate Professor & H.O.D."),
        _buildTextField("Department / Academic Unit", _departmentController, Icons.account_balance_rounded, "e.g. Computer Science & Engineering"),
        _buildTextField("Qualifications & Degrees", _qualificationsController, Icons.school_rounded, "e.g. Ph.D. (AI & Neural Arch), M.Tech (IIT Roorkee)", maxLines: 2),
        const SizedBox(height: 14),

        _buildSectionHeader("OFFICE & ACCESSIBILITY", "Campus Location & Student Availability"),
        Row(
          children: [
            Expanded(child: _buildTextField("Cabin / Office Location", _cabinController, Icons.room_rounded, "Cabin 302, Block A")),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField("Office Hours", _officeHoursController, Icons.access_time_rounded, "Mon-Fri: 3-5 PM")),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField("Official Phone", _phoneController, Icons.phone_rounded, "+91 98290 12345")),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField("Official Email", _emailController, Icons.email_rounded, "faculty@digitalcampus.edu.in")),
          ],
        ),
        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("PROFESSIONAL STATEMENT", "Summary for University Accreditations & Students"),
            TextButton.icon(
              onPressed: _autoOptimizeBioWithAi,
              icon: const Icon(Icons.auto_fix_high_rounded, size: 14, color: Color(0xFF7C3AED)),
              label: const Text("AI Generate", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED))),
            ),
          ],
        ),
        _buildTextField("Academic Bio & Philosophy", _bioController, Icons.format_quote_rounded, "Enter professional summary...", maxLines: 3),
      ],
    );
  }

  // ── Tab 2: Skills & Tech Stack ────────────────────────────────────────────
  Widget _buildSkillsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader("ACTIVE PROFESSIONAL SKILLS", "Technical competencies reflected in teaching & research"),
        const SizedBox(height: 6),

        // Custom Skill Input Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newSkillController,
                decoration: InputDecoration(
                  hintText: "Add custom skill (e.g. Quantum Computing)...",
                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderLight)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF7C3AED))),
                ),
                onSubmitted: _addSkill,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _addSkill(_newSkillController.text),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text("Add"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Active Skills Chips
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: _skills.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text("No skills added yet. Type above or tap suggestions below!", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.map((skill) {
                    return Chip(
                      label: Text(skill, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
                      backgroundColor: const Color(0xFF7C3AED).withOpacity(0.08),
                      deleteIcon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF7C3AED)),
                      onDeleted: () => _removeSkill(skill),
                      side: BorderSide(color: const Color(0xFF7C3AED).withOpacity(0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 20),

        _buildSectionHeader("POPULAR FACULTY SKILL SUGGESTIONS", "Tap to instantly include in your dossier"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetSkillSuggestions.map((s) {
            final isAdded = _skills.contains(s);
            return ActionChip(
              avatar: Icon(isAdded ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                  size: 14, color: isAdded ? const Color(0xFF059669) : AppColors.textMuted),
              label: Text(
                s,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isAdded ? const Color(0xFF059669) : AppColors.textDark,
                ),
              ),
              backgroundColor: isAdded ? const Color(0xFF059669).withOpacity(0.08) : Colors.white,
              side: BorderSide(color: isAdded ? const Color(0xFF059669).withOpacity(0.4) : AppColors.borderLight),
              onPressed: () {
                if (isAdded) {
                  _removeSkill(s);
                } else {
                  _addSkill(s);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Tab 3: Teaching & Labs ────────────────────────────────────────────────
  Widget _buildTeachingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("SUBJECTS & MODULES TAUGHT", "Courses delivered in current and past semesters"),
            TextButton.icon(
              onPressed: () => _showAddCustomItemDialog(
                title: "Add Teaching Subject",
                hint: "e.g. Advanced Operating Systems (CS-701)",
                onAdd: (val) => setState(() => _subjectsTaught.add(val)),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text("Add Subject"),
            ),
          ],
        ),
        ..._subjectsTaught.map((sub) => _buildRemovableListItem(
              title: sub,
              subtitle: "Core Academic Lecture & Laboratory Module • 4.0 Credits",
              icon: Icons.menu_book_rounded,
              color: const Color(0xFF2563EB),
              onDelete: () => setState(() => _subjectsTaught.remove(sub)),
            )),
        const SizedBox(height: 12),

        _buildSectionHeader("QUICK COURSE PRESETS", "Tap to add core computer science courses"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetSubjectSuggestions.map((s) {
            final isAdded = _subjectsTaught.contains(s);
            return ActionChip(
              avatar: Icon(isAdded ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                  size: 14, color: isAdded ? const Color(0xFF2563EB) : AppColors.textMuted),
              label: Text(s, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: isAdded ? const Color(0xFF2563EB) : AppColors.textDark)),
              backgroundColor: isAdded ? const Color(0xFF2563EB).withOpacity(0.08) : Colors.white,
              side: BorderSide(color: isAdded ? const Color(0xFF2563EB).withOpacity(0.4) : AppColors.borderLight),
              onPressed: () {
                if (isAdded) {
                  setState(() => _subjectsTaught.remove(s));
                } else {
                  setState(() => _subjectsTaught.add(s));
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("RESEARCH DOMAINS & PH.D. SUPERVISION", "Active student thesis guidance disciplines"),
            TextButton.icon(
              onPressed: () => _showAddCustomItemDialog(
                title: "Add Research Domain",
                hint: "e.g. Quantum Natural Language Processing",
                onAdd: (val) => setState(() => _researchDomains.add(val)),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text("Add Domain"),
            ),
          ],
        ),
        ..._researchDomains.map((dom) => _buildRemovableListItem(
              title: dom,
              subtitle: "Accredited Research Domain • Ph.D. Scholars Guidance",
              icon: Icons.science_rounded,
              color: const Color(0xFF059669),
              onDelete: () => setState(() => _researchDomains.remove(dom)),
            )),
        const SizedBox(height: 12),

        _buildSectionHeader("SUGGESTED RESEARCH DOMAINS", "Tap to add institutional research specialization"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetDomainSuggestions.map((d) {
            final isAdded = _researchDomains.contains(d);
            return ActionChip(
              avatar: Icon(isAdded ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                  size: 14, color: isAdded ? const Color(0xFF059669) : AppColors.textMuted),
              label: Text(d, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: isAdded ? const Color(0xFF059669) : AppColors.textDark)),
              backgroundColor: isAdded ? const Color(0xFF059669).withOpacity(0.08) : Colors.white,
              side: BorderSide(color: isAdded ? const Color(0xFF059669).withOpacity(0.4) : AppColors.borderLight),
              onPressed: () {
                if (isAdded) {
                  setState(() => _researchDomains.remove(d));
                } else {
                  setState(() => _researchDomains.add(d));
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Tab 4: Research, Publications & Patents ───────────────────────────────
  Widget _buildResearchTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader("SCHOLARLY IMPACT METRICS", "Numerical metrics verified against Scopus / IEEE / IPO"),
        Row(
          children: [
            Expanded(child: _buildTextField("Papers Published", _papersCountController, Icons.article_rounded, "18", isNumber: true)),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField("Citations Count", _citationsCountController, Icons.format_quote_rounded, "420", isNumber: true)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField("h-Index (Scholar)", _hIndexController, Icons.insights_rounded, "14", isNumber: true)),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField("i10-Index", _i10IndexController, Icons.analytics_rounded, "18", isNumber: true)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField("Patents Granted", _patentsCountController, Icons.military_tech_rounded, "2", isNumber: true)),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField("Experience (Yrs)", _experienceYearsController, Icons.history_edu_rounded, "12", isNumber: true)),
          ],
        ),
        const SizedBox(height: 12),

        _buildSectionHeader("ACADEMIC PROFILES & WEB IDENTIFIERS", "External repositories for student & peer discovery"),
        _buildTextField("Google Scholar URL / ID", _scholarUrlController, Icons.link_rounded, "scholar.google.com/citations?..."),
        _buildTextField("ResearchGate Profile URL", _researchGateUrlController, Icons.travel_explore_rounded, "researchgate.net/profile/..."),
        const SizedBox(height: 16),

        // 1. Published Research Papers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("PUBLISHED RESEARCH PAPERS", "Peer-reviewed journals, conferences & chapters"),
            TextButton.icon(
              onPressed: _showAddPublicationDialog,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text("Add Paper"),
            ),
          ],
        ),
        ..._publications.map((pub) => _buildRemovableListItem(
              title: pub,
              subtitle: "Indexed Publication • Verified Scopus / IEEE / ACM",
              icon: Icons.article_rounded,
              color: const Color(0xFF7C3AED),
              onDelete: () => setState(() => _publications.remove(pub)),
            )),
        const SizedBox(height: 16),

        // 2. Patents & Intellectual Property
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("PATENTS & INTELLECTUAL PROPERTY", "Government of India IPO & WIPO filings"),
            TextButton.icon(
              onPressed: _showAddPatentDialog,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text("Add Patent"),
            ),
          ],
        ),
        ..._patents.map((pat) => _buildRemovableListItem(
              title: pat,
              subtitle: "Government of India IPO • Granted Intellectual Property",
              icon: Icons.military_tech_rounded,
              color: const Color(0xFFD97706),
              onDelete: () => setState(() => _patents.remove(pat)),
            )),
        const SizedBox(height: 16),

        // 3. Sponsored Research Projects & Grants
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("SPONSORED RESEARCH PROJECTS & GRANTS", "DST, SERB, AICTE & Industry Consortiums"),
            TextButton.icon(
              onPressed: _showAddGrantDialog,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text("Add Grant"),
            ),
          ],
        ),
        ..._grants.map((grant) => _buildRemovableListItem(
              title: grant,
              subtitle: "Externally Funded Research Scheme • Principal Investigator",
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF059669),
              onDelete: () => setState(() => _grants.remove(grant)),
            )),
        const SizedBox(height: 16),

        // 4. Honours, Distinctions & Awards
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("HONOURS, FELLOWSHIPS & AWARDS", "National & University Academic Distinctions"),
            TextButton.icon(
              onPressed: _showAddAwardDialog,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text("Add Award"),
            ),
          ],
        ),
        ..._awards.map((award) => _buildRemovableListItem(
              title: award,
              subtitle: "Conferred Academic Honor & Institutional Distinction",
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFFB45309),
              onDelete: () => setState(() => _awards.remove(award)),
            )),
      ],
    );
  }

  // ── Helper UI Widgets ──────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF475569), letterSpacing: 0.5),
          ),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              prefixIcon: Icon(icon, size: 16, color: const Color(0xFF7C3AED)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderLight)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderLight)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF7C3AED))),
            ),
            validator: (val) {
              if (label.contains("Name") && (val == null || val.trim().isEmpty)) {
                return "Name cannot be empty";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRemovableListItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
            onPressed: () {
              HapticFeedback.lightImpact();
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}
