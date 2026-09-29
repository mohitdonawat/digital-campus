import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../services/timetable_service.dart';
import '../services/timetable_analysis_service.dart';
import '../models/timetable_model.dart';

class StudentTimetableScreen extends StatefulWidget {
  const StudentTimetableScreen({super.key});

  @override
  State<StudentTimetableScreen> createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen> {
  Map<String, dynamic>? _studentData;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _studentData = {
            'name': 'Student',
            'branch': 'Computer Science & Engineering',
            'year': '3rd Year',
            'semester': '6th Semester',
            'section': 'A',
          };
          _dataLoaded = true;
        });
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          if (doc.exists && doc.data() != null) {
            _studentData = doc.data();
          } else {
            _studentData = {
              'name': user.displayName ?? 'Student',
              'branch': 'Computer Science & Engineering',
              'year': '3rd Year',
              'semester': '6th Semester',
              'section': 'A',
            };
          }
          _dataLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _studentData = {
            'name': user.displayName ?? 'Student',
            'branch': 'Computer Science & Engineering',
            'year': '3rd Year',
            'semester': '6th Semester',
            'section': 'A',
          };
          _dataLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📅 My Timetable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: !_dataLoaded
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          : _buildTimetableList(),
    );
  }

  Widget _buildTimetableList() {
    final branch = _studentData?['branch'] ?? '';
    final year = _studentData?['year'] ?? '';
    final section = _studentData?['section'] ?? '';
    final semester = _studentData?['semester'] ?? '';

    return StreamBuilder<List<TimetableModel>>(
      stream: TimetableService.getTimetablesForStudent(
        branch: branch,
        year: year,
        section: section,
        semester: semester,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          );
        }

        // Resilient fallback: never display raw database error on user's screen
        if (snapshot.hasError) {
          debugPrint('Timetable stream error (handled): ${snapshot.error}');
          return _buildEmptyState();
        }

        final timetables = snapshot.data ?? [];

        if (timetables.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppColors.secondary,
          backgroundColor: AppColors.surface,
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: timetables.length,
            itemBuilder: (ctx, i) => _TimetableCard(
              timetable: timetables[i],
              studentName: _studentData?['name'] ?? 'Student',
              studentBranch: branch,
              studentYear: year,
              studentSemester: semester,
              studentSection: section,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today_rounded, color: AppColors.secondary, size: 38),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Timetable Published Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your department or faculty has not sent a schedule for your batch yet.\nCheck back soon!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dual-Mode Timetable Card (Image + Extracted Text Schedule) ──────────────
class _TimetableCard extends StatefulWidget {
  final TimetableModel timetable;
  final String studentName;
  final String studentBranch;
  final String studentYear;
  final String studentSemester;
  final String studentSection;

  const _TimetableCard({
    required this.timetable,
    required this.studentName,
    required this.studentBranch,
    required this.studentYear,
    required this.studentSemester,
    required this.studentSection,
  });

  @override
  State<_TimetableCard> createState() => _TimetableCardState();
}

class _TimetableCardState extends State<_TimetableCard> {
  // 0: Image View, 1: Structured Schedule View
  int _viewMode = 0;

  @override
  void initState() {
    super.initState();
    _viewMode = widget.timetable.imageUrl.isNotEmpty ? 0 : 1;
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('dd MMM, hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isFromAdmin = widget.timetable.sentByRole == 'admin';
    final now = DateTime.now();
    final todayName = DateFormat('EEEE').format(now);

    // Filter slots for today or generate slots if none stored
    List<TimetablePeriodSlot> slots = widget.timetable.slots;
    if (slots.isEmpty) {
      final analysis = TimetableAnalysisService.analyzeAndExtractSchedule(
        branch: widget.studentBranch.isNotEmpty ? widget.studentBranch : 'Computer Science & Engineering',
        year: widget.studentYear.isNotEmpty ? widget.studentYear : '3rd Year',
        semester: widget.studentSemester.isNotEmpty ? widget.studentSemester : '6th Semester',
        section: widget.studentSection.isNotEmpty ? widget.studentSection : 'A',
      );
      slots = analysis.slots;
    }

    final activeSlot = TimetableAnalysisService.detectCurrentPeriod(slots);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isFromAdmin
              ? const Color(0xFF7C3AED).withOpacity(0.4)
              : AppColors.secondary.withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isFromAdmin ? const Color(0xFF7C3AED) : AppColors.primary).withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Sender info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isFromAdmin ? const Color(0xFF7C3AED).withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFromAdmin ? const Color(0xFF7C3AED).withOpacity(0.5) : AppColors.secondary.withOpacity(0.4),
                        ),
                      ),
                      child: Icon(
                        isFromAdmin ? Icons.admin_panel_settings_rounded : Icons.person_4_rounded,
                        color: isFromAdmin ? const Color(0xFFA78BFA) : AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isFromAdmin ? '🛡️ Admin' : widget.timetable.senderLabel,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isFromAdmin ? const Color(0xFFA78BFA) : AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isFromAdmin ? const Color(0xFF7C3AED).withOpacity(0.15) : AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isFromAdmin ? 'ADMIN' : 'FACULTY',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: isFromAdmin ? const Color(0xFFA78BFA) : AppColors.info,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(widget.timetable.createdAt),
                            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.timetable.title,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info.withOpacity(0.25)),
                  ),
                  child: Text(
                    widget.timetable.targetLabel,
                    style: const TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // View Switcher Bar (Image View vs Period Schedule View - only if image exists)
          if (widget.timetable.imageUrl.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _viewMode = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _viewMode == 0 ? AppColors.secondary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_rounded, size: 16, color: _viewMode == 0 ? Colors.white : AppColors.textHint),
                            const SizedBox(width: 6),
                            Text(
                              'Photo View',
                              style: TextStyle(
                                color: _viewMode == 0 ? Colors.white : AppColors.textHint,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _viewMode = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _viewMode == 1 ? AppColors.secondary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.format_list_bulleted_rounded, size: 16, color: _viewMode == 1 ? Colors.white : AppColors.textHint),
                            const SizedBox(width: 6),
                            Text(
                              'Period Schedule',
                              style: TextStyle(
                                color: _viewMode == 1 ? Colors.white : AppColors.textHint,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Main View Body
          if (_viewMode == 0 && widget.timetable.imageUrl.isNotEmpty) ...[
            // ─── Photo View ───
            GestureDetector(
              onTap: () => _openFullScreen(context),
              child: ClipRRect(
                child: widget.timetable.imageUrl.startsWith('data:image')
                    ? Image.memory(
                        base64Decode(widget.timetable.imageUrl.contains(',')
                            ? widget.timetable.imageUrl.split(',').last
                            : widget.timetable.imageUrl),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : widget.timetable.imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: widget.timetable.imageUrl,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              height: 200,
                              color: AppColors.surfaceVariant,
                              child: const Center(child: CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 2)),
                            ),
                            errorWidget: (_, __, ___) => _buildImageFallback(),
                          )
                        : File(widget.timetable.imageUrl).existsSync()
                            ? Image.file(File(widget.timetable.imageUrl), height: 220, width: double.infinity, fit: BoxFit.cover)
                            : _buildImageFallback(),
              ),
            ),
          ] else ...[
            // ─── Period-Wise Structured Text View ───
            Container(
              padding: const EdgeInsets.all(14),
              color: const Color(0xFF0F172A),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Live Status Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.today_rounded, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 5),
                            Text('TODAY: $todayName', style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      if (activeSlot != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.success.withOpacity(0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.fiber_manual_record, size: 10, color: AppColors.success),
                              SizedBox(width: 4),
                              Text('LIVE CLASS', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Today's schedule list
                  ...slots.where((s) => s.day.toLowerCase() == todayName.toLowerCase()).map((slot) {
                    final isNow = (activeSlot != null && activeSlot.periodNumber == slot.periodNumber);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isNow ? AppColors.success.withOpacity(0.1) : AppColors.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isNow ? AppColors.success : AppColors.primary.withOpacity(0.2),
                          width: isNow ? 1.4 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: isNow ? AppColors.success : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              slot.startTime,
                              style: TextStyle(
                                color: isNow ? Colors.white : AppColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slot.subject,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isNow ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${slot.periodName} • ${slot.room}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          if (isNow)
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                        ],
                      ),
                    );
                  }).toList(),

                  // Extracted Full Text Viewer
                  if (widget.timetable.extractedScheduleText.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _showFullTextSchedule(context),
                      icon: const Icon(Icons.description_rounded, size: 15),
                      label: const Text('View Full Week Schedule (Text)', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: const BorderSide(color: AppColors.secondary),
                        minimumSize: const Size(double.infinity, 38),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // ─── Actions Bar ───
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openFullScreen(context),
                    icon: const Icon(Icons.zoom_in_rounded, size: 16),
                    label: const Text('View Full Image', style: TextStyle(fontSize: 12.5)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.info,
                      side: const BorderSide(color: AppColors.info),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadImage(context),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Download', style: TextStyle(fontSize: 12.5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success.withOpacity(0.85),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      height: 180,
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_rounded, color: AppColors.secondary, size: 36),
            SizedBox(height: 8),
            Text('Timetable Schedule Attached', style: TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showFullTextSchedule(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('📋 Extracted Weekly Schedule', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: AppColors.secondary, size: 20),
                  tooltip: 'Copy text',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.timetable.extractedScheduleText));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied timetable text!')));
                  },
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.timetable.extractedScheduleText,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace', height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(
          imageUrl: widget.timetable.imageUrl,
          title: widget.timetable.title,
          senderName: widget.timetable.senderLabel,
          sentAt: widget.timetable.createdAt,
        ),
      ),
    );
  }

  Future<void> _downloadImage(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading timetable...'), backgroundColor: AppColors.info, duration: Duration(seconds: 3)),
      );

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'timetable_${widget.timetable.id.substring(0, 8)}.jpg';
      final file = File('${dir.path}/$fileName');

      if (widget.timetable.imageUrl.startsWith('http')) {
        final response = await http.get(Uri.parse(widget.timetable.imageUrl));
        await file.writeAsBytes(response.bodyBytes);
      } else if (File(widget.timetable.imageUrl).existsSync()) {
        await File(widget.timetable.imageUrl).copy(file.path);
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Saved to device: $fileName'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () => OpenFile.open(file.path),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download notice: $e'), backgroundColor: AppColors.error),
      );
    }
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String senderName;
  final DateTime sentAt;

  const _FullScreenImageViewer({
    required this.imageUrl,
    required this.title,
    required this.senderName,
    required this.sentAt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: imageUrl.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const CircularProgressIndicator(color: AppColors.secondary),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54, size: 60),
                )
              : File(imageUrl).existsSync()
                  ? Image.file(File(imageUrl), fit: BoxFit.contain)
                  : const Icon(Icons.calendar_today_rounded, color: Colors.white54, size: 60),
        ),
      ),
    );
  }
}
