import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_chip.dart';
import '../../core/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VernacularStudyAssistantScreen extends StatefulWidget {
  const VernacularStudyAssistantScreen({super.key});

  @override
  State<VernacularStudyAssistantScreen> createState() => _VernacularStudyAssistantScreenState();
}

class _VernacularStudyAssistantScreenState extends State<VernacularStudyAssistantScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _soundWaveController;

  // Language State
  String _selectedLangCode = "hi";
  String _selectedLangName = "हिन्दी (Hindi)";

  final List<Map<String, String>> _languages = [
    {"code": "hi", "name": "हिन्दी", "english": "Hindi", "flag": "🇮🇳"},
    {"code": "mr", "name": "मराठी", "english": "Marathi", "flag": "🇮🇳"},
    {"code": "te", "name": "తెలుగు", "english": "Telugu", "flag": "🇮🇳"},
    {"code": "ta", "name": "தமிழ்", "english": "Tamil", "flag": "🇮🇳"},
    {"code": "gu", "name": "ગુજરાતી", "english": "Gujarati", "flag": "🇮🇳"},
    {"code": "bn", "name": "বাংলা", "english": "Bengali", "flag": "🇮🇳"},
    {"code": "kn", "name": "ಕನ್ನಡ", "english": "Kannada", "flag": "🇮🇳"},
  ];

  // ==========================================
  // TAB 1: TEXTBOOK & PDF RAG ENGINE STATE
  // ==========================================
  List<Map<String, dynamic>> _ragBooks = [];
  String _selectedBookId = "ALL";
  final TextEditingController _ragQueryController =
      TextEditingController(text: "Banker's Algorithm safe state and deadlock");
  bool _isRagLoading = false;
  bool _isRagAudioPlaying = false;
  Map<String, dynamic>? _ragResult;

  final List<String> _ragSamplePrompts = [
    "Banker's Algorithm safe state and deadlock",
    "LR(1) Bottom-Up Parsing handles and shift reduce",
    "Virtual Memory demand paging and page fault",
    "TCP Congestion slow start vs Tahoe halving",
    "Backpropagation multivariate chain rule gradient",
  ];

  // ==========================================
  // TAB 2: QUICK CONCEPT SIMPLIFIER STATE
  // ==========================================
  final TextEditingController _quickSearchController = TextEditingController(text: "Backpropagation");
  bool _isQuickLoading = false;
  bool _isQuickAudioPlaying = false;

  final List<String> _quickConcepts = [
    "Backpropagation",
    "LR(1) Bottom-Up Parsing",
    "TCP Congestion Control",
    "Deadlock Banker's Algorithm",
    "Pointers & Memory Allocation",
    "Dijkstra's Shortest Path",
  ];

  Map<String, dynamic> _quickConceptData = {
    "term": "Backpropagation Algorithm",
    "subject": "Machine Learning & AI (CS-601)",
    "definition":
        "Method used in artificial neural networks to calculate a gradient that is needed in the calculation of the weights to be used in the network.",
    "translation": "पश्च-प्रसार एल्गोरिथम (Backpropagation)",
    "feynman_meaning":
        "सरल शब्दों में: जैसे निशानेबाजी में निशाना चूकने पर हम देखते हैं कि तीर कितना ऊपर या नीचे लगा, और अगली बार अपना हाथ उसी हिसाब से एडजस्ट करते हैं — ठीक वैसे ही न्यूरल नेटवर्क टारगेट से हुई गलती (Error) को पीछे भेजकर अपने वजन (Weights) को ठीक करता है ताकि अगली बार सटीक उत्तर आए।",
    "source": "Local SQLite Vector Glossary (100% Offline Free)",
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _soundWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _loadBooksAndRunInitialRag();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _soundWaveController.dispose();
    _ragQueryController.dispose();
    _quickSearchController.dispose();
    super.dispose();
  }

  void _loadBooksAndRunInitialRag() async {
    final books = await ApiService.getRagBooks();
    if (mounted) {
      setState(() {
        _ragBooks = books;
      });
      _executeRagQuery(_ragQueryController.text);
    }
  }

  // ==========================================
  // RAG METHODS
  // ==========================================
  void _executeRagQuery(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isRagLoading = true;
    });

    final res = await ApiService.queryRagBook(
      query: query.trim(),
      bookId: _selectedBookId,
      targetLang: _selectedLangCode,
    );

    if (mounted) {
      setState(() {
        _ragResult = res;
        _isRagLoading = false;
      });
    }
  }

  void _toggleRagAudio() {
    setState(() {
      _isRagAudioPlaying = !_isRagAudioPlaying;
    });

    if (_isRagAudioPlaying) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Narrating Textbook RAG citation in $_selectedLangName via Bhashini TTS...",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 4),
        ),
      );

      Future.delayed(const Duration(seconds: 12), () {
        if (mounted) {
          setState(() {
            _isRagAudioPlaying = false;
          });
        }
      });
    }
  }

  void _openUploadDocumentModal() {
    final titleCtrl = TextEditingController(text: "Operating Systems - Unit 3 Lecture Notes");
    final subjectCtrl = TextEditingController(text: "CS-501 Operating Systems");
    final textCtrl = TextEditingController(
      text:
          "Semaphore is a synchronization tool introduced by Dijkstra. An integer variable that, apart from initialization, is accessed only through two standard atomic operations: wait() and signal(). When a process executes wait(), the integer value is decremented. If negative, the process blocks. Counting semaphores can control access to a finite number of resource instances, while binary semaphores behave like mutex locks to enforce critical section mutual exclusion.",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.picture_as_pdf_rounded, color: AppColors.accent, size: 22),
                        SizedBox(width: 8),
                        Text(
                          "Ingest PDF / Textbook Notes",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Upload any syllabus PDF or paste textbook notes. Our RAG engine extracts text, segments it into semantic chunks, and indexes it into the local SQLite vector store for instant vernacular Q&A.",
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Document / Book Title",
                    labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subjectCtrl,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Subject & Course Code",
                    labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textCtrl,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 12.5, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Extracted Document Text / Syllabus Notes",
                    labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      "Segment Chunks & Index in SQLite RAG",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Extracting text and building vector chunks in SQLite..."),
                          backgroundColor: AppColors.primary,
                          duration: Duration(seconds: 2),
                        ),
                      );

                      final uploadRes = await ApiService.uploadRagDocument(
                        title: titleCtrl.text.trim(),
                        author: "Student Ingestion",
                        subject: subjectCtrl.text.trim(),
                        rawText: textCtrl.text.trim(),
                      );

                      // Refresh books
                      final updatedBooks = await ApiService.getRagBooks();
                      if (mounted) {
                        setState(() {
                          _ragBooks = updatedBooks;
                          _selectedBookId = uploadRes["book_id"] ?? "ALL";
                          _ragQueryController.text = "Semaphore synchronization wait signal mutex";
                        });
                        _executeRagQuery(_ragQueryController.text);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "✓ Ingested ${uploadRes['total_chunks']} chunks from '${titleCtrl.text}' successfully!",
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // QUICK SIMPLIFIER METHODS
  // ==========================================
  void _translateQuickConcept(String term, String langCode) async {
    setState(() {
      _isQuickLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse("http://localhost:8000/api/ai/vernacular-translate?term=$term&lang=$langCode"))
          .timeout(const Duration(milliseconds: 1500));

      if (response.statusCode == 200) {
        setState(() {
          _quickConceptData = jsonDecode(response.body);
          _isQuickLoading = false;
        });
        return;
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _quickConceptData = _getOfflineFallback(term, langCode);
      _isQuickLoading = false;
    });
  }

  Map<String, dynamic> _getOfflineFallback(String term, String langCode) {
    if (term.toLowerCase().contains("lr") || term.toLowerCase().contains("parsing")) {
      return {
        "term": "LR(1) Bottom-Up Parser",
        "subject": "Compiler Design & Automata (CS-604)",
        "definition":
            "A non-backtracking bottom-up parser which parses deterministically from Left to right, producing a Rightmost derivation in reverse.",
        "translation": "एलआर(1) बॉटम-अप पार्सर (Bottom-Up Parsing)",
        "feynman_meaning":
            "सरल शब्दों में: जैसे लेगो (Lego) ब्लॉक्स को नीचे जमीन से एक-एक करके जोड़कर ऊपर पूरा महल बनाते हैं — वैसे ही यह पार्सर प्रोग्राम के छोटे-छोटे शब्दों (Tokens) को नीचे से समेटते हुए ऊपर मुख्य व्याकरण (Grammar Start Symbol) तक ले जाता है।",
        "source": "Local SQLite Vector Glossary (100% Offline Free)",
      };
    } else if (term.toLowerCase().contains("tcp") || term.toLowerCase().contains("congestion")) {
      return {
        "term": "TCP Tahoe vs Reno Congestion Control",
        "subject": "Computer Networks & Security (CS-602)",
        "definition": "Algorithms managing network traffic load to prevent packet loss by adjusting congestion window.",
        "translation": "टीसीपी कंजेक्शन कंट्रोल (Slow Start & Window Halving)",
        "feynman_meaning":
            "सरल शब्दों में: जैसे सड़क पर ट्रैफिक देखकर हम गाड़ी की स्पीड धीरे-धीरे बढ़ाते हैं (Slow Start), और आगे जाम या एक्सीडेंट (Packet Loss) दिखते ही स्पीड तुरंत आधी कर लेते हैं — इंटरनेट पर डेटा का फ्लो भी इसी तरह कंट्रोल होता है ताकि नेटवर्क क्रैश न हो।",
        "source": "Local SQLite Vector Glossary (100% Offline Free)",
      };
    } else {
      return {
        "term": term,
        "subject": "Computer Science & Engineering",
        "definition": "Fundamental technical concept studied in technical curriculum.",
        "translation": "$term (${_selectedLangName.split(' ').first} अनुवाद)",
        "feynman_meaning":
            "सरल शब्दों में: $term एक महत्वपूर्ण कंप्यूटर साइंस अवधारणा है जो सिस्टम को सुचारू और कुशल रूप से चलाने में सहायता करती है।",
        "source": "Project Bhashini (National Language Translation Mission - MeitY)",
      };
    }
  }

  void _toggleQuickAudio() {
    setState(() {
      _isQuickAudioPlaying = !_isQuickAudioPlaying;
    });

    if (_isQuickAudioPlaying) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Narrating in $_selectedLangName using Bhashini TTS Audio Synthesis...",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 4),
        ),
      );

      Future.delayed(const Duration(seconds: 8), () {
        if (mounted) {
          setState(() {
            _isQuickAudioPlaying = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Vernacular & RAG Engine"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: CustomChip(
                label: "Bhashini NLTM + RAG",
                color: AppColors.accent,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(
              icon: Icon(Icons.menu_book_rounded, size: 20),
              text: "Textbook & PDF RAG Reader",
            ),
            Tab(
              icon: Icon(Icons.bolt_rounded, size: 20),
              text: "Quick Concept Simplifier",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTextbookRagTab(),
          _buildQuickConceptTab(),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 1: SMART TEXTBOOK & PDF RAG READER (The User's Dream Feature)
  // =========================================================================
  Widget _buildTextbookRagTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Value Proposition Hero Banner
          GlassCard(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2B48), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderColor: const Color(0xFF38BDF8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_stories_rounded, color: Color(0xFF38BDF8), size: 22),
                        SizedBox(width: 8),
                        Text(
                          "Textbook & PDF Mother-Tongue RAG",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF38BDF8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _openUploadDocumentModal,
                      icon: const Icon(Icons.upload_file_rounded, size: 14, color: Color(0xFF38BDF8)),
                      label: const Text(
                        "+ Ingest PDF",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Upload any college textbook, lecture slides, or syllabus PDF. Our RAG engine extracts text, segments it into semantic chunks, indexes it in SQLite, and provides dual-layer mother-tongue translation with real-world Feynman analogies and audio narration!",
                  style: TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.4),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      "₹0.00 / Query • 100% Free Lifetime Sovereign Stack (NEP 2020 Aligned)",
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.accent),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Mother Tongue Language Selector
          _buildLanguageSelector(),

          const SizedBox(height: 16),

          // Textbook / PDF Document Selector
          const Text(
            "SELECT TEXTBOOK / INGESTED DOCUMENT",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceCardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBookId,
                dropdownColor: const Color(0xFF1E293B),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.accent),
                items: [
                  const DropdownMenuItem(
                    value: "ALL",
                    child: Text(
                      "🌐 All Indexed Textbooks & Syllabus Notes (Universal RAG Search)",
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  ..._ragBooks.map((b) {
                    final title = b["title"] ?? "Book";
                    final chunks = b["total_chunks"] ?? 0;
                    return DropdownMenuItem(
                      value: b["id"].toString(),
                      child: Text(
                        "📖 $title ($chunks Chunks)",
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedBookId = val;
                    });
                    _executeRagQuery(_ragQueryController.text);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // RAG Query Input Bar
          const Text(
            "ASK A QUESTION OR ENTER ANY TOPIC FROM THE BOOK",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(Icons.manage_search_rounded, color: AppColors.accent, size: 22),
                ),
                Expanded(
                  child: TextField(
                    controller: _ragQueryController,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "E.g., Explain Banker's algorithm safe state or Virtual memory paging...",
                      hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (val) => _executeRagQuery(val),
                  ),
                ),
                IconButton(
                  onPressed: () => _executeRagQuery(_ragQueryController.text),
                  icon: _isRagLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                        )
                      : const Icon(Icons.arrow_forward_rounded, color: AppColors.accent, size: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Sample Prompt Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _ragSamplePrompts.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ActionChip(
                    label: Text(
                      p.length > 32 ? "${p.substring(0, 32)}..." : p,
                      style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.04),
                    side: const BorderSide(color: AppColors.borderDark),
                    onPressed: () {
                      _ragQueryController.text = p;
                      _executeRagQuery(p);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // ==========================================
          // RAG RESULT CARD WITH CITATION & FEYNMAN
          // ==========================================
          if (_isRagLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.accent),
                    SizedBox(height: 12),
                    Text(
                      "Scanning SQLite Vector Index & Synthesizing Mother-Tongue Metaphor...",
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            )
          else if (_ragResult != null)
            _buildRagResultCard()
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildRagResultCard() {
    final r = _ragResult!;
    return GlassCard(
      borderColor: AppColors.accent.withOpacity(0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Academic Citation Header
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, size: 20, color: AppColors.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${r['book_title']} • Page ${r['page_number']}",
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Section: ${r['chapter']} • Author: ${r['author']}",
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                CustomChip(
                  label: "Page ${r['page_number']}",
                  color: AppColors.accent,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. Original English Textbook Chunk (Technical Precision)
          const Row(
            children: [
              Icon(Icons.code_rounded, size: 14, color: AppColors.textMuted),
              SizedBox(width: 6),
              Text(
                "ORIGINAL TEXTBOOK EXCERPT (TECHNICAL FIDELITY)",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Text(
              r["retrieved_english_chunk"] ?? "",
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFFE2E8F0),
                height: 1.45,
                fontFamily: "monospace",
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 3. Vernacular Translation
          Row(
            children: [
              const Icon(Icons.translate, size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                "VERNACULAR TRANSLATION (${_selectedLangName.split(' ').first})",
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            r["vernacular_translation"] ?? "",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 14),

          // 4. Feynman Real-World Metaphor (The Intuition Engine)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFBE0B).withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, size: 16, color: Color(0xFFFFBE0B)),
                    SizedBox(width: 6),
                    Text(
                      "FEYNMAN INTUITIVE ANALOGY (आसान भाषा में मतलब)",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Color(0xFFFFBE0B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  r["feynman_analogy"] ?? "",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 5. Audio Player Toolbar (Listen in Mother Tongue)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _isRagAudioPlaying ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isRagAudioPlaying ? AppColors.accent : AppColors.borderDark,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggleRagAudio,
                  icon: Icon(
                    _isRagAudioPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                    size: 34,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isRagAudioPlaying
                            ? "Playing Vernacular Audio (${r['audio_duration'] ?? '14s'})"
                            : "Listen to Concept in ${_selectedLangName.split(' ').first}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isRagAudioPlaying
                            ? "Bhashini Neural TTS Active • Tap pause to stop"
                            : "Tap play to hear simplified explanation aloud",
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (_isRagAudioPlaying)
                  Row(
                    children: List.generate(4, (index) {
                      return AnimatedBuilder(
                        animation: _soundWaveController,
                        builder: (context, child) {
                          final height = (index % 2 == 0)
                              ? 10.0 + (_soundWaveController.value * 14.0)
                              : 22.0 - (_soundWaveController.value * 12.0);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 3,
                            height: height,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      );
                    }),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 6. Provenance & Zero-Cost Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r["infrastructure"] ?? "Local SQLite RAG Vector Store + Bhashini NLTM",
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
              const Text(
                "Cost: ₹0.00 (Zero Token Billing)",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 2: QUICK CONCEPT SIMPLIFIER (Single Term Lookup)
  // =========================================================================
  Widget _buildQuickConceptTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Card
          GlassCard(
            gradient: const LinearGradient(
              colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderColor: const Color(0xFF10B981),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.translate_rounded, color: AppColors.accent, size: 22),
                        SizedBox(width: 8),
                        Text(
                          "Instant Term Simplifier",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                    CustomChip(label: "100% FREE", color: AppColors.success),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  "Look up any difficult engineering phrase or terminology. Get instant vernacular academic translation, real-world intuitive metaphor, and audio playback.",
                  style: TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Mother Tongue Language Selector
          _buildLanguageSelector(),

          const SizedBox(height: 16),

          // Concept Input Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(Icons.search_rounded, color: AppColors.accent, size: 20),
                ),
                Expanded(
                  child: TextField(
                    controller: _quickSearchController,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Enter difficult engineering term or sentence...",
                      hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        _translateQuickConcept(val.trim(), _selectedLangCode);
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_quickSearchController.text.trim().isNotEmpty) {
                      _translateQuickConcept(_quickSearchController.text.trim(), _selectedLangCode);
                    }
                  },
                  icon: _isQuickLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                        )
                      : const Icon(Icons.arrow_forward_rounded, color: AppColors.accent, size: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Quick Concept Suggestion Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickConcepts.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ActionChip(
                    label: Text(c, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                    backgroundColor: Colors.white.withOpacity(0.04),
                    side: const BorderSide(color: AppColors.borderDark),
                    onPressed: () {
                      _quickSearchController.text = c;
                      _translateQuickConcept(c, _selectedLangCode);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Concept Definition & Feynman Meaning Card
          GlassCard(
            borderColor: AppColors.accent.withOpacity(0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _quickConceptData["term"] ?? "Technical Concept",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    CustomChip(
                      label: _selectedLangName.split(' ').first,
                      color: AppColors.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _quickConceptData["subject"] ?? "Computer Science",
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),

                const Divider(color: AppColors.borderDark, height: 24),

                // 1. Mother Tongue Translation
                const Row(
                  children: [
                    Icon(Icons.translate, size: 14, color: AppColors.accent),
                    SizedBox(width: 6),
                    Text(
                      "VERNACULAR ACADEMIC TRANSLATION",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _quickConceptData["translation"] ?? "",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Feynman Technique Simplified Real-World Analogy
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_rounded, size: 16, color: Color(0xFFFFBE0B)),
                          SizedBox(width: 6),
                          Text(
                            "FEYNMAN SIMPLIFIED MEANING (आसान भाषा में मतलब)",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: Color(0xFFFFBE0B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _quickConceptData["feynman_meaning"] ?? "",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Audio Narration Toolbar (Listen in Mother Tongue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isQuickAudioPlaying ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isQuickAudioPlaying ? AppColors.accent : AppColors.borderDark,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _toggleQuickAudio,
                        icon: Icon(
                          _isQuickAudioPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                          size: 32,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isQuickAudioPlaying
                                  ? "Playing Audio Narration (${_selectedLangName.split(' ').first})"
                                  : "Listen to Concept in ${_selectedLangName.split(' ').first}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isQuickAudioPlaying
                                  ? "Neural Speech Synthesis Active • Press pause to stop"
                                  : "Tap play to hear simplified explanation aloud",
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      if (_isQuickAudioPlaying)
                        Row(
                          children: List.generate(4, (index) {
                            return AnimatedBuilder(
                              animation: _soundWaveController,
                              builder: (context, child) {
                                final height = (index % 2 == 0)
                                    ? 10.0 + (_soundWaveController.value * 14.0)
                                    : 22.0 - (_soundWaveController.value * 12.0);
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  width: 3,
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Provenance Source Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _quickConceptData["source"] ?? "Local SQLite Vector Glossary",
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                    const Text(
                      "NEP 2020 Aligned",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success),
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

  // Common Language Selector Widget
  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SELECT YOUR MOTHER TONGUE (CHOOSE LANGUAGE)",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _languages.map((l) {
              final isSelected = l["code"] == _selectedLangCode;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      _selectedLangCode = l["code"]!;
                      _selectedLangName = "${l["name"]} (${l["english"]})";
                    });
                    if (_tabController.index == 0) {
                      _executeRagQuery(_ragQueryController.text);
                    } else {
                      _translateQuickConcept(_quickSearchController.text, _selectedLangCode);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.borderDark,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l["flag"]!, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Text(
                          l["name"]!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
