import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/campus_provider.dart';
import '../attendance/attendance_screen.dart';
import '../timetable/timetable_screen.dart';
import '../fees/fee_payment_screen.dart';
import '../certificates/digital_certificates_screen.dart';
import '../ai_analytics/predictive_performance_screen.dart';
import '../ai_analytics/early_dropout_screen.dart';
import '../transport/transport_screen.dart';
import '../hostel/hostel_screen.dart';
import '../lifecycle/edit_profile_screen.dart';
import '../helpdesk/helpdesk_screen.dart';

class AiVoiceAssistantScreen extends StatefulWidget {
  const AiVoiceAssistantScreen({super.key});

  @override
  State<AiVoiceAssistantScreen> createState() => _AiVoiceAssistantScreenState();
}

class _AiVoiceAssistantScreenState extends State<AiVoiceAssistantScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final messages = provider.chatMessages;
    final isListening = provider.isVoiceListening;
    final isSpeaking = provider.isAiSpeaking;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text("Campus AI Copilot"),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isSpeaking ? AppColors.primary.withOpacity(0.12) : AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSpeaking ? AppColors.primary : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSpeaking ? Icons.volume_up_rounded : Icons.graphic_eq_rounded,
                  size: 14,
                  color: isSpeaking ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  isSpeaking ? "Speaking..." : "Voice Ready",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSpeaking ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Voice Sound Wave Visualizer when Listening
          if (isListening || isSpeaking)
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isListening ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF),
                    border: Border(
                      bottom: BorderSide(
                        color: isListening ? const Color(0xFFFECACA) : const Color(0xFFBFDBFE),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(12, (index) {
                          final double waveValue = (index.isEven ? _waveController.value : (1.0 - _waveController.value));
                          final double height = 12 + waveValue * 24;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 4,
                            height: height,
                            decoration: BoxDecoration(
                              color: isListening ? AppColors.error : AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isListening ? "Listening to your voice... (Speak now)" : "AI Voice Synthesizer Active",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isListening ? AppColors.error : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // Chat message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildMessageItem(context, msg, provider);
              },
            ),
          ),

          // Suggested Prompts Carousel
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderLight, width: 1.0)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildPromptChip(provider, "Mera attendance kitna hai?"),
                  _buildPromptChip(provider, "Compiler Design safe bunks"),
                  _buildPromptChip(provider, "Aaj ka timetable aur substitute"),
                  _buildPromptChip(provider, "Mess me aaj lunch kya hai?"),
                  _buildPromptChip(provider, "Pending fees dues kitni hai?"),
                  _buildPromptChip(provider, "Bus Route 4 live kahan hai?"),
                  _buildPromptChip(provider, "Placement package kitna gaya?"),
                  _buildPromptChip(provider, "Gate Pass kaise banega?"),
                  _buildPromptChip(provider, "Bonafide Certificate chahiye"),
                ],
              ),
            ),
          ),

          // Input Bar with Voice Microphone Button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Interactive Voice Assistant Mic Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      _showVoiceOptionsModal(context, provider);
                    },
                    onLongPress: () {
                      HapticFeedback.mediumImpact();
                      provider.toggleVoiceListening();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isListening ? AppColors.error : AppColors.primary,
                        boxShadow: isListening
                            ? [
                                BoxShadow(
                                  color: AppColors.error.withOpacity(0.4),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                )
                              ]
                            : [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                )
                              ],
                      ),
                      child: Icon(
                        isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: isListening ? "Listening..." : "Ask AI or tap mic to speak...",
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.surfaceSubtle,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 20),
                          onPressed: () {
                            if (_textController.text.trim().isNotEmpty) {
                              provider.sendAiUserMessage(_textController.text.trim());
                              _textController.clear();
                              _scrollToBottom();
                            }
                          },
                        ),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          provider.sendAiUserMessage(val.trim());
                          _textController.clear();
                          _scrollToBottom();
                        }
                      },
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

  Widget _buildPromptChip(CampusProvider provider, String prompt) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        backgroundColor: AppColors.surfaceSubtle,
        side: const BorderSide(color: AppColors.borderLight, width: 1.0),
        label: Text(
          prompt,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textDark, fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          provider.sendAiUserMessage(prompt);
          _scrollToBottom();
        },
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, dynamic msg, CampusProvider provider) {
    final bool isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser ? AppColors.primary : AppColors.borderLight,
                  width: 1.0,
                ),
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
                  Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: isUser ? Colors.white : AppColors.textDark,
                      fontWeight: isUser ? FontWeight.w500 : FontWeight.w600,
                    ),
                  ),
                  if (msg.actionSuggestions != null && msg.actionSuggestions!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Divider(color: AppColors.borderLight, height: 1),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: msg.actionSuggestions!.map<Widget>((action) {
                        return InkWell(
                          onTap: () {
                            _handleActionClick(context, action, provider);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.touch_app_rounded, size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  action,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                provider.student.name.isNotEmpty ? provider.student.name.substring(0, 1) : "S",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showVoiceOptionsModal(BuildContext context, CampusProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.mic_rounded, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Smart Voice Queries",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Tap any query below or long-press the mic to cycle:",
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              ...[
                "Mera attendance kitna hai aur safe bunks kitne hain?",
                "Compiler Design me kitni classes attend karni hongi?",
                "Aaj ka timetable aur lecture substitution batao",
                "Hostel mess me aaj lunch aur dinner me kya bana hai?",
                "Pending fee dues kitni hai aur due date kab hai?",
                "Campus Bus Route 4 abhi kahan tak pahuchi hai?",
                "Hostel gate pass aur Bonafide certificate kaise milega?",
                "College placement package aur top companies ke baare me batao",
              ].map((queryText) => InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.pop(ctx);
                  provider.toggleVoiceListening(queryText);
                  _scrollToBottom();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.surfaceSubtle,
                        child: Icon(Icons.record_voice_over_rounded, size: 14, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          queryText,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _handleActionClick(BuildContext context, String action, CampusProvider provider) {
    if (action.contains("Attendance") || action.contains("Radar") || action.contains("Subjects")) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
    } else if (action.contains("GPA") || action.contains("Performance") || action.contains("Sandbox") || action.contains("Roadmap")) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PredictivePerformanceScreen()));
    } else if (action.contains("Dropout") || action.contains("EWS") || action.contains("Risk") || action.contains("Remedial")) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const EarlyDropoutScreen()));
    } else if (action.contains("Timetable") || action.contains("Classroom") || action.contains("Leave Note")) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen()));
    } else if (action.contains("Fee") || action.contains("Tuition") || action.contains("UPI") || action.contains("Receipts") || action.contains("Installment")) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FeePaymentScreen()));
    } else if (action.contains("Certificate") || action.contains("Bonafide") || action.contains("Marksheet") || action.contains("QR Hash")) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DigitalCertificatesScreen()));
    } else if (action.contains("Bus") || action.contains("Track") || action.contains("GPS") || action.contains("Pass")) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportScreen()));
    } else if (action.contains("Menu") || action.contains("Hostel") || action.contains("Gate Pass") || action.contains("Passes") || action.contains("Warden") || action.contains("Security QR")) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HostelScreen()));
    } else if (action.contains("Profile") || action.contains("Edit") || action.contains("PVC") || action.contains("ID Card")) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
    } else if (action.contains("Helpdesk") || action.contains("Ragging") || action.contains("SOS") || action.contains("Ticket")) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpdeskScreen()));
    } else {
      provider.sendAiUserMessage(action);
      _scrollToBottom();
    }
  }
}
