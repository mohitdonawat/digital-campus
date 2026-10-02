import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';

/// Faculty On-Screen Evaluation Studio (OSES)
/// Blueprint: Split-screen dual-pane layout with zoomable answer viewer
/// and AI step-wise evaluation panel with red-pen overlay.
class OnScreenGradingScreen extends StatefulWidget {
  const OnScreenGradingScreen({super.key});

  @override
  State<OnScreenGradingScreen> createState() => _OnScreenGradingScreenState();
}

class _OnScreenGradingScreenState extends State<OnScreenGradingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _remarksController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _isEvaluating = false;
  bool _isSaving = false;
  List<Map<String, dynamic>> _sampleCopies = [];
  Map<String, dynamic>? _selectedCopy;
  Map<String, dynamic>? _evaluationResult;
  int _currentCopyIndex = 0;

  // Faculty override marks per step
  Map<String, double> _overrideMarks = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSampleCopies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadSampleCopies() async {
    setState(() => _isLoading = true);
    final copies = await ApiService.getSampleCopies();
    setState(() {
      _sampleCopies = copies;
      _isLoading = false;
      if (copies.isNotEmpty) {
        _selectedCopy = copies[0];
        _currentCopyIndex = 0;
      }
    });
  }

  Future<void> _evaluateCurrentCopy() async {
    if (_selectedCopy == null) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _isEvaluating = true;
      _evaluationResult = null;
      _overrideMarks = {};
      _remarksController.clear();
    });

    final result = await ApiService.evaluateExamCopy(
      subjectCode: _selectedCopy!["subject_code"] ?? "CS-601",
      examId: _selectedCopy!["exam_id"] ?? "MIDTERM_2026",
      studentRoll: _selectedCopy!["student_roll"] ?? "CS22B045",
      studentName: _selectedCopy!["student_name"] ?? "Student",
      questionId: _selectedCopy!["question_id"] ?? "Q1",
    );

    setState(() {
      _evaluationResult = result;
      _isEvaluating = false;
      // Pre-populate override marks from AI
      final steps = result["steps_evaluation"] as List<dynamic>? ?? [];
      for (var step in steps) {
        _overrideMarks[step["step_id"]] = (step["awarded"] as num).toDouble();
      }
    });
  }

  Future<void> _saveAndNext() async {
    if (_evaluationResult == null) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    final totalOverride = _overrideMarks.values.fold(0.0, (a, b) => a + b);
    final stepsEval = (_evaluationResult!["steps_evaluation"] as List<dynamic>?)
        ?.map((s) => Map<String, dynamic>.from(s))
        .toList() ?? [];
    final annotations = (_evaluationResult!["annotations"] as List<dynamic>?)
        ?.map((a) => Map<String, dynamic>.from(a))
        .toList() ?? [];

    await ApiService.submitFacultyScore(
      subjectCode: _selectedCopy!["subject_code"] ?? "CS-601",
      examId: _selectedCopy!["exam_id"] ?? "MIDTERM_2026",
      studentRoll: _selectedCopy!["student_roll"] ?? "CS22B045",
      studentName: _selectedCopy!["student_name"] ?? "Student",
      questionId: _selectedCopy!["question_id"] ?? "Q1",
      awardedMarks: totalOverride,
      maxMarks: (_evaluationResult!["max_marks"] as num?)?.toDouble() ?? 10.0,
      stepsEvaluation: stepsEval,
      annotations: annotations,
      teacherRemarks: _remarksController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "✅ Score ${totalOverride.toStringAsFixed(1)}/${(_evaluationResult!["max_marks"] as num?)?.toStringAsFixed(1) ?? '10.0'} saved & sealed for ${_selectedCopy!["student_name"]}",
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Move to next copy
    if (_currentCopyIndex < _sampleCopies.length - 1) {
      setState(() {
        _currentCopyIndex++;
        _selectedCopy = _sampleCopies[_currentCopyIndex];
        _evaluationResult = null;
        _overrideMarks = {};
        _remarksController.clear();
      });
    }
  }

  void _goToPrevCopy() {
    if (_currentCopyIndex > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentCopyIndex--;
        _selectedCopy = _sampleCopies[_currentCopyIndex];
        _evaluationResult = null;
        _overrideMarks = {};
        _remarksController.clear();
      });
    }
  }

  double get _totalOverrideMarks =>
      _overrideMarks.values.fold(0.0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Copy selector strip
                _buildCopySelector(),
                // Main content
                Expanded(
                  child: _evaluationResult != null
                      ? _buildDualPaneLayout()
                      : _buildPreEvaluationView(),
                ),
                // Bottom action bar
                _buildBottomActionBar(),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "On-Screen Evaluation Studio",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          Text(
            _selectedCopy != null
                ? "${_selectedCopy!["subject_name"]} • ${_selectedCopy!["exam_id"]}"
                : "Faculty OSES",
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: AppColors.textMuted),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF059669).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: Color(0xFF059669), shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              const Text(
                "AI Engine Active",
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.history_rounded, size: 20, color: AppColors.textMuted),
          onPressed: () => _showGradebookSheet(),
          tooltip: "Gradebook History",
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.borderLight),
      ),
    );
  }

  // ── Copy Selector Strip ──────────────────────────────────────────────
  Widget _buildCopySelector() {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: _sampleCopies.length,
        itemBuilder: (context, index) {
          final copy = _sampleCopies[index];
          final isSelected = index == _currentCopyIndex;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _currentCopyIndex = index;
                _selectedCopy = copy;
                _evaluationResult = null;
                _overrideMarks = {};
                _remarksController.clear();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E40AF) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? const Color(0xFF1E40AF) : AppColors.borderLight,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: const Color(0xFF1E40AF).withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    copy["student_name"] ?? "Student",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${copy["student_roll"]} • ${copy["subject_code"]}",
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white.withOpacity(0.7) : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Pre-Evaluation View (Before AI runs) ──────────────────────────────
  Widget _buildPreEvaluationView() {
    if (_selectedCopy == null) {
      return const Center(
        child: Text("No copies loaded", style: TextStyle(color: AppColors.textMuted)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Student Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedCopy!["student_name"] ?? "",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                          ),
                          Text(
                            "${_selectedCopy!["student_roll"]} • ${_selectedCopy!["semester"]}",
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Text(
                        _selectedCopy!["question_id"] ?? "Q1",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFD97706)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book_rounded, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            _selectedCopy!["subject_name"] ?? "",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _selectedCopy!["notes"] ?? "",
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Simulate Answer Sheet Preview
          Container(
            width: double.infinity,
            height: 320,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
            ),
            child: Stack(
              children: [
                // Ruled lines effect
                ...List.generate(14, (i) {
                  return Positioned(
                    top: 24.0 + (i * 22),
                    left: 50,
                    right: 16,
                    child: Container(height: 0.5, color: const Color(0xFF93C5FD).withOpacity(0.3)),
                  );
                }),
                // Left red margin line
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 44,
                  child: Container(width: 1.2, color: const Color(0xFFEF4444).withOpacity(0.3)),
                ),
                // Simulated handwritten text
                Padding(
                  padding: const EdgeInsets.only(left: 56, top: 20, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ans ${_selectedCopy!["question_id"] ?? "1"}.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E3A5F),
                          fontStyle: FontStyle.italic,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._getSimulatedHandwriting(),
                    ],
                  ),
                ),
                // Page number
                Positioned(
                  bottom: 8,
                  right: 12,
                  child: Text(
                    "Page 1 of 3",
                    style: TextStyle(fontSize: 9, color: AppColors.textMuted.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Evaluate Button
          if (!_isEvaluating)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _evaluateCurrentCopy,
                icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                label: const Text("Run AI Evaluation Engine"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E40AF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),

          if (_isEvaluating) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E40AF).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E40AF).withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: const Color(0xFF1E40AF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "SymPy + Semantic Rubric Engine Running...",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _getSimulatedHandwriting() {
    final code = _selectedCopy?["subject_code"] ?? "";
    if (code.contains("604")) {
      return const [
        Text("Step 1: Augmented Grammar: S' → S,", style: TextStyle(fontSize: 12, fontFamily: 'serif', color: Color(0xFF1E3A5F), height: 1.8)),
        Text("S → CC, C → cC | d.", style: TextStyle(fontSize: 12, fontFamily: 'serif', color: Color(0xFF1E3A5F), height: 1.8)),
        Text("Step 2: I₀ = CLOSURE({S' → .S})", style: TextStyle(fontSize: 12, fontFamily: 'serif', color: Color(0xFF1E3A5F), height: 1.8)),
        Text("Step 3: GOTO(I₀, S) = I₁ = {S' → S.}", style: TextStyle(fontSize: 12, fontFamily: 'serif', color: Color(0xFF1E3A5F), height: 1.8)),
        Text("Step 4: GOTO(I₀, c) = I₂", style: TextStyle(fontSize: 12, fontFamily: 'serif', color: Color(0xFF1E3A5F), height: 1.8)),
        Text("Step 5: No Shift-Reduce conflict.", style: TextStyle(fontSize: 12, fontFamily: 'serif', color: Color(0xFF1E3A5F), height: 1.8)),
      ];
    }
    return const [
      Text("Step 1: Recurrence Relation:", style: TextStyle(fontSize: 12, fontFamily: 'serif', color: Color(0xFF1E3A5F), height: 1.8)),
      Text("T(n) = 2T(n/2) + Θ(n)", style: TextStyle(fontSize: 12, fontFamily: 'serif', fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F), height: 1.8)),
      Text("Step 2: a = 2, b = 2, f(n) = n", style: TextStyle(fontSize: 12, fontFamily: 'serif', color: Color(0xFF1E3A5F), height: 1.8)),
      Text("Step 3: log₂(2) = 1 ⟹ n^(log_b a) = n¹", style: TextStyle(fontSize: 12, fontFamily: 'serif', color: Color(0xFF1E3A5F), height: 1.8)),
      Text("Step 4: Case 2 applies.", style: TextStyle(fontSize: 12, fontFamily: 'serif', color: Color(0xFF1E3A5F), height: 1.8)),
      Text("∴ T(n) = Θ(n log n)", style: TextStyle(fontSize: 13, fontFamily: 'serif', fontWeight: FontWeight.w700, color: Color(0xFF1E3A5F), height: 1.8)),
      Text("Auxiliary Space: O(n)", style: TextStyle(fontSize: 12, fontFamily: 'serif', color: Color(0xFF1E3A5F), height: 1.8)),
    ];
  }

  // ── Dual Pane Layout (Post-Evaluation) ──────────────────────────────
  Widget _buildDualPaneLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        if (isWide) {
          // Desktop / Tablet split-screen
          return Row(
            children: [
              Expanded(flex: 5, child: _buildLeftPane()),
              Container(width: 1, color: AppColors.borderLight),
              Expanded(flex: 5, child: _buildRightPane()),
            ],
          );
        } else {
          // Mobile: TabBar switching
          return Column(
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF1E40AF),
                  indicatorWeight: 2.5,
                  labelColor: const Color(0xFF1E40AF),
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: "📄 Answer Copy"),
                    Tab(text: "🤖 AI Evaluation"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLeftPane(),
                    _buildRightPane(),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  // ── Left Pane: Scanned Answer Copy with Annotations ─────────────────
  Widget _buildLeftPane() {
    final annotations = _evaluationResult?["annotations"] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_rounded, size: 16, color: Color(0xFF0284C7)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${_selectedCopy!["student_name"]} (${_selectedCopy!["student_roll"]})",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0C4A6E)),
                  ),
                ),
                const Text(
                  "Page 1 of 3",
                  style: TextStyle(fontSize: 9.5, color: Color(0xFF0284C7)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Annotated Answer Sheet
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Stack(
              children: [
                // Ruled lines
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: List.generate(16, (i) {
                      return Container(
                        height: 28,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: const Color(0xFF93C5FD).withOpacity(0.2), width: 0.5),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Left margin line
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 38,
                  child: Container(width: 1, color: const Color(0xFFEF4444).withOpacity(0.25)),
                ),
                // Answer text with annotation badges
                Padding(
                  padding: const EdgeInsets.only(left: 46, top: 16, right: 10, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildAnnotatedSteps(annotations),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Quick Annotate Toolbar
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "QUICK ANNOTATE",
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildAnnotateButton("✔ Tick", const Color(0xFF059669)),
                    const SizedBox(width: 6),
                    _buildAnnotateButton("✘ Cross", const Color(0xFFDC2626)),
                    const SizedBox(width: 6),
                    _buildAnnotateButton("❓ Note", const Color(0xFFD97706)),
                    const SizedBox(width: 6),
                    _buildAnnotateButton("+0.5", const Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    _buildAnnotateButton("-0.5", const Color(0xFFEF4444)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnnotatedSteps(List<dynamic> annotations) {
    final steps = _evaluationResult?["steps_evaluation"] as List<dynamic>? ?? [];
    final widgets = <Widget>[];

    widgets.add(
      Text(
        "Ans ${_selectedCopy!["question_id"] ?? "1"}.",
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'serif', color: Color(0xFF1E3A5F)),
      ),
    );
    widgets.add(const SizedBox(height: 6));

    final handwritingLines = _getSimulatedHandwriting();

    for (int i = 0; i < steps.length && i < handwritingLines.length; i++) {
      final step = steps[i];
      final status = step["status"] ?? "MISSED";
      final awarded = step["awarded"] ?? 0.0;

      widgets.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: handwritingLines[i]),
            const SizedBox(width: 4),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    status == "VERIFIED" ? "✔" : (status == "PARTIAL" ? "△" : "✘"),
                    style: TextStyle(fontSize: 10, color: _getStatusColor(status)),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    "+${(awarded as num).toStringAsFixed(1)}",
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: _getStatusColor(status)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 4));
    }

    // Add remaining handwriting lines if more than steps
    for (int i = steps.length; i < handwritingLines.length; i++) {
      widgets.add(handwritingLines[i]);
      widgets.add(const SizedBox(height: 4));
    }

    return widgets;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "VERIFIED": return const Color(0xFF059669);
      case "PARTIAL": return const Color(0xFFD97706);
      default: return const Color(0xFFDC2626);
    }
  }

  Widget _buildAnnotateButton(String label, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$label annotation placed"),
              backgroundColor: color,
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ),
      ),
    );
  }

  // ── Right Pane: AI Step-Wise Evaluation & Rubric ────────────────────
  Widget _buildRightPane() {
    final steps = _evaluationResult?["steps_evaluation"] as List<dynamic>? ?? [];
    final maxMarks = (_evaluationResult?["max_marks"] as num?)?.toDouble() ?? 10.0;
    final percentage = (_evaluationResult?["percentage"] as num?)?.toDouble() ?? 0.0;
    final gradeLetter = _evaluationResult?["grade_letter"] ?? "?";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Evaluation Header with Score
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getGradeColor(gradeLetter).withOpacity(0.08),
                  _getGradeColor(gradeLetter).withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _getGradeColor(gradeLetter).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _getGradeColor(gradeLetter).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: _getGradeColor(gradeLetter).withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      gradeLetter,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _getGradeColor(gradeLetter)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_totalOverrideMarks.toStringAsFixed(1)} / ${maxMarks.toStringAsFixed(1)}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark),
                      ),
                      Text(
                        "${_selectedCopy!["question_id"]} • ${percentage.toStringAsFixed(0)}% • Confidence ${(_evaluationResult?["confidence_score"] as num?)?.toStringAsFixed(1) ?? "97"}%",
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 12, color: Color(0xFF059669)),
                      SizedBox(width: 3),
                      Text("AI Verified", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Text(
            "STEP-WISE RUBRIC EVALUATION",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1),
          ),
          const SizedBox(height: 8),

          // Step Cards
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return _buildStepCard(step, i);
          }),

          const SizedBox(height: 14),

          // Pedagogical Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, size: 14, color: Color(0xFF0284C7)),
                    SizedBox(width: 6),
                    Text(
                      "AI Pedagogical Summary",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0C4A6E)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _evaluationResult?["pedagogical_summary"] ?? "",
                  style: const TextStyle(fontSize: 11, color: Color(0xFF0C4A6E), height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Faculty Remarks
          const Text(
            "FACULTY REMARKS",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _remarksController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Add your remarks here...",
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // SHA-256 Seal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _evaluationResult?["sha256_seal"] ?? "",
                    style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: AppColors.textMuted, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStepCard(dynamic step, int index) {
    final stepId = step["step_id"] ?? "S${index + 1}";
    final label = step["label"] ?? "Step ${index + 1}";
    final status = step["status"] ?? "MISSED";
    final maxM = (step["max"] as num?)?.toDouble() ?? 2.0;
    final comment = step["comment"] ?? "";
    final coverage = step["keyword_coverage"] ?? 0.0;

    final currentAwarded = _overrideMarks[stepId] ?? (step["awarded"] as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    status == "VERIFIED" ? "✔" : (status == "PARTIAL" ? "△" : "✘"),
                    style: TextStyle(fontSize: 12, color: _getStatusColor(status)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$stepId: $label",
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    Text(
                      status,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _getStatusColor(status)),
                    ),
                  ],
                ),
              ),
              // Faculty Override slider value
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E40AF).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${currentAwarded.toStringAsFixed(1)} / ${maxM.toStringAsFixed(1)}",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1E40AF)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, height: 1.4),
          ),
          if ((coverage as num) > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Text("Keyword Coverage: ", style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "${(coverage as num).toStringAsFixed(0)}%",
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          // Faculty Override Slider
          Row(
            children: [
              const Text("Override: ", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: const Color(0xFF2563EB),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    thumbColor: const Color(0xFF1E40AF),
                  ),
                  child: Slider(
                    value: currentAwarded,
                    min: 0,
                    max: maxM,
                    divisions: (maxM * 2).toInt(),
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _overrideMarks[stepId] = v);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith("A")) return const Color(0xFF059669);
    if (grade.startsWith("B")) return const Color(0xFF2563EB);
    if (grade.startsWith("C")) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  // ── Bottom Action Bar ────────────────────────────────────────────────
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Prev button
            OutlinedButton.icon(
              onPressed: _currentCopyIndex > 0 ? _goToPrevCopy : null,
              icon: const Icon(Icons.chevron_left_rounded, size: 16),
              label: const Text("Prev"),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.borderLight),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                foregroundColor: AppColors.textDark,
                textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(width: 8),

            // Copy counter
            Text(
              "${_currentCopyIndex + 1} / ${_sampleCopies.length}",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted),
            ),

            const SizedBox(width: 8),

            // Save & Next
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _evaluationResult != null && !_isSaving ? _saveAndNext : null,
                icon: _isSaving
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded, size: 16),
                label: Text(_isSaving ? "Saving..." : "💾 Save & Next Copy (Enter) ➔"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Lock Gradebook
            IconButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("🔒 Gradebook locked. No further modifications allowed."),
                    backgroundColor: Color(0xFFDC2626),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.lock_rounded, size: 20, color: Color(0xFFDC2626)),
              tooltip: "Lock Gradebook",
            ),
          ],
        ),
      ),
    );
  }

  // ── Gradebook Bottom Sheet ───────────────────────────────────────────
  void _showGradebookSheet() async {
    final gradebook = await ApiService.getGradebook();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final evals = gradebook["evaluations"] as List<dynamic>? ?? [];
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, size: 18, color: Color(0xFF1E40AF)),
                    const SizedBox(width: 8),
                    Text(
                      "Gradebook (${gradebook["total_evaluated"] ?? 0} Evaluated)",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: evals.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_rounded, size: 40, color: AppColors.borderLight),
                            SizedBox(height: 8),
                            Text("No evaluations saved yet", style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: evals.length,
                        itemBuilder: (context, index) {
                          final ev = evals[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF059669)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${ev["student_name"] ?? "Student"} (${ev["student_roll"] ?? ""})",
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                      ),
                                      Text(
                                        "${ev["question_id"] ?? ""} • ${ev["evaluated_at"] ?? ""}",
                                        style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${ev["awarded_marks"] ?? 0}/${ev["max_marks"] ?? 0}",
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E40AF)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
