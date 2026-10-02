import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_chip.dart';
import '../../models/campus_models.dart';
import '../../providers/campus_provider.dart';
import '../../data/campus_database.dart';
import '../study_assistant/vernacular_study_assistant_screen.dart';
import '../ai_assistant/ai_voice_assistant_screen.dart';
import '../../core/services/document_download_service.dart';
import 'in_app_live_classroom_screen.dart';
import '../attendance/dynamic_attendance_qr_modal.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _liveClassesFilter = "All"; // "All", "Live Now", "Scheduled", "Completed History"

  // Live Class Real-Time Doubts & Chat State
  final List<Map<String, dynamic>> _liveChatMessages = [
    {
      "sender": "Dr. Mohit Donawat",
      "message": "Welcome everyone to today's hybrid smart lecture. Screen sharing and audio stream are live!",
      "isFaculty": true,
      "time": "Just now",
    },
    {
      "sender": "Ananya Patel",
      "message": "Sir, will the backpropagation derivation be asked in Mid-Sem 2?",
      "isFaculty": false,
      "time": "2m ago",
    },
    {
      "sender": "Rahul Sharma (You)",
      "message": "Sir, why do we use multivariate chain rule instead of direct derivative in deep networks?",
      "isFaculty": false,
      "time": "1m ago",
    },
    {
      "sender": "Dr. Mohit Donawat",
      "message": "Good question Rahul! Because weights are nested across multiple sequential non-linear layers.",
      "isFaculty": true,
      "time": "Just now",
    },
  ];

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

  // ── Meeting Launcher Helper (Jitsi, Meet, Zoom, Any Link) ───────────────
  Future<void> _launchMeetingUrl(BuildContext context, String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Launching video call: $urlString"),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not open meeting: $urlString"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final timetable = provider.timetable;
    final role = provider.currentRole;
    final isFaculty = role == UserRole.faculty || role == UserRole.admin;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Smart Timetable & Live Classes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            Text(
              isFaculty
                  ? "Faculty Console • Schedule Class • Jitsi/Meet/Zoom"
                  : "Hybrid Classrooms • AI Lecture Notes • Live Streams",
              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          if (isFaculty)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 22),
              tooltip: "Go Live / Schedule Class",
              onPressed: () => _showScheduleOrGoLiveDialog(context, provider),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(icon: Icon(Icons.live_tv_rounded, size: 16), text: "Live & History"),
            Tab(icon: Icon(Icons.calendar_today_rounded, size: 16), text: "Today's Schedule"),
            Tab(icon: Icon(Icons.calendar_month_rounded, size: 16), text: "Weekly Master"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: Live, Scheduled & History Classes ──
          _buildLiveClassesSuiteTab(context, provider, isFaculty),

          // ── Tab 2: Today's Class Schedule (Timetable) ──
          _buildTodayTimetableTab(context, provider, timetable, isFaculty),

          // ── Tab 3: Weekly Master Timetable ──
          _buildWeeklyMasterTab(context, provider, isFaculty),
        ],
      ),
      floatingActionButton: isFaculty
          ? FloatingActionButton.extended(
              onPressed: () => _showScheduleOrGoLiveDialog(context, provider),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.video_call_rounded, color: Colors.white),
              label: const Text("Go Live / Schedule", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
            )
          : null,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 1: Live Classes Suite (Live Now • Scheduled • Completed History)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildLiveClassesSuiteTab(BuildContext context, CampusProvider provider, bool isFaculty) {
    final allSessions = provider.liveClasses;
    final liveSessions = allSessions.where((s) => s.status == LiveClassStatus.live).toList();
    final scheduledSessions = allSessions.where((s) => s.status == LiveClassStatus.scheduled).toList();
    final historySessions = allSessions.where((s) => s.status == LiveClassStatus.completed).toList();

    List<LiveClassSession> displayList;
    if (_liveClassesFilter == "Live Now") {
      displayList = liveSessions;
    } else if (_liveClassesFilter == "Scheduled") {
      displayList = scheduledSessions;
    } else if (_liveClassesFilter == "Completed History") {
      displayList = historySessions;
    } else {
      displayList = allSessions;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Faculty Action Banner ──────────────────────────────────
          if (isFaculty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cast_for_education_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Faculty Smart Class Studio",
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Host Jitsi, Google Meet, Zoom or any custom meeting link.",
                          style: TextStyle(fontSize: 10.5, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showScheduleOrGoLiveDialog(context, provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text("+ Host Class", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),

          // ── Filter Chips Bar ───────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("All", "All (${allSessions.length})", Icons.apps_rounded),
                const SizedBox(width: 8),
                _buildFilterChip("Live Now", "🔴 Live Now (${liveSessions.length})", Icons.sensors_rounded, isLive: true),
                const SizedBox(width: 8),
                _buildFilterChip("Scheduled", "⏳ Scheduled (${scheduledSessions.length})", Icons.schedule_rounded),
                const SizedBox(width: 8),
                _buildFilterChip("Completed History", "📜 History (${historySessions.length})", Icons.history_rounded),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Live Stream Highlight (if any currently live) ──────────────
          if (liveSessions.isNotEmpty && (_liveClassesFilter == "All" || _liveClassesFilter == "Live Now")) ...[
            ...liveSessions.map((session) => _buildLiveSessionCard(context, provider, session, isFaculty)),
            const SizedBox(height: 14),
          ],

          // ── Scheduled Classes Section ──────────────────────────────────
          if (scheduledSessions.isNotEmpty && (_liveClassesFilter == "All" || _liveClassesFilter == "Scheduled")) ...[
            if (_liveClassesFilter == "All") ...[
              const Row(
                children: [
                  Icon(Icons.upcoming_rounded, size: 15, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    "SCHEDULED UPCOMING CLASSES",
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            ...scheduledSessions.map((session) => _buildScheduledSessionCard(context, provider, session, isFaculty)),
            const SizedBox(height: 14),
          ],

          // ── Completed / History Classes Section ────────────────────────
          if (historySessions.isNotEmpty && (_liveClassesFilter == "All" || _liveClassesFilter == "Completed History")) ...[
            if (_liveClassesFilter == "All") ...[
              const Row(
                children: [
                  Icon(Icons.video_library_rounded, size: 15, color: Color(0xFF059669)),
                  SizedBox(width: 6),
                  Text(
                    "LECTURE RECORDINGS & CLASS HISTORY",
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            ...historySessions.map((session) => _buildHistorySessionCard(context, session)),
          ],

          if (displayList.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.event_busy_rounded, size: 40, color: AppColors.textMuted),
                  const SizedBox(height: 8),
                  Text("No $_liveClassesFilter classes found", style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                ],
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, IconData icon, {bool isLive = false}) {
    final isSelected = _liveClassesFilter == filterKey;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _liveClassesFilter = filterKey);
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isLive ? const Color(0xFFFEF2F2) : AppColors.primary.withOpacity(0.12))
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? (isLive ? AppColors.error : AppColors.primary)
                : AppColors.borderLight,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? (isLive ? AppColors.error : AppColors.primary)
                  : AppColors.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isLive ? AppColors.error : AppColors.primary)
                    : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Live Session Card (Active 🔴) ───────────────────────────────────────
  Widget _buildLiveSessionCard(
      BuildContext context, CampusProvider provider, LiveClassSession session, bool isFaculty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "LIVE NOW",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        session.platform.displayName,
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_alt_rounded, size: 11, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text("${session.attendeesCount} Present", style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.success)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Info
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${session.title} (${session.subjectCode})",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 3),
                Text(
                  "Topic: ${session.topic}",
                  style: const TextStyle(fontSize: 12, color: Color(0xFFC7D2FE), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  "Instructor: ${session.instructorName} • Room: ${session.room}",
                  style: const TextStyle(fontSize: 10.5, color: Colors.white60),
                ),

                const SizedBox(height: 14),

                // Action Buttons
                Row(
                  children: [
                    // 1. Enter In-App Smart Classroom Studio (Zero Exit)
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InAppLiveClassroomScreen(
                                session: session,
                                isFaculty: isFaculty,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.sensors_rounded, size: 16, color: Colors.white),
                        label: const Text(
                          "Enter Live Studio",
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                          elevation: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 2. Faculty Dynamic QR Launcher
                    if (isFaculty) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          DynamicAttendanceQrModal.show(
                            context,
                            subjectCode: session.subjectCode,
                            subjectName: session.title,
                            room: session.room,
                            isFaculty: true,
                          );
                        },
                        icon: const Icon(Icons.qr_code_2_rounded, size: 15, color: Colors.white),
                        label: const Text(
                          "Dynamic QR",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                          elevation: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // 3. Open In-App Smart Class Room (with chat, doubts, attendance)
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _showLiveClassModal(context, session, isFaculty);
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF818CF8)),
                        label: const Text(
                          "Class Chat",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF818CF8)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF6366F1)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                        ),
                      ),
                    ),

                    // 3. Faculty End Class Option
                    if (isFaculty) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          provider.endLiveClass(session.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Class Ended & Successfully archived to History with AI Notes!"),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        tooltip: "End Class & Save to History",
                        icon: const Icon(Icons.stop_circle_rounded, color: AppColors.error, size: 24),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Scheduled Session Card (⏳ Upcoming) ──────────────────────────────────
  Widget _buildScheduledSessionCard(
      BuildContext context, CampusProvider provider, LiveClassSession session, bool isFaculty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text(
                    session.durationText,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  session.platform.displayName,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${session.title} (${session.subjectCode})",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 2),
          Text("Topic: ${session.topic}", style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          const SizedBox(height: 3),
          Text("Faculty: ${session.instructorName} • ${session.room}", style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),

          const SizedBox(height: 10),

          Row(
            children: [
              if (isFaculty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      provider.startLiveClass(session.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InAppLiveClassroomScreen(
                            session: session,
                            isFaculty: true,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.sensors_rounded, size: 14, color: Colors.white),
                    label: const Text("Start Class Now (In-App)", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), elevation: 0),
                  ),
                )
              else
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Class link: ${session.meetingUrl}"),
                          action: SnackBarAction(label: "Open", onPressed: () => _launchMeetingUrl(context, session.meetingUrl)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.link_rounded, size: 14, color: AppColors.primary),
                    label: const Text("View Meeting Link", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.borderLight)),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _launchMeetingUrl(context, session.meetingUrl),
                tooltip: "Open Link",
                icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Completed / History Session Card (📜 Past) ──────────────────────────
  Widget _buildHistorySessionCard(BuildContext context, LiveClassSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Text("COMPLETED", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF047857))),
              ),
              Text("${session.attendeesCount} Students attended", style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${session.title} (${session.subjectCode})",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 2),
          Text("Topic: ${session.topic}", style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          const SizedBox(height: 3),
          Text("Instructor: ${session.instructorName}", style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),

          if (session.aiSummary != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text("AI GENERATED LECTURE RECAP", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(session.aiSummary!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showLiveClassModal(context, session, false);
                  },
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 14, color: Colors.white),
                  label: const Text("Watch Recording", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showAiLectureNotesModal(context);
                },
                icon: const Icon(Icons.description_rounded, size: 14, color: AppColors.primary),
                label: const Text("Lecture Notes", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.borderLight)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 2: Today's Class Schedule (Timetable)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTodayTimetableTab(
      BuildContext context, CampusProvider provider, List<TimetablePeriod> timetable, bool isFaculty) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Faculty Timetable Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.schedule_rounded, color: AppColors.primary, size: 16),
                  SizedBox(width: 6),
                  Text(
                    "TODAY'S SCHEDULE",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textDark),
                  ),
                ],
              ),
              if (isFaculty)
                Row(
                  children: [
                    InkWell(
                      onTap: () => _showUploadTimetableModal(context, provider),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.upload_file_rounded, size: 12, color: Color(0xFF047857)),
                            SizedBox(width: 4),
                            Text("Upload", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF047857))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _showAddPeriodModal(context, provider),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add_rounded, size: 13, color: AppColors.primary),
                            SizedBox(width: 3),
                            Text("+ Add Slot", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Text("${timetable.length} Periods • Sec A", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Periods List
          ...timetable.map((period) => _buildPeriodCard(context, provider, period, isFaculty)),

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
                    "Dynamic timetable instantly updates across student mobile apps, attendance register, and smart digital notice boards.",
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

  // ── Period Card ─────────────────────────────────────────────────────────
  Widget _buildPeriodCard(BuildContext context, CampusProvider provider, TimetablePeriod period, bool isFaculty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: period.isSubstitute ? AppColors.warning : AppColors.borderLight,
          width: period.isSubstitute ? 1.5 : 1.0,
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
                  const Icon(Icons.schedule_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    "${period.startTime} - ${period.endTime}",
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
              Row(
                children: [
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
                  if (isFaculty) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                      tooltip: "Edit slot",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showEditPeriodModal(context, provider, period),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                      tooltip: "Remove slot",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        provider.deleteTimetablePeriod(period.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Period removed from today's timetable"), duration: Duration(seconds: 1)),
                        );
                      },
                    ),
                  ],
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
                      "Faculty Substitution: ${period.substituteReason ?? 'Leave'}. Regular: ${period.originalFacultyName}.",
                      style: const TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 3: Weekly Master Timetable
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildWeeklyMasterTab(BuildContext context, CampusProvider provider, bool isFaculty) {
    final days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isFaculty)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Master Timetable ERP", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    Text("Sync or upload semester schedules", style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showUploadTimetableModal(context, provider),
                  icon: const Icon(Icons.upload_file_rounded, size: 14, color: Colors.white),
                  label: const Text("Upload Timetable", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0),
                ),
              ],
            ),
          ),

        ...days.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
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
                index == 0 ? "5 Classes (Current Day Schedule)" : "5 Scheduled Lectures & Labs",
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
        }),
      ],
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

  // ──────────────────────────────────────────────────────────────────────────
  // Dialog: Faculty Go Live or Schedule Class (Jitsi / Meet / Zoom / Any Link)
  // ──────────────────────────────────────────────────────────────────────────
  void _showScheduleOrGoLiveDialog(BuildContext context, CampusProvider provider) {
    final titleController = TextEditingController(text: "Cloud Architecture & DevOps");
    final codeController = TextEditingController(text: "CS-603");
    final topicController = TextEditingController(text: "Kubernetes Cluster Auto-scaling & Ingress Controller");
    final roomController = TextEditingController(text: "LH-302 (Smart Studio)");
    MeetingPlatform selectedPlatform = MeetingPlatform.jitsi;
    final meetingUrlController = TextEditingController(
      text: "https://meet.jit.si/DigitalCampus_CS603_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          void updatePlatformUrl(MeetingPlatform p) {
            selectedPlatform = p;
            if (p == MeetingPlatform.jitsi) {
              meetingUrlController.text =
                  "https://meet.jit.si/DigitalCampus_${codeController.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
            } else if (p == MeetingPlatform.googleMeet) {
              meetingUrlController.text = "https://meet.google.com/dcs-live-lec";
            } else if (p == MeetingPlatform.zoom) {
              meetingUrlController.text = "https://zoom.us/j/84920194812";
            } else {
              meetingUrlController.text = "https://stream.digitalcampus.edu/live/session";
            }
            setModalState(() {});
          }

          return Container(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 18,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Row(
                    children: [
                      Icon(Icons.video_call_rounded, color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        "Host Live Class or Schedule",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Connect via Jitsi (Free Instant Room), Google Meet, Zoom or any custom meeting link.",
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),

                  const SizedBox(height: 16),

                  // Subject Title
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Subject Name",
                      prefixIcon: const Icon(Icons.menu_book_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: codeController,
                          decoration: InputDecoration(
                            labelText: "Subject Code",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: roomController,
                          decoration: InputDecoration(
                            labelText: "Studio / Room",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Topic
                  TextField(
                    controller: topicController,
                    decoration: InputDecoration(
                      labelText: "Lecture Topic",
                      prefixIcon: const Icon(Icons.topic_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Platform Selector
                  const Text("Select Meeting Platform:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MeetingPlatform.values.map((platform) {
                      final isSel = selectedPlatform == platform;
                      return ChoiceChip(
                        label: Text(platform.displayName),
                        selected: isSel,
                        onSelected: (_) => updatePlatformUrl(platform),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSel ? Colors.white : AppColors.textDark,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // Meeting URL Field
                  TextField(
                    controller: meetingUrlController,
                    decoration: InputDecoration(
                      labelText: "Meeting Link (Approved for Direct Launch)",
                      prefixIcon: const Icon(Icons.link_rounded, size: 18, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        onPressed: () => updatePlatformUrl(selectedPlatform),
                        tooltip: "Regenerate unique room link",
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Action Buttons: Go Live Now VS Schedule Later
                  Row(
                    children: [
                      // Schedule Later
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final newSession = LiveClassSession(
                              id: "LIVE-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                              title: titleController.text,
                              subjectCode: codeController.text,
                              instructorName: provider.currentProfile?.name ?? "Dr. Mohit Donawat",
                              topic: topicController.text,
                              room: roomController.text,
                              scheduledAt: DateTime.now().add(const Duration(hours: 1)),
                              durationText: "Starts in 1 hour",
                              status: LiveClassStatus.scheduled,
                              platform: selectedPlatform,
                              meetingUrl: meetingUrlController.text,
                            );
                            provider.scheduleLiveClass(newSession);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Live Lecture Scheduled! Notified all enrolled students."),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          icon: const Icon(Icons.schedule_rounded, size: 16),
                          label: const Text("Schedule Later"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Go Live Now
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final newSession = LiveClassSession(
                              id: "LIVE-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                              title: titleController.text,
                              subjectCode: codeController.text,
                              instructorName: provider.currentProfile?.name ?? "Dr. Mohit Donawat",
                              topic: topicController.text,
                              room: roomController.text,
                              scheduledAt: DateTime.now(),
                              durationText: "Live Stream Active",
                              status: LiveClassStatus.live,
                              platform: selectedPlatform,
                              meetingUrl: meetingUrlController.text,
                              attendeesCount: 1,
                            );
                            provider.scheduleLiveClass(newSession);
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InAppLiveClassroomScreen(
                                  session: newSession,
                                  isFaculty: true,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.sensors_rounded, size: 16, color: Colors.white),
                          label: const Text("Go Live Now", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
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
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Dialog: Add Timetable Slot Modal
  // ──────────────────────────────────────────────────────────────────────────
  void _showAddPeriodModal(BuildContext context, CampusProvider provider) {
    final subController = TextEditingController();
    final codeController = TextEditingController();
    final roomController = TextEditingController(text: "LH-302");
    final facController = TextEditingController(text: provider.currentProfile?.name ?? "Dr. Mohit Donawat");
    final startController = TextEditingController(text: "09:30 AM");
    final endController = TextEditingController(text: "10:30 AM");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text("Add Timetable Period", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subController,
                decoration: const InputDecoration(labelText: "Subject Name (e.g. Distributed Systems)", isDense: true),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: codeController,
                      decoration: const InputDecoration(labelText: "Subject Code", isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: roomController,
                      decoration: const InputDecoration(labelText: "Room / Lab", isDense: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: facController,
                decoration: const InputDecoration(labelText: "Faculty Name", isDense: true),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startController,
                      decoration: const InputDecoration(labelText: "Start Time", isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: endController,
                      decoration: const InputDecoration(labelText: "End Time", isDense: true),
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
              if (subController.text.isNotEmpty) {
                final newPeriod = TimetablePeriod(
                  id: "TT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                  day: "Today",
                  startTime: startController.text,
                  endTime: endController.text,
                  subjectName: subController.text,
                  subjectCode: codeController.text.isEmpty ? "CS-XXX" : codeController.text,
                  roomNumber: roomController.text,
                  facultyName: facController.text,
                );
                provider.addTimetablePeriod(newPeriod);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("New slot added to Timetable!"), backgroundColor: AppColors.success),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Save Slot", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Dialog: Edit Timetable Slot Modal (Faculty Only)
  // ──────────────────────────────────────────────────────────────────────────
  void _showEditPeriodModal(BuildContext context, CampusProvider provider, TimetablePeriod period) {
    final subController = TextEditingController(text: period.subjectName);
    final codeController = TextEditingController(text: period.subjectCode);
    final roomController = TextEditingController(text: period.roomNumber);
    final facController = TextEditingController(text: period.facultyName);
    final startController = TextEditingController(text: period.startTime);
    final endController = TextEditingController(text: period.endTime);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text("Edit Timetable Period", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subController,
                decoration: const InputDecoration(labelText: "Subject Name", isDense: true),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: codeController,
                      decoration: const InputDecoration(labelText: "Subject Code", isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: roomController,
                      decoration: const InputDecoration(labelText: "Room / Lab", isDense: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: facController,
                decoration: const InputDecoration(labelText: "Faculty Name", isDense: true),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startController,
                      decoration: const InputDecoration(labelText: "Start Time", isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: endController,
                      decoration: const InputDecoration(labelText: "End Time", isDense: true),
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
              if (subController.text.isNotEmpty) {
                final updated = TimetablePeriod(
                  id: period.id,
                  day: period.day,
                  startTime: startController.text,
                  endTime: endController.text,
                  subjectName: subController.text,
                  subjectCode: codeController.text,
                  roomNumber: roomController.text,
                  facultyName: facController.text,
                  isSubstitute: period.isSubstitute,
                  originalFacultyName: period.originalFacultyName,
                  substituteReason: period.substituteReason,
                );
                provider.updateTimetablePeriod(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Timetable period updated successfully!"), backgroundColor: AppColors.success),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Dialog: Upload / Parse Timetable
  // ──────────────────────────────────────────────────────────────────────────
  void _showUploadTimetableModal(BuildContext context, CampusProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.upload_file_rounded, color: AppColors.primary, size: 22),
                SizedBox(width: 8),
                Text("Upload & Auto-Parse Timetable", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              "Upload an image, PDF or CSV schedule. The sovereign ERP engine parses slots into active timetable records.",
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 18),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.table_chart_rounded, color: AppColors.primary),
              ),
              title: const Text("Load Department Master Template (CSE Sem 6)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              subtitle: const Text("Applies 5 official accredited syllabus slots with room allocations.", style: TextStyle(fontSize: 10.5)),
              onTap: () {
                provider.uploadTimetable(CampusDatabase.todayTimetable);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Official Master Timetable loaded successfully!"), backgroundColor: AppColors.success),
                );
              },
            ),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.description_rounded, color: Color(0xFF047857)),
              ),
              title: const Text("Upload Document / Spreadsheet File", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              subtitle: const Text("Parses CSV, Excel or AI OCR extracted class timetable.", style: TextStyle(fontSize: 10.5)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Timetable document parsed and synchronized with Academic Register!"),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Live Stream Player & Interactive Doubts Modal
  // ──────────────────────────────────────────────────────────────────────────
  void _showLiveClassModal(BuildContext context, LiveClassSession session, bool isFaculty) {
    final chatInputController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
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

              // Video Player Header with Direct Meeting Link
              Container(
                height: 210,
                width: double.infinity,
                color: const Color(0xFF0B1120),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.sensors_rounded, size: 36, color: Color(0xFF818CF8)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          session.status == LiveClassStatus.live
                              ? "Live Smart Class Stream Active"
                              : "Lecture Recording Archive",
                          style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Platform: ${session.platform.displayName}",
                          style: const TextStyle(color: Colors.white60, fontSize: 10.5),
                        ),
                        const SizedBox(height: 10),

                        // Direct Launch In-App Classroom & Dynamic QR Buttons
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InAppLiveClassroomScreen(
                                      session: session,
                                      isFaculty: isFaculty,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.fullscreen_rounded, size: 16, color: Colors.white),
                              label: const Text(
                                "Enter Live Studio",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                                DynamicAttendanceQrModal.show(
                                  context,
                                  subjectCode: session.subjectCode,
                                  subjectName: session.title,
                                  room: session.room,
                                  isFaculty: isFaculty,
                                );
                              },
                              icon: Icon(isFaculty ? Icons.qr_code_2_rounded : Icons.qr_code_scanner_rounded, size: 15, color: Colors.white),
                              label: Text(
                                isFaculty ? "Launch Dynamic QR" : "Scan Class QR",
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFaculty ? const Color(0xFF0D9488) : const Color(0xFF059669),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Positioned(
                      top: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: session.status == LiveClassStatus.live ? AppColors.error : const Color(0xFF059669),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          session.status == LiveClassStatus.live ? "🔴 LIVE STREAM" : "📹 RECORDING",
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Class Information Bar
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          const SizedBox(height: 1),
                          Text("Instructor: ${session.instructorName} • ${session.room}", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    if (isFaculty)
                      ElevatedButton.icon(
                        onPressed: () {
                          Provider.of<CampusProvider>(context, listen: false).endLiveClass(session.id);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Live Lecture ended and saved to History!"), backgroundColor: AppColors.success),
                          );
                        },
                        icon: const Icon(Icons.stop_circle_rounded, size: 14, color: Colors.white),
                        label: const Text("End Class", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, elevation: 0),
                      )
                    else
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

              // Live Class Q&A and Doubts Header
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 8, 14, 4),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text("LIVE CLASS CHAT & DOUBTS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
              ),

              // Chat Messages List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  itemCount: _liveChatMessages.length,
                  itemBuilder: (context, idx) {
                    final item = _liveChatMessages[idx];
                    return _chatBubble(item["sender"], item["message"], item["isFaculty"]);
                  },
                ),
              ),

              // Live Doubts Input Field
              Container(
                padding: EdgeInsets.only(
                  left: 14,
                  right: 14,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: chatInputController,
                        decoration: InputDecoration(
                          hintText: "Type doubt or message to class...",
                          hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: AppColors.surfaceSubtle,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 20),
                      onPressed: () {
                        if (chatInputController.text.trim().isNotEmpty) {
                          final text = chatInputController.text.trim();
                          setSheetState(() {
                            _liveChatMessages.add({
                              "sender": isFaculty ? "Prof. Mohit Donawat" : "Rahul Sharma (You)",
                              "message": text,
                              "isFaculty": isFaculty,
                              "time": "Just now",
                            });
                          });
                          chatInputController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
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
