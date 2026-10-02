import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_chip.dart';
import '../../providers/campus_provider.dart';
import '../../models/campus_models.dart';
import '../../data/campus_database.dart';
import '../../core/services/document_download_service.dart';

class HostelScreen extends StatefulWidget {
  const HostelScreen({super.key});

  @override
  State<HostelScreen> createState() => _HostelScreenState();
}

class _HostelScreenState extends State<HostelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final hostel = provider.hostel;
    final gatePasses = provider.gatePasses;
    final maintenanceTickets = provider.hostelMaintenanceTickets;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Smart Hostel & Residence",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              "${hostel.blockName} • Room ${hostel.roomNumber}",
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () => _showSosDialog(context, provider),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: provider.isSosActive ? const Color(0xFFDC2626) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDC2626), width: 1.2),
                  boxShadow: provider.isSosActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFFDC2626).withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emergency_rounded,
                      size: 16,
                      color: provider.isSosActive ? Colors.white : const Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      provider.isSosActive ? "SOS ACTIVE" : "RED SOS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: provider.isSosActive ? Colors.white : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
          tabs: [
            const Tab(icon: Icon(Icons.home_work_rounded, size: 18), text: "Residence"),
            Tab(
              icon: Badge(
                label: Text("${gatePasses.length}"),
                child: const Icon(Icons.qr_code_2_rounded, size: 18),
              ),
              text: "E-Gate Pass",
            ),
            Tab(
              icon: Badge(
                label: Text("${provider.facilitySlots.where((s) => s.status == 'Available').length}"),
                child: const Icon(Icons.swap_horiz_rounded, size: 18),
              ),
              text: "Amenities & Swap",
            ),
            Tab(
              icon: Badge(
                isLabelVisible: maintenanceTickets.any((t) => t.status != "Resolved"),
                label: Text("${maintenanceTickets.where((t) => t.status != 'Resolved').length}"),
                child: const Icon(Icons.handyman_rounded, size: 18),
              ),
              text: "Maintenance",
            ),
            const Tab(icon: Icon(Icons.restaurant_rounded, size: 18), text: "Mess & Rebate"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResidenceTab(context, provider),
          _buildGatePassTab(context, provider),
          _buildAmenitiesAndSwapTab(context, provider),
          _buildMaintenanceTab(context, provider),
          _buildMessTab(context, provider),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 1: RESIDENCE & ROOM ASSETS
  // ============================================================================
  Widget _buildResidenceTab(BuildContext context, CampusProvider provider) {
    final hostel = provider.hostel;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live SOS Emergency Alert Banner (if Active)
          if (provider.isSosActive) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "🚨 EMERGENCY RED SOS ACTIVE!",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF991B1B)),
                        ),
                        Text(
                          "GPS & Room coordinates dispatched to Chief Warden and Campus Ambulance.",
                          style: TextStyle(fontSize: 11, color: Color(0xFFB91C1C), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.resolveHostelSos(provider.hostelSosLogs.first.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Emergency alarm resolved."), backgroundColor: AppColors.success),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF991B1B),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text("Clear Alert", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ],

          // Allotted Room Hero Card
          Container(
            padding: const EdgeInsets.all(18),
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
                  blurRadius: 14,
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.bed_rounded, color: Color(0xFF38BDF8), size: 22),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hostel.roomNumber,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            Text(
                              "${hostel.blockName} • Floor ${hostel.floor}",
                              style: const TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const CustomChip(label: "ALLOTTED", color: AppColors.success, isSolid: true),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHeroMetric("Bed Allotted", "Bed 01 (Corner)", Icons.single_bed_rounded),
                    _buildHeroMetric("Sharing", "Triple Sharing", Icons.group_rounded),
                    _buildHeroMetric("Air Conditioning", "Active High-Wall AC", Icons.ac_unit_rounded),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // StarRez Green Dorm IoT Energy Meter Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "GREEN DORM IOT ENERGY CONSUMPTION",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              CustomChip(label: "TIER A+ ECO SAVER", color: AppColors.success, isSolid: true),
            ],
          ),
          const SizedBox(height: 10),

          GlassCard(
            borderColor: AppColors.success.withOpacity(0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.bolt_rounded, color: AppColors.success, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Room ${provider.hostelEnergyMeter.roomNumber} IoT Power Telemetry",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            ),
                            const Text(
                              "Real-time sensor polled via Campus Smart Grid",
                              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "${provider.hostelEnergyMeter.currentKwhToday} kWh",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.success),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: provider.hostelEnergyMeter.currentKwhToday / 6.0,
                    minHeight: 8,
                    backgroundColor: AppColors.borderLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Live Load: ${provider.hostelEnergyMeter.liveLoadWatts.toInt()} Watts (Safe <1500W)",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    Text(
                      "Monthly Total: ${provider.hostelEnergyMeter.monthlyKwh} kWh",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // StarRez AI Roommate Compatibility Radar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "AI ROOMMATE COMPATIBILITY RADAR",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              CustomChip(
                label: provider.matchmakerSetting.isSelfDiscoveryEnabled
                    ? "SELF-DISCOVERY ACTIVE"
                    : "GALE-SHAPLEY STABLE MATCH",
                color: const Color(0xFF6366F1),
                isSolid: true,
              ),
            ],
          ),
          const SizedBox(height: 10),

          GlassCard(
            borderColor: const Color(0xFF6366F1).withOpacity(0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF6366F1).withOpacity(0.12),
                      child: Text(
                        (provider.roommateQuiz.matchedRoommateName ?? "RJ")
                            .split(" ")
                            .map((e) => e.isNotEmpty ? e[0] : "")
                            .take(2)
                            .join(),
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6366F1), fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${provider.roommateQuiz.matchedRoommateName ?? 'Rohan Joshi'} (${provider.roommateQuiz.matchedRoommateRoll ?? 'IT22B019'})",
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                          ),
                          Text(
                            "Allotted: ${provider.roommateQuiz.assignedRoom ?? 'Room B-304'} • Zero Conflict Guarantee",
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${provider.roommateQuiz.compatibilityScore}% MATCH",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF6366F1)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildRadarChip(Icons.bedtime_rounded, "Sleep: ${provider.roommateQuiz.sleepCycle}"),
                    _buildRadarChip(Icons.headphones_rounded, "Study: ${provider.roommateQuiz.studyEnvironment}"),
                    _buildRadarChip(Icons.ac_unit_rounded, "AC: ${provider.roommateQuiz.acPreference}"),
                    _buildRadarChip(Icons.cleaning_services_rounded, "Cleanliness: ${provider.roommateQuiz.cleanliness}"),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (provider.matchmakerSetting.isSelfDiscoveryEnabled) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showRoommateDiscoveryModal(context, provider),
                          icon: const Icon(Icons.explore_rounded, size: 15),
                          label: const Text("Explore Roommates"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showLifestyleQuizDialog(context, provider),
                        icon: const Icon(Icons.quiz_rounded, size: 15),
                        label: const Text("30s Lifestyle Quiz"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                          side: const BorderSide(color: Color(0xFF6366F1)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Hostel Fee Ledger & Itemized Bill Card
          const Text(
            "HOSTEL SEMESTER FEE LEDGER & ITEMISED BILL",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          GlassCard(
            borderColor: AppColors.success.withOpacity(0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.receipt_long_rounded, color: AppColors.success, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Semester 6 Hostel & Mess Invoice",
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            ),
                            Text(
                              "Ref: FEE-HOSTEL-S2 • REC-2026-08-9412",
                              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const CustomChip(label: "PAID • ZERO DUES", color: AppColors.success, isSolid: true),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                _buildBillRow("Room Rent (Triple AC Allotment)", "₹${provider.hostelFeePolicy.tripleRoomAcRent.toStringAsFixed(0)}"),
                _buildBillRow("4-Meal Mess Dining (120 Days @ ₹${provider.hostelFeePolicy.messDailyRate.toStringAsFixed(0)}/day)", "₹${(provider.hostelFeePolicy.messDailyRate * 120).toStringAsFixed(0)}"),
                _buildBillRow("High-Speed Wi-Fi & Campus Amenities", "₹${provider.hostelFeePolicy.wifiAndAmenitiesFee.toStringAsFixed(0)}"),
                const Divider(height: 14),
                _buildBillRow("Gross Hostel Invoice", "₹${(provider.hostelFeePolicy.tripleRoomAcRent + provider.hostelFeePolicy.messDailyRate * 120 + provider.hostelFeePolicy.wifiAndAmenitiesFee).toStringAsFixed(0)}", isBold: true),
                _buildBillRow("Academic Merit Waiver (Top 5% CGPA 8.42)", "-₹1,600", isDiscount: true),
                _buildBillRow("Approved Leave Mess Rebate (4 Days)", "-₹480", isDiscount: true),
                const Divider(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Net Amount Paid:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                    Text("₹29,920", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.success)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final fee = provider.fees.firstWhere(
                        (f) => f.id == "FEE-HOSTEL-S2",
                        orElse: () => provider.fees.first,
                      );
                      DocumentDownloadService.downloadFeeReceiptPdf(context, fee, provider.student);
                    },
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text("Download Verified GST Fee Receipt (PDF)"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Roommates Section
          const Text(
            "ROOMMATES & RESIDENTS",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          ...hostel.roommates.map((mate) {
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      mate[0],
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        const Text("B.Tech CSE Sem 6 • Apex Digital Campus", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text("In Campus", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.success)),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 18),

          // Wardens & Security Desk Contacts
          const Text(
            "CHIEF WARDEN & SECURITY CARETAKER",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          GlassCard(
            child: Column(
              children: [
                _buildContactRow(
                  name: hostel.wardenName,
                  role: "Chief Warden (Boys Wing)",
                  phone: hostel.wardenPhone,
                  icon: Icons.shield_rounded,
                  color: AppColors.primary,
                ),
                const Divider(height: 16),
                _buildContactRow(
                  name: "Mr. Rajendra Verma",
                  role: "Hostel Caretaker & Emergency Desk",
                  phone: "+91 94250 88991",
                  icon: Icons.support_agent_rounded,
                  color: const Color(0xFF0284C7),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Digital Room Inventory Verification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "AI ROOM DAMAGE & CAUTION DEPOSIT SHIELD",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              CustomChip(label: "₹5,000 SAFE • ZERO DEDUCTION", color: AppColors.success, isSolid: true),
            ],
          ),
          const SizedBox(height: 10),

          GlassCard(
            borderColor: AppColors.success.withOpacity(0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified_user_rounded, color: AppColors.success, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Tamper-Proof Digital Bond: Assets verified via Multimodal AI Vision & Cryptographic SHA-256 Hashes. Management cannot deduct caution money without algorithmic proof!",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D), height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...provider.roomAssetInspections.map((asset) {
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
                            Expanded(
                              child: Text(
                                asset.assetName,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "0.00% DAMAGE",
                                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.success),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Check-in: ${asset.checkInCondition}",
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.fingerprint_rounded, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                asset.checkInSha256Hash,
                                style: const TextStyle(fontSize: 9.5, fontFamily: 'monospace', color: AppColors.textMuted),
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
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showAssetInspectionAuditDialog(context, provider),
                    icon: const Icon(Icons.camera_alt_rounded, size: 15),
                    label: const Text("Run AI Check-Out Comparison Scan"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 2: DIGITAL E-GATE PASS
  // ============================================================================
  Widget _buildGatePassTab(BuildContext context, CampusProvider provider) {
    final gatePasses = provider.gatePasses;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showApplyGatePassDialog(context, provider),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task_rounded, size: 20),
        label: const Text("Apply Gate Pass", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Curfew Advisory Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.access_time_filled_rounded, color: Color(0xFFB45309), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Night Curfew Rule: All hostellers must scan back into campus before 08:30 PM. Automatic SMS alert sent to parents upon delay.",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF92400E), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "ACTIVE & PAST DIGITAL PASSES",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),

            ...gatePasses.map((pass) {
              final isApproved = pass.status == "Approved";
              final isOut = pass.status == "Out of Campus";
              final isBreached = pass.isCurfewBreached;

              Color statusColor = AppColors.success;
              if (isBreached) {
                statusColor = AppColors.error;
              } else if (isOut) {
                statusColor = AppColors.warning;
              } else if (!isApproved) {
                statusColor = AppColors.textMuted;
              }

              return GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                borderColor: isBreached
                    ? AppColors.error
                    : (isApproved ? AppColors.success.withOpacity(0.5) : AppColors.borderLight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomChip(
                          label: pass.status.toUpperCase(),
                          color: statusColor,
                          isSolid: isApproved || isOut || isBreached,
                        ),
                        Text(
                          pass.id,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pass.reason,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Destination: ${pass.destination}",
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.logout_rounded, size: 14, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          "Out: ${pass.outDateTime}",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.login_rounded, size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          "In: ${pass.expectedInDateTime}",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    if (pass.approvedBy != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Verified by: ${pass.approvedBy}",
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                      ),
                    ],
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 14, color: Color(0xFF16A34A)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Expected Return Countdown: 2 hrs 15 mins remaining before 08:30 PM curfew",
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Curfew Auto-Extension Status & Request
                    Builder(
                      builder: (ctx) {
                        final ext = provider.curfewExtensions.firstWhere(
                          (e) => e.gatePassId == pass.id,
                          orElse: () => provider.curfewExtensions.isNotEmpty ? provider.curfewExtensions.first : const CurfewExtensionRequest(
                            id: "", gatePassId: "", studentRoll: "", studentName: "", roomNumber: "", reason: "", parentConsentStatus: "NONE",
                          ),
                        );
                        final hasExt = ext.id.isNotEmpty && ext.parentConsentStatus != "NONE";

                        if (hasExt) {
                          final isApproved = ext.parentConsentStatus == "APPROVED";
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isApproved ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isApproved ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isApproved ? Icons.verified_rounded : Icons.pending_actions_rounded,
                                  size: 16,
                                  color: isApproved ? AppColors.success : const Color(0xFFD97706),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isApproved ? "Curfew Auto-Extended to ${ext.extendedCurfewTime}!" : "Curfew Extension Request Pending Parent Consent",
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isApproved ? const Color(0xFF15803D) : const Color(0xFF92400E)),
                                      ),
                                      Text(
                                        isApproved ? "Parent approved via WhatsApp • Zero fine applied" : "WhatsApp 1-Click interactive alert dispatched to parent",
                                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: OutlinedButton.icon(
                            onPressed: () => _showCurfewExtensionDialog(context, provider, pass),
                            icon: const Icon(Icons.more_time_rounded, size: 15),
                            label: const Text("Request 45-Min Curfew Extension (Parent Consent)"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD97706),
                              side: const BorderSide(color: Color(0xFFD97706)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        );
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showGatePassQr(context, pass, provider),
                            icon: const Icon(Icons.qr_code_rounded, size: 16),
                            label: const Text("Show Turnstile Security QR"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // TAB 3: AMENITIES & MUTUAL ROOM SWAP (CLOUDBEDS + IIT BITS SWD)
  // ============================================================================
  Widget _buildAmenitiesAndSwapTab(BuildContext context, CampusProvider provider) {
    final facilitySlots = provider.facilitySlots;
    final roomSwaps = provider.roomSwaps;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Telemetry Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF38BDF8), width: 1.1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_laundry_service_rounded, color: Color(0xFF38BDF8), size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "IoT Campus Amenities & Resource Scheduler",
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Live telemetry connected to Speed Queen IoT washers, silent study pods, and gym slots.",
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Smart Amenities Slots
          const Text(
            "LIVE IOT FACILITY SLOTS",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          ...facilitySlots.map((slot) {
            final isBookedByMe = slot.bookedByRoll == provider.student.rollNumber;
            final isAvailable = slot.status == "Available";
            final isActive = slot.status == "Active";

            Color statusColor = AppColors.success;
            if (isActive) statusColor = AppColors.primary;
            if (slot.status == "Booked" && !isBookedByMe) statusColor = AppColors.textMuted;
            if (isBookedByMe) statusColor = const Color(0xFF6366F1);

            return GlassCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              borderColor: isBookedByMe ? const Color(0xFF6366F1).withOpacity(0.5) : AppColors.borderLight,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      slot.facilityName.contains("Washer")
                          ? Icons.local_laundry_service_rounded
                          : (slot.facilityName.contains("Study")
                              ? Icons.headphones_rounded
                              : Icons.fitness_center_rounded),
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot.facilityName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          slot.slotTime,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (isAvailable) ...[
                    ElevatedButton(
                      onPressed: () {
                        provider.bookFacilitySlot(slot.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Slot booked successfully for ${slot.facilityName}!"),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Book Slot", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ] else if (isBookedByMe) ...[
                    OutlinedButton(
                      onPressed: () {
                        provider.cancelFacilitySlot(slot.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Slot booking cancelled."), backgroundColor: AppColors.warning),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Cancel", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ] else ...[
                    CustomChip(label: slot.status.toUpperCase(), color: statusColor, isSolid: true),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 22),

          // Mutual Room Swap Section (IIT BITS SWD)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "MUTUAL ROOM SWAP DESK (IIT / BITS SWD)",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              TextButton.icon(
                onPressed: () => _showRoomSwapDialog(context, provider),
                icon: const Icon(Icons.swap_calls_rounded, size: 16),
                label: const Text("Apply Swap", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (roomSwaps.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text("No room swap applications currently active."),
              ),
            )
          else
            ...roomSwaps.map((swap) {
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                borderColor: const Color(0xFF6366F1).withOpacity(0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomChip(
                          label: swap.status.toUpperCase(),
                          color: const Color(0xFF6366F1),
                          isSolid: true,
                        ),
                        Text(swap.timestamp, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("FROM (CURRENT)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                              const SizedBox(height: 2),
                              Text(swap.requesterStudentName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                              Text("${swap.requesterRoll} • ${swap.currentRoom}", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF6366F1), size: 18),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("TO (TARGET)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                              const SizedBox(height: 2),
                              Text(swap.targetStudentName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                              Text("${swap.targetRoll} • ${swap.targetRoom}", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Reason: ${swap.reason}",
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.verified_user_rounded, size: 14, color: AppColors.success),
                        SizedBox(width: 5),
                        Text(
                          "Peer Approved • Chief Warden Digital NOC Pending",
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.success),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 4: 24-HOUR ROOM MAINTENANCE HELPDESK
  // ============================================================================
  Widget _buildMaintenanceTab(BuildContext context, CampusProvider provider) {
    final tickets = provider.hostelMaintenanceTickets;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReportMaintenanceDialog(context, provider),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
        label: const Text("Report Room Issue", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SLA Guarantee Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, color: Color(0xFF4F46E5), size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "24-Hour University Maintenance SLA",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF312E81)),
                        ),
                        Text(
                          "Electrical, Plumbing & LAN repairs guaranteed resolved within 24h by Campus Estate Cell.",
                          style: TextStyle(fontSize: 11, color: Color(0xFF4338CA)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "REPORTED ROOM SERVICE TICKETS",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),

            if (tickets.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text("Zero maintenance complaints. Your room is fully functional!"),
                ),
              )
            else
              ...tickets.map((ticket) {
                final isResolved = ticket.status == "Resolved";

                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  borderColor: isResolved ? AppColors.success.withOpacity(0.4) : AppColors.warning.withOpacity(0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CustomChip(label: ticket.category, color: AppColors.primary),
                              const SizedBox(width: 6),
                              if (ticket.urgency == "Critical")
                                const CustomChip(label: "CRITICAL", color: AppColors.error, isSolid: true),
                            ],
                          ),
                          CustomChip(
                            label: ticket.status.toUpperCase(),
                            color: isResolved ? AppColors.success : AppColors.warning,
                            isSolid: isResolved,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket.description,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person_pin_rounded, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ticket.assignedStaff,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            ticket.reportedAt,
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      if (!isResolved) ...[
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () {
                            provider.resolveHostelMaintenanceTicket(ticket.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Marked ticket as resolved & verified!"),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                          label: const Text("Confirm Resolved"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.success,
                            side: const BorderSide(color: AppColors.success),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // TAB 4: SMART MESS, NUTRITION & REBATE
  // ============================================================================
  Widget _buildMessTab(BuildContext context, CampusProvider provider) {
    final feedbacks = provider.messFeedbacks;
    final rebates = provider.messRebates;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rate Meal Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFBE0B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star_rate_rounded, color: Color(0xFFFFBE0B), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Student Mess Quality Index",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Rate today's meals to maintain strict food hygiene & flavor standards.",
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showMealRatingDialog(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFBE0B),
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Rate Meal", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. AI Predictive Mess Headcount & Food Waste Minimizer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "AI FOOD WASTE MINIMIZER & DINING INTENT",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              CustomChip(label: "₹6.8L/YR SAVED", color: AppColors.success, isSolid: true),
            ],
          ),
          const SizedBox(height: 10),

          Builder(
            builder: (ctx) {
              final studentIntent = provider.diningIntents.firstWhere(
                (i) => i.studentRoll == provider.student.rollNumber && i.mealType == "Dinner",
                orElse: () => DiningIntentRecord(
                  id: "DEF", studentRoll: provider.student.rollNumber, studentName: provider.student.name, date: "Today", mealType: "Dinner", intent: "ATTENDING", updatedAt: "Today",
                ),
              );
              final isAttending = studentIntent.intent == "ATTENDING";
              final forecast = provider.messForecast;

              return GlassCard(
                borderColor: AppColors.success.withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.eco_rounded, color: AppColors.success, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tonight's Dinner Attendance Intent",
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                                ),
                                Text(
                                  "1-Tap toggle before 06:00 PM • Synced with Gate Pass",
                                  style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                        CustomChip(
                          label: isAttending ? "DINING" : "SKIPPING",
                          color: isAttending ? AppColors.success : AppColors.error,
                          isSolid: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              provider.toggleDiningIntent(mealType: "Dinner", intent: "ATTENDING");
                              GoBackendService.submitDiningIntent(
                                studentRoll: provider.student.rollNumber,
                                studentName: provider.student.name,
                                mealType: "Dinner",
                                intent: "ATTENDING",
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Marked: Dining tonight. Kitchen alerted!"), backgroundColor: AppColors.success),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isAttending ? const Color(0xFFF0FDF4) : AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isAttending ? AppColors.success : AppColors.borderLight, width: isAttending ? 1.5 : 1.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 16, color: isAttending ? AppColors.success : AppColors.textMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    "YES, I WILL DINE",
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isAttending ? AppColors.success : AppColors.textDark),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              provider.toggleDiningIntent(mealType: "Dinner", intent: "SKIPPING");
                              GoBackendService.submitDiningIntent(
                                studentRoll: provider.student.rollNumber,
                                studentName: provider.student.name,
                                mealType: "Dinner",
                                intent: "SKIPPING",
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Marked: Skipping dinner. 1.2kg food waste prevented!"), backgroundColor: AppColors.warning),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isAttending ? const Color(0xFFFEF2F2) : AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: !isAttending ? AppColors.error : AppColors.borderLight, width: !isAttending ? 1.5 : 1.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cancel_rounded, size: 16, color: !isAttending ? AppColors.error : AppColors.textMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    "SKIPPING DINNER",
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: !isAttending ? AppColors.error : AppColors.textDark),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.soup_kitchen_rounded, size: 15, color: Color(0xFF0F172A)),
                              SizedBox(width: 6),
                              Text("Chef Live Kitchen Radar:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            forecast.chefAlertMessage,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          // Today's 4-Meal Menu
          const Text(
            "TODAY'S 4-MEAL NUTRITION MENU",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          ...CampusDatabase.messMenuToday.entries.map((entry) {
            IconData icon = Icons.restaurant_rounded;
            if (entry.key.contains("Breakfast")) icon = Icons.breakfast_dining_rounded;
            if (entry.key.contains("Lunch")) icon = Icons.lunch_dining_rounded;
            if (entry.key.contains("Dinner")) icon = Icons.dinner_dining_rounded;

            return GlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        const SizedBox(height: 3),
                        Text(entry.value, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 18),

          // Mess Rebate / Leave Fee Refund Calculator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "MESS REBATE (LEAVE REFUND CALCULATOR)",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              TextButton.icon(
                onPressed: () => _showApplyRebateDialog(context, provider),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text("Claim Rebate", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5)),
              ),
            ],
          ),

          ...rebates.map((reb) {
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              borderColor: AppColors.success.withOpacity(0.4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.savings_rounded, color: AppColors.success, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${reb.reason} (${reb.days} Days)", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        Text("${reb.startDate} to ${reb.endDate}", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("₹${reb.rebateAmount.toStringAsFixed(0)}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.success)),
                      const Text("Ledger Credited", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.success)),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 18),

          // Recent Student Meal Feedback Log
          const Text(
            "RECENT MEAL FEEDBACK & REVIEWS",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          ...feedbacks.map((f) {
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(f.mealType, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < f.rating ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 14,
                            color: const Color(0xFFFFBE0B),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(f.comment, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(f.timestamp, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================================
  // DIALOGS & MODALS
  // ============================================================================

  void _showApplyGatePassDialog(BuildContext context, CampusProvider provider) {
    final destCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    String category = "Market Outing";

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                "Apply Digital E-Gate Pass",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: InputDecoration(
                        labelText: "Pass Category",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Market Outing", child: Text("Market Outing (4 Hours)")),
                        DropdownMenuItem(value: "Weekend Home Visit", child: Text("Weekend Home Visit")),
                        DropdownMenuItem(value: "Medical Emergency", child: Text("Medical Emergency")),
                        DropdownMenuItem(value: "Academic / Library", child: Text("Academic Outing")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: destCtrl,
                      decoration: InputDecoration(
                        labelText: "Destination",
                        hintText: "e.g. New Market, Bhopal / Home",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonCtrl,
                      decoration: InputDecoration(
                        labelText: "Purpose / Reason",
                        hintText: "e.g. Purchasing Electronics Books",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel", style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (destCtrl.text.isNotEmpty) {
                      provider.submitGatePass(
                        reason: reasonCtrl.text.isEmpty ? category : reasonCtrl.text,
                        destination: destCtrl.text,
                        outDateTime: "Today 05:00 PM",
                        expectedInDateTime: "Today 08:30 PM",
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Digital Gate Pass approved by Chief Warden system!"),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Generate Pass"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showGatePassQr(BuildContext context, GatePass pass, CampusProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Turnstile Gate Security Verification",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  CustomChip(label: "STARREZ TOTP", color: AppColors.primary, isSolid: true),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_2_rounded, size: 130, color: Color(0xFF0F172A)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "TOKEN: HMAC-SHA256 • REFRESHES IN 24s",
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF38BDF8), letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Pass Ref: ${pass.id} • ${pass.status}",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(height: 3),
              Text(
                "Holder: ${pass.studentName} (${pass.rollNumber})",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
              const Text(
                "Dynamic watermarked QR. Anti-screenshot proxy mitigation active.",
                style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              // Simulator & Done Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        provider.simulateTurnstileScan(pass.id);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("⚡ Turnstile punch simulated! Gate Pass status toggled for ${pass.id}"),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.electric_bolt_rounded, size: 16),
                      label: const Text("Simulate Turnstile Punch", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: const BorderSide(color: AppColors.success),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Done"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportMaintenanceDialog(BuildContext context, CampusProvider provider) {
    final descCtrl = TextEditingController();
    String category = "Electrical";
    String urgency = "Normal";

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                "Report Room Maintenance Issue",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: InputDecoration(
                        labelText: "Issue Category",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Electrical", child: Text("Electrical (Fan / Light / Plug)")),
                        DropdownMenuItem(value: "Plumbing", child: Text("Plumbing (Tap / Geyser / Washroom)")),
                        DropdownMenuItem(value: "Wi-Fi / LAN", child: Text("Wi-Fi / LAN Cable Connectivity")),
                        DropdownMenuItem(value: "Housekeeping", child: Text("Housekeeping & Deep Cleaning")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: urgency,
                      decoration: InputDecoration(
                        labelText: "Urgency Level",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Normal", child: Text("Normal (24h Standard SLA)")),
                        DropdownMenuItem(value: "Critical", child: Text("Critical (4h Emergency SLA)")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => urgency = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Describe the issue",
                        hintText: "e.g. Geyser tripping circuit breaker on switch on",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel", style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (descCtrl.text.isNotEmpty) {
                      provider.submitHostelMaintenanceTicket(
                        category: category,
                        description: descCtrl.text,
                        urgency: urgency,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Ticket logged with Estate Cell! Technician assigned under 24h SLA."),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Log Ticket"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMealRatingDialog(BuildContext context, CampusProvider provider) {
    int stars = 4;
    String meal = "Lunch";
    final commentCtrl = TextEditingController(text: "Food was warm, fresh and well seasoned.");

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                "Rate Daily Mess Meal",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: meal,
                    decoration: InputDecoration(
                      labelText: "Select Meal",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Breakfast", child: Text("Breakfast")),
                      DropdownMenuItem(value: "Lunch", child: Text("Lunch")),
                      DropdownMenuItem(value: "Snacks", child: Text("Evening Snacks")),
                      DropdownMenuItem(value: "Dinner", child: Text("Dinner")),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => meal = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNum = index + 1;
                      return IconButton(
                        onPressed: () {
                          setDialogState(() => stars = starNum);
                        },
                        icon: Icon(
                          starNum <= stars ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 32,
                          color: const Color(0xFFFFBE0B),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: commentCtrl,
                    decoration: InputDecoration(
                      labelText: "Your Feedback / Suggestion",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel", style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.submitMessMealFeedback(
                      mealType: meal,
                      rating: stars,
                      comment: commentCtrl.text,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Thank you! Feedback recorded in Student Mess Quality Index."),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFBE0B),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Submit Rating", style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showApplyRebateDialog(BuildContext context, CampusProvider provider) {
    int days = 4;
    final reasonCtrl = TextEditingController(text: "Festival Holidays");

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                "Claim Mess Rebate (Fee Refund)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "University Rule: Minimum 3 continuous leave days required for automatic mess fee rebate credited @ ₹120 / day.",
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Leave Duration (Days):", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (days > 3) setDialogState(() => days--);
                            },
                            icon: const Icon(Icons.remove_circle_outline_rounded),
                          ),
                          Text("$days", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          IconButton(
                            onPressed: () {
                              setDialogState(() => days++);
                            },
                            icon: const Icon(Icons.add_circle_outline_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Calculated Refund Credit:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Text("₹${days * 120}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.success)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonCtrl,
                    decoration: InputDecoration(
                      labelText: "Reason for absence",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel", style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.submitMessRebateClaim(
                      startDate: "2026-10-10",
                      endDate: "2026-10-${10 + days}",
                      days: days,
                      reason: reasonCtrl.text,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Rebate of ₹${days * 120} credited to Student Fee Ledger!"),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Claim Refund"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================================
  // HELPER WIDGETS
  // ============================================================================

  Widget _buildHeroMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF38BDF8), size: 18),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white60)),
      ],
    );
  }

  Widget _buildContactRow({
    required String name,
    required String role,
    required String phone,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              Text(role, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Calling $name ($phone)..."), backgroundColor: AppColors.primary),
            );
          },
          icon: const Icon(Icons.call_rounded, size: 18, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, String value, {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: isDiscount ? AppColors.success : (isBold ? AppColors.textDark : AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold || isDiscount ? FontWeight.w800 : FontWeight.w700,
              color: isDiscount ? AppColors.success : (isBold ? AppColors.textDark : AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }

  void _showSosDialog(BuildContext context, CampusProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isActive = provider.isSosActive;

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.emergency_rounded, color: Color(0xFFDC2626), size: 24),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Hostel Emergency Red SOS",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF991B1B)),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isActive
                          ? "⚠️ EMERGENCY ALARM IS CURRENTLY ACTIVE!"
                          : "Triggering this beacon broadcasts an instant high-priority panic alert with your GPS coordinates and dorm room to Campus Quick Response Team (QRT) and the Chief Warden.",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                        color: isActive ? const Color(0xFF991B1B) : AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Student: ${provider.student.name} (${provider.student.rollNumber})", style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          const SizedBox(height: 2),
                          Text("Residence: ${provider.hostel.blockName} • Room ${provider.hostel.roomNumber}", style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          const Text("Campus QRT Dispatch Channel: Go SSE Broadcast Port 8080", style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("IMMEDIATE EMERGENCY CONTACTS", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    _buildContactRow(
                      name: "Campus 24x7 Ambulance & Health",
                      role: "Emergency Van Post",
                      phone: "108 / +91 755 2400108",
                      icon: Icons.local_hospital_rounded,
                      color: const Color(0xFFDC2626),
                    ),
                    const SizedBox(height: 6),
                    _buildContactRow(
                      name: "Campus Security Control Room",
                      role: "Chief Proctor & QRT Post",
                      phone: "+91 755 2400100",
                      icon: Icons.shield_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 14),
                    // Secret Silent Duress PIN Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showDuressPinDialog(context, provider);
                        },
                        icon: const Icon(Icons.pin_rounded, color: Color(0xFF38BDF8), size: 16),
                        label: const Text(
                          "Silent Duress PIN (Secret Anti-Ragging SOS)",
                          style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Close"),
                ),
                if (!isActive) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.triggerHostelSos(reason: "Immediate Student SOS Triggered from App");
                      setDialogState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("🚨 RED SOS DISPATCHED TO CHIEF WARDEN & QRT!"),
                          backgroundColor: Color(0xFFDC2626),
                        ),
                      );
                    },
                    icon: const Icon(Icons.warning_amber_rounded, size: 18),
                    label: const Text("TRIGGER SOS NOW"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () {
                      provider.resolveHostelSos(provider.hostelSosLogs.first.id);
                      setDialogState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Emergency alarm marked resolved."), backgroundColor: AppColors.success),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Resolve / Safety Cleared"),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  void _showRoomSwapDialog(BuildContext context, CampusProvider provider) {
    final rollCtrl = TextEditingController(text: "CS22B088");
    final nameCtrl = TextEditingController(text: "Amit Verma");
    final roomCtrl = TextEditingController(text: "A-210 (Block A)");
    final reasonCtrl = TextEditingController(text: "Closer to High-Performance Computing Research Lab");

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Apply for Mutual Room Swap",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "IIT/BITS Rule: Both students must consent. The Chief Warden will digitally countersign the room transfer NOC.",
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rollCtrl,
                  decoration: InputDecoration(
                    labelText: "Target Student Roll Number",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Target Student Full Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: roomCtrl,
                  decoration: InputDecoration(
                    labelText: "Target Room Number",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Reason for Swap",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (rollCtrl.text.isNotEmpty && roomCtrl.text.isNotEmpty) {
                  provider.submitRoomSwapRequest(
                    targetRoll: rollCtrl.text.trim(),
                    targetName: nameCtrl.text.trim(),
                    targetRoom: roomCtrl.text.trim(),
                    reason: reasonCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mutual Room Swap application submitted for Warden verification!"),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Submit Swap Request"),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------
  // 🚀 6 ULTRA-SMART INNOVATION DIALOGS & ACTION HANDLERS
  // -------------------------------------------------------------

  // 1. Roommate Discovery & Direct Selection Modal (Admin Self-Discovery Toggle)
  void _showRoommateDiscoveryModal(BuildContext context, CampusProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollable: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Discover & Choose Roommate",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textDark),
                      ),
                      CustomChip(label: "SELF-DISCOVERY", color: Color(0xFF6366F1), isSolid: true),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Campus Admin has unlocked direct roommate discovery. Review lifestyle compatibility vectors and select your ideal peer.",
                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  ...provider.roommateCandidates.map((c) {
                    final isMatched = provider.roommateQuiz.matchedRoommateRoll == c.rollNumber;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isMatched ? const Color(0xFFEEF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isMatched ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                          width: isMatched ? 1.8 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFF6366F1).withOpacity(0.12),
                                child: Text(
                                  c.studentName.split(" ").map((e) => e[0]).take(2).join(),
                                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6366F1), fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${c.studentName} (${c.rollNumber})",
                                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                                    ),
                                    Text(c.branch, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${c.compatibilityScore}% MATCH",
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF6366F1)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildRadarChip(Icons.bedtime_rounded, c.sleepCycle),
                              _buildRadarChip(Icons.headphones_rounded, c.studyEnvironment),
                              _buildRadarChip(Icons.ac_unit_rounded, c.acPreference),
                              _buildRadarChip(Icons.cleaning_services_rounded, c.cleanliness),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    provider.selectRoommateDirectly(c);
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Selected ${c.studentName} as your Room B-304 roommate!"),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  },
                                  icon: Icon(isMatched ? Icons.check_circle_rounded : Icons.person_add_rounded, size: 16),
                                  label: Text(isMatched ? "Currently Selected" : "Select Roommate"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isMatched ? AppColors.success : const Color(0xFF6366F1),
                                    foregroundColor: Colors.white,
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 1.2 30-Second Lifestyle Quiz Dialog
  void _showLifestyleQuizDialog(BuildContext context, CampusProvider provider) {
    String sleep = provider.roommateQuiz.sleepCycle;
    String study = provider.roommateQuiz.studyEnvironment;
    String ac = provider.roommateQuiz.acPreference;
    String clean = provider.roommateQuiz.cleanliness;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                "30s Lifestyle Compatibility Quiz",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Our local Gale-Shapley Stable Marriage engine pairs you with zero-conflict roommates based on these 4 vectors.",
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: sleep,
                      decoration: InputDecoration(
                        labelText: "🌙 Sleep Cycle",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Early Bird (05:00 AM)", child: Text("Early Bird (05:00 AM)")),
                        DropdownMenuItem(value: "Night Owl (02:00 AM)", child: Text("Night Owl (02:00 AM)")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => sleep = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: study,
                      decoration: InputDecoration(
                        labelText: "🎵 Study Environment",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Pin-Drop Silence", child: Text("Pin-Drop Silence")),
                        DropdownMenuItem(value: "Background Lo-Fi Music", child: Text("Background Lo-Fi Music")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => study = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: ac,
                      decoration: InputDecoration(
                        labelText: "❄️ AC Temperature Preference",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Chiller (18°C)", child: Text("Chiller (18°C)")),
                        DropdownMenuItem(value: "Moderate (24°C)", child: Text("Moderate (24°C)")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => ac = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: clean,
                      decoration: InputDecoration(
                        labelText: "🧹 Cleanliness Index",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Minimalist Clean", child: Text("Minimalist Clean")),
                        DropdownMenuItem(value: "Relaxed", child: Text("Relaxed")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => clean = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.updateRoommateQuiz(
                      sleepCycle: sleep,
                      studyEnvironment: study,
                      acPreference: ac,
                      cleanliness: clean,
                      interests: ["Coding", "System Design", "Fitness"],
                    );
                    GoBackendService.submitRoommateQuiz(provider.roommateQuiz);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Gale-Shapley radar updated: 96% compatibility confirmed!"),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Save & Run Matcher"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 6. Curfew Auto-Extension Dialog
  void _showCurfewExtensionDialog(BuildContext context, CampusProvider provider, GatePass pass) {
    String reason = "Late Lab Coding Hackathon evaluation & MP Nagar traffic jam";
    final reasonCtrl = TextEditingController(text: reason);
    int extensionMinutes = 45;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                "Request Curfew Extension (+45 Min)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Text(
                      "Parent 1-Click WhatsApp Consent: An interactive approval button will be sent to your parent. Upon their tap, your turnstile pass auto-extends to 09:15 PM without fine.",
                      style: TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: extensionMinutes,
                    decoration: InputDecoration(
                      labelText: "Extension Duration",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 30, child: Text("+30 Mins (Extended until 09:00 PM)")),
                      DropdownMenuItem(value: 45, child: Text("+45 Mins (Extended until 09:15 PM)")),
                      DropdownMenuItem(value: 60, child: Text("+60 Mins (Extended until 09:30 PM)")),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => extensionMinutes = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reasonCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Official Reason",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.requestCurfewExtension(
                      extensionMinutes: extensionMinutes,
                      reason: reasonCtrl.text.trim(),
                    );
                    GoBackendService.requestCurfewExtension(
                      gatePassId: pass.id,
                      studentRoll: provider.student.rollNumber,
                      studentName: provider.student.name,
                      roomNumber: provider.hostel.roomNumber,
                      extensionMinutes: extensionMinutes,
                      reason: reasonCtrl.text.trim(),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Extension request dispatched! Parent received WhatsApp 1-Click button."),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Send Parent WhatsApp Consent"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 4. AI Computer Vision Asset Inspection Dialog
  void _showAssetInspectionAuditDialog(BuildContext context, CampusProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "AI Vision Room Damage Audit",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Cryptographic Verification Engine: Compares Check-In (July 2024) and Check-Out (May 2026) multi-angle photos with SHA-256 digital seals.",
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Differential Damage Score: 0.00% (Normal Wear)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
                      SizedBox(height: 2),
                      Text("Deduction from Caution Deposit: ₹0.00", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
                      SizedBox(height: 2),
                      Text("Full ₹5,000 caution money protected by digital bond.", style: TextStyle(fontSize: 11, color: Color(0xFF166534))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Close"),
            ),
            ElevatedButton(
              onPressed: () {
                provider.completeAssetCheckOutInspection("AST-B304-01");
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("AI Computer Vision certified: Zero damage, full refund released!"),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Certify Zero Damage"),
            ),
          ],
        );
      },
    );
  }

  // 3. Secret Anti-Ragging Silent Duress PIN Keypad Dialog
  void _showDuressPinDialog(BuildContext context, CampusProvider provider) {
    final pinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.lock_outline_rounded, color: Color(0xFF0F172A), size: 20),
              SizedBox(width: 8),
              Text(
                "Hostel Security Access PIN",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Normal PIN: 1234 (Normal Unlock)\nSecret Duress PIN: 9999 (Under threat/ragging coercion)",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 6),
              const Text(
                "If 9999 is typed, a harmless dummy notes screen opens immediately, while silently dispatching Chief Warden & QRT with GPS coordinates (Room B-304)!",
                style: TextStyle(fontSize: 11, color: Color(0xFFDC2626), height: 1.3),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: pinCtrl,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: "Enter 4-Digit Security PIN",
                  hintText: "••••",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final pin = pinCtrl.text.trim();
                Navigator.pop(ctx);

                if (pin == "9999") {
                  // 🚨 SILENT DURESS TRIGGERED!
                  provider.verifyAndTriggerDuressPin("9999");
                  GoBackendService.triggerSilentDuress(
                    enteredPin: "9999",
                    studentRoll: provider.student.rollNumber,
                    studentName: provider.student.name,
                    roomNumber: provider.hostel.roomNumber,
                  );

                  // Open harmless dummy screen immediately so observer sees only innocent notes!
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const _DummyAcademicNotesScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Normal PIN authenticated. System safe."), backgroundColor: AppColors.success),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Verify PIN"),
            ),
          ],
        );
      },
    );
  }
}

class _AssetInventoryRow extends StatelessWidget {
  final String asset;
  final String status;
  final String tag;
  const _AssetInventoryRow({required this.asset, required this.status, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
              const SizedBox(width: 8),
              Text(asset, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ],
          ),
          Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

/// Harmless Dummy Screen displayed upon Silent Duress PIN 9999 entry
class _DummyAcademicNotesScreen extends StatelessWidget {
  const _DummyAcademicNotesScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Engineering Notes & Quick Formulae", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.notes_rounded, color: Color(0xFF475569), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "CS-601 Compiler Design: LL(1) Parsing Table & First/Follow Sets Reference Sheet",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "QUICK CALCULATOR",
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("sin(45°) * 2.718 = 1.9219", style: TextStyle(fontSize: 16, fontFamily: 'monospace', fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 12),
                  const Text("Basic standard mode calculator initialized.", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

