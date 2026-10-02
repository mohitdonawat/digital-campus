import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/quiz_models.dart';
import '../../providers/campus_provider.dart';
import '../../core/services/textbook_quiz_repository.dart';
import 'quiz_leaderboard_screen.dart';

/// 👨‍🏫 Teacher Adaptive Bloom's Quiz Studio
/// Allows faculty to configure targeted academic quizzes (Branch, Year, Semester),
/// set scoring rules (2/4 options, marks, negative marking, timer),
/// pull questions from local Textbook RAG (Goodfellow, Galvin, Kurose, Dragon Book),
/// and monitor class performance and live leaderboards.
class TeacherQuizStudioScreen extends StatefulWidget {
  const TeacherQuizStudioScreen({super.key});

  @override
  State<TeacherQuizStudioScreen> createState() => _TeacherQuizStudioScreenState();
}

class _TeacherQuizStudioScreenState extends State<TeacherQuizStudioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form Controllers for Quiz Creation
  final _titleController = TextEditingController(text: "Unit 3 Assessment: Deep Neural Optimization");
  final _subjectCodeController = TextEditingController(text: "CS-601");
  final _subjectNameController = TextEditingController(text: "Machine Learning & AI");
  final _durationController = TextEditingController(text: "15");
  final _marksPerQuestionController = TextEditingController(text: "4.0");
  final _negativePenaltyController = TextEditingController(text: "1.0");

  String _selectedBranch = "CSE";
  int _selectedSemester = 6;
  int _selectedYear = 3;
  bool _hasNegativeMarking = true;

  // Staged Questions for new quiz
  final List<QuizQuestion> _stagedQuestions = [];

  final List<String> _branches = ["CSE", "IT", "ECE", "ME", "Civil", "AI-DS", "All"];
  final List<int> _semesters = [1, 2, 3, 4, 5, 6, 7, 8];
  final List<int> _years = [1, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Pre-populate with sample syllabus questions from CS-601
    final sampleQ = TextbookQuizRepository.textbookQuestionBank["CS-601"];
    if (sampleQ != null && sampleQ.isNotEmpty) {
      _stagedQuestions.addAll(sampleQ.take(3));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _subjectCodeController.dispose();
    _subjectNameController.dispose();
    _durationController.dispose();
    _marksPerQuestionController.dispose();
    _negativePenaltyController.dispose();
    super.dispose();
  }

  void _showAddQuestionDialog() {
    final qTextController = TextEditingController();
    final opt1Controller = TextEditingController();
    final opt2Controller = TextEditingController();
    final opt3Controller = TextEditingController();
    final opt4Controller = TextEditingController();
    final explanationController = TextEditingController();
    final citationController = TextEditingController(text: "Textbook Standard Syllabus Reference");

    int optionCount = 4; // 2 or 4 options
    int correctIndex = 0;
    BloomsLevel selectedBlooms = BloomsLevel.understand;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add Custom Question",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Question Text
                TextField(
                  controller: qTextController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: "Question Statement",
                    hintText: "Enter the conceptual or numerical problem...",
                    filled: true,
                    fillColor: AppColors.surfaceSubtle,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                // Options Count Selector (2 Options vs 4 Options)
                Row(
                  children: [
                    const Text("Options Format:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text("4 Options (MCQ)", style: TextStyle(fontSize: 11)),
                      selected: optionCount == 4,
                      onSelected: (val) {
                        if (val) setModalState(() => optionCount = 4);
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("2 Options (True/False)", style: TextStyle(fontSize: 11)),
                      selected: optionCount == 2,
                      onSelected: (val) {
                        if (val) {
                          setModalState(() {
                            optionCount = 2;
                            if (correctIndex > 1) correctIndex = 0;
                            opt1Controller.text = "True";
                            opt2Controller.text = "False";
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Options inputs with radio for correct answer
                _buildOptionInput("Option A", opt1Controller, 0, correctIndex, (val) => setModalState(() => correctIndex = val)),
                const SizedBox(height: 8),
                _buildOptionInput("Option B", opt2Controller, 1, correctIndex, (val) => setModalState(() => correctIndex = val)),
                if (optionCount == 4) ...[
                  const SizedBox(height: 8),
                  _buildOptionInput("Option C", opt3Controller, 2, correctIndex, (val) => setModalState(() => correctIndex = val)),
                  const SizedBox(height: 8),
                  _buildOptionInput("Option D", opt4Controller, 3, correctIndex, (val) => setModalState(() => correctIndex = val)),
                ],
                const SizedBox(height: 14),

                // Bloom's Level & Textbook Citation
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<BloomsLevel>(
                        value: selectedBlooms,
                        decoration: InputDecoration(
                          labelText: "Bloom's Taxonomy",
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: BloomsLevel.values.map((b) {
                          return DropdownMenuItem(value: b, child: Text(b.label, style: TextStyle(fontSize: 11, color: b.color, fontWeight: FontWeight.w700)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedBlooms = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: explanationController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    labelText: "Explanation / Textbook Solution",
                    hintText: "Explain why this answer is correct...",
                    filled: true,
                    fillColor: AppColors.surfaceSubtle,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final qText = qTextController.text.trim();
                      final o1 = opt1Controller.text.trim();
                      final o2 = opt2Controller.text.trim();
                      if (qText.isEmpty || o1.isEmpty || o2.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill question statement and options")),
                        );
                        return;
                      }

                      final opts = optionCount == 4
                          ? [o1, o2, opt3Controller.text.trim(), opt4Controller.text.trim()]
                          : [o1, o2];

                      setState(() {
                        _stagedQuestions.add(QuizQuestion(
                          id: "Q-CUSTOM-${DateTime.now().millisecondsSinceEpoch}",
                          questionText: qText,
                          options: opts,
                          correctOptionIndex: correctIndex,
                          explanation: explanationController.text.trim(),
                          textbookCitation: citationController.text.trim(),
                          bloomsLevel: selectedBlooms,
                        ));
                      });

                      Navigator.pop(ctx);
                      HapticFeedback.mediumImpact();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Add to Staged Quiz", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionInput(String label, TextEditingController controller, int index, int currentCorrectIndex, Function(int) onSelected) {
    final isSelected = index == currentCorrectIndex;
    return Row(
      children: [
        Radio<int>(
          value: index,
          groupValue: currentCorrectIndex,
          activeColor: AppColors.success,
          onChanged: (val) {
            if (val != null) onSelected(val);
          },
        ),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              labelText: label,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: isSelected ? AppColors.success.withOpacity(0.06) : AppColors.surfaceSubtle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: isSelected ? AppColors.success : AppColors.borderLight),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTextbookRagPickerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: ListView(
            controller: scrollController,
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
                  Icon(Icons.auto_stories_rounded, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Local Textbook RAG Question Bank",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Syllabus-aligned questions extracted from standard university curriculum textbooks with chapter and page citations.",
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),

              ...TextbookQuizRepository.textbookQuestionBank.entries.map((entry) {
                final subCode = entry.key;
                final qList = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Subject: $subCode (${qList.length} Verified Questions)",
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...qList.map((q) {
                      final alreadyAdded = _stagedQuestions.any((sq) => sq.id == q.id);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: alreadyAdded ? AppColors.success : AppColors.borderLight),
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
                                    color: q.bloomsLevel.color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    q.bloomsLevel.label,
                                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: q.bloomsLevel.color),
                                  ),
                                ),
                                if (alreadyAdded)
                                  const Row(
                                    children: [
                                      Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                                      SizedBox(width: 4),
                                      Text("Added", style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w700)),
                                    ],
                                  )
                                else
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _stagedQuestions.add(q);
                                      });
                                      HapticFeedback.lightImpact();
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("✓ Added question from ${q.textbookCitation.split(',').first}"),
                                          backgroundColor: AppColors.success,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add_rounded, size: 14),
                                    label: const Text("Import", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              q.questionText,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.menu_book_rounded, size: 11, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    q.textbookCitation,
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _publishQuiz(CampusProvider provider) {
    if (_stagedQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least 1 question before publishing!"), backgroundColor: AppColors.error),
      );
      return;
    }

    final duration = int.tryParse(_durationController.text.trim()) ?? 15;
    final marks = double.tryParse(_marksPerQuestionController.text.trim()) ?? 2.0;
    final penalty = _hasNegativeMarking ? (double.tryParse(_negativePenaltyController.text.trim()) ?? 0.5) : 0.0;

    final newQuiz = CampusQuiz(
      id: "QUIZ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
      title: _titleController.text.trim(),
      subjectCode: _subjectCodeController.text.trim(),
      subjectName: _subjectNameController.text.trim(),
      targetBranch: _selectedBranch,
      targetSemester: _selectedSemester,
      targetYear: _selectedYear,
      durationMinutes: duration,
      marksPerQuestion: marks,
      hasNegativeMarking: _hasNegativeMarking,
      negativePenalty: penalty,
      questions: List.from(_stagedQuestions),
      createdByFaculty: provider.facultyProfile.name,
      createdAt: DateTime.now(),
      status: QuizStatus.active,
    );

    provider.createQuiz(newQuiz);
    HapticFeedback.heavyImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✓ Quiz Published! Targeted for $_selectedBranch - Semester $_selectedSemester ($_selectedYear Year)."),
        backgroundColor: AppColors.success,
      ),
    );

    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final quizzes = provider.quizzes;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Adaptive Bloom's Quiz Studio", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text("Faculty Assessment & Targeted Examination Engine", style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: "Active Quizzes (${quizzes.length})"),
            const Tab(text: "Create Quiz"),
            const Tab(text: "Textbook RAG"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Active Quizzes
          _buildActiveQuizzesTab(context, provider, quizzes),
          // Tab 2: Create Targeted Quiz
          _buildCreateQuizTab(context, provider),
          // Tab 3: Textbook Curriculum Library
          _buildTextbookLibraryTab(context),
        ],
      ),
    );
  }

  Widget _buildActiveQuizzesTab(BuildContext context, CampusProvider provider, List<CampusQuiz> quizzes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        final totalMarks = quiz.totalPossibleMarks;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: quiz.status.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      quiz.status.label.toUpperCase(),
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: quiz.status.color),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text("${quiz.durationMinutes} Mins", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                quiz.title,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 3),
              Text(
                "${quiz.subjectName} (${quiz.subjectCode}) • Created by ${quiz.createdByFaculty}",
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 10),

              // Targeting Pill Matrix
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _badgePill(Icons.apartment_rounded, "Branch: ${quiz.targetBranch}"),
                  _badgePill(Icons.school_rounded, "Sem: ${quiz.targetSemester}"),
                  _badgePill(Icons.military_tech_rounded, "Total: ${totalMarks.toStringAsFixed(0)} Marks"),
                  if (quiz.hasNegativeMarking)
                    _badgePill(Icons.warning_amber_rounded, "Neg: -${quiz.negativePenalty}", isWarning: true),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(color: AppColors.borderLight, height: 1),
              const SizedBox(height: 12),

              // Submissions & Leaderboard Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${quiz.totalSubmissions} Submissions",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      Text(
                        "Avg: ${quiz.classAverageScore} • Top: ${quiz.highestScore}",
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizLeaderboardScreen(
                            quiz: quiz,
                            isFacultyView: true,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.leaderboard_rounded, size: 14, color: Colors.white),
                    label: const Text("View Leaderboard", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _badgePill(IconData icon, String label, {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: isWarning ? AppColors.error.withOpacity(0.08) : AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isWarning ? AppColors.error.withOpacity(0.25) : AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: isWarning ? AppColors.error : AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isWarning ? AppColors.error : AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildCreateQuizTab(BuildContext context, CampusProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Academic Targeting Matrix
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text("1. ACADEMIC TARGETING MATRIX", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBranch,
                        decoration: const InputDecoration(labelText: "Target Branch", isDense: true),
                        items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (val) => setState(() => _selectedBranch = val ?? "CSE"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedSemester,
                        decoration: const InputDecoration(labelText: "Semester", isDense: true),
                        items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text("Sem $s", style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (val) => setState(() => _selectedSemester = val ?? 6),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedYear,
                        decoration: const InputDecoration(labelText: "Year", isDense: true),
                        items: _years.map((y) => DropdownMenuItem(value: y, child: Text("Year $y", style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (val) => setState(() => _selectedYear = val ?? 3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Quiz Title / Assessment Topic", isDense: true),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _subjectCodeController,
                        decoration: const InputDecoration(labelText: "Subject Code", isDense: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _subjectNameController,
                        decoration: const InputDecoration(labelText: "Subject Name", isDense: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Section 2: Exam Rules & Scoring
          const Row(
            children: [
              Icon(Icons.rule_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text("2. EXAM RULES & SCORING CONTROLS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Timer (Minutes)", isDense: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _marksPerQuestionController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Marks per Correct (+)", isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Negative Marking", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        Text(
                          _hasNegativeMarking ? "Penalty deducted on wrong answer" : "No penalty for wrong choices",
                          style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    Switch(
                      value: _hasNegativeMarking,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _hasNegativeMarking = val),
                    ),
                  ],
                ),
                if (_hasNegativeMarking) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _negativePenaltyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Penalty Deduction Amount (e.g. 0.5 or 1.0)",
                      isDense: true,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Section 3: Questions Management
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "3. STAGED QUESTIONS (${_stagedQuestions.length})",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _showTextbookRagPickerModal,
                    icon: const Icon(Icons.auto_stories_rounded, size: 14),
                    label: const Text("Textbook RAG", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddQuestionDialog,
                    icon: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                    label: const Text("+ Custom", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_stagedQuestions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
              ),
              child: const Center(
                child: Text(
                  "No questions added yet. Tap 'Textbook RAG' to pull questions from curriculum books or '+ Custom' to write one.",
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ..._stagedQuestions.asMap().entries.map((entry) {
              final idx = entry.key;
              final q = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Question ${idx + 1} (${q.options.length} Options)",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                          onPressed: () {
                            setState(() {
                              _stagedQuestions.removeAt(idx);
                            });
                          },
                        ),
                      ],
                    ),
                    Text(
                      q.questionText,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Correct: Option ${String.fromCharCode(65 + q.correctOptionIndex)} (${q.options[q.correctOptionIndex]})",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 20),

          // Publish Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _publishQuiz(provider),
              icon: const Icon(Icons.rocket_launch_rounded, size: 18, color: Colors.white),
              label: const Text(
                "Publish Quiz to Targeted Class",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTextbookLibraryTab(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: TextbookQuizRepository.textbooks.length,
      itemBuilder: (context, index) {
        final book = TextbookQuizRepository.textbooks[index];
        final chapters = (book["chapters"] as List?) ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book["title"] ?? "",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Author: ${book["author"]} • ${book["edition"]}",
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "${book["subjectName"]} (${book["subjectCode"]})",
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text("Curriculum Chapters Indexed for Local RAG:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              ...chapters.map((ch) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 12, color: AppColors.success),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(ch, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
