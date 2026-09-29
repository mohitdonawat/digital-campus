import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_chip.dart';
import '../../providers/campus_provider.dart';

class PersonalizedLearningScreen extends StatefulWidget {
  const PersonalizedLearningScreen({super.key});

  @override
  State<PersonalizedLearningScreen> createState() => _PersonalizedLearningScreenState();
}

class _PersonalizedLearningScreenState extends State<PersonalizedLearningScreen> {
  final Map<String, bool> _completedItems = {
    "Complete CNN Pooling Quiz": false,
    "Review TCP Sliding Window Slides": true,
    "Watch 10-Min Normalization Video": false,
  };

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final recommendations = provider.learningRecommendations;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("AI Adaptive Study Pathways"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: CustomChip(
                label: "Cognitive Skill-Gap",
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Diagnostic Skill-Gap Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA855F7), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA855F7).withOpacity(0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.psychology_rounded, color: AppColors.accent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "AI Diagnostic Skill-Gap Analysis",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ],
                      ),
                      CustomChip(label: "Real-Time", color: AppColors.accent, isSolid: true),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Our AI analyzed your recent Mid-Term exam answers, laboratory submissions, and quiz errors. 3 critical topics have been identified where 2.5 hours of targeted review will maximize semester SGPA.",
                    style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Tailored Learning Modules
            const Text(
              "TAILORED REMEDIAL & ADVANCED MODULES",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),

            ...recommendations.map((rec) {
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomChip(label: rec.subject, color: AppColors.primary),
                        Row(
                          children: [
                            Icon(
                              rec.resourceType.contains("Video")
                                  ? Icons.smart_display_rounded
                                  : (rec.resourceType.contains("Handout")
                                      ? Icons.description_rounded
                                      : Icons.quiz_rounded),
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rec.resourceType,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rec.topic,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Diagnostic Note: ${rec.reason}",
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Estimate: ${rec.durationOrPages} • Difficulty: ${rec.difficulty}",
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                        ),
                        ElevatedButton(
                          onPressed: () => _showModuleContentModal(context, rec),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Launch Module", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 18),

            // Daily Micro-Study Checklist
            const Text(
              "TODAY'S 15-MINUTE RETENTION SPRINT",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),

            GlassCard(
              child: Column(
                children: [
                  _buildSprintCheckbox("Complete CNN Pooling Quiz", "5 conceptual MCQ problems", "Complete CNN Pooling Quiz"),
                  const Divider(height: 1, color: AppColors.borderLight),
                  _buildSprintCheckbox("Review TCP Sliding Window Slides", "Faculty lecture companion", "Review TCP Sliding Window Slides"),
                  const Divider(height: 1, color: AppColors.borderLight),
                  _buildSprintCheckbox("Watch 10-Min Normalization Video", "Bhashini translated audio", "Watch 10-Min Normalization Video"),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSprintCheckbox(String title, String subtitle, String key) {
    final bool isDone = _completedItems[key] ?? false;
    return CheckboxListTile(
      value: isDone,
      onChanged: (val) {
        setState(() {
          _completedItems[key] = val ?? false;
        });
      },
      activeColor: AppColors.success,
      checkColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDone ? AppColors.textMuted : AppColors.textDark,
          decoration: isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
      ),
    );
  }

  void _showModuleContentModal(BuildContext context, dynamic rec) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomChip(label: rec.subject, color: AppColors.primary),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                rec.topic,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                rec.reason,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 52),
                      const SizedBox(height: 8),
                      Text(
                        "Playing: ${rec.topic} (${rec.durationOrPages})",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Module finished! +50 Learning XP awarded."),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Mark Module as Completed (+50 XP)", style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
