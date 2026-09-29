import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_chip.dart';
import '../../providers/campus_provider.dart';
import '../study_assistant/vernacular_study_assistant_screen.dart';
import '../ai_assistant/ai_voice_assistant_screen.dart';
import '../../core/services/document_download_service.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final timetable = provider.timetable;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Smart Timetable & Live Classes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            Text(
              "Hybrid Classrooms • AI Lecture Notes • Live Streams",
              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(icon: Icon(Icons.live_tv_rounded, size: 16), text: "Live & Today"),
            Tab(icon: Icon(Icons.calendar_month_rounded, size: 16), text: "Weekly Master"),
            Tab(icon: Icon(Icons.video_library_rounded, size: 16), text: "AI Recordings"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: Live Classroom & Today's Schedule ──
          _buildLiveAndTodayTab(context, timetable),

          // ── Tab 2: Weekly Master Timetable ──
          _buildWeeklyMasterTab(context),

          // ── Tab 3: Recorded Lectures & AI Summaries ──
          _buildRecordedLecturesTab(context),
        ],
      ),
    );
  }

  // ── Tab 1: Live & Today ──────────────────────────────────────────────────
  Widget _buildLiveAndTodayTab(BuildContext context, dynamic timetable) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔴 PROMINENT LIVE CLASSROOM STREAM BANNER
          _buildLiveStreamBanner(context),

          const SizedBox(height: 18),

          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.schedule_rounded, color: AppColors.primary, size: 16),
                  SizedBox(width: 6),
                  Text(
                    "TODAY'S LECTURE SESSIONS",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textDark),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: const Text("5 Periods • Section A", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Periods List
          ...timetable.map((period) => _buildPeriodCard(context, period)),

          const SizedBox(height: 14),

          // Timetable Sync Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight, width: 1.0),
            ),
            child: const Row(
              children: [
                Icon(Icons.sync_rounded, color: AppColors.success, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Real-time Faculty Substitution syncs automatically across student app, attendance register, and digital notice board.",
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Live Streaming Classroom Banner ─────────────────────────────────────
  Widget _buildLiveStreamBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with pulsating live tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: AppColors.borderDark.withOpacity(0.5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "LIVE SMART CLASSROOM IN SESSION",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.people_alt_rounded, size: 11, color: AppColors.success),
                      SizedBox(width: 4),
                      Text("38 Present", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.success)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Class Info
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.sensors_rounded, color: Color(0xFF818CF8), size: 26),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Machine Learning & AI (CS-601)",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Topic: Backpropagation Gradient & Multivariate Chain Rule",
                            style: TextStyle(fontSize: 11.5, color: Color(0xFFC7D2FE), fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Instructor: Dr. Mohit Donawat • Room: LH-302 (Hybrid Stream)",
                            style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Action Buttons: Join Stream, AI Notes, Ask Doubt
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          _showLiveClassModal(context, "Machine Learning & AI", "Dr. Mohit Donawat");
                        },
                        icon: const Icon(Icons.play_circle_fill_rounded, size: 16, color: Colors.white),
                        label: const Text(
                          "Join Live Stream",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _showAiLectureNotesModal(context);
                        },
                        icon: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.accent),
                        label: const Text(
                          "AI Notes",
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.accent),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderDark),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Period Card ─────────────────────────────────────────────────────────
  Widget _buildPeriodCard(BuildContext context, dynamic period) {
    final isLive = period.subjectCode == "CS-601";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: period.isSubstitute
              ? AppColors.warning
              : (isLive ? AppColors.primary : AppColors.borderLight),
          width: period.isSubstitute || isLive ? 1.5 : 1.0,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: isLive ? AppColors.primary : AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${period.startTime} - ${period.endTime}",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: isLive ? AppColors.primary : AppColors.accent,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isLive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.error, width: 0.8),
                      ),
                      child: const Text("🔴 LIVE NOW", style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.error)),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (period.isSubstitute)
                    const CustomChip(label: "SUBSTITUTE", color: AppColors.warning, isSolid: true)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(
                        period.roomNumber,
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            period.subjectName,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 2),
          Text(
            "Faculty: ${period.facultyName} (${period.subjectCode})",
            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),

          if (period.isSubstitute && period.originalFacultyName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_rounded, size: 14, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Faculty Substitution: ${period.substituteReason ?? 'Medical leave'}. Regular: ${period.originalFacultyName}.",
                      style: const TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Period Action Buttons
          Row(
            children: [
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showAiLectureNotesModal(context);
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.notes_rounded, size: 12, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text("Lecture Notes", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VernacularStudyAssistantScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.translate_rounded, size: 12, color: AppColors.success),
                      SizedBox(width: 4),
                      Text("Hindi/Audio Tutor", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.success)),
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

  // ── Tab 2: Weekly Master Timetable ──────────────────────────────────────
  Widget _buildWeeklyMasterTab(BuildContext context) {
    final days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExpansionTile(
            initiallyExpanded: index == 0,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 18),
            ),
            title: Text(
              day,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            subtitle: Text(
              index == 0 ? "5 Classes (Current Day)" : "5 Scheduled Lectures & Practical Labs",
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            children: [
              _buildMiniScheduleRow("09:30 - 10:30", "Machine Learning & AI", "LH-302", "Dr. Mohit Donawat"),
              _buildMiniScheduleRow("10:30 - 11:30", "Computer Networks", "LH-302", "Prof. Vikram Sen"),
              _buildMiniScheduleRow("11:45 - 01:15", "DevOps & Cloud Lab", "Lab 3", "Prof. Ankit Saxena"),
              _buildMiniScheduleRow("02:00 - 03:00", "Compiler Design", "LH-302", "Dr. S.K. Rathore"),
              _buildMiniScheduleRow("03:00 - 04:30", "Project & Doubt Mentorship", "Inno Lab", "Dr. Mohit Donawat"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniScheduleRow(String time, String subject, String room, String faculty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
          Expanded(
            child: Text(subject, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ),
          Text("$room • $faculty", style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  // ── Tab 3: Recorded Lectures & AI Summaries ─────────────────────────────
  Widget _buildRecordedLecturesTab(BuildContext context) {
    final recordings = [
      {
        "title": "CS-601: Backpropagation & Neural Network Optimizers",
        "date": "Yesterday • 54 mins",
        "instructor": "Dr. Mohit Donawat",
        "views": "42 Students watched",
        "aiSummary": "Key concepts: Forward pass, Cross-entropy loss, Backward pass via chain rule, Adam vs SGD optimizer comparison.",
      },
      {
        "title": "CS-602: TCP Congestion Control & Windowing Mechanism",
        "date": "23 Sep • 48 mins",
        "instructor": "Prof. Priya Verma",
        "views": "39 Students watched",
        "aiSummary": "Key concepts: Slow start threshold, Tahoe vs Reno fast retransmit, Three-way handshake sequence.",
      },
      {
        "title": "CS-604: LR(1) Bottom-Up Parsing & Shift-Reduce Conflicts",
        "date": "21 Sep • 58 mins",
        "instructor": "Dr. S.K. Rathore",
        "views": "45 Students watched",
        "aiSummary": "Key concepts: Canonical collections of LR(1) items, Lookahead calculation, Handle pruning technique.",
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        final rec = recordings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight, width: 1.0),
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
              // Mock Video Preview Box
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1E293B), Colors.black.withOpacity(0.8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.85),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, size: 32, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        rec["date"]!,
                        style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),

              // Lecture Details
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec["title"]!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Instructor: ${rec["instructor"]} • ${rec["views"]}",
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 10),

                    // AI Generated Summary Box
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight, width: 1.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.primary),
                              SizedBox(width: 5),
                              Text("AI GENERATED LECTURE SUMMARY", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rec["aiSummary"]!,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.35),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _showLiveClassModal(context, rec["title"]!, rec["instructor"]!);
                            },
                            icon: const Icon(Icons.play_circle_outline_rounded, size: 15, color: Colors.white),
                            label: const Text("Watch Lecture", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const VernacularStudyAssistantScreen()),
                            );
                          },
                          icon: const Icon(Icons.translate_rounded, size: 14, color: AppColors.success),
                          label: const Text("Audio Hindi", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFA7F3D0)),
                            backgroundColor: const Color(0xFFECFDF5),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Live Stream Player Modal ─────────────────────────────────────────────
  void _showLiveClassModal(BuildContext context, String subject, String instructor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
            ),

            // Video Player Mock
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.live_tv_rounded, size: 40, color: AppColors.error),
                        SizedBox(height: 8),
                        Text("Live WebRTC Smart Class Stream", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                        Text("Low Latency 1080p • Audio Active", style: TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text("🔴 LIVE STREAM", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),

            // Class Information
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subject, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        Text("Instructor: $instructor • LH-302", style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Biometric Digital Attendance marked for this lecture!"), backgroundColor: AppColors.success),
                      );
                    },
                    icon: const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                    label: const Text("Mark Attendance", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, elevation: 0),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.borderLight, height: 1),

            // Live Class Q&A and Chat
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text("LIVE CLASS CHAT & DOUBTS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                children: [
                  _chatBubble("Prof. Mohit Donawat", "Please look at the slide on Backprop gradient calculation.", true),
                  _chatBubble("Ananya Patel", "Sir, will this derivation be asked in Mid-Sem 2?", false),
                  _chatBubble("Rahul Sharma (You)", "Sir, why do we use Chain Rule instead of direct derivative?", false),
                  _chatBubble("Prof. Mohit Donawat", "Good question Rahul! Because weights are nested within multiple activation layers.", true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatBubble(String sender, String message, bool isFaculty) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isFaculty ? AppColors.primary : const Color(0xFF64748B),
            child: Text(sender[0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isFaculty ? AppColors.primary.withOpacity(0.08) : AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isFaculty ? AppColors.primary.withOpacity(0.25) : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isFaculty ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.25),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AI Lecture Notes Modal ──────────────────────────────────────────────
  void _showAiLectureNotesModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text("AI Smart Lecture Notes", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "CS-601: Machine Learning & AI",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              SizedBox(height: 4),
              Text("Lecture: Backpropagation & Neural Net Weight Updates", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              SizedBox(height: 10),
              Text(
                "1. Forward Pass:\n"
                "• Input features multiply with weight matrix W1.\n"
                "• Pass through activation function (ReLU / Sigmoid).\n"
                "• Loss computed using Cross-Entropy vs true label.\n\n"
                "2. Backward Pass:\n"
                "• Error propagated backwards via Multivariate Chain Rule.\n"
                "• Partial derivatives computed: ∂Loss/∂Weight.\n\n"
                "3. Key Exam Questions:\n"
                "• Why vanishing gradients occur in deep networks.\n"
                "• Comparison between SGD, RMSprop, and Adam optimizers.",
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              DocumentDownloadService.downloadLectureNotesPdf(
                context,
                "Machine Learning & AI",
                "Dr. Mohit Donawat",
                "Backpropagation & Convolutional Neural Networks",
              );
            },
            icon: const Icon(Icons.download_rounded, size: 14, color: Colors.white),
            label: const Text("Download PDF", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
