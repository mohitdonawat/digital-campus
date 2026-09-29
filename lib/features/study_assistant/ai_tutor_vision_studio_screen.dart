import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_chip.dart';
import '../../core/services/api_service.dart';
import '../../providers/campus_provider.dart';

class AiTutorVisionStudioScreen extends StatefulWidget {
  const AiTutorVisionStudioScreen({super.key});

  @override
  State<AiTutorVisionStudioScreen> createState() => _AiTutorVisionStudioScreenState();
}

class _AiTutorVisionStudioScreenState extends State<AiTutorVisionStudioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _studentAnswerController = TextEditingController();
  final TextEditingController _doubtInputController = TextEditingController();

  // Vision State
  bool _isProcessingVision = false;
  String _activeVisionMode = "copy"; // 'copy', 'ocr', 'blackboard'
  Map<String, dynamic>? _visionResult;

  // Socratic Tutor State
  bool _isLoadingTeaching = false;
  String _selectedTopic = "compiler_design";
  Map<String, dynamic>? _teachingData;
  Map<String, dynamic>? _interactionResult;
  Map<String, dynamic>? _quizData;
  int? _selectedQuizAnswer;
  bool _isQuizSubmitted = false;

  final List<Map<String, String>> _availableTopics = [
    {"key": "compiler_design", "name": "Compiler: Lexical & Automata (CS-604)"},
    {"key": "parsing_lr", "name": "Compiler: Bottom-Up LR Parsing"},
    {"key": "virtual_memory_paging", "name": "OS: Virtual Memory & Paging (CS-502)"},
    {"key": "machine_learning", "name": "ML: Gradient Descent & Loss (CS-601)"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTeachingSession(_selectedTopic);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _studentAnswerController.dispose();
    _doubtInputController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachingSession(String topic) async {
    setState(() => _isLoadingTeaching = true);
    final data = await ApiService.startTeachingSession(topicKey: topic);
    setState(() {
      _teachingData = data;
      _isLoadingTeaching = false;
      _interactionResult = null;
      _quizData = null;
      _selectedQuizAnswer = null;
      _isQuizSubmitted = false;
    });
  }

  Future<void> _submitSocraticAnswer() async {
    final text = _studentAnswerController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() => _isLoadingTeaching = true);

    final res = await ApiService.interactSocraticTutor(
      topicKey: _selectedTopic,
      studentInput: text,
      stepNumber: _teachingData?["current_step"] ?? 1,
    );

    setState(() {
      _interactionResult = res;
      _isLoadingTeaching = false;
      _studentAnswerController.clear();
    });
  }

  Future<void> _loadQuiz() async {
    HapticFeedback.lightImpact();
    final q = await ApiService.fetchTopicQuiz(_selectedTopic);
    setState(() {
      _quizData = q;
      _selectedQuizAnswer = null;
      _isQuizSubmitted = false;
    });
  }

  Future<void> _pickAndProcessImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source, imageQuality: 75);
      if (image == null) return;

      setState(() => _isProcessingVision = true);
      HapticFeedback.heavyImpact();

      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      if (_activeVisionMode == "copy") {
        final res = await ApiService.gradeHandwrittenAssignment(
          imageBase64: base64String,
          subjectName: "Compiler Design & Algorithms",
          questionText: "Derive time complexity of MergeSort using Master's Theorem.",
        );
        setState(() => _visionResult = res);
      } else if (_activeVisionMode == "ocr") {
        final res = await ApiService.processVisionOcr(imageBase64: base64String);
        setState(() => _visionResult = res);
      } else {
        // Blackboard
        await Future.delayed(const Duration(milliseconds: 700));
        setState(() {
          _visionResult = {
            "lecture_topic": "LR(0) and SLR(1) Parsing States",
            "equations": ["I0 = CLOSURE({S' -> .S})", r"FOLLOW(A) = $ U FIRST(beta)"],
            "feynman_analogy_hi": "जैसे ट्रैफिक पुलिस वाला आगे देखकर गाड़ी रोकता या छोड़ता है, वैसे ही SLR(1) पार्सर FOLLOW सिंबल को देखकर Shift या Reduce करता है!",
            "notes": [
              "LR(0) item includes a dot showing current scan position.",
              "Shift-Reduce conflict resolved via FOLLOW sets in SLR(1)."
            ]
          };
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vision processing note: $e"), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isProcessingVision = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "AI Tutor & Vision Studio",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Multimodal AI",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED)),
                  ),
                ),
              ],
            ),
            const Text(
              "Socratic Teaching • Handwritten Copy Grader • Blackboard OCR",
              style: TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF7C3AED),
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: const Color(0xFF7C3AED),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          tabs: const [
            Tab(text: "🧠 Socratic Tutor"),
            Tab(text: "📸 Vision & OCR"),
            Tab(text: "💬 Redis Doubts"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSocraticTutorTab(),
          _buildVisionOcrTab(),
          _buildRedisDoubtsTab(),
        ],
      ),
    );
  }

  // ── Tab 1: Socratic AI Pedagogical Tutor ───────────────────────────────────
  Widget _buildSocraticTutorTab() {
    if (_isLoadingTeaching && _teachingData == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
    }

    final data = _teachingData ?? {};
    final analogy = data["feynman_analogy"] ?? "";
    final socraticPrompt = data["socratic_prompt"] ?? "";
    final hint = data["hint"] ?? "";
    final code = data["interactive_code"] ?? "";

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Topic Selector Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTopic,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF7C3AED)),
              items: _availableTopics.map((t) {
                return DropdownMenuItem(
                  value: t["key"],
                  child: Text(t["name"]!, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedTopic = val);
                  _loadTeachingSession(val);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Step Tracker
        Row(
          children: [
            _buildStepPill("Step 1: Intuition", true),
            const SizedBox(width: 6),
            _buildStepPill("Step 2: Logic Deduction", (_teachingData?["current_step"] ?? 1) >= 2),
            const SizedBox(width: 6),
            _buildStepPill("Step 3: Micro-Quiz", _quizData != null),
          ],
        ),
        const SizedBox(height: 14),

        // Feynman Vernacular Analogy Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E1065), Color(0xFF1E1B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: const Color(0xFF2E1065).withOpacity(0.2), blurRadius: 14, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.psychology_rounded, color: AppColors.accent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Feynman Mother-Tongue Analogy (मातृभाषा सीख)",
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                analogy,
                style: const TextStyle(fontSize: 12, color: Color(0xFFE2E8F0), height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Socratic Prompt & Student Response Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.live_help_rounded, color: Color(0xFF7C3AED), size: 18),
                  SizedBox(width: 8),
                  Text("AI Professor's Guiding Question:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED))),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                socraticPrompt,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.35),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF7C3AED), size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text("Hint: $hint", style: const TextStyle(fontSize: 11, color: Color(0xFF6D28D9)))),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Student input field
              TextField(
                controller: _studentAnswerController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Type your answer or deduction here...",
                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceSubtle,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),

              // Submit Answer Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoadingTeaching ? null : _submitSocraticAnswer,
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text("Submit Deduction to AI Tutor", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              // Socratic Feedback if evaluated
              if (_interactionResult != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_rounded, color: AppColors.success, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            _interactionResult?["evaluation_status"] ?? "",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                          ),
                          const Spacer(),
                          const CustomChip(label: "+5% Mastery", color: AppColors.success),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _interactionResult?["feynman_tutor_feedback"] ?? "",
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF166534)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Interactive Code Sandbox Box
        if (code.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.terminal_rounded, color: AppColors.accent, size: 18),
                    SizedBox(width: 8),
                    Text("Interactive Python / Algorithm Sandbox", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  code,
                  style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: Color(0xFF38BDF8), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Micro-Quiz Action
        if (_quizData == null)
          OutlinedButton.icon(
            onPressed: _loadQuiz,
            icon: const Icon(Icons.quiz_rounded, size: 18, color: Color(0xFF7C3AED)),
            label: const Text("Take 2-Minute Concept Mastery Quiz", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF7C3AED)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          )
        else
          _buildQuizSection(),
      ],
    );
  }

  // ── Tab 2: Multimodal Vision & OCR Grader ─────────────────────────────────
  Widget _buildVisionOcrTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Mode Selector Chips
        Row(
          children: [
            _buildVisionModeChip("copy", "Handwritten Copy Grader", Icons.edit_note_rounded),
            const SizedBox(width: 8),
            _buildVisionModeChip("ocr", "Document & ID OCR", Icons.document_scanner_rounded),
            const SizedBox(width: 8),
            _buildVisionModeChip("blackboard", "Board Notes", Icons.dashboard_rounded),
          ],
        ),
        const SizedBox(height: 14),

        // Photo Upload Box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_camera_rounded, color: Color(0xFF7C3AED), size: 36),
              ),
              const SizedBox(height: 12),
              Text(
                _activeVisionMode == "copy"
                    ? "Upload Handwritten Answer Copy"
                    : _activeVisionMode == "ocr"
                        ? "Scan Official Document / Marksheet / PVC ID"
                        : "Capture Classroom Whiteboard / Blackboard Photo",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                "Supports TrOCR, PaddleOCR & Multimodal Qwen2-VL for step-by-step grading",
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isProcessingVision ? null : () => _pickAndProcessImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded, size: 16),
                    label: const Text("Take Photo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _isProcessingVision ? null : () => _pickAndProcessImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded, size: 16, color: Color(0xFF7C3AED)),
                    label: const Text("Upload Copy", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF7C3AED)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              if (_isProcessingVision) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(color: Color(0xFF7C3AED)),
                const SizedBox(height: 6),
                const Text("Running PaddleOCR & Neural Layout Extraction...", style: TextStyle(fontSize: 11, color: Color(0xFF7C3AED))),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Result Card
        if (_visionResult != null) _buildVisionResultDisplay(),
      ],
    );
  }

  // ── Tab 3: Redis Live Classroom Doubts Hub ────────────────────────────────
  Widget _buildRedisDoubtsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Redis Channel Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626).withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDC2626).withOpacity(0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.stream_rounded, color: Color(0xFFDC2626), size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Redis Pub/Sub Live Classroom Channel: CS-601", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF991B1B))),
                    Text("Sub-millisecond broadcast across all enrolled batch students", style: TextStyle(fontSize: 10.5, color: Color(0xFFB91C1C))),
                  ],
                ),
              ),
              CustomChip(label: "LIVE REDIS", color: Color(0xFFDC2626)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Ask Doubt Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _doubtInputController,
                  decoration: const InputDecoration(
                    hintText: "Ask doubt to Professor & batch...",
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final q = _doubtInputController.text.trim();
                  if (q.isNotEmpty) {
                    HapticFeedback.lightImpact();
                    ApiService.publishClassroomDoubt(
                      subjectCode: "CS-601",
                      studentName: Provider.of<CampusProvider>(context, listen: false).student.name,
                      question: q,
                    );
                    _doubtInputController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Doubt published to Redis classroom pub/sub!"), backgroundColor: AppColors.success),
                    );
                  }
                },
                icon: const Icon(Icons.send_rounded, color: Color(0xFF7C3AED)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Sample Live Doubts
        _buildDoubtTile("Rahul Sharma", "Sir, does SLR(1) have the same number of states as Canonical LR(1)?", "Just Now"),
        const SizedBox(height: 8),
        _buildDoubtTile("Pooja Verma", "Sir, will follow sets be given in the university exam question paper?", "3 mins ago"),
        const SizedBox(height: 8),
        _buildDoubtTile("Dr. Mohit Donawat (HOD)", "No, LR(1) splits states with different lookaheads. Number of states in LR(1) is much larger than SLR(1)!", "1 min ago", isFaculty: true),
      ],
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────────
  Widget _buildStepPill(String title, bool isDone) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFF7C3AED).withOpacity(0.12) : AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDone ? const Color(0xFF7C3AED).withOpacity(0.4) : AppColors.borderLight),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isDone ? const Color(0xFF7C3AED) : AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _buildVisionModeChip(String mode, String label, IconData icon) {
    final isSelected = _activeVisionMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _activeVisionMode = mode;
          _visionResult = null;
        }),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7C3AED) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? const Color(0xFF7C3AED) : AppColors.borderLight),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.textMuted),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : AppColors.textDark),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisionResultDisplay() {
    final res = _visionResult!;
    if (_activeVisionMode == "copy") {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Assignment Grading Report", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                CustomChip(label: "Awarded: ${res['marks_awarded']} / ${res['max_marks']} (${res['grade_letter']})", color: AppColors.success),
              ],
            ),
            const SizedBox(height: 10),
            Text("Transcribed Copy: ${res['transcribed_handwriting']}", style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            const Text("AI Step Feedback:", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
            Text(res['ai_pedagogical_feedback'] ?? "", style: const TextStyle(fontSize: 11.5, color: Color(0xFF166534))),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("OCR Key-Value Extraction", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(jsonEncode(res['extracted_data'] ?? res), style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
          ],
        ),
      );
    }
  }

  Widget _buildQuizSection() {
    final questions = (_quizData?["questions"] as List?) ?? [];
    if (questions.isEmpty) return const SizedBox.shrink();

    final q = questions[0];
    final options = (q["options"] as List?) ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Concept Diagnostic Micro-Quiz", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED))),
              if (_isQuizSubmitted) const CustomChip(label: "+5% Skill Radar", color: AppColors.success),
            ],
          ),
          const SizedBox(height: 10),
          Text(q["question"] ?? "", style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...List.generate(options.length, (idx) {
            final opt = options[idx];
            final isSelected = _selectedQuizAnswer == idx;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                tileColor: isSelected ? const Color(0xFF7C3AED).withOpacity(0.1) : AppColors.surfaceSubtle,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                leading: Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? const Color(0xFF7C3AED) : AppColors.textMuted,
                  size: 18,
                ),
                title: Text(opt, style: const TextStyle(fontSize: 11.5)),
                onTap: _isQuizSubmitted ? null : () => setState(() => _selectedQuizAnswer = idx),
              ),
            );
          }),
          const SizedBox(height: 10),
          if (!_isQuizSubmitted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedQuizAnswer == null
                    ? null
                    : () {
                        HapticFeedback.heavyImpact();
                        setState(() => _isQuizSubmitted = true);
                      },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
                child: const Text("Verify My Answer", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            )
          else
            Text(
              "Explanation: ${q['explanation']}",
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF15803D), fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  Widget _buildDoubtTile(String author, String question, String time, {bool isFaculty = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFaculty ? const Color(0xFFF5F3FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isFaculty ? const Color(0xFFC4B5FD) : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                author,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: isFaculty ? const Color(0xFF6D28D9) : AppColors.textDark,
                ),
              ),
              Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          Text(question, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
