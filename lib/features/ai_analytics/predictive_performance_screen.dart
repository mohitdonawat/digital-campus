import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_chip.dart';
import '../../providers/campus_provider.dart';

class PredictivePerformanceScreen extends StatefulWidget {
  const PredictivePerformanceScreen({super.key});

  @override
  State<PredictivePerformanceScreen> createState() => _PredictivePerformanceScreenState();
}

class _PredictivePerformanceScreenState extends State<PredictivePerformanceScreen> {
  double _studyHoursSlider = 3.5;
  double _attendanceTargetSlider = 85.0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final perf = provider.predictivePerformance;
    final adjustedSgpa = perf.predictedSgpa;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("AI Predictive Performance & CGPA"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: CustomChip(
                label: "Ensemble ML Engine",
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
            // Top Forecast Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Predicted Semester 6 SGPA",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                        ),
                      ),
                      CustomChip(label: "ML Multi-Regression", color: AppColors.primary, isSolid: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        adjustedSgpa.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF38BDF8),
                          letterSpacing: -1,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                        child: Text(
                          "/ 10.0",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "95% Confidence Interval: [${perf.lowerConfidenceBound} - ${perf.upperConfidenceBound}]",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF34D399),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Calculated via Gradient Boosted Decision Trees trained on past 4 years of university cohorts, continuous internal assessments, and lecture presence.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.white60, height: 1.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Historical CGPA Trajectory
            const Text(
              "SEMESTER TRAJECTORY (SEM 1 TO 6)",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTrajectoryPoint("Sem 1", "7.90", false),
                      _buildTrajectoryPoint("Sem 2", "8.12", false),
                      _buildTrajectoryPoint("Sem 3", "8.25", false),
                      _buildTrajectoryPoint("Sem 4", "8.38", false),
                      _buildTrajectoryPoint("Sem 5", "8.42", false),
                      _buildTrajectoryPoint("Sem 6", adjustedSgpa.toStringAsFixed(2), true),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Subject-Wise Mastery Radar
            const Text(
              "SUBJECT-WISE EXPECTED SCORE RADAR",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),

            ...perf.subjectRiskScores.entries.map((entry) {
              final isWeak = entry.value < 75.0;
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                borderColor: isWeak ? AppColors.warning.withOpacity(0.5) : AppColors.borderLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "${entry.value.toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isWeak ? AppColors.warning : AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 6),
                            CustomChip(
                              label: isWeak ? "Needs Review" : "Mastery",
                              color: isWeak ? AppColors.warning : AppColors.success,
                              isSolid: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: entry.value / 100,
                      backgroundColor: AppColors.surfaceSubtle,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isWeak ? AppColors.warning : AppColors.success,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 18),

            // Interactive What-If Simulator
            GlassCard(
              borderColor: AppColors.primary.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "AI 'What-If' Simulation Sandbox",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Daily Self-Study Hours", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      Text("${_studyHoursSlider.toStringAsFixed(1)} hrs/day",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: _studyHoursSlider,
                    min: 1.0,
                    max: 8.0,
                    divisions: 14,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        _studyHoursSlider = val;
                      });
                      provider.updateWhatIfSimulation(_studyHoursSlider, _attendanceTargetSlider);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Target Lecture Attendance", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      Text("${_attendanceTargetSlider.toStringAsFixed(0)}%",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: _attendanceTargetSlider,
                    min: 65.0,
                    max: 98.0,
                    divisions: 33,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        _attendanceTargetSlider = val;
                      });
                      provider.updateWhatIfSimulation(_studyHoursSlider, _attendanceTargetSlider);
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      "Simulated Outcome: Achieving ${_attendanceTargetSlider.toStringAsFixed(0)}% attendance with ${_studyHoursSlider.toStringAsFixed(1)} daily hours projects your SGPA to ${adjustedSgpa.toStringAsFixed(2)}.",
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // High-Leverage AI Recommendations
            const Text(
              "HIGH-LEVERAGE ACTION RECOMMENDATIONS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),

            ...perf.highLeverageActions.map((action) {
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        action,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.3),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTrajectoryPoint(String label, String score, bool isProjected) {
    return Column(
      children: [
        Text(
          score,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isProjected ? AppColors.primary : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isProjected ? AppColors.primary : AppColors.success,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isProjected ? AppColors.primary : AppColors.textMuted,
            fontWeight: isProjected ? FontWeight.w800 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
