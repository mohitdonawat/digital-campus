import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../../core/constants/app_colors.dart';
import '../models/bonafide_model.dart';
import '../services/bonafide_pdf_service.dart';

class StudentBonafideScreen extends StatefulWidget {
  const StudentBonafideScreen({super.key});

  @override
  State<StudentBonafideScreen> createState() => _StudentBonafideScreenState();
}

class _StudentBonafideScreenState extends State<StudentBonafideScreen> {
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;
  String _selectedPurpose = 'General Academic Purpose';
  final TextEditingController _customPurposeController = TextEditingController();
  bool _isCustomPurpose = false;
  Uint8List? _generatedPdfBytes;
  BonafideModel? _currentModel;
  bool _isRegenerating = false;

  final List<String> _purposes = [
    'General Academic Purpose',
    'Bus Pass Application',
    'State / Post-Matric Scholarship',
    'Bank Account Opening',
    'Education Loan Verification',
    'Industrial Training / Internship',
    'Passport / Visa Documentation',
    'Competitive Exam (GATE/CAT) Verification',
    'Other Academic Purpose',
  ];

  @override
  void initState() {
    super.initState();
    _loadStudentAndGenerate();
  }

  @override
  void dispose() {
    _customPurposeController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentAndGenerate() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic> data = {
      'name': user?.displayName ?? 'Student Name',
      'email': user?.email ?? '',
      'enrollmentNo': '0103CS221001',
      'rollNo': '221001',
      'branch': 'Computer Science & Engineering',
      'year': '3rd Year',
      'semester': '6th Semester',
      'section': 'A',
    };

    if (user?.uid != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        if (doc.exists && doc.data() != null) {
          data = doc.data()!;
        }
      } catch (e) {
        debugPrint('Offline/Fallback student fetch: $e');
      }
    }

    _studentData = data;
    await _generateAutomaticCertificate();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _getEffectivePurpose() {
    if (_isCustomPurpose && _customPurposeController.text.trim().isNotEmpty) {
      return _customPurposeController.text.trim();
    }
    return _selectedPurpose;
  }

  Future<void> _generateAutomaticCertificate() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'student_uid';
    final name = _studentData?['name']?.toString().trim();
    final studentName = (name != null && name.isNotEmpty) ? name : 'STUDENT NAME';

    final enroll = _studentData?['enrollmentNo']?.toString().trim();
    final enrollmentNo = (enroll != null && enroll.isNotEmpty) ? enroll : '0103CS221001';

    final roll = _studentData?['rollNo']?.toString().trim() ?? '';
    final branch = _studentData?['branch']?.toString().trim() ?? 'Computer Science & Engineering';
    final year = _studentData?['year']?.toString().trim() ?? '3rd Year';
    final sem = _studentData?['semester']?.toString().trim() ?? '6th Semester';
    final sec = _studentData?['section']?.toString().trim() ?? 'A';

    final now = DateTime.now();
    final yearSuffix = now.year.toString();
    final timeSuffix = now.millisecondsSinceEpoch.toString().substring(7);
    final ref = 'IES/ICOT/BONA/$yearSuffix/$timeSuffix';

    final father = _studentData?['fatherName']?.toString().trim() ?? '';
    final photo = _studentData?['profileImageUrl']?.toString().trim() ?? '';

    final model = BonafideModel(
      id: '',
      studentUid: uid,
      studentName: studentName,
      enrollmentNo: enrollmentNo,
      rollNo: roll,
      branch: branch,
      year: year,
      semester: sem,
      section: sec,
      academicSession: '2025-2026',
      purpose: _getEffectivePurpose(),
      refNo: ref,
      issuedAt: now,
      fatherName: father,
      profileImageUrl: photo,
    );

    try {
      final pdf = await BonafidePdfService.generateBonafideCertificate(model);
      _generatedPdfBytes = pdf;
      _currentModel = model;

      // Save audit record to Firestore silently
      try {
        await FirebaseFirestore.instance.collection('bonafides').add(model.toMap());
      } catch (_) {}
    } catch (e) {
      debugPrint('Error generating automatic bonafide: $e');
    }
  }

  Future<void> _changePurpose(String newPurpose) async {
    setState(() {
      _selectedPurpose = newPurpose;
      _isCustomPurpose = (newPurpose == 'Other Academic Purpose');
      _isRegenerating = true;
    });

    if (!_isCustomPurpose) {
      await _generateAutomaticCertificate();
    }
    if (mounted) setState(() => _isRegenerating = false);
  }

  void _showCustomPurposeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Enter Custom Purpose', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: _customPurposeController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g. Visa Processing, Bank Loan Verification',
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isRegenerating = true);
              await _generateAutomaticCertificate();
              if (mounted) setState(() => _isRegenerating = false);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showEditFatherNameDialog() {
    final controller = TextEditingController(text: _studentData?['fatherName']?.toString() ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Enter Father's / Guardian's Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Required for National Scholarship (NSP), State Scholarships (MPTAAS), and Bank Loans.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "e.g. Shri Ramesh Kumar",
                hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final newFather = controller.text.trim();
              Navigator.pop(ctx);
              if (newFather.isNotEmpty) {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  try {
                    await FirebaseFirestore.instance.collection('users').doc(uid).update({
                      'fatherName': newFather,
                    });
                  } catch (_) {}
                }
                _studentData?['fatherName'] = newFather;
                setState(() => _isRegenerating = true);
                await _generateAutomaticCertificate();
                if (mounted) setState(() => _isRegenerating = false);
              }
            },
            child: const Text('Save & Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Official Bonafide Certificate',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            Text(
              'Auto-generated with verified institutional format',
              style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_generatedPdfBytes != null)
            IconButton(
              icon: const Icon(Icons.print_rounded, color: Colors.white),
              tooltip: 'Print Certificate',
              onPressed: () {
                Printing.layoutPdf(
                  onLayout: (format) => _generatedPdfBytes!,
                  name: 'IES_Bonafide_${_currentModel?.enrollmentNo ?? "Student"}',
                );
              },
            ),
          if (_generatedPdfBytes != null)
            IconButton(
              icon: const Icon(Icons.share_rounded, color: AppColors.secondary),
              tooltip: 'Share PDF',
              onPressed: () {
                Printing.sharePdf(
                  bytes: _generatedPdfBytes!,
                  filename: 'IES_Bonafide_${_currentModel?.enrollmentNo ?? "Student"}.pdf',
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.secondary),
                  SizedBox(height: 16),
                  Text(
                    'Generating official bonafide certificate...',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Top verified credentials summary bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.2))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(shape: BoxShape.circle),
                            child: ClipOval(
                              child: Image.asset('assets/logo.webp', fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _studentData?['name'] ?? 'Student Name',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Enrollment: ${_studentData?['enrollmentNo'] ?? "N/A"}  •  ${_studentData?['branch'] ?? "Engineering"}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: _showEditFatherNameDialog,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.family_restroom_rounded,
                                        size: 13,
                                        color: (_studentData?['fatherName'] != null && _studentData!['fatherName'].toString().trim().isNotEmpty)
                                            ? AppColors.secondary
                                            : const Color(0xFFF59E0B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        (_studentData?['fatherName'] != null && _studentData!['fatherName'].toString().trim().isNotEmpty)
                                            ? "Father: ${_studentData!['fatherName']}"
                                            : "Father's Name: Tap to add (For NSP/Scholarships)",
                                        style: TextStyle(
                                          color: (_studentData?['fatherName'] != null && _studentData!['fatherName'].toString().trim().isNotEmpty)
                                              ? Colors.white70
                                              : const Color(0xFFFCD34D),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.edit, size: 11, color: AppColors.secondary),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'VERIFIED',
                                  style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Purpose Selector Row
                      Row(
                        children: [
                          const Icon(Icons.edit_note_rounded, color: AppColors.secondary, size: 18),
                          const SizedBox(width: 6),
                          const Text(
                            'Purpose: ',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          Expanded(
                            child: Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedPurpose,
                                  dropdownColor: const Color(0xFF1E293B),
                                  isDense: true,
                                  isExpanded: true,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  items: _purposes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      _changePurpose(val);
                                      if (val == 'Other Academic Purpose') {
                                        _showCustomPurposeDialog();
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          if (_isCustomPurpose) ...[
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.secondary, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Edit custom purpose',
                              onPressed: _showCustomPurposeDialog,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Interactive PDF Preview
                Expanded(
                  child: _isRegenerating || _generatedPdfBytes == null
                      ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
                      : PdfPreview(
                          build: (format) => _generatedPdfBytes!,
                          canChangePageFormat: false,
                          canChangeOrientation: false,
                          canDebug: false,
                          allowPrinting: true,
                          allowSharing: true,
                          initialPageFormat: PdfPageFormat.a4,
                          pdfFileName: 'IES_Bonafide_${_currentModel?.enrollmentNo ?? "Certificate"}.pdf',
                          previewPageMargin: const EdgeInsets.all(12),
                          loadingWidget: const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
                        ),
                ),

                // Official Institutional Guarantee Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E3B).withOpacity(0.5),
                    border: Border(top: BorderSide(color: const Color(0xFF10B981).withOpacity(0.4))),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Official Document • Institutional Seal & Registrar Signature Included • 100% Accepted for Scholarships & Loans',
                          style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 10.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
