import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../models/timetable_model.dart';
import '../services/timetable_service.dart';
import '../services/timetable_analysis_service.dart';

class SendTimetableScreen extends StatefulWidget {
  final bool isAdmin;
  const SendTimetableScreen({super.key, this.isAdmin = false});

  @override
  State<SendTimetableScreen> createState() => _SendTimetableScreenState();
}

class _SendTimetableScreenState extends State<SendTimetableScreen> {
  final _titleController = TextEditingController();

  // Class Selection Filters
  String _selectedBranch = 'Computer Science & Engineering';
  String _selectedYear = '3rd Year';
  String _selectedSemester = '6th Sem';
  String _selectedSection = 'A';

  // Day Navigation
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  String _selectedDay = 'Monday';

  // Slots & State
  List<TimetablePeriodSlot> _slots = [];
  String? _existingId;
  bool _isLoadingClass = false;
  bool _isSaving = false;
  bool _isLoadedFromDb = false;

  // Optional Notice Board Image Attachment
  File? _selectedImage;

  // Schedule Mode: 0 = Master Weekly Schedule (Daily Default), 1 = Today's Quick Reschedule / Substitute
  int _scheduleMode = 0;

  Map<String, dynamic>? _senderData;

  final _branches = AppStrings.departments;
  final _years = AppStrings.years;
  final _semesters = AppStrings.semesters;
  final _sections = AppStrings.sections;

  @override
  void initState() {
    super.initState();
    _initDay();
    _loadSenderData();
  }

  void _initDay() {
    final today = DateFormat('EEEE').format(DateTime.now());
    if (_days.contains(today)) {
      _selectedDay = today;
    } else {
      _selectedDay = 'Monday';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadSenderData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (mounted && doc.exists) {
          setState(() {
            _senderData = doc.data();
            final depts = _senderData?['departments'] as List<dynamic>?;
            if (!widget.isAdmin && depts != null && depts.isNotEmpty) {
              final d = depts.first.toString();
              if (_branches.contains(d)) _selectedBranch = d;
            }
          });
        }
      } catch (e) {
        debugPrint('Sender fetch note: $e');
      }
    }
    _loadClassTimetable();
  }

  /// Automatically aligns Semester when Year changes
  void _syncSemesterWithYear(String year) {
    if (year.contains('1')) {
      _selectedSemester = '2nd Sem';
    } else if (year.contains('2')) {
      _selectedSemester = '4th Sem';
    } else if (year.contains('3')) {
      _selectedSemester = '6th Sem';
    } else {
      _selectedSemester = '8th Sem';
    }
  }

  /// Load existing timetable from Firestore/Cache for the selected class
  Future<void> _loadClassTimetable() async {
    setState(() => _isLoadingClass = true);

    try {
      final existing = await TimetableService.getTimetableForClass(
        branch: _selectedBranch,
        year: _selectedYear,
        semester: _selectedSemester,
        section: _selectedSection,
      );

      if (mounted) {
        if (existing != null && existing.slots.isNotEmpty) {
          setState(() {
            _existingId = existing.id;
            _slots = List.from(existing.slots);
            _titleController.text = existing.title;
            _isLoadedFromDb = true;
            _isLoadingClass = false;
          });
        } else {
          // If no existing timetable in DB, auto-fill default curriculum schedule
          _autoFillTemplate(notify: false);
          setState(() {
            _existingId = null;
            _isLoadedFromDb = false;
            _isLoadingClass = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _autoFillTemplate(notify: false);
        setState(() => _isLoadingClass = false);
      }
    }
  }

  /// Auto-fill standard curriculum schedule for this branch & year
  void _autoFillTemplate({bool notify = true}) {
    final teacher = '${_senderData?['title'] ?? 'Prof.'} ${_senderData?['name'] ?? 'Faculty'}';
    final analysis = TimetableAnalysisService.analyzeAndExtractSchedule(
      branch: _selectedBranch,
      year: _selectedYear,
      semester: _selectedSemester,
      section: _selectedSection,
      teacherName: teacher,
    );

    setState(() {
      _slots = List.from(analysis.slots);
      if (_titleController.text.trim().isEmpty) {
        _titleController.text = '$_selectedBranch $_selectedYear ($_selectedSemester) - Official Schedule';
      }
    });

    if (notify) {
      _showSnack('🪄 Standard curriculum schedule generated! You can now edit any period.', AppColors.info);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.textHint, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Attach Notice Board Timetable Photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Optional: Upload a camera photo of the printed department schedule',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _pickOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: AppColors.info,
                    onTap: () async {
                      final f = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                      Navigator.pop(context, f);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _pickOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: AppColors.success,
                    onTap: () async {
                      final f = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                      Navigator.pop(context, f);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedImage = File(result.path);
      });
      _showSnack('📷 Timetable image attached! Both photo & structured periods will be saved.', AppColors.success);
    }
  }

  Widget _pickOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  /// Open Dialog to Add or Edit a Period Slot
  void _openPeriodDialog({TimetablePeriodSlot? slot, int? slotIndex}) {
    final isEditing = slot != null;
    final periodNum = isEditing ? slot.periodNumber : (_slots.where((s) => s.day == _selectedDay).length + 1);

    int selectedPeriodNumber = (periodNum >= 1 && periodNum <= 8) ? periodNum : 1;
    String startTime = isEditing ? slot.startTime : '09:00';
    String endTime = isEditing ? slot.endTime : '10:00';

    final subjectController = TextEditingController(text: isEditing ? slot.subject : '');
    final roomController = TextEditingController(text: isEditing ? slot.room : 'Room 201');
    final facultyController = TextEditingController(
      text: isEditing
          ? slot.facultyName
          : '${_senderData?['title'] ?? 'Prof.'} ${_senderData?['name'] ?? 'Faculty'}',
    );

    final curriculumSubjects = TimetableAnalysisService.getSubjectsForBranch(_selectedBranch, _selectedYear);
    final allSuggestions = [
      ...curriculumSubjects,
      'Laboratory / Practical',
      'Library / Self Study',
      'Seminar / Project',
      'Sports / Remedial',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: AppColors.textHint, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isEditing ? Icons.edit_calendar_rounded : Icons.add_circle_outline_rounded,
                            color: AppColors.secondary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'Edit Period Slot' : 'Add Period Slot',
                                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$_selectedDay  •  $_selectedBranch ($_selectedYear)',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Period Number & Timing Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Period Number', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                              const SizedBox(height: 4),
                              Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: selectedPeriodNumber,
                                    dropdownColor: const Color(0xFF1E293B),
                                    isExpanded: true,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    items: [1, 2, 3, 4, 5, 6, 7, 8].map((n) {
                                      return DropdownMenuItem(value: n, child: Text('Period $n'));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setModalState(() => selectedPeriodNumber = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Time Slot', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTimePickerBox(
                                      label: startTime,
                                      onTap: () async {
                                        final t = await _showTimePicker(context, startTime);
                                        if (t != null) setModalState(() => startTime = t);
                                      },
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    child: Text('-', style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    child: _buildTimePickerBox(
                                      label: endTime,
                                      onTap: () async {
                                        final t = await _showTimePicker(context, endTime);
                                        if (t != null) setModalState(() => endTime = t);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Subject Input
                    const Text('Subject Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: subjectController,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'e.g. Database Management Systems',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12.5),
                        prefixIcon: const Icon(Icons.menu_book_rounded, color: AppColors.secondary, size: 18),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.secondary)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Quick Subject Chips
                    const Text('Quick Select Subject:', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: allSuggestions.map((sub) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              label: Text(sub, style: const TextStyle(fontSize: 10.5, color: Colors.white)),
                              backgroundColor: AppColors.surfaceVariant,
                              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              onPressed: () {
                                subjectController.text = sub;
                                setModalState(() {});
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Room and Faculty Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Classroom / Lab', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: roomController,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Room 201 / Lab 2',
                                  hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                                  prefixIcon: const Icon(Icons.meeting_room_rounded, color: AppColors.info, size: 18),
                                  filled: true,
                                  fillColor: AppColors.surfaceVariant,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.secondary)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Faculty Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: facultyController,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Faculty In-Charge',
                                  hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                                  prefixIcon: const Icon(Icons.person_rounded, color: AppColors.secondary, size: 18),
                                  filled: true,
                                  fillColor: AppColors.surfaceVariant,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.secondary)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Actions
                    Row(
                      children: [
                        if (isEditing)
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _deleteSlot(slot);
                              },
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                              label: const Text('Delete Slot', style: TextStyle(color: AppColors.error, fontSize: 13)),
                            ),
                          ),
                        if (isEditing) const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              final sub = subjectController.text.trim();
                              if (sub.isEmpty) {
                                _showSnack('Please enter a subject name', AppColors.error);
                                return;
                              }

                              final newSlot = TimetablePeriodSlot(
                                day: _selectedDay,
                                periodNumber: selectedPeriodNumber,
                                periodName: 'Period $selectedPeriodNumber ($startTime - $endTime)',
                                startTime: startTime,
                                endTime: endTime,
                                subject: sub,
                                branch: _selectedBranch,
                                year: _selectedYear,
                                semester: _selectedSemester,
                                section: _selectedSection,
                                room: roomController.text.trim().isNotEmpty ? roomController.text.trim() : 'Classroom 201',
                                facultyName: facultyController.text.trim().isNotEmpty ? facultyController.text.trim() : 'Faculty',
                              );

                              Navigator.pop(ctx);
                              _savePeriodSlot(newSlot, originalSlot: slot);
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            label: Text(
                              isEditing ? 'Update Slot' : 'Add Slot to $_selectedDay',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimePickerBox({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time_rounded, color: AppColors.secondary, size: 15),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<String?> _showTimePicker(BuildContext context, String current) async {
    int curH = 9;
    int curM = 0;
    try {
      final parts = current.split(':');
      curH = int.parse(parts[0]);
      curM = int.parse(parts[1]);
    } catch (_) {}

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: curH, minute: curM),
    );

    if (picked != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    return null;
  }

  void _savePeriodSlot(TimetablePeriodSlot newSlot, {TimetablePeriodSlot? originalSlot}) {
    setState(() {
      if (originalSlot != null) {
        _slots.remove(originalSlot);
      } else {
        // If slot with same day and periodNumber exists, replace it
        _slots.removeWhere((s) => s.day == newSlot.day && s.periodNumber == newSlot.periodNumber);
      }
      _slots.add(newSlot);
      // Sort slots by period number
      _slots.sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
    });
    _showSnack('Slot ${newSlot.periodNumber} (${newSlot.subject}) saved for ${newSlot.day}', AppColors.success);
  }

  void _deleteSlot(TimetablePeriodSlot slot) {
    setState(() {
      _slots.remove(slot);
    });
    _showSnack('Period slot removed from ${slot.day}', AppColors.info);
  }

  /// Publish and Save Timetable to Firestore & Local Cache
  Future<void> _publishTimetable() async {
    if (_slots.isEmpty) {
      _showSnack('Please add at least one period before publishing', AppColors.error);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'teacher_uid';
      final teacherName = _senderData?['name'] ?? 'Faculty Member';
      final teacherTitle = _senderData?['title'] ?? 'Prof.';
      final todayDateStr = DateFormat('dd MMM, yyyy').format(DateTime.now());

      final title = _scheduleMode == 1
          ? '$_selectedBranch $_selectedYear ($_selectedSemester) - Today\'s Schedule ($todayDateStr)'
          : (_titleController.text.trim().isNotEmpty
              ? _titleController.text.trim()
              : '$_selectedBranch $_selectedYear ($_selectedSemester) - Master Schedule');

      await TimetableService.uploadTimetable(
        existingId: _existingId,
        imageFile: _selectedImage,
        title: title,
        sentByUid: uid,
        sentByName: teacherName,
        sentByRole: widget.isAdmin ? 'admin' : 'teacher',
        sentByTitle: teacherTitle,
        targetBranch: widget.isAdmin ? 'ALL' : _selectedBranch,
        targetYear: widget.isAdmin ? 'ALL' : _selectedYear,
        targetSemester: widget.isAdmin ? 'ALL' : _selectedSemester,
        targetSection: widget.isAdmin ? 'ALL' : _selectedSection,
        slots: _slots,
      );

      if (!mounted) return;
      final successMsg = _scheduleMode == 1
          ? '✅ Today\'s reschedule updated! Students will see today\'s adjusted lectures.'
          : '✅ Weekly Master Timetable published! All students of $_selectedBranch $_selectedYear Sec $_selectedSection will see this schedule daily.';
      _showSnack(successMsg, AppColors.success);
      setState(() => _isLoadedFromDb = true);
    } catch (e) {
      if (mounted) _showSnack('Failed to save timetable: $e', AppColors.error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayName = DateFormat('EEEE').format(DateTime.now());
    final currentDaySlots = _slots.where((s) => s.day.toLowerCase() == _selectedDay.toLowerCase()).toList();
    currentDaySlots.sort((a, b) => a.periodNumber.compareTo(b.periodNumber));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '📅 Class Timetable Management',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        backgroundColor: AppColors.surface,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isSaving)
            TextButton.icon(
              onPressed: _publishTimetable,
              icon: const Icon(Icons.cloud_upload_rounded, color: AppColors.secondary, size: 18),
              label: const Text('Publish', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // ─── Top Filter Panel: Select Class (Branch, Year, Sem, Section) ───
          _buildClassSelectorPanel(),

          // ─── Mode & Status Bar ───
          _buildScheduleStatusBar(),

          // ─── Day Navigation Bar ───
          _buildDaySelectorBar(todayName),

          // ─── Period Slots List for Selected Day ───
          Expanded(
            child: _isLoadingClass
                ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
                : currentDaySlots.isEmpty
                    ? _buildEmptyDayView()
                    : _buildSlotsListView(currentDaySlots),
          ),

          // ─── Bottom Action Bar ───
          _buildBottomActionToolbar(),
        ],
      ),
    );
  }

  /// Top Class Filter Selector Card
  Widget _buildClassSelectorPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.2))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Branch Selector
          Row(
            children: [
              const Icon(Icons.account_balance_rounded, color: AppColors.secondary, size: 16),
              const SizedBox(width: 6),
              const Text('Branch: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              Expanded(
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBranch,
                      dropdownColor: const Color(0xFF1E293B),
                      isDense: true,
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedBranch = val);
                          _loadClassTimetable();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Year, Semester, Section
          Row(
            children: [
              // Year
              Expanded(
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedYear,
                      dropdownColor: const Color(0xFF1E293B),
                      isDense: true,
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                      items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedYear = val;
                            _syncSemesterWithYear(val);
                          });
                          _loadClassTimetable();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Semester
              Expanded(
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _semesters.contains(_selectedSemester) ? _selectedSemester : _semesters.first,
                      dropdownColor: const Color(0xFF1E293B),
                      isDense: true,
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                      items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedSemester = val);
                          _loadClassTimetable();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Section
              Expanded(
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sections.contains(_selectedSection) ? _selectedSection : _sections.first,
                      dropdownColor: const Color(0xFF1E293B),
                      isDense: true,
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                      items: _sections.map((sec) => DropdownMenuItem(value: sec, child: Text('Sec $sec'))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedSection = val);
                          _loadClassTimetable();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Live Status & Mode Indicator
  Widget _buildScheduleStatusBar() {
    final todayName = DateFormat('EEEE').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          // Schedule Mode Toggle: Weekly Master (Daily Default) vs Today's Quick Update
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _scheduleMode = 0);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: _scheduleMode == 0 ? AppColors.secondary.withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _scheduleMode == 0 ? AppColors.secondary : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.repeat_rounded, size: 14, color: _scheduleMode == 0 ? AppColors.secondary : AppColors.textSecondary),
                        const SizedBox(width: 5),
                        Text(
                          'Weekly Master (Daily Default)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _scheduleMode == 0 ? AppColors.secondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _scheduleMode = 1;
                      if (_days.contains(todayName)) _selectedDay = todayName;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: _scheduleMode == 1 ? const Color(0xFFF59E0B).withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _scheduleMode == 1 ? const Color(0xFFF59E0B) : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt_rounded, size: 14, color: _scheduleMode == 1 ? const Color(0xFFF59E0B) : AppColors.textSecondary),
                        const SizedBox(width: 5),
                        Text(
                          "Today's Change / Substitute",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _scheduleMode == 1 ? const Color(0xFFF59E0B) : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Status and period count row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _isLoadedFromDb
                      ? const Color(0xFF10B981).withOpacity(0.15)
                      : AppColors.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _isLoadedFromDb
                        ? const Color(0xFF10B981).withOpacity(0.4)
                        : AppColors.secondary.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isLoadedFromDb ? Icons.verified_rounded : Icons.auto_fix_high_rounded,
                      color: _isLoadedFromDb ? const Color(0xFF10B981) : AppColors.secondary,
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isLoadedFromDb ? 'ACTIVE IN DATABASE' : 'DEFAULT CURRICULUM TEMPLATE',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: _isLoadedFromDb ? const Color(0xFF10B981) : AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${_slots.length} Total Periods',
                style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              Tooltip(
                message: 'Reset to standard RGPV template',
                child: InkWell(
                  onTap: () => _autoFillTemplate(notify: true),
                  child: const Icon(Icons.refresh_rounded, color: AppColors.secondary, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Day Selector Bar (Mon to Sat)
  Widget _buildDaySelectorBar(String todayName) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final day = _days[index];
          final isSelected = day.toLowerCase() == _selectedDay.toLowerCase();
          final isToday = day.toLowerCase() == todayName.toLowerCase();
          final dayCount = _slots.where((s) => s.day.toLowerCase() == day.toLowerCase()).length;

          return InkWell(
            onTap: () => setState(() => _selectedDay = day),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isToday
                      ? const Color(0xFF10B981)
                      : isSelected
                          ? AppColors.secondary
                          : Colors.transparent,
                  width: isToday ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    day.substring(0, 3),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$dayCount',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 5, height: 5,
                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Empty state when no periods scheduled for selected day
  Widget _buildEmptyDayView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy_rounded, size: 54, color: AppColors.textHint),
            const SizedBox(height: 14),
            Text(
              'No Periods for $_selectedDay',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap "+ Add Period" to schedule a lecture or "Auto-Fill Template" to populate standard slots.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () => _openPeriodDialog(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Add Period to $_selectedDay', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  /// List of period slot cards for selected day
  Widget _buildSlotsListView(List<TimetablePeriodSlot> currentSlots) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: currentSlots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final slot = currentSlots[index];
        final isLab = slot.subject.toLowerCase().contains('lab') || slot.subject.toLowerCase().contains('practical');

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isLab ? AppColors.info.withOpacity(0.4) : AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Period Number Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLab ? AppColors.info.withOpacity(0.15) : AppColors.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'P${slot.periodNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: isLab ? AppColors.info : AppColors.secondary,
                      ),
                    ),
                    const Text(
                      'Period',
                      style: TextStyle(fontSize: 8, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Details: Subject, Time, Room, Teacher
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.subject,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          '${slot.startTime} - ${slot.endTime}',
                          style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.meeting_room_rounded, size: 12, color: AppColors.textHint),
                        const SizedBox(width: 3),
                        Text(
                          slot.room,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Faculty: ${slot.facultyName}',
                      style: const TextStyle(color: AppColors.textHint, fontSize: 10.5),
                    ),
                  ],
                ),
              ),

              // Edit & Delete Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: AppColors.secondary, size: 20),
                    tooltip: 'Edit Slot',
                    onPressed: () => _openPeriodDialog(slot: slot, slotIndex: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    tooltip: 'Delete Slot',
                    onPressed: () => _deleteSlot(slot),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Bottom action toolbar: Add Period, Attach Image & Save
  Widget _buildBottomActionToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Add Period Button
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.secondary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  onPressed: () => _openPeriodDialog(),
                  icon: const Icon(Icons.add_rounded, color: AppColors.secondary, size: 18),
                  label: Text(
                    '+ Add to $_selectedDay',
                    style: const TextStyle(color: AppColors.secondary, fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Attach Board Photo Button (Optional)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _selectedImage != null ? AppColors.success : AppColors.primary.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                ),
                onPressed: _pickImage,
                icon: Icon(
                  _selectedImage != null ? Icons.check_circle_rounded : Icons.camera_alt_outlined,
                  color: _selectedImage != null ? AppColors.success : AppColors.textSecondary,
                  size: 17,
                ),
                label: Text(
                  _selectedImage != null ? 'Photo OK' : 'Attach Photo',
                  style: TextStyle(
                    color: _selectedImage != null ? AppColors.success : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Publish Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSaving ? null : _publishTimetable,
              icon: _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.check_circle_rounded, size: 20),
              label: Text(
                _isSaving
                    ? 'Publishing Schedule...'
                    : 'Save & Publish Timetable (${_selectedBranch.split(' ').first} $_selectedYear Sec $_selectedSection)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
