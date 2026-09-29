import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/bonafide_model.dart';
import '../services/bonafide_pdf_service.dart';

class TeacherBonafideScreen extends StatefulWidget {
  const TeacherBonafideScreen({super.key});

  @override
  State<TeacherBonafideScreen> createState() => _TeacherBonafideScreenState();
}

class _TeacherBonafideScreenState extends State<TeacherBonafideScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Teacher Certificate State
  Map<String, dynamic>? _teacherData;
  bool _isLoadingTeacher = true;
  String _selectedPurpose = 'Proof of Active Employment & Service Verification';
  Uint8List? _teacherPdfBytes;
  TeacherBonafideModel? _currentTeacherModel;
  bool _isRegeneratingTeacher = false;

  final List<String> _facultyPurposes = [
    'Proof of Active Employment & Service Verification',
    'Bank Loan (Home Loan / Personal Loan / Auto Loan)',
    'Passport & Visa Application (Employment Verification)',
    'Income Tax Return & Form 16 Verification',
    'Higher Studies / Ph.D. NOC & Admission',
    'Academic Research Grant / Project Submission (AICTE/DST)',
    'Credit Card & Salary Account Opening',
    'Faculty Exchange & Conference Participation',
    'Official Address & Service Reference',
  ];

  // Student Directory Search State
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTeacherAndGenerate();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTeacherAndGenerate() async {
    setState(() => _isLoadingTeacher = true);
    final user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic> data = {
      'name': user?.displayName ?? 'Faculty Member',
      'email': user?.email ?? '',
      'employeeId': 'IES/FAC/1042',
      'designation': 'Assistant Professor',
      'departments': ['Computer Science & Engineering'],
      'department': 'Computer Science & Engineering',
      'dateOfJoining': '01 August, 2021',
      'employmentType': 'Regular & Full-Time Faculty',
    };

    if (user?.uid != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        if (doc.exists && doc.data() != null) {
          data = Map<String, dynamic>.from(doc.data()!);
        }
      } catch (e) {
        debugPrint('Offline/fallback teacher fetch: $e');
      }
    }

    _teacherData = data;
    await _generateAutomaticTeacherCertificate();

    if (mounted) {
      setState(() => _isLoadingTeacher = false);
    }
  }

  Future<void> _generateAutomaticTeacherCertificate() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'teacher_uid';
    final name = _teacherData?['name']?.toString().trim();
    final teacherName = (name != null && name.isNotEmpty) ? name : 'FACULTY MEMBER';

    final empId = _teacherData?['employeeId']?.toString().trim();
    final employeeId = (empId != null && empId.isNotEmpty) ? empId : 'IES/FAC/1042';

    final desig = _teacherData?['designation']?.toString().trim();
    final designation = (desig != null && desig.isNotEmpty) ? desig : 'Assistant Professor';

    String deptString = 'Computer Science & Engineering';
    final rawDepts = _teacherData?['departments'];
    if (rawDepts is List && rawDepts.isNotEmpty) {
      deptString = rawDepts.join(', ');
    } else if (_teacherData?['department'] != null) {
      deptString = _teacherData!['department'].toString();
    }

    final doj = _teacherData?['dateOfJoining']?.toString().trim();
    final dateOfJoining = (doj != null && doj.isNotEmpty)
        ? doj
        : (_teacherData?['createdAt'] != null
            ? DateFormat('dd MMMM, yyyy').format(
                (_teacherData!['createdAt'] is Timestamp)
                    ? (_teacherData!['createdAt'] as Timestamp).toDate()
                    : DateTime.now().subtract(const Duration(days: 365 * 3)))
            : '01 August, 2021');

    final empType = _teacherData?['employmentType']?.toString().trim();
    final employmentType = (empType != null && empType.isNotEmpty)
        ? empType
        : 'Regular & Full-Time Faculty';

    final profileImg = _teacherData?['profileImageUrl']?.toString() ??
        _teacherData?['photoUrl']?.toString() ??
        _teacherData?['image']?.toString() ??
        '';

    final now = DateTime.now();
    final yearSuffix = now.year.toString();
    final timeSuffix = now.millisecondsSinceEpoch.toString().substring(7);
    final ref = 'IES/ESTB/FAC-SER/$yearSuffix/$timeSuffix';

    final model = TeacherBonafideModel(
      id: '',
      teacherUid: uid,
      teacherName: teacherName,
      employeeId: employeeId,
      designation: designation,
      departments: deptString,
      college: 'IES College of Technology, Bhopal',
      academicSession: '2025-2026',
      purpose: _selectedPurpose,
      refNo: ref,
      issuedAt: now,
      dateOfJoining: dateOfJoining,
      employmentType: employmentType,
      profileImageUrl: profileImg,
      phone: _teacherData?['phone']?.toString() ?? '',
    );

    try {
      final pdf = await BonafidePdfService.generateTeacherBonafideCertificate(model);
      _teacherPdfBytes = pdf;
      _currentTeacherModel = model;

      // Save audit record to Firestore
      try {
        await FirebaseFirestore.instance.collection('faculty_bonafides').add(model.toMap());
      } catch (_) {}
    } catch (e) {
      debugPrint('Error generating automatic faculty bonafide: $e');
    }
  }

  Future<void> _changeTeacherPurpose(String newPurpose) async {
    setState(() {
      _selectedPurpose = newPurpose;
      _isRegeneratingTeacher = true;
    });

    await _generateAutomaticTeacherCertificate();

    if (mounted) {
      setState(() => _isRegeneratingTeacher = false);
    }
  }

  void _openEditParticularsDialog() {
    final empIdController = TextEditingController(text: _teacherData?['employeeId'] ?? 'IES/FAC/1042');
    final desigController = TextEditingController(text: _teacherData?['designation'] ?? 'Assistant Professor');
    final dojController = TextEditingController(text: _teacherData?['dateOfJoining'] ?? '01 August, 2021');
    final deptController = TextEditingController(text: _teacherData?['department'] ?? 'Computer Science & Engineering');
    final empTypeController = TextEditingController(text: _teacherData?['employmentType'] ?? 'Regular & Full-Time Faculty');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.primary.withOpacity(0.3))),
        title: const Row(
          children: [
            Icon(Icons.badge_rounded, color: AppColors.secondary, size: 22),
            SizedBox(width: 8),
            Text('Edit Service Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('Employee ID', empIdController, Icons.numbers_rounded),
              const SizedBox(height: 12),
              _buildDialogField('Designation', desigController, Icons.work_rounded),
              const SizedBox(height: 12),
              _buildDialogField('Department', deptController, Icons.apartment_rounded),
              const SizedBox(height: 12),
              _buildDialogField('Date of Joining', dojController, Icons.calendar_month_rounded),
              const SizedBox(height: 12),
              _buildDialogField('Employment Status', empTypeController, Icons.verified_user_rounded),
            ],
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() {
                _teacherData?['employeeId'] = empIdController.text.trim();
                _teacherData?['designation'] = desigController.text.trim();
                _teacherData?['department'] = deptController.text.trim();
                _teacherData?['departments'] = [deptController.text.trim()];
                _teacherData?['dateOfJoining'] = dojController.text.trim();
                _teacherData?['employmentType'] = empTypeController.text.trim();
                _isRegeneratingTeacher = true;
              });
              await _generateAutomaticTeacherCertificate();
              if (mounted) {
                setState(() => _isRegeneratingTeacher = false);
              }
            },
            child: const Text('Update & Regenerate', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.secondary, size: 18),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Bonafide & Service Portal',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        backgroundColor: AppColors.surface,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.badge_rounded, size: 20), text: 'My Service Certificate'),
            Tab(icon: Icon(Icons.fact_check_rounded, size: 20), text: 'Student Verification'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Faculty Service Bonafide (Automatic)
          _buildMyFacultyBonafideTab(),

          // TAB 2: Student Bonafides Verification Directory
          _buildStudentVerificationTab(),
        ],
      ),
    );
  }

  // ==================== TAB 1: FACULTY BONAFIDE ====================
  Widget _buildMyFacultyBonafideTab() {
    if (_isLoadingTeacher) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.secondary),
            SizedBox(height: 16),
            Text(
              'Generating faculty service certificate...',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      );
    }

    String deptDisplay = 'Department of Engineering';
    final rawDepts = _teacherData?['departments'];
    if (rawDepts is List && rawDepts.isNotEmpty) {
      deptDisplay = rawDepts.join(', ');
    } else if (_teacherData?['department'] != null) {
      deptDisplay = _teacherData!['department'].toString();
    }

    return Column(
      children: [
        // Verified Faculty Badge Bar
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
                    width: 40,
                    height: 40,
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
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _teacherData?['name'] ?? 'Faculty Member',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: _openEditParticularsDialog,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_rounded, color: AppColors.secondary, size: 11),
                                    SizedBox(width: 2),
                                    Text(
                                      'Edit',
                                      style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Emp ID: ${_teacherData?['employeeId'] ?? "IES/FAC/1042"}  •  ${_teacherData?['designation'] ?? "Assistant Professor"}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$deptDisplay  •  Joined: ${_teacherData?['dateOfJoining'] ?? "01 Aug 2021"}',
                          style: const TextStyle(color: AppColors.secondary, fontSize: 10.5, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
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
                          'REGULAR',
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
                  const Icon(Icons.description_rounded, color: AppColors.secondary, size: 18),
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
                          value: _facultyPurposes.contains(_selectedPurpose) ? _selectedPurpose : _facultyPurposes.first,
                          dropdownColor: const Color(0xFF1E293B),
                          isDense: true,
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          items: _facultyPurposes.map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) {
                            if (val != null) _changeTeacherPurpose(val);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // PDF Preview
        Expanded(
          child: _isRegeneratingTeacher || _teacherPdfBytes == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
              : PdfPreview(
                  build: (format) => _teacherPdfBytes!,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  allowPrinting: true,
                  allowSharing: true,
                  initialPageFormat: PdfPageFormat.a4,
                  pdfFileName: 'IES_Faculty_Service_Certificate_${_currentTeacherModel?.employeeId.replaceAll('/', '_') ?? "Doc"}.pdf',
                  previewPageMargin: const EdgeInsets.all(12),
                  loadingWidget: const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
                ),
        ),

        // Verified Official Guarantee Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            border: Border(top: BorderSide(color: const Color(0xFF10B981).withOpacity(0.2))),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Officially Authenticated Service Certificate • Valid Proof of Employment for Bank Loans, Passport/Visa & Govt. Submissions',
                  style: TextStyle(color: Color(0xFF10B981), fontSize: 10.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== TAB 2: STUDENT VERIFICATION ====================
  Widget _buildStudentVerificationTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search student name, enrollment, branch...',
                hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('bonafides').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
              }

              final docs = snapshot.data?.docs ?? [];
              var bonafides = docs.map((d) => BonafideModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
              bonafides.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));

              if (_searchQuery.isNotEmpty) {
                bonafides = bonafides.where((b) {
                  return b.studentName.toLowerCase().contains(_searchQuery) ||
                      b.enrollmentNo.toLowerCase().contains(_searchQuery) ||
                      b.branch.toLowerCase().contains(_searchQuery) ||
                      b.refNo.toLowerCase().contains(_searchQuery) ||
                      b.purpose.toLowerCase().contains(_searchQuery);
                }).toList();
              }

              if (bonafides.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.verified_user_outlined, size: 54, color: AppColors.textHint),
                        SizedBox(height: 14),
                        Text(
                          'No Bonafide Records Found',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Generated student bonafide records will automatically appear here for verification.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: bonafides.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = bonafides[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.school_rounded, color: AppColors.secondary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.studentName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${item.enrollmentNo}  •  ${item.branch}',
                                style: const TextStyle(color: AppColors.secondary, fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${item.year} (${item.semester})  •  Purpose: ${item.purpose}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ref: ${item.refNo}',
                                style: const TextStyle(color: AppColors.textHint, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye_rounded, color: AppColors.secondary),
                          tooltip: 'View & Print Certificate',
                          onPressed: () async {
                            final bytes = await BonafidePdfService.generateBonafideCertificate(item);
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  backgroundColor: AppColors.background,
                                  appBar: AppBar(
                                    title: Text(
                                      '${item.studentName} - Bonafide',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                    ),
                                    backgroundColor: AppColors.surface,
                                    leading: IconButton(
                                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                  body: PdfPreview(
                                    build: (format) => bytes,
                                    canChangePageFormat: false,
                                    canChangeOrientation: false,
                                    pdfFileName: 'IES_Bonafide_${item.enrollmentNo}.pdf',
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
