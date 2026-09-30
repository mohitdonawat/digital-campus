import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
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
    final role = provider.currentRole;
    final isFacultyOrAdmin = role == UserRole.faculty || role == UserRole.admin;

    // ── STRICT ROLE ISOLATION: Students & Parents get Personal Radar ONLY ──
    if (!isFacultyOrAdmin) {
      return _buildStudentPersonalAttendanceView(context, provider, overall, role);
    }

    // ── Faculty & Admin get the full Attendance Suite & Class Register ──
    return _buildFacultyAttendanceSuiteView(context, provider, overall);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Student & Parent View: Strict Personal Attendance Radar (No Faculty Controls)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildStudentPersonalAttendanceView(
      BuildContext context, CampusProvider provider, double overall, UserRole role) {
    final isParent = role == UserRole.parent;
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
            Text(
              isParent ? "Ward's Attendance Radar" : "My Attendance Radar",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            Text(
              isParent
                  ? "Real-time Ward Attendance • Subject Attendance Math"
                  : "Personal Presence • Subject Breakdown • Safe Bunk Math",
              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: overall >= 75 ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: overall >= 75 ? AppColors.success : AppColors.error,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  overall >= 75 ? Icons.verified_rounded : Icons.warning_amber_rounded,
                  size: 13,
                  color: overall >= 75 ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  overall >= 75 ? "Safe Eligible" : "Detention Risk",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: overall >= 75 ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildPersonalRadarTab(context, provider, overall),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Faculty & Admin View: Full Attendance Suite & Class Register
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildFacultyAttendanceSuiteView(
      BuildContext context, CampusProvider provider, double overall) {
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
              "Faculty Attendance Suite",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            Text(
              "Class Register • Faculty Marking • AI Defaulters",
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
                  content: Text(provider.isAiCopilotEnabled
                      ? "AI Copilot Active: Live attendance forecasting ON"
                      : "AI Copilot Disabled"),
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
            Tab(icon: Icon(Icons.psychology_rounded, size: 16), text: "AI Defaulters"),
            Tab(icon: Icon(Icons.pie_chart_rounded, size: 16), text: "Class Radar"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: Class-Wise Register with Filters ──
          _buildClassRegisterTab(context, provider),

          // ── Tab 2: AI Detention & Defaulter Analytics ──
          _buildAiDefaulterAnalyticsTab(context, provider),

          // ── Tab 3: All-Over Class Attendance & Performance Radar ──
          _buildFacultyAllOverClassRadarTab(context, provider),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Left interactive area opens Student All-Over Dossier
            Expanded(
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showStudentAllOverDossier(context, provider, student);
                },
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
                              const SizedBox(width: 6),
                              const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

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
      ),
    );
  }

  // ── Modal: Comprehensive Student Academic & Attendance Dossier ───────────
  void _showStudentAllOverDossier(BuildContext context, CampusProvider provider, StudentAttendanceRecord student) {
    final isDefaulter = student.attendancePercentage < 75.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),

              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: isDefaulter ? AppColors.errorLight : AppColors.primary.withOpacity(0.1),
                    child: Text(
                      student.name[0],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isDefaulter ? AppColors.error : AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        Text("${student.rollNumber} • ${student.branch} Sem ${student.semester} (${student.section})", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vitals Grid (Attendance, Total Classes, CGPA, Registration)
                      Row(
                        children: [
                          Expanded(
                            child: _buildDossierMetricTile(
                              "Overall Attendance",
                              "${student.attendancePercentage}%",
                              isDefaulter ? AppColors.error : AppColors.success,
                              subtitle: isDefaulter ? "DETENTION RISK" : "COMPLIANT",
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDossierMetricTile(
                              "Lectures Attended",
                              "${student.attendedClasses}/${student.totalClasses}",
                              const Color(0xFF2563EB),
                              subtitle: "${student.totalClasses - student.attendedClasses} Missed",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDossierMetricTile(
                              "Current CGPA",
                              "${student.cgpa}",
                              const Color(0xFF7C3AED),
                              subtitle: "University Rank Standing",
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDossierMetricTile(
                              "Sem Registration",
                              student.registrationStatus,
                              student.registrationStatus == "Approved" ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                              subtitle: "Semester 6 Status",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Safe Bunk / Attendance Recovery Math
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDefaulter ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDefaulter ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isDefaulter ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                              color: isDefaulter ? AppColors.error : AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isDefaulter
                                    ? "Student is below the mandatory 75% threshold! Requires attending the next 12 consecutive lectures to become eligible for university exams."
                                    : "Student is safely above 75%. Can miss up to 8 more lectures without dropping into the detention zone.",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDefaulter ? const Color(0xFF991B1B) : const Color(0xFF166534),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // All-Over Subject-by-Subject Attendance
                      const Text(
                        "SUBJECT-WISE ALL-OVER ATTENDANCE RECORD",
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: 0.4),
                      ),
                      const SizedBox(height: 8),
                      ...student.subjectAttendance.entries.map((entry) {
                        final subPercent = entry.value;
                        final subDefaulter = subPercent < 75.0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                  ),
                                  Text(
                                    "$subPercent%",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: subDefaulter ? AppColors.error : AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: subPercent / 100,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    subDefaulter ? AppColors.error : AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 14),

                      // Parent Contact Information & Action
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Parent / Guardian Contact:", style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                                const SizedBox(height: 2),
                                Text(student.parentPhone, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                HapticFeedback.mediumImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("SMS & WhatsApp attendance dispatch sent to ${student.name}'s parent!"),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.send_rounded, size: 13),
                              label: const Text("Dispatch Alert", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Bottom Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    provider.toggleStudentAttendance(student.studentId);
                    Navigator.pop(ctx);
                  },
                  icon: Icon(student.isPresentToday ? Icons.cancel_rounded : Icons.check_circle_rounded, size: 16),
                  label: Text(
                    student.isPresentToday ? "Mark ABSENT for Today" : "Mark PRESENT for Today",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: student.isPresentToday ? AppColors.error : AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDossierMetricTile(String label, String value, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
          ],
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 3 for Faculty: All-Over Student Performance & Class Radar
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildFacultyAllOverClassRadarTab(BuildContext context, CampusProvider provider) {
    final allStudents = provider.classAttendanceRecords;
    final totalStudents = allStudents.length;
    final compliantStudents = allStudents.where((s) => s.attendancePercentage >= 75.0).length;
    final defaultersCount = totalStudents - compliantStudents;
    final avgAttendance = totalStudents == 0
        ? 0.0
        : (allStudents.fold<double>(0.0, (acc, s) => acc + s.attendancePercentage) / totalStudents);

    // Sort by attendance percentage descending
    final sorted = List<StudentAttendanceRecord>.from(allStudents)
      ..sort((a, b) => b.attendancePercentage.compareTo(a.attendancePercentage));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "CLASS ALL-OVER ATTENDANCE RADAR",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                    ),
                    Icon(Icons.pie_chart_rounded, color: Colors.white, size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Batch Average", style: TextStyle(fontSize: 10.5, color: Colors.white70)),
                        Text("${avgAttendance.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Safe (≥75%)", style: TextStyle(fontSize: 10.5, color: Colors.white70)),
                        Text("$compliantStudents Students", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF86EFAC))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Defaulters (<75%)", style: TextStyle(fontSize: 10.5, color: Colors.white70)),
                        Text("$defaultersCount Flagged", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFFCA5A5))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "COMPLETE STUDENT ALL-OVER ROSTER",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: 0.4),
              ),
              Text(
                "Tap row for full subject dossier",
                style: TextStyle(fontSize: 10.5, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // All-Over Roster List
          ...sorted.asMap().entries.map((item) {
            final rank = item.key + 1;
            final s = item.value;
            final isDef = s.attendancePercentage < 75.0;

            return InkWell(
              onTap: () => _showStudentAllOverDossier(context, provider, s),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDef ? AppColors.error.withOpacity(0.3) : AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: rank <= 3 ? const Color(0xFFFEF3C7) : AppColors.surfaceSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "#$rank",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: rank <= 3 ? const Color(0xFFD97706) : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isDef ? AppColors.errorLight : AppColors.successLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isDef ? "DEFAULTER" : "SAFE",
                                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: isDef ? AppColors.error : AppColors.success),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text("${s.rollNumber} • CGPA: ${s.cgpa} • Reg: ${s.registrationStatus}", style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${s.attendancePercentage}%",
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: isDef ? AppColors.error : AppColors.success),
                        ),
                        Text("${s.attendedClasses}/${s.totalClasses} classes", style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
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
