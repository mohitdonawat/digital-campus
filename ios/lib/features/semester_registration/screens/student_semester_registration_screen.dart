import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/semester_registration_model.dart';
import '../services/semester_registration_service.dart';
import '../services/semester_registration_pdf_service.dart';

class StudentSemesterRegistrationScreen extends StatefulWidget {
  const StudentSemesterRegistrationScreen({super.key});

  @override
  State<StudentSemesterRegistrationScreen> createState() => _StudentSemesterRegistrationScreenState();
}

class _StudentSemesterRegistrationScreenState extends State<StudentSemesterRegistrationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _studentData;
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Form Controllers
  late TextEditingController _sgpaController;
  late TextEditingController _cgpaController;
  late TextEditingController _achievementsController;
  late TextEditingController _electivesController;
  late TextEditingController _backlogDetailsController;
  late TextEditingController _feeReceiptController;

  String _selectedApplyingSemester = '5th Semester';
  String _academicSession = '2024 - 2025';
  bool _hasBacklogs = false;
  String _feeStatus = 'PAID';
  bool _undertakingAccepted = true;

  final List<String> _semesters = [
    '1st Semester',
    '2nd Semester',
    '3rd Semester',
    '4th Semester',
    '5th Semester',
    '6th Semester',
    '7th Semester',
    '8th Semester',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _sgpaController = TextEditingController();
    _cgpaController = TextEditingController();
    _achievementsController = TextEditingController();
    _electivesController = TextEditingController();
    _backlogDetailsController = TextEditingController();
    _feeReceiptController = TextEditingController();

    _loadStudentData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sgpaController.dispose();
    _cgpaController.dispose();
    _achievementsController.dispose();
    _electivesController.dispose();
    _backlogDetailsController.dispose();
    _feeReceiptController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _studentData = doc.data();

        // Infer next applying semester from current semester
        final currentSem = _studentData?['semester']?.toString() ?? '';
        for (final s in _semesters) {
          if (s.toLowerCase().contains(currentSem.toLowerCase())) {
            _selectedApplyingSemester = s;
            break;
          }
        }
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  SemesterRegistrationModel _buildModelFromForm({String id = ''}) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'uid';
    final name = _studentData?['name'] ?? 'Student Name';
    final enroll = _studentData?['enrollmentNo'] ?? '0103CS221001';
    final roll = _studentData?['rollNo'] ?? '221001';
    final branch = _studentData?['branch'] ?? 'Computer Science & Engineering';
    final currentYear = _studentData?['year'] ?? '3rd Year';
    final currentSem = _studentData?['semester'] ?? '5th Sem';
    final section = _studentData?['section'] ?? 'A';
    final father = _studentData?['fatherName'] ?? '';
    final phone = _studentData?['phone'] ?? '';
    final email = _studentData?['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
    final address = _studentData?['address'] ?? 'Bhopal, M.P.';

    final now = DateTime.now();
    final ref = 'IES/REG/${now.year}/${enroll.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}';

    return SemesterRegistrationModel(
      id: id,
      refNo: ref,
      studentUid: uid,
      studentName: name,
      enrollmentNo: enroll,
      rollNo: roll,
      branch: branch,
      currentYear: currentYear,
      currentSemester: currentSem,
      applyingSemester: _selectedApplyingSemester,
      academicSession: _academicSession,
      section: section,
      fatherName: father,
      phone: phone,
      email: email,
      address: address,
      previousSemSgpa: _sgpaController.text.trim().isEmpty ? '0.0' : _sgpaController.text.trim(),
      overallCgpa: _cgpaController.text.trim().isEmpty ? '0.0' : _cgpaController.text.trim(),
      hasBacklogs: _hasBacklogs,
      backlogDetails: _hasBacklogs ? _backlogDetailsController.text.trim() : 'NIL (All Clear)',
      achievements: _achievementsController.text.trim(),
      electiveSubjects: _electivesController.text.trim(),
      feeReceiptNo: _feeReceiptController.text.trim(),
      feePaymentStatus: _feeStatus,
      studentUndertakingAccepted: _undertakingAccepted,
      status: 'PENDING_APPROVAL',
      submittedAt: now,
    );
  }

  Future<void> _previewAndPrintPdf() async {
    if (!_formKey.currentState!.validate()) return;
    final model = _buildModelFromForm();

    try {
      final pdfBytes = await SemesterRegistrationPdfService.generateOfficialRegistrationForm(model);
      await Printing.layoutPdf(
        name: 'IES_REGISTRATION_${model.enrollmentNo}_${model.applyingSemester}',
        onLayout: (format) async => pdfBytes,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.error, content: Text('Print Error: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_undertakingAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Please accept the student undertaking and declaration before submitting.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final model = _buildModelFromForm();
      await SemesterRegistrationService.submitRegistration(model);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('Semester Registration Form submitted for HOD approval! ✓'),
              ],
            ),
          ),
        );
        _tabController.animateTo(1); // Switch to History tab
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.error, content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Semester Registration Portal',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: AppColors.secondary,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Fill Registration Form', icon: Icon(Icons.edit_document, size: 18)),
            Tab(text: 'My Registered Forms', icon: Icon(Icons.history_edu_rounded, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFillFormTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildFillFormTab() {
    final name = _studentData?['name'] ?? 'Student Name';
    final enroll = _studentData?['enrollmentNo'] ?? '0103CS221001';
    final roll = _studentData?['rollNo'] ?? '221001';
    final branch = _studentData?['branch'] ?? 'Computer Science & Engineering';
    final currentYear = _studentData?['year'] ?? '3rd Year';
    final section = _studentData?['section'] ?? 'A';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auto-Populated Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary.withOpacity(0.4), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.how_to_reg_rounded, color: AppColors.secondary, size: 22),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Candidate Profile Particulars',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '✓ Auto-Populated',
                          style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Roll: $roll • Enroll: $enroll • $branch',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                  ),
                  Text(
                    'Current Status: $currentYear • Section $section • IES College of Technology',
                    style: TextStyle(color: AppColors.secondary.withOpacity(0.9), fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Target Semester & Academic Session Selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Semester Registration Details',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: _selectedApplyingSemester,
                          dropdownColor: AppColors.surfaceVariant,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Registering For Semester *',
                            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            prefixIcon: const Icon(Icons.school_rounded, color: AppColors.secondary, size: 20),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() => _selectedApplyingSemester = v!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: _academicSession,
                          onChanged: (v) => _academicSession = v,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Session',
                            labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Academic Progression: SGPA, CGPA & Backlogs
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '2. Academic Progression & Scores',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _sgpaController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter last SGPA' : null,
                          decoration: InputDecoration(
                            labelText: 'Previous Sem SGPA *',
                            hintText: 'e.g. 8.42',
                            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                            prefixIcon: const Icon(Icons.speed_rounded, color: AppColors.secondary, size: 20),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cgpaController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter overall CGPA' : null,
                          decoration: InputDecoration(
                            labelText: 'Cumulative CGPA *',
                            hintText: 'e.g. 8.15',
                            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                            prefixIcon: const Icon(Icons.grade_rounded, color: AppColors.secondary, size: 20),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Backlogs / ATKT Check
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Any Active Backlog / ATKT Papers?', style: TextStyle(color: Colors.white, fontSize: 13)),
                    subtitle: Text(
                      _hasBacklogs ? 'Yes, have pending papers to clear' : 'No, all papers cleared (All Clear)',
                      style: TextStyle(color: _hasBacklogs ? const Color(0xFFEF4444) : AppColors.success, fontSize: 11),
                    ),
                    value: _hasBacklogs,
                    activeColor: const Color(0xFFEF4444),
                    onChanged: (val) => setState(() => _hasBacklogs = val),
                  ),

                  if (_hasBacklogs) ...[
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _backlogDetailsController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Backlog Subject Codes / Names *',
                        hintText: 'e.g. CS-302 Discrete Math, CS-404 DBMS',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Achievements & Co-Curricular (High-Priority User Requirement)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.emoji_events_rounded, color: Color(0xFFFBBF24), size: 20),
                      SizedBox(width: 8),
                      Text(
                        '3. Academic & Technical Achievements',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Mention your certifications, hackathons, projects, paper presentations, or sports achievements achieved during previous semesters.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _achievementsController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Achievements / Certifications / Hackathons',
                      hintText: 'e.g. Smart India Hackathon (SIH 2024) Finalist, NPTEL Elite Python Certification, Google Cloud Arcade Winner...',
                      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Electives & Fee Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '4. Electives & Fee Clearance',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _electivesController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Electives / Specialization Papers Chosen',
                      hintText: 'e.g. Cloud Computing & DevOps, Deep Learning',
                      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                      prefixIcon: const Icon(Icons.menu_book_rounded, color: AppColors.secondary, size: 20),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _feeStatus,
                          dropdownColor: AppColors.surfaceVariant,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Fee Status',
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          items: ['PAID', 'PENDING', 'FEE CONCESSION']
                              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                              .toList(),
                          onChanged: (v) => setState(() => _feeStatus = v!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _feeReceiptController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Fee Receipt / Challan No',
                            hintText: 'e.g. IES/FEE/2024/091',
                            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 11),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Student Declaration & Undertaking
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _undertakingAccepted,
                    activeColor: AppColors.secondary,
                    onChanged: (v) => setState(() => _undertakingAccepted = v ?? true),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'I declare that all details furnished above are correct. I agree to abide by college regulations and attend at least 75% classes.',
                        style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _previewAndPrintPdf,
                    icon: const Icon(Icons.print_rounded, size: 18, color: Colors.white),
                    label: const Text(
                      'Preview & Print (PDF)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitForm,
                    icon: _isSubmitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.send_rounded, size: 18, color: Colors.black),
                    label: Text(
                      _isSubmitting ? 'Submitting...' : 'Submit to HOD',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<List<SemesterRegistrationModel>>(
      stream: SemesterRegistrationService.getStudentRegistrations(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
        }

        final registrations = snapshot.data ?? [];
        if (registrations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.description_outlined, color: AppColors.secondary, size: 36),
                  ),
                  const SizedBox(height: 16),
                  const Text('No Registrations Submitted Yet',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text(
                    'Fill out the registration form in the first tab to submit your semester enrollment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textHint, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: registrations.length,
          itemBuilder: (context, index) {
            final reg = registrations[index];
            final dateStr = DateFormat('dd MMM, yyyy').format(reg.submittedAt);
            final isApproved = reg.status == 'APPROVED';
            final isRejected = reg.status == 'REJECTED';

            Color statusColor = const Color(0xFFF59E0B);
            String statusText = 'PENDING APPROVAL';
            if (isApproved) {
              statusColor = AppColors.success;
              statusText = 'APPROVED & VERIFIED ✓';
            } else if (isRejected) {
              statusColor = const Color(0xFFEF4444);
              statusText = 'REJECTED';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        reg.applyingSemester.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor, width: 0.8),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ref: ${reg.refNo} • Session ${reg.academicSession} • $dateStr',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _metricBadge('Previous SGPA', '${reg.previousSemSgpa} / 10.0'),
                      const SizedBox(width: 8),
                      _metricBadge('Overall CGPA', '${reg.overallCgpa} / 10.0'),
                      const SizedBox(width: 8),
                      _metricBadge('Backlogs', reg.hasBacklogs ? 'YES' : 'NONE'),
                    ],
                  ),
                  if (reg.achievements.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Achievements: ${reg.achievements}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                    ),
                  ],
                  if (reg.hodRemarks != null && reg.hodRemarks!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'HOD Remarks: "${reg.hodRemarks}"',
                        style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final bytes = await SemesterRegistrationPdfService.generateOfficialRegistrationForm(reg);
                        await Printing.layoutPdf(
                          name: 'IES_REG_${reg.enrollmentNo}_${reg.applyingSemester}',
                          onLayout: (_) async => bytes,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                      label: const Text('Download Official PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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

  Widget _metricBadge(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.6))),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
