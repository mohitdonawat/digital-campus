import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_chip.dart';
import '../../providers/campus_provider.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final route = provider.busRoute;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Smart Transport & Transit"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: CustomChip(
                label: "Live GPS Tracking",
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
            // Live Bus GPS Radar Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.directions_bus_rounded, color: AppColors.accent, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            "${route.routeNumber} (${route.busPlateNumber})",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ],
                      ),
                      const CustomChip(label: "ON SCHEDULE", color: AppColors.success, isSolid: true),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    route.routeName,
                    style: const TextStyle(fontSize: 12.5, color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricColumn("Next Stop", route.nextStop, Icons.pin_drop_rounded),
                      _buildMetricColumn("Estimated Arrival", "${route.etaMinutes} mins", Icons.timer_rounded),
                      _buildMetricColumn("Current Speed", "${route.speedKmph} km/h", Icons.speed_rounded),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Calling driver ${route.driverName} (${route.driverPhone})..."),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          icon: const Icon(Icons.call_rounded, size: 16),
                          label: Text("Call Driver (${route.driverName})"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Emergency SOS alert sent to Transport Cell!"),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        },
                        icon: const Icon(Icons.emergency_rounded, color: AppColors.error),
                        tooltip: "SOS Alert",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Route Stops Journey
            const Text(
              "ROUTE 04 STOP SCHEDULE & LIVE VEHICLE POSITION",
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
                children: route.stopList.map((stop) {
                  final bool isNext = stop.contains(route.nextStop);
                  final bool isPassed = stop.contains("MP Nagar") || stop.contains("Board Office");

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isNext
                                ? AppColors.accent
                                : (isPassed ? AppColors.success : AppColors.surfaceSubtle),
                          ),
                          child: Icon(
                            isNext
                                ? Icons.directions_bus_rounded
                                : (isPassed ? Icons.check_rounded : Icons.radio_button_unchecked_rounded),
                            size: 14,
                            color: isNext || isPassed ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            stop,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
                              color: isNext ? AppColors.primary : (isPassed ? AppColors.textMuted : AppColors.textDark),
                            ),
                          ),
                        ),
                        if (isNext)
                          const CustomChip(label: "ARRIVING NEXT", color: AppColors.accent, isSolid: true),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            // Digital Bus Pass Card
            GlassCard(
              borderColor: AppColors.primaryLight.withOpacity(0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Digital Transit Bus Pass (Valid 2026-27)",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      CustomChip(label: "ACTIVE PASS", color: AppColors.success, isSolid: true),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Holder: ${provider.student.name} • Roll: ${provider.student.rollNumber}",
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Allotted: Route 04 (City Express) • Pickup: Board Office Square",
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Center(
                      child: Text(
                        "||||| |||| |||||||| |||| ||||||| ||||||",
                        style: TextStyle(
                          fontSize: 22,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }
}
