import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';

class TeacherCreateQuizScreen extends StatefulWidget {
  final QuizModel? existingQuiz;

  const TeacherCreateQuizScreen({super.key, this.existingQuiz});

  @override
  State<TeacherCreateQuizScreen> createState() => _TeacherCreateQuizScreenState();
}

class _TeacherCreateQuizScreenState extends State<TeacherCreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _subjectController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;

  late String _selectedBranch;
  late String _selectedYear;
  late String _selectedSemester;

  final List<QuizQuestion> _questions = [];
  bool _isLoading = false;

  final List<String> _branchOptions = ['ALL', ...AppStrings.departments];
  final List<String> _yearOptions = ['ALL', ...AppStrings.years];
  final List<String> _semesterOptions = ['ALL', ...AppStrings.semesters];

  @override
  void initState() {
    super.initState();
    final q = widget.existingQuiz;
    _titleController = TextEditingController(text: q?.title ?? '');
    _subjectController = TextEditingController(text: q?.subject ?? '');
    _descriptionController = TextEditingController(text: q?.description ?? '');
    _durationController = TextEditingController(text: (q?.durationMinutes ?? 15).toString());
    _selectedBranch = q?.targetBranch ?? 'ALL';
    _selectedYear = q?.targetYear ?? 'ALL';
    _selectedSemester = q?.targetSemester ?? 'ALL';

    if (q != null && q.questions.isNotEmpty) {
      _questions.addAll(q.questions);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  double get _totalMarks => _questions.fold<double>(0.0, (sum, q) => sum + q.positiveMarks);

  void _openAddQuestionDialog({QuizQuestion? existing, int? index}) {
    final qTextController = TextEditingController(text: existing?.questionText ?? '');
    final opt0Controller = TextEditingController(text: existing != null && existing.options.isNotEmpty ? existing.options[0] : '');
    final opt1Controller = TextEditingController(text: existing != null && existing.options.length > 1 ? existing.options[1] : '');
    final opt2Controller = TextEditingController(text: existing != null && existing.options.length > 2 ? existing.options[2] : '');
    final opt3Controller = TextEditingController(text: existing != null && existing.options.length > 3 ? existing.options[3] : '');
    final expController = TextEditingController(text: existing?.explanation ?? '');
    final posMarksController = TextEditingController(text: (existing?.positiveMarks ?? 1.0).toString());
    final negMarksController = TextEditingController(text: (existing?.negativeMarks ?? 0.0).toString());

    int correctIdx = existing?.correctOptionIndex ?? 0;
    final dialogKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.help_outline_rounded, color: AppColors.secondary, size: 22),
              const SizedBox(width: 8),
              Text(
                existing == null ? 'Add Question #${_questions.length + 1}' : 'Edit Question #${index! + 1}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: dialogKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Statement
                    TextFormField(
                      controller: qTextController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Question text required' : null,
                      decoration: InputDecoration(
                        labelText: 'Question Statement *',
                        hintText: 'Type your question here...',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Options & Correct Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Options & Correct Answer *',
                            style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('(Tap letter to mark correct)',
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    _buildOptionInput('A', opt0Controller, 0, correctIdx, (val) => setDialogState(() => correctIdx = val)),
                    const SizedBox(height: 8),
                    _buildOptionInput('B', opt1Controller, 1, correctIdx, (val) => setDialogState(() => correctIdx = val)),
                    const SizedBox(height: 8),
                    _buildOptionInput('C', opt2Controller, 2, correctIdx, (val) => setDialogState(() => correctIdx = val)),
                    const SizedBox(height: 8),
                    _buildOptionInput('D', opt3Controller, 3, correctIdx, (val) => setDialogState(() => correctIdx = val)),

                    const SizedBox(height: 16),

                    // Marking Scheme: Positive Marks & Negative Penalty
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Marking Scheme & Negative Marking',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Positive Marks
                              Expanded(
                                child: TextFormField(
                                  controller: posMarksController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  validator: (v) {
                                    final numVal = double.tryParse(v ?? '');
                                    if (numVal == null || numVal <= 0) return 'Invalid';
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Correct (+Marks) *',
                                    hintText: 'e.g. 1.0 or 2.0',
                                    filled: true,
                                    fillColor: AppColors.surfaceVariant,
                                    prefixIcon: const Icon(Icons.add_circle_outline, color: AppColors.success, size: 16),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Negative Penalty
                              Expanded(
                                child: TextFormField(
                                  controller: negMarksController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  validator: (v) {
                                    final numVal = double.tryParse(v ?? '');
                                    if (numVal == null || numVal < 0) return 'Invalid';
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Wrong (-Penalty)',
                                    hintText: 'e.g. 0.25 or 0.5',
                                    filled: true,
                                    fillColor: AppColors.surfaceVariant,
                                    prefixIcon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 16),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tip: Enter 0 if this question has no negative marking penalty.',
                            style: TextStyle(color: AppColors.textHint, fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Explanation
                    TextFormField(
                      controller: expController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Answer Explanation (Optional)',
                        hintText: 'Why this option is correct (shown in review)',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 11),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (!dialogKey.currentState!.validate()) return;
                final posMarks = double.tryParse(posMarksController.text.trim()) ?? 1.0;
                final negMarks = double.tryParse(negMarksController.text.trim()) ?? 0.0;

                final newQ = QuizQuestion(
                  id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  questionText: qTextController.text.trim(),
                  options: [
                    opt0Controller.text.trim(),
                    opt1Controller.text.trim(),
                    opt2Controller.text.trim(),
                    opt3Controller.text.trim(),
                  ],
                  correctOptionIndex: correctIdx,
                  explanation: expController.text.trim(),
                  positiveMarks: posMarks,
                  negativeMarks: negMarks,
                );

                setState(() {
                  if (existing == null) {
                    _questions.add(newQ);
                  } else {
                    _questions[index!] = newQ;
                  }
                });

                Navigator.pop(ctx);
              },
              child: Text(
                existing == null ? 'Add Question' : 'Save Changes',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionInput(
    String label,
    TextEditingController controller,
    int optionIndex,
    int currentCorrect,
    Function(int) onSelectCorrect,
  ) {
    final isCorrect = currentCorrect == optionIndex;
    return Row(
      children: [
        GestureDetector(
          onTap: () => onSelectCorrect(optionIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCorrect ? AppColors.success : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrect ? AppColors.success : Colors.white24,
                width: isCorrect ? 2 : 1,
              ),
            ),
            child: Center(
              child: isCorrect
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                  : Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            validator: (v) => v == null || v.trim().isEmpty ? 'Option $label required' : null,
            decoration: InputDecoration(
              hintText: 'Option $label',
              hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _publishQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least 1 question to publish this quiz!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      String facultyName = 'Faculty';
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          facultyName = '${doc.data()?['title'] ?? 'Prof.'} ${doc.data()?['name'] ?? 'Faculty'}';
        }
      }

      final duration = int.tryParse(_durationController.text.trim()) ?? 15;

      final quiz = QuizModel(
        id: widget.existingQuiz?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subject: _subjectController.text.trim(),
        teacherUid: user?.uid ?? '',
        teacherName: facultyName,
        targetBranch: _selectedBranch,
        targetYear: _selectedYear,
        targetSemester: _selectedSemester,
        durationMinutes: duration,
        totalMarks: _totalMarks,
        questions: _questions,
        createdAt: widget.existingQuiz?.createdAt ?? DateTime.now(),
        isActive: true,
      );

      if (widget.existingQuiz != null) {
        await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.existingQuiz!.id)
            .update(quiz.toMap());
      } else {
        await QuizService.createQuiz(quiz);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingQuiz != null
              ? 'Quiz updated successfully! 📝'
              : 'Targeted Quiz published successfully! 🚀'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish quiz: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.existingQuiz != null ? 'Edit Quiz & Questions' : 'Create Targeted Quiz',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.score_rounded, color: AppColors.secondary, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_totalMarks.toStringAsFixed(1)} Marks',
                  style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quiz Basic Info
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                validator: (v) => v == null || v.trim().isEmpty ? 'Quiz Title is required' : null,
                decoration: InputDecoration(
                  labelText: 'Quiz Title *',
                  hintText: 'e.g. Mid-Term DBMS MCQ Challenge',
                  prefixIcon: const Icon(Icons.title_rounded, color: AppColors.secondary),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _subjectController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Subject required' : null,
                      decoration: InputDecoration(
                        labelText: 'Subject *',
                        hintText: 'e.g. DBMS',
                        prefixIcon: const Icon(Icons.book_rounded, color: AppColors.secondary),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      validator: (v) => int.tryParse(v ?? '') == null ? 'Mins' : null,
                      decoration: InputDecoration(
                        labelText: 'Time (Min) *',
                        prefixIcon: const Icon(Icons.timer_rounded, color: AppColors.secondary),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Targeting Options
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedBranch,
                      dropdownColor: AppColors.surfaceVariant,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Department',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: _branchOptions.map((b) => DropdownMenuItem(value: b, child: Text(b, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _selectedBranch = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedYear,
                      dropdownColor: AppColors.surfaceVariant,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Target Year',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: _yearOptions.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                      onChanged: (v) => setState(() => _selectedYear = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _selectedSemester,
                dropdownColor: AppColors.surfaceVariant,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Target Semester',
                  prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppColors.secondary, size: 18),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: _semesterOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _selectedSemester = v!),
              ),

              const SizedBox(height: 20),

              // Questions Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Questions (${_questions.length})',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Total Marks: ${_totalMarks.toStringAsFixed(1)}',
                        style: const TextStyle(color: AppColors.secondary, fontSize: 12),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openAddQuestionDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Question', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Questions List
              if (_questions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.quiz_outlined, color: AppColors.secondary, size: 40),
                      SizedBox(height: 12),
                      Text(
                        'No Questions Added Yet',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Click "+ Add Question" to enter questions with options, positive marks and negative penalty.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textHint, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final q = _questions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.secondary.withOpacity(0.2),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  q.questionText,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                                onPressed: () => _openAddQuestionDialog(existing: q, index: index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                onPressed: () => setState(() => _questions.removeAt(index)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Correct Option & Marking Badge
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Correct: Opt ${String.fromCharCode(65 + q.correctOptionIndex)} (${q.options[q.correctOptionIndex]})',
                                  style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+${q.positiveMarks} / -${q.negativeMarks}',
                                  style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Publish Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _publishQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.rocket_launch_rounded),
                  label: Text(
                    _isLoading
                        ? 'Publishing Quiz...'
                        : (widget.existingQuiz != null ? 'Save Quiz Updates' : 'Launch Quiz to Students'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
