import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/models/student_model.dart';
import '../../timetable/models/timetable_model.dart';
import '../../timetable/services/timetable_service.dart';
import '../../timetable/services/timetable_analysis_service.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  // Selections for the class
  String _selectedBranch = AppStrings.departments.first;
  String _selectedYear = AppStrings.years.first;
  String _selectedSemester = AppStrings.semesters.first;
  String _selectedSection = AppStrings.sections.first;
  String _selectedPeriod = AppStrings.periods.first;
  final _subjectController = TextEditingController();

  Map<String, dynamic>? _teacherData;
  bool _isClassSelected = false;
  bool _isLoadingStudents = false;
  bool _isSubmitting = false;

  // Timetable auto-detection
  List<TimetablePeriodSlot> _allTimetableSlots = [];
  List<TimetablePeriodSlot> _todaySlots = [];
  TimetablePeriodSlot? _detectedCurrentSlot;
  bool _isLoadingTimetable = false;

  // Student list & attendance state
  List<StudentModel> _students = [];
  List<StudentModel> _filteredStudents = [];
  final _searchController = TextEditingController();

  // uid -> 'P' or 'A'
  final Map<String, String> _attendanceMap = {};

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTeacherData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (mounted && doc.exists) {
          setState(() {
            _teacherData = doc.data();
            final depts = _teacherData?['departments'] as List<dynamic>?;
            if (depts != null && depts.isNotEmpty) {
              _selectedBranch = depts.first.toString();
            }
            final subs = _teacherData?['subjects'] as List<dynamic>?;
            if (subs != null && subs.isNotEmpty) {
              _subjectController.text = subs.first.toString();
            }
          });
        }
      } catch (_) {}
    }

    // Auto-detect current period and branch from timetable
    await _detectTimetableSlot(uid);
  }

  Future<void> _detectTimetableSlot(String uid) async {
    setState(() => _isLoadingTimetable = true);
    try {
      final slots = await TimetableService.getTeacherPeriodSlots(uid, _selectedBranch);
      final now = DateTime.now();
      final todayName = DateFormat('EEEE').format(now);

      final todayList = slots.where((s) => s.day.toLowerCase() == todayName.toLowerCase()).toList();
      final detected = TimetableAnalysisService.detectCurrentPeriod(slots);

      if (mounted) {
        setState(() {
          _allTimetableSlots = slots;
          _todaySlots = todayList;
          _detectedCurrentSlot = detected;

          if (detected != null) {
            _applyTimetableSlot(detected);
          }
          _isLoadingTimetable = false;
        });
      }
    } catch (e) {
      debugPrint('Timetable auto-detect notice: $e');
      if (mounted) setState(() => _isLoadingTimetable = false);
    }
  }

  void _applyTimetableSlot(TimetablePeriodSlot slot) {
    setState(() {
      _selectedBranch = slot.branch;
      _selectedYear = slot.year;
      _selectedSemester = slot.semester;
      _selectedSection = slot.section;
      _selectedPeriod = slot.periodName;
      _subjectController.text = slot.subject;
      _detectedCurrentSlot = slot;
    });
  }

  void _filterStudents() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = List.from(_students);
      } else {
        _filteredStudents = _students.where((s) {
          final nameMatch = s.name.toLowerCase().contains(query);
          final rollMatch = s.rollNo.toLowerCase().contains(query);
          final enrollMatch = s.enrollmentNo.toLowerCase().contains(query);
          return nameMatch || rollMatch || enrollMatch;
        }).toList();
      }
    });
  }

  Future<void> _loadStudents() async {
    if (_subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or select Subject Name!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingStudents = true;
      _attendanceMap.clear();
    });

    try {
      final list = await AttendanceService.getStudentsForClass(
        branch: _selectedBranch,
        year: _selectedYear,
        semester: _selectedSemester,
        section: _selectedSection,
      );

      // Default mark all as Present ('P')
      for (final s in list) {
        _attendanceMap[s.uid] = 'P';
      }

      setState(() {
        _students = list;
        _filteredStudents = List.from(list);
        _isClassSelected = true;
        _isLoadingStudents = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStudents = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load students: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _markAll(String status) {
    setState(() {
      for (final s in _students) {
        _attendanceMap[s.uid] = status;
      }
    });
  }

  Future<void> _submitAttendance() async {
    if (_students.isEmpty) return;

    final presentCount =
        _attendanceMap.values.where((v) => v == 'P').length;
    final absentCount =
        _attendanceMap.values.where((v) => v == 'A').length;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Confirm Attendance Submission',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Class: $_selectedBranch ($_selectedYear - $_selectedSemester)',
                style: const TextStyle(color: AppColors.textSecondary)),
            Text('Section: $_selectedSection • Period: $_selectedPeriod',
                style: const TextStyle(color: AppColors.textSecondary)),
            Text('Subject: ${_subjectController.text.trim()}',
                style: const TextStyle(color: AppColors.textSecondary)),
            const Divider(color: AppColors.surfaceVariant, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryPill('Total', '${_students.length}', Colors.white),
                _summaryPill('Present', '$presentCount', AppColors.success),
                _summaryPill('Absent', '$absentCount', AppColors.error),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textHint)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            child: const Text('Confirm & Save'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final teacherName = _teacherData?['name'] ?? 'Faculty';
      final teacherTitle = _teacherData?['title'] ?? 'Prof';

      // Create snapshot of student details
      final Map<String, Map<String, String>> studentDetails = {};
      for (final s in _students) {
        studentDetails[s.uid] = {
          'name': s.name,
          'rollNo': s.rollNo,
          'enrollmentNo': s.enrollmentNo,
        };
      }

      final record = AttendanceRecordModel(
        id: const Uuid().v4(),
        teacherUid: uid,
        teacherName: teacherName,
        teacherTitle: teacherTitle,
        branch: _selectedBranch,
        year: _selectedYear,
        semester: _selectedSemester,
        section: _selectedSection,
        subject: _subjectController.text.trim(),
        period: _selectedPeriod,
        date: DateTime.now(),
        totalStudents: _students.length,
        presentCount: presentCount,
        absentCount: absentCount,
        statusMap: Map<String, String>.from(_attendanceMap),
        studentDetails: Map<String, Map<String, String>>.from(studentDetails),
        createdAt: DateTime.now(),
      );

      await AttendanceService.submitAttendance(record);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Attendance saved! Report generated for Admin.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _summaryPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final presentCount =
        _attendanceMap.values.where((v) => v == 'P').length;
    final absentCount =
        _attendanceMap.values.where((v) => v == 'A').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📋 Mark Attendance'),
        backgroundColor: AppColors.surface,
        actions: [
          if (_isClassSelected)
            TextButton(
              onPressed: () => setState(() => _isClassSelected = false),
              child: const Text('Change Class',
                  style: TextStyle(color: AppColors.secondary, fontSize: 13)),
            ),
        ],
      ),
      body: !_isClassSelected ? _buildClassSelector() : _buildStudentAttendanceList(presentCount, absentCount),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 1: CLASS, PERIOD & SUBJECT SELECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildClassSelector() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.co_present_rounded,
                      color: AppColors.secondary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Class Attendance Session',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select the class, semester & period you are teaching',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ─── Timetable Auto-Detection Banner & Multi-Branch Chips ───
          if (_detectedCurrentSlot != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B).withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.alarm_on_rounded, color: Color(0xFF34D399), size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'AUTO-DETECTED FROM ACTIVE TIMETABLE',
                        style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('AUTO-FILLED', style: TextStyle(color: Color(0xFF34D399), fontSize: 9.5, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_detectedCurrentSlot!.periodName} • ${_detectedCurrentSlot!.subject}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_detectedCurrentSlot!.branch} (${_detectedCurrentSlot!.year} ${_detectedCurrentSlot!.semester}) • Sec ${_detectedCurrentSlot!.section}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingStudents ? null : _loadStudents,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.flash_on_rounded, size: 18),
                      label: const Text('1-Tap Load Students For This Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // If teacher has multiple slots/branches today, show quick switcher chips
          if (_todaySlots.length > 1) ...[
            const Text(
              'TODAY\'S SCHEDULED CLASSES (TAP TO SWITCH BATCH)',
              style: TextStyle(color: AppColors.textHint, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _todaySlots.map((slot) {
                  final isCurrentSelected = (_selectedBranch == slot.branch &&
                      _selectedYear == slot.year &&
                      _selectedSemester == slot.semester &&
                      _selectedPeriod == slot.periodName);
                  return GestureDetector(
                    onTap: () => _applyTimetableSlot(slot),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrentSelected ? AppColors.secondary : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrentSelected ? AppColors.secondary : AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.periodName.split('(').first.trim(),
                            style: TextStyle(
                              color: isCurrentSelected ? Colors.white : AppColors.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            slot.subject,
                            style: TextStyle(
                              color: isCurrentSelected ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${slot.branch.split(' ').first} ${slot.year}',
                            style: TextStyle(
                              color: isCurrentSelected ? Colors.white70 : AppColors.textHint,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Department / Branch
          _buildDropdown(
            label: 'Branch / Department',
            icon: Icons.category_rounded,
            value: _selectedBranch,
            items: AppStrings.departments,
            onChanged: (v) => setState(() => _selectedBranch = v!),
          ),

          const SizedBox(height: 16),

          // Year & Semester Row
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Year',
                  icon: Icons.calendar_today_rounded,
                  value: _selectedYear,
                  items: AppStrings.years,
                  onChanged: (v) => setState(() => _selectedYear = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Semester',
                  icon: Icons.school_rounded,
                  value: _selectedSemester,
                  items: AppStrings.semesters,
                  onChanged: (v) => setState(() => _selectedSemester = v!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Section & Period Row
          Row(
            children: [
              SizedBox(
                width: 110,
                child: _buildDropdown(
                  label: 'Section',
                  icon: Icons.group_rounded,
                  value: _selectedSection,
                  items: AppStrings.sections,
                  onChanged: (v) => setState(() => _selectedSection = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Period / Time',
                  icon: Icons.schedule_rounded,
                  value: _selectedPeriod,
                  items: AppStrings.periods,
                  onChanged: (v) => setState(() => _selectedPeriod = v!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Subject Name
          TextFormField(
            controller: _subjectController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Subject Name',
              hintText: 'e.g. Database Management Systems',
              prefixIcon: const Icon(Icons.menu_book_rounded,
                  color: AppColors.secondary, size: 20),
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoadingStudents ? null : _loadStudents,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoadingStudents
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Load Students List',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 2: STUDENT ATTENDANCE LIST (ALPHABETICAL + SEARCH)
  // ─────────────────────────────────────────────────────────────
  Widget _buildStudentAttendanceList(int presentCount, int absentCount) {
    return Column(
      children: [
        // Class Banner & Quick Controls
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: AppColors.surface,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_selectedBranch ($_selectedYear - $_selectedSemester)',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Sec $_selectedSection • ${_subjectController.text.trim()}',
                          style: const TextStyle(
                              color: AppColors.secondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedPeriod.split(' ').first,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Live Counter bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text('Present: $presentCount',
                            style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text('Absent: $absentCount',
                            style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Quick Mark All buttons
                  PopupMenuButton<String>(
                    onSelected: (val) => _markAll(val),
                    color: AppColors.surfaceVariant,
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                          value: 'P',
                          child: Text('Mark All Present (P)',
                              style: TextStyle(color: AppColors.success))),
                      const PopupMenuItem(
                          value: 'A',
                          child: Text('Mark All Absent (A)',
                              style: TextStyle(color: AppColors.error))),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.tune_rounded,
                              size: 14, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text('Bulk',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Search Bar (Name or Roll Number)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by student name or roll number...',
              hintStyle:
                  const TextStyle(color: AppColors.textHint, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.secondary, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear,
                          size: 18, color: AppColors.textHint),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Alphabetical List Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STUDENTS (${_filteredStudents.length} of ${_students.length}) • SORTED A-Z',
                style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5),
              ),
              const Text(
                'TAP TO TOGGLE',
                style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),

        // Students ListView
        Expanded(
          child: _students.isEmpty
              ? _buildNoStudentsFound()
              : _filteredStudents.isEmpty
                  ? const Center(
                      child: Text('No student matched your search query',
                          style: TextStyle(color: AppColors.textHint)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                      itemCount: _filteredStudents.length,
                      itemBuilder: (ctx, i) {
                        final student = _filteredStudents[i];
                        final status = _attendanceMap[student.uid] ?? 'P';
                        final isPresent = status == 'P';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            gradient: AppColors.cardGradient,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isPresent
                                  ? AppColors.success.withOpacity(0.3)
                                  : AppColors.error.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 2),
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: isPresent
                                  ? AppColors.success.withOpacity(0.2)
                                  : AppColors.error.withOpacity(0.2),
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: isPresent
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            title: Text(
                              student.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            subtitle: Text(
                              'Roll: ${student.rollNo} • Enroll: ${student.enrollmentNo}',
                              style: const TextStyle(
                                  color: AppColors.textHint, fontSize: 11),
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _attendanceMap[student.uid] =
                                      isPresent ? 'A' : 'P';
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isPresent
                                      ? AppColors.success
                                      : AppColors.error,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isPresent
                                              ? AppColors.success
                                              : AppColors.error)
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),

        // Bottom Fixed Submit Button
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded),
                          const SizedBox(width: 8),
                          Text(
                            'Submit Attendance ($presentCount P / $absentCount A)',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoStudentsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline_rounded,
              color: AppColors.textHint, size: 48),
          const SizedBox(height: 12),
          Text(
            'No approved students found for\n$_selectedBranch - $_selectedYear ($_selectedSemester) Sec $_selectedSection',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => setState(() => _isClassSelected = false),
            child: const Text('Select Another Class'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      dropdownColor: AppColors.surfaceVariant,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.secondary, size: 18),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ))
          .toList(),
    );
  }
}
