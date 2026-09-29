import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/models/student_model.dart';
import '../widgets/id_card_front.dart';
import '../widgets/id_card_back.dart';
import '../services/id_card_pdf_service.dart';
import 'edit_student_profile_screen.dart';

class StudentIdCardScreen extends StatefulWidget {
  const StudentIdCardScreen({super.key});

  @override
  State<StudentIdCardScreen> createState() => _StudentIdCardScreenState();
}

class _StudentIdCardScreenState extends State<StudentIdCardScreen> with SingleTickerProviderStateMixin {
  final GlobalKey _frontKey = GlobalKey();
  final GlobalKey _backKey = GlobalKey();

  bool _showFront = true;
  bool _isLoading = true;
  bool _isProcessing = false;
  StudentModel? _student;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _student = StudentModel.fromMap(data);
      } else {
        // Fallback default model for demo
        _student = StudentModel(
          uid: uid,
          name: FirebaseAuth.instance.currentUser?.displayName ?? 'Mohit Donawat',
          email: FirebaseAuth.instance.currentUser?.email ?? 'student@iesbhopal.ac.in',
          branch: 'Computer Science & Engineering',
          year: '3rd Year',
          semester: '5th Sem',
          section: 'A',
          rollNo: '221045',
          enrollmentNo: '0103CS221045',
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error fetching student data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Uint8List?> _captureWidget(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }

  Future<void> _downloadIdCardPng() async {
    setState(() => _isProcessing = true);
    try {
      final targetKey = _showFront ? _frontKey : _backKey;
      final bytes = await _captureWidget(targetKey);

      if (bytes == null) {
        throw Exception('Failed to generate card image. Please try again.');
      }

      final dir = await getApplicationDocumentsDirectory();
      final sideName = _showFront ? 'FRONT' : 'BACK';
      final fileName = 'IES_ID_${_student?.enrollmentNo ?? "CARD"}_$sideName.png';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text('ID Card ($sideName) saved to device!'),
            action: SnackBarAction(
              label: 'OPEN',
              textColor: Colors.white,
              onPressed: () => OpenFile.open(file.path),
            ),
          ),
        );
        // Automatically open file preview
        await OpenFile.open(file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.error, content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _printOrSavePdf() async {
    setState(() => _isProcessing = true);
    try {
      // 1. Capture Front Side
      final frontBytes = await _captureWidget(_frontKey);
      if (frontBytes == null) throw Exception('Could not render front side');

      // 2. Capture Back Side
      final backBytes = await _captureWidget(_backKey);

      // 3. Build Print Document
      final pdfBytes = await IdCardPdfService.generatePrintableIdCardPdf(
        frontImageBytes: frontBytes,
        backImageBytes: backBytes,
        studentName: _student?.name ?? 'Student',
        enrollmentNo: _student?.enrollmentNo ?? '0103CS221045',
      );

      // 4. Open Print Preview Dialog
      await Printing.layoutPdf(
        name: 'IES_ID_CARD_${_student?.enrollmentNo ?? "PRINT"}',
        onLayout: (format) async => pdfBytes,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.error, content: Text('PDF Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _navigateToEditProfile() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditStudentProfileScreen(
          initialData: _student?.toMap(),
        ),
      ),
    );

    if (updated == true) {
      _fetchStudentData();
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

    final student = _student ??
        StudentModel(
          uid: 'sample',
          name: 'Student Name',
          email: 'student@iesbhopal.ac.in',
          branch: 'Computer Science & Engineering',
          year: '3rd Year',
          semester: '5th Sem',
          section: 'A',
          rollNo: '221001',
          enrollmentNo: '0103CS221001',
          createdAt: DateTime.now(),
        );

    final bool hasPhoto = student.profileImageUrl != null && student.profileImageUrl!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        title: const Text('Official College ID Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _navigateToEditProfile,
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.secondary, size: 26),
            tooltip: 'Update Profile & Photo',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Warning Banner if passport photo is missing
            if (!hasPhoto)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFD97706).withOpacity(0.2), const Color(0xFF991B1B).withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD97706), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_a_photo_rounded, color: Color(0xFFFBBF24), size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Passport Photo Missing!',
                            style: TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'Please upload your passport photo to complete your official lanyard ID badge.',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _navigateToEditProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFBBF24),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Upload', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ),

            // Toggle Bar: FRONT SIDE vs BACK SIDE
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _toggleTabButton(
                      label: 'FRONT SIDE',
                      icon: Icons.badge_rounded,
                      isActive: _showFront,
                      onTap: () => setState(() => _showFront = true),
                    ),
                  ),
                  Expanded(
                    child: _toggleTabButton(
                      label: 'BACK SIDE',
                      icon: Icons.flip_to_back_rounded,
                      isActive: !_showFront,
                      onTap: () => setState(() => _showFront = false),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // LANYARD STRAP VISUALIZATION (Authentic Hanging Ribbon with Metal Hook Clip)
            _buildLanyardHanger(),

            // ID CARD DISPLAY AREA
            Center(
              child: GestureDetector(
                onTap: () => setState(() => _showFront = !_showFront),
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _showFront ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  firstChild: RepaintBoundary(
                    key: _frontKey,
                    child: IdCardFront(
                      student: student,
                      onPhotoTap: _navigateToEditProfile,
                    ),
                  ),
                  secondChild: RepaintBoundary(
                    key: _backKey,
                    child: IdCardBack(student: student),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Tap hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_rounded, size: 14, color: Colors.white.withOpacity(0.4)),
                const SizedBox(width: 4),
                Text(
                  'Tap on the card to flip between Front and Back view',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.45)),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ACTION BUTTONS (Download PNG, Print/Save PDF, Edit Profile)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _downloadIdCardPng,
                    icon: const Icon(Icons.download_rounded, color: Colors.black, size: 18),
                    label: Text(
                      _showFront ? 'Download Front (PNG)' : 'Download Back (PNG)',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _printOrSavePdf,
                    icon: const Icon(Icons.print_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'Print / PDF (Both)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Profile Edit Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _navigateToEditProfile,
                icon: const Icon(Icons.account_circle_rounded, color: AppColors.secondary, size: 18),
                label: const Text(
                  'Update Student Profile & Passport Photo',
                  style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _toggleTabButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.black : Colors.white60),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.black : Colors.white60,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lanyard ribbon and metal clip hanging from top
  Widget _buildLanyardHanger() {
    return Column(
      children: [
        // Blue lanyard ribbon strap
        Container(
          width: 32,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF1E3A8A)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'IES',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.85),
                letterSpacing: 1,
              ),
            ),
          ),
        ),

        // Metallic Swivel Hook Clip
        Container(
          width: 22,
          height: 14,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF94A3B8), Color(0xFFF1F5F9), Color(0xFF64748B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 3),
            ],
          ),
        ),
        // Clip hook loop entering the slot
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF475569),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
          ),
        ),
      ],
    );
  }
}
