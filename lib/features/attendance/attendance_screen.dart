import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_chip.dart';
import '../../models/campus_models.dart';
import '../../providers/campus_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Class-wise Filter State
  String _selectedBranch = "All";
  int _selectedSemester = 0; // 0 means All
  String _selectedSection = "All";
  String _statusFilter = "All"; // "All", "Defaulters", "Safe"

  final List<String> _branchOptions = ["All", "CSE", "IT", "ECE"];
  final List<int> _semesterOptions = [0, 4, 6, 8];
  final List<String> _sectionOptions = ["All", "Sec A", "Sec B"];
  final List<String> _statusOptions = ["All", "Defaulters (<75%)", "Safe (≥75%)"];

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
    final overall = provider.overallAttendance;

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
              "Attendance & Academic Radar",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            Text(
              "Class Filter • Faculty Register • AI Analytics",
              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          // AI Copilot Mode Toggle
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              provider.toggleAiCopilot();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.isAiCopilotEnabled ? "AI Copilot Active: Live attendance forecasting ON" : "AI Copilot Disabled"),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: provider.isAiCopilotEnabled ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: provider.isAiCopilotEnabled ? AppColors.primary : AppColors.borderLight,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 13,
                    color: provider.isAiCopilotEnabled ? AppColors.primary : AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    provider.isAiCopilotEnabled ? "AI Active" : "AI Off",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: provider.isAiCopilotEnabled ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
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
            Tab(icon: Icon(Icons.fact_check_rounded, size: 16), text: "Class Register"),
            Tab(icon: Icon(Icons.pie_chart_rounded, size: 16), text: "My Radar"),
            Tab(icon: Icon(Icons.psychology_rounded, size: 16), text: "AI Defaulters"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: Class-Wise Register with Filters ──
          _buildClassRegisterTab(context, provider),

          // ── Tab 2: Personal Student Radar ──
          _buildPersonalRadarTab(context, provider, overall),

          // ── Tab 3: AI Detention & Defaulter Analytics ──
          _buildAiDefaulterAnalyticsTab(context, provider),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 1: Class-Wise Register with Interactive Filters
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildClassRegisterTab(BuildContext context, CampusProvider provider) {
    // Filter the records based on active user filters
    final filtered = provider.classAttendanceRecords.where((s) {
      final matchBranch = _selectedBranch == "All" || s.branch == _selectedBranch;
      final matchSem = _selectedSemester == 0 || s.semester == _selectedSemester;
      final matchSec = _selectedSection == "All" || s.section == _selectedSection;

      bool matchStatus = true;
      if (_statusFilter == "Defaulters (<75%)") {
        matchStatus = s.attendancePercentage < 75.0;
      } else if (_statusFilter == "Safe (≥75%)") {
        matchStatus = s.attendancePercentage >= 75.0;
      }

      return matchBranch && matchSem && matchSec && matchStatus;
    }).toList();

    final presentCount = filtered.where((s) => s.isPresentToday).length;
    final totalCount = filtered.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips Container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
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
                    const Row(
                      children: [
                        Icon(Icons.filter_list_rounded, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          "SMART CLASS FILTERS",
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedBranch = "All";
                          _selectedSemester = 0;
                          _selectedSection = "All";
                          _statusFilter = "All";
                        });
                      },
                      child: const Text(
                        "Reset",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 1. Branch Selector
                Row(
                  children: [
                    const SizedBox(
                      width: 65,
                      child: Text("Branch:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        children: _branchOptions.map((b) {
                          final isSel = _selectedBranch == b;
                          return ChoiceChip(
                            label: Text(b, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isSel ? Colors.white : AppColors.textDark)),
                            selected: isSel,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surfaceSubtle,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            onSelected: (_) => setState(() => _selectedBranch = b),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // 2. Semester Selector
                Row(
                  children: [
                    const SizedBox(
                      width: 65,
                      child: Text("Sem:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        children: _semesterOptions.map((sem) {
                          final isSel = _selectedSemester == sem;
                          final label = sem == 0 ? "All" : "Sem $sem";
                          return ChoiceChip(
                            label: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isSel ? Colors.white : AppColors.textDark)),
                            selected: isSel,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surfaceSubtle,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            onSelected: (_) => setState(() => _selectedSemester = sem),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // 3. Status Filter (Defaulters)
                Row(
                  children: [
                    const SizedBox(
                      width: 65,
                      child: Text("Status:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        children: _statusOptions.map((st) {
                          final isSel = _statusFilter == st;
                          final isDefaulter = st.contains("Defaulters");
                          return ChoiceChip(
                            label: Text(
                              st,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : (isDefaulter ? AppColors.error : AppColors.textDark),
                              ),
                            ),
                            selected: isSel,
                            selectedColor: isDefaulter ? AppColors.error : AppColors.primary,
                            backgroundColor: AppColors.surfaceSubtle,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            onSelected: (_) => setState(() => _statusFilter = st),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Action Bar: Bulk Actions & Summary ─────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Showing $totalCount Enrolled Students",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  Text(
                    "$presentCount Present • ${totalCount - presentCount} Absent Today",
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      provider.bulkMarkAttendance(
                        branch: _selectedBranch,
                        semester: _selectedSemester,
                        section: _selectedSection,
                        isPresent: true,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("All filtered students marked PRESENT!"), backgroundColor: AppColors.success),
                      );
                    },
                    icon: const Icon(Icons.done_all_rounded, size: 14),
                    label: const Text("All Present", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Automated absentee SMS dispatched to registered parents!"), backgroundColor: AppColors.primary),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 13, color: AppColors.primary),
                    label: const Text("Alert SMS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Student Register List ──────────────────────────────────────────
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.person_off_rounded, size: 40, color: AppColors.textMuted),
                  SizedBox(height: 8),
                  Text("No students match the selected filter", style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                ],
              ),
            )
          else
            ...filtered.map((student) => _buildClassStudentTile(context, provider, student)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildClassStudentTile(BuildContext context, CampusProvider provider, StudentAttendanceRecord student) {
    final isDefaulter = student.attendancePercentage < 75.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDefaulter ? AppColors.error.withOpacity(0.3) : AppColors.borderLight,
          width: isDefaulter ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: isDefaulter ? AppColors.errorLight : AppColors.primary.withOpacity(0.1),
            child: Text(
              student.name[0],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDefaulter ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        student.name,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isDefaulter ? AppColors.errorLight : AppColors.successLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isDefaulter ? "DEFAULTER" : "SAFE",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: isDefaulter ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "${student.rollNumber} • ${student.branch} Sem ${student.semester} (${student.section})",
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "${student.attendancePercentage}%",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDefaulter ? AppColors.error : AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "(${student.attendedClasses}/${student.totalClasses} lectures)",
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Interactive Attendance Toggle Button
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              provider.toggleStudentAttendance(student.studentId);
            },
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: student.isPresentToday ? AppColors.success : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: student.isPresentToday ? AppColors.success : AppColors.error,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    student.isPresentToday ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 14,
                    color: student.isPresentToday ? Colors.white : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    student.isPresentToday ? "Present" : "Absent",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: student.isPresentToday ? Colors.white : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 2: Personal Student Radar
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPersonalRadarTab(BuildContext context, CampusProvider provider, double overall) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cumulative Meter Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Cumulative Attendance Meter",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    CustomChip(
                      label: overall >= 75 ? "EXAM ELIGIBLE" : "DETENTION RISK",
                      color: overall >= 75 ? AppColors.success : AppColors.error,
                      isSolid: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: overall / 100,
                        strokeWidth: 12,
                        backgroundColor: AppColors.surfaceSubtle,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          overall >= 75 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${overall.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: overall >= 75 ? AppColors.textDark : AppColors.error,
                            letterSpacing: -1,
                          ),
                        ),
                        const Text(
                          "Overall Presence",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: overall >= 75 ? AppColors.successLight : AppColors.errorLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    overall >= 75
                        ? "✓ Safely above the 75% RGPV & AICTE criteria for exam hall ticket release."
                        : "⚠ Warning: Attendance below 75%. Detention risk flagged by Dean Academics.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: overall >= 75 ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Subject-Wise Breakdown
          const Text(
            "SUBJECT-WISE RADAR & ATTENDANCE MATH",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),

          ...provider.attendance.map((subject) {
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              borderColor: subject.isSafe ? AppColors.borderLight : AppColors.error.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject.subjectName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${subject.subjectCode} • ${subject.facultyName}",
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${subject.percentage.toStringAsFixed(1)}%",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: subject.isSafe ? AppColors.success : AppColors.error,
                            ),
                          ),
                          Text(
                            "${subject.attendedClasses}/${subject.totalClasses} classes",
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: subject.percentage / 100,
                    backgroundColor: AppColors.surfaceSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      subject.isSafe ? AppColors.success : AppColors.error,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 12),

                  // Smart Attendance Math Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: subject.isSafe ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: subject.isSafe ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          subject.isSafe ? Icons.beach_access_rounded : Icons.priority_high_rounded,
                          size: 15,
                          color: subject.isSafe ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            subject.isSafe
                                ? "Safe Bunks: You can safely miss ${subject.safeBunksPossible} more lecture(s) without falling below 75%."
                                : "Action Required: You must attend ${subject.classesNeededFor75} consecutive class(es) to reach 75%.",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: subject.isSafe ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 3: AI Detention & Defaulter Analytics
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildAiDefaulterAnalyticsTab(BuildContext context, CampusProvider provider) {
    final defaulters = provider.classAttendanceRecords.where((s) => s.attendancePercentage < 75.0).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Detention Engine Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      "AI Predictive Attendance Intervention",
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Deep learning models predict exam disqualification 3 weeks before finals. Early SMS and mentor counseling triggers prevent semester dropouts.",
                  style: TextStyle(fontSize: 11.5, color: Colors.white70, height: 1.35),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${defaulters.length} Defaulters Flagged",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "94% Recovery Success Rate",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "CRITICAL DEFAULTER ROSTER & PARENT OUTREACH",
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),

          ...defaulters.map((s) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      Text(
                        "${s.attendancePercentage}%",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text("Roll: ${s.rollNumber} • ${s.branch} Sem ${s.semester} (${s.section})", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Needs to attend ${((0.75 * s.totalClasses - s.attendedClasses) / (1 - 0.75)).ceil()} consecutive classes to qualify for Hall Ticket release.",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF991B1B)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Defaulter warning WhatsApp sent to parent of ${s.name}!"), backgroundColor: AppColors.success),
                            );
                          },
                          icon: const Icon(Icons.chat_rounded, size: 14, color: AppColors.success),
                          label: const Text("WhatsApp Parent", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.success),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Compensatory lab schedule allotted for ${s.name}!"), backgroundColor: AppColors.primary),
                            );
                          },
                          icon: const Icon(Icons.schedule_rounded, size: 14),
                          label: const Text("Compensate", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
