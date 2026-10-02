import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_chip.dart';
import '../../models/campus_models.dart';
import '../../providers/campus_provider.dart';

/// Comprehensive Executive Admin Hostel Management & Tariff Control Desk
class AdminHostelManagementScreen extends StatefulWidget {
  const AdminHostelManagementScreen({super.key});

  @override
  State<AdminHostelManagementScreen> createState() => _AdminHostelManagementScreenState();
}

class _AdminHostelManagementScreenState extends State<AdminHostelManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for dynamic fee configuration
  late TextEditingController _singleAcCtrl;
  late TextEditingController _doubleAcCtrl;
  late TextEditingController _tripleAcCtrl;
  late TextEditingController _nonAcCtrl;
  late TextEditingController _messDailyCtrl;
  late TextEditingController _messRebateCtrl;
  late TextEditingController _minLeaveCtrl;
  late TextEditingController _electricityRateCtrl;
  late TextEditingController _curfewTimeCtrl;
  late TextEditingController _curfewFineCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    final provider = Provider.of<CampusProvider>(context, listen: false);
    final p = provider.hostelFeePolicy;

    _singleAcCtrl = TextEditingController(text: p.singleRoomAcRent.toStringAsFixed(0));
    _doubleAcCtrl = TextEditingController(text: p.doubleRoomAcRent.toStringAsFixed(0));
    _tripleAcCtrl = TextEditingController(text: p.tripleRoomAcRent.toStringAsFixed(0));
    _nonAcCtrl = TextEditingController(text: p.nonAcRoomRent.toStringAsFixed(0));
    _messDailyCtrl = TextEditingController(text: p.messDailyRate.toStringAsFixed(0));
    _messRebateCtrl = TextEditingController(text: p.messRebatePerDay.toStringAsFixed(0));
    _minLeaveCtrl = TextEditingController(text: "${p.minLeaveDaysForRebate}");
    _electricityRateCtrl = TextEditingController(text: p.electricityUnitRate.toStringAsFixed(0));
    _curfewTimeCtrl = TextEditingController(text: p.curfewTime);
    _curfewFineCtrl = TextEditingController(text: p.curfewViolationFine.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _singleAcCtrl.dispose();
    _doubleAcCtrl.dispose();
    _tripleAcCtrl.dispose();
    _nonAcCtrl.dispose();
    _messDailyCtrl.dispose();
    _messRebateCtrl.dispose();
    _minLeaveCtrl.dispose();
    _electricityRateCtrl.dispose();
    _curfewTimeCtrl.dispose();
    _curfewFineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final policy = provider.hostelFeePolicy;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Hostel Administration & Tariff Desk",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              "Chief Warden ERP • Fee Structure & Policy Engine",
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: const Color(0xFF6366F1),
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
          tabs: const [
            Tab(icon: Icon(Icons.tune_rounded, size: 18), text: "Fee Policy & Tariff"),
            Tab(icon: Icon(Icons.account_balance_wallet_rounded, size: 18), text: "Financial Ledger"),
            Tab(icon: Icon(Icons.bed_rounded, size: 18), text: "Bed & Maintenance Matrix"),
            Tab(icon: Icon(Icons.security_rounded, size: 18), text: "Curfew & Passes"),
            Tab(icon: Icon(Icons.restaurant_rounded, size: 18), text: "Mess Quality Index"),
            Tab(icon: Icon(Icons.auto_awesome_rounded, size: 18), text: "AI Ultra-Smart Radar"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTariffPolicyTab(context, provider, policy),
          _buildFinancialLedgerTab(context, provider),
          _buildBedAndMaintenanceTab(context, provider),
          _buildCurfewSecurityTab(context, provider),
          _buildMessQualityTab(context, provider),
          _buildAiUltraSmartRadarTab(context, provider),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 1: DYNAMIC TARIFF & FEE POLICY ENGINE
  // ============================================================================
  Widget _buildTariffPolicyTab(BuildContext context, CampusProvider provider, HostelFeePolicy policy) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Executive Advisory Strip
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF4F46E5), size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Autonomous Financial Tariff Authority",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF312E81)),
                      ),
                      Text(
                        "Modifications made here immediately update room billing, daily mess deductions, rebate refunds, and curfew fines across the university ERP.",
                        style: TextStyle(fontSize: 11, color: Color(0xFF4338CA)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 1. Room Accommodation Rents
          const Text(
            "ROOM TYPE & ACCOMMODATION PRICING (PER SEMESTER)",
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          GlassCard(
            child: Column(
              children: [
                _buildPriceField("Single Bed Room (AC Private)", _singleAcCtrl, "₹48,000 / Sem", Icons.single_bed_rounded),
                const Divider(height: 16),
                _buildPriceField("Double Sharing (AC Premium)", _doubleAcCtrl, "₹38,000 / Sem", Icons.bed_rounded),
                const Divider(height: 16),
                _buildPriceField("Triple Sharing (AC Standard)", _tripleAcCtrl, "₹16,000 / Sem", Icons.group_rounded),
                const Divider(height: 16),
                _buildPriceField("Standard Quad (Non-AC Economy)", _nonAcCtrl, "₹12,000 / Sem", Icons.roofing_rounded),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. Mess & Dining Tariff + Rebate Rules
          const Text(
            "MESS DINING TARIFF & LEAVE REBATE FORMULA",
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          GlassCard(
            child: Column(
              children: [
                _buildPriceField("Daily 4-Meal Dining Charge (₹/Day)", _messDailyCtrl, "₹120 / Day (₹14,400 / Sem)", Icons.restaurant_rounded),
                const Divider(height: 16),
                _buildPriceField("Student Leave Rebate Rate (₹/Day)", _messRebateCtrl, "₹120 / Day Refund", Icons.savings_rounded),
                const Divider(height: 16),
                _buildPriceField("Minimum Leave Days for Rebate Eligibility", _minLeaveCtrl, "3 Days (University Policy)", Icons.calendar_today_rounded),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3. Energy, Sub-metering & Security Deposits
          const Text(
            "ELECTRICITY SUB-METER & SECURITY DEPOSIT",
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          GlassCard(
            child: Column(
              children: [
                _buildPriceField("Extra Electricity Unit Rate (Beyond 100 free units)", _electricityRateCtrl, "₹8.0 / kWh Unit", Icons.bolt_rounded),
                const Divider(height: 16),
                _buildPriceField("Curfew Deadline Time", _curfewTimeCtrl, "08:30 PM", Icons.access_time_rounded),
                const Divider(height: 16),
                _buildPriceField("Late Curfew Violation Penalty", _curfewFineCtrl, "₹250 / Offense", Icons.warning_amber_rounded),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Save & Apply Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact();
                final updatedPolicy = policy.copyWith(
                  singleRoomAcRent: double.tryParse(_singleAcCtrl.text) ?? policy.singleRoomAcRent,
                  doubleRoomAcRent: double.tryParse(_doubleAcCtrl.text) ?? policy.doubleRoomAcRent,
                  tripleRoomAcRent: double.tryParse(_tripleAcCtrl.text) ?? policy.tripleRoomAcRent,
                  nonAcRoomRent: double.tryParse(_nonAcCtrl.text) ?? policy.nonAcRoomRent,
                  messDailyRate: double.tryParse(_messDailyCtrl.text) ?? policy.messDailyRate,
                  messRebatePerDay: double.tryParse(_messRebateCtrl.text) ?? policy.messRebatePerDay,
                  minLeaveDaysForRebate: int.tryParse(_minLeaveCtrl.text) ?? policy.minLeaveDaysForRebate,
                  electricityUnitRate: double.tryParse(_electricityRateCtrl.text) ?? policy.electricityUnitRate,
                  curfewTime: _curfewTimeCtrl.text,
                  curfewViolationFine: double.tryParse(_curfewFineCtrl.text) ?? policy.curfewViolationFine,
                );

                provider.updateHostelFeePolicy(updatedPolicy);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Hostel fee policy & tariff structure saved! Updated across student ledgers."),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              icon: const Icon(Icons.save_rounded, size: 20),
              label: const Text(
                "Save & Broadcast Tariff to University ERP",
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 2: FINANCIAL COLLECTION & SUB-LEDGER
  // ============================================================================
  Widget _buildFinancialLedgerTab(BuildContext context, CampusProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Master KPI Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Semester 6 Hostel Fee Collection",
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white70),
                    ),
                    CustomChip(label: "93.8% REALIZED", color: AppColors.success, isSolid: true),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLedgerKpi("Total Billed", "₹1.31 Cr", const Color(0xFF38BDF8)),
                    _buildLedgerKpi("Total Collected", "₹1.23 Cr", AppColors.success),
                    _buildLedgerKpi("Outstanding Dues", "₹8.24 Lakh", const Color(0xFFF59E0B)),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Total Leave Rebates Disbursed: ₹48,240 (402 Days)", style: TextStyle(fontSize: 11, color: Colors.white60)),
                    Text("Caution Security: ₹22.5 L", style: TextStyle(fontSize: 11, color: Colors.white60)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Fee Defaulters Roster
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "UNPAID HOSTEL DEFAULTERS ROSTER",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.error),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Automated WhatsApp fee reminders dispatched to all 4 pending hosteller parents!"),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 14),
                label: const Text("Broadcast Reminders", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _buildDefaulterCard("Amit Verma", "0103CS211050", "B-202", "₹32,000", "Overdue by 14 Days", "+91 98930 77120"),
          _buildDefaulterCard("Rohit Jain", "0103IT211013", "B-108", "₹32,000", "Overdue by 12 Days", "+91 98263 44550"),
          _buildDefaulterCard("Deepak Sahu", "0103EC211006", "A-301", "₹32,000", "Overdue by 8 Days", "+91 94251 12380"),
          _buildDefaulterCard("Vikas Mehra", "0103CS211052", "B-302", "₹16,000", "Partial Balance Pending", "+91 98270 33900"),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 3: BED MATRIX & 24h SLA MAINTENANCE QUEUE
  // ============================================================================
  Widget _buildBedAndMaintenanceTab(BuildContext context, CampusProvider provider) {
    final blocks = provider.hostelBlocksOccupancy;
    final tickets = provider.hostelMaintenanceTickets;

    final reportedCount = tickets.where((t) => t.status == "Reported").length;
    final assignedCount = tickets.where((t) => t.status == "Assigned").length;
    final resolvedCount = tickets.where((t) => t.status == "Resolved").length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Global Capacity Matrix Summary (StarRez / Cloudbeds Style)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "CENTRAL RESIDENTIAL BED CAPACITY MATRIX",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Colors.white70),
                    ),
                    CustomChip(label: "LIVE INVENTORY", color: AppColors.success, isSolid: true),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLedgerKpi("Total Beds", "450", const Color(0xFF38BDF8)),
                    _buildLedgerKpi("Occupied", "412", const Color(0xFF4ADE80)),
                    _buildLedgerKpi("Vacant", "34", const Color(0xFFFBBF24)),
                    _buildLedgerKpi("Under Maint.", "4", const Color(0xFFF87171)),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Overall Campus Occupancy: 91.5%", style: TextStyle(fontSize: 11, color: Colors.white60)),
                    Text("Turnstile Gates: Active (Post 01 & 02)", style: TextStyle(fontSize: 11, color: Colors.white60)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "HOSTEL BLOCKS & FLOOR OCCUPANCY BREAKDOWN",
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          ...blocks.map((block) {
            final occPct = ((block.occupiedBeds / block.totalCapacity) * 100).toStringAsFixed(1);

            return GlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            block.type == "Girls" ? Icons.female_rounded : Icons.male_rounded,
                            color: block.type == "Girls" ? const Color(0xFFEC4899) : const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            block.blockName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      CustomChip(
                        label: "$occPct% FULL",
                        color: block.vacantBeds < 10 ? AppColors.warning : AppColors.success,
                        isSolid: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Warden: ${block.wardenName} (${block.wardenPhone})",
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBlockMetric("Total Capacity", "${block.totalCapacity} Beds"),
                      _buildBlockMetric("Occupied", "${block.occupiedBeds} Beds"),
                      _buildBlockMetric("Vacant Available", "${block.vacantBeds} Beds", isHighlight: true),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 18),

          // 24h SLA Maintenance Work-Order Queue
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "24h SLA ROOM SERVICE & MAINTENANCE QUEUE",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              CustomChip(
                label: "$reportedCount PENDING",
                color: reportedCount > 0 ? AppColors.warning : AppColors.success,
                isSolid: true,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Quick status pill row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Text("Reported: $reportedCount", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Text("Assigned: $assignedCount", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF3730A3))),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Text("Resolved: $resolvedCount", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF166534))),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...tickets.map((t) {
            final isReported = t.status == "Reported";
            final isAssigned = t.status == "Assigned";
            final isResolved = t.status == "Resolved";

            IconData catIcon;
            if (t.category == "Electrical") {
              catIcon = Icons.bolt_rounded;
            } else if (t.category == "Plumbing") {
              catIcon = Icons.water_drop_rounded;
            } else if (t.category == "Wi-Fi / LAN") {
              catIcon = Icons.wifi_rounded;
            } else {
              catIcon = Icons.cleaning_services_rounded;
            }

            return GlassCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              borderColor: isReported ? const Color(0xFFF59E0B).withOpacity(0.4) : (isAssigned ? const Color(0xFF6366F1).withOpacity(0.4) : AppColors.success.withOpacity(0.4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(catIcon, size: 18, color: const Color(0xFF6366F1)),
                          const SizedBox(width: 6),
                          Text("${t.category} • Room ${t.roomNumber}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        ],
                      ),
                      CustomChip(
                        label: t.status.toUpperCase(),
                        color: isResolved ? AppColors.success : (isAssigned ? const Color(0xFF6366F1) : AppColors.warning),
                        isSolid: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(t.description, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("By: ${t.studentName} (${t.rollNumber})", style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                      Text(t.reportedAt, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("Staff: ${t.assignedStaff}", style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5))),
                  if (!isResolved) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (isReported) ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                provider.assignHostelMaintenanceTicket(t.id, "Campus Duty Technician");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Ticket ${t.id} assigned to Duty Technician."), backgroundColor: const Color(0xFF6366F1)),
                                );
                              },
                              icon: const Icon(Icons.person_add_rounded, size: 14),
                              label: const Text("Assign Tech", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF6366F1),
                                side: const BorderSide(color: Color(0xFF6366F1)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              provider.resolveHostelMaintenanceTicket(t.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Ticket ${t.id} marked as Resolved!"), backgroundColor: AppColors.success),
                              );
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 14),
                            label: const Text("Mark Resolved", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 4: CURFEW & GATE PASS DESK
  // ============================================================================
  Widget _buildCurfewSecurityTab(BuildContext context, CampusProvider provider) {
    final passes = provider.gatePasses;
    final overduePasses = passes.where((p) => p.isCurfewBreached && p.status != "Closed").toList();
    final pendingPasses = passes.where((p) => p.status == "Pending").toList();
    final activePasses = passes.where((p) => p.status != "Pending").toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Curfew Overdue Warning Watchdog (High Priority Alert)
          if (overduePasses.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "⚠️ HIGH PRIORITY: NIGHT CURFEW BREACH RADAR",
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF991B1B)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${overduePasses.length} student(s) still outside campus after 08:30 PM curfew cut-off. Immediate warden protocol initiated.",
                    style: const TextStyle(fontSize: 11, color: Color(0xFFB91C1C)),
                  ),
                  const SizedBox(height: 12),
                  ...overduePasses.map((p) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${p.studentName} (${p.rollNumber})", style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF991B1B))),
                              CustomChip(label: "OVERDUE", color: AppColors.error, isSolid: true),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("Dest: ${p.destination} • Expected In: ${p.expectedInDateTime}", style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                          Text("Parent Contact: ${p.parentPhone}", style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Initiating call to Parent (${p.parentPhone})..."), backgroundColor: const Color(0xFF2563EB)),
                                    );
                                  },
                                  icon: const Icon(Icons.phone_rounded, size: 14),
                                  label: const Text("Call Parent", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Automated Curfew Fine Notice (₹${provider.hostelFeePolicy.curfewViolationFine.toStringAsFixed(0)}) sent via WhatsApp to ${p.parentPhone}!"),
                                        backgroundColor: const Color(0xFF25D366),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.send_rounded, size: 14),
                                  label: const Text("WhatsApp Alert", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Night Curfew Protocol Active (08:30 PM Cut-off)",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF166534)),
                        ),
                        Text(
                          "All students verified inside campus. Zero curfew breaches currently.",
                          style: TextStyle(fontSize: 11, color: Color(0xFF15803D)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          // 1-Tap Gate Pass Approval Desk
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "E-GATE PASS APPROVAL DESK (PENDING)",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              CustomChip(
                label: "${pendingPasses.length} PENDING",
                color: pendingPasses.isNotEmpty ? AppColors.warning : AppColors.success,
                isSolid: true,
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (pendingPasses.isNotEmpty) ...[
            ...pendingPasses.map((pass) {
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                borderColor: const Color(0xFFF59E0B).withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${pass.studentName} (${pass.rollNumber})", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        CustomChip(label: "PENDING WARDEN", color: AppColors.warning, isSolid: true),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text("Reason: ${pass.reason} ➔ ${pass.destination}", style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    Text("Out: ${pass.outDateTime} | Expected In: ${pass.expectedInDateTime}", style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              provider.approveGatePass(pass.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gate Pass ${pass.id} Approved with Cryptographic Seal!"), backgroundColor: AppColors.success),
                              );
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 14),
                            label: const Text("1-Tap Approve", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              provider.rejectGatePass(pass.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gate Pass ${pass.id} Rejected."), backgroundColor: AppColors.error),
                              );
                            },
                            icon: const Icon(Icons.cancel_rounded, size: 14),
                            label: const Text("Reject", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
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
          ] else ...[
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: const [
                  Icon(Icons.task_alt_rounded, color: AppColors.success, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "All pending outpass and leave requests have been reviewed and signed.",
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Emergency Red SOS Monitoring Radar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "CAMPUS EMERGENCY RED SOS DISPATCH RADAR",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              CustomChip(
                label: provider.isSosActive ? "CRITICAL ALARM" : "ALL QUIET",
                color: provider.isSosActive ? AppColors.error : AppColors.success,
                isSolid: true,
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (provider.isSosActive) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.warning_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "🚨 ACTIVE PANIC ALARM IN ${provider.hostel.blockName}!",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF991B1B)),
                        ),
                        Text(
                          "Student ${provider.student.name} (${provider.student.rollNumber}) at Room ${provider.hostel.roomNumber}. Campus QRT dispatched.",
                          style: const TextStyle(fontSize: 11, color: Color(0xFFB91C1C), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      provider.resolveHostelSos(provider.hostelSosLogs.first.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Emergency alarm cleared & logged."), backgroundColor: AppColors.success),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Clear Alert", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ] else ...[
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: const [
                  Icon(Icons.shield_rounded, color: AppColors.success, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Zero active SOS panic signals. Quick Response Team (QRT) standing by at Security Post 01.",
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Mutual Room Swap Warden NOC Desk (IIT BITS SWD)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "MUTUAL ROOM SWAP DESK (WARDEN NOC)",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              CustomChip(label: "SWD PROTOCOL", color: Color(0xFF6366F1), isSolid: true),
            ],
          ),
          const SizedBox(height: 8),

          ...provider.roomSwaps.map((swap) {
            final isPeerApproved = swap.status == "Peer Approved";

            return GlassCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              borderColor: isPeerApproved ? const Color(0xFF6366F1).withOpacity(0.4) : AppColors.success.withOpacity(0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomChip(
                        label: swap.status.toUpperCase(),
                        color: isPeerApproved ? const Color(0xFF6366F1) : AppColors.success,
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
                            Text(swap.requesterStudentName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                            Text("${swap.requesterRoll} • ${swap.currentRoom}", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.swap_horiz_rounded, color: Color(0xFF6366F1), size: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(swap.targetStudentName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                            Text("${swap.targetRoll} • ${swap.targetRoom}", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Reason: ${swap.reason}", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  if (isPeerApproved) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          provider.approveRoomSwapByWarden(swap.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Room Swap Digitally Signed! NOC Certificate issued to both students."),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        icon: const Icon(Icons.verified_rounded, size: 16),
                        label: const Text("Digitally Sign & Grant Warden NOC"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 18),

          const Text(
            "RECENT OUTPASS & GATE CHECK-OUT REQUESTS",
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          ...activePasses.map((pass) {
            Color statusColor = AppColors.success;
            if (pass.status == "Out of Campus") {
              statusColor = const Color(0xFFF59E0B);
            } else if (pass.status == "Rejected") {
              statusColor = AppColors.error;
            }

            return GlassCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.badge_rounded, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${pass.studentName} (${pass.rollNumber})",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                        Text(
                          "${pass.reason} ➔ ${pass.destination}",
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                        Text(
                          "Expected Return: ${pass.expectedInDateTime}",
                          style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  CustomChip(label: pass.status.toUpperCase(), color: statusColor, isSolid: true),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 5: MESS QUALITY INDEX & REBATE CLAIMS
  // ============================================================================
  Widget _buildMessQualityTab(BuildContext context, CampusProvider provider) {
    final feedbacks = provider.messFeedbacks;
    final rebates = provider.messRebates;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mess Quality Index Executive Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "MESS QUALITY & NUTRITION INDEX (MQI)",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Colors.white70),
                    ),
                    CustomChip(label: "4.5 / 5.0 ⭐", color: Color(0xFFFBBF24), isSolid: true),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLedgerKpi("Breakfast", "4.4 ⭐", Colors.white),
                    _buildLedgerKpi("Lunch", "4.8 ⭐", const Color(0xFF6EE7B7)),
                    _buildLedgerKpi("High Tea", "4.2 ⭐", Colors.white),
                    _buildLedgerKpi("Dinner", "4.6 ⭐", const Color(0xFF6EE7B7)),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Overall Student Satisfaction: 94.8%", style: TextStyle(fontSize: 11, color: Colors.white70)),
                    Text("Daily Calories Served: 1,900 kcal", style: TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Mess Rebate Fee Refund Claims
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "STUDENT MESS REBATE CLAIMS (₹120/DAY)",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              CustomChip(label: "${rebates.length} CLAIMS", color: const Color(0xFF059669), isSolid: true),
            ],
          ),
          const SizedBox(height: 10),

          ...rebates.map((rebate) {
            final isCredited = rebate.status == "Approved & Credited";

            return GlassCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              borderColor: isCredited ? AppColors.success.withOpacity(0.4) : const Color(0xFF059669).withOpacity(0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${rebate.studentName} (${rebate.rollNumber})", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      CustomChip(
                        label: isCredited ? "CREDITED" : "PENDING CREDIT",
                        color: isCredited ? AppColors.success : const Color(0xFF059669),
                        isSolid: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("Reason: ${rebate.reason}", style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  Text("Duration: ${rebate.startDate} to ${rebate.endDate} (${rebate.days} Days)", style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Rebate Refund: ₹${rebate.rebateAmount.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                      if (!isCredited) ...[
                        ElevatedButton.icon(
                          onPressed: () {
                            provider.approveMessRebate(rebate.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("₹${rebate.rebateAmount.toStringAsFixed(0)} Mess Refund Credited to ${rebate.studentName}'s Fee Ledger!"),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          icon: const Icon(Icons.account_balance_wallet_rounded, size: 14),
                          label: const Text("Credit to Ledger", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 18),

          // Daily Student Feedback Logs
          const Text(
            "LIVE STUDENT DINING REVIEWS & RATINGS",
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          ...feedbacks.map((f) {
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF059669).withOpacity(0.1),
                    child: Text("${f.rating}★", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(f.mealType, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                            Text(f.timestamp, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(f.comment, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================================
  // HELPER WIDGETS
  // ============================================================================

  Widget _buildPriceField(String label, TextEditingController controller, String hint, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6366F1)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              Text("Current: $hint", style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            ],
          ),
        ),
        SizedBox(
          width: 95,
          height: 38,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
            decoration: InputDecoration(
              prefixText: "₹",
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerKpi(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.white70)),
      ],
    );
  }

  Widget _buildDefaulterCard(String name, String roll, String room, String amount, String note, String phone) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      borderColor: AppColors.error.withOpacity(0.3),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.error.withOpacity(0.1),
            child: Text(name[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.error)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                Text("$roll • Room $room", style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                Text(note, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.error)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.error)),
              const Text("UNPAID", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.error)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlockMetric(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isHighlight ? AppColors.success : AppColors.textDark,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  // ============================================================================
  // TAB 6: AI ULTRA-SMART INNOVATIONS & CHIEF WARDEN COMMAND RADAR
  // ============================================================================
  Widget _buildAiUltraSmartRadarTab(BuildContext context, CampusProvider provider) {
    final matchSetting = provider.matchmakerSetting;
    final forecast = provider.messForecast;
    final isDuress = provider.isSilentDuressTriggered;
    final duress = provider.silentDuress;
    final greenDorm = provider.greenDormEnergy;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. AI Stable-Marriage Roommate Matchmaking & Self-Discovery ────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "1. AI STABLE-MARRIAGE ROOMMATE MATCHMAKER",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              CustomChip(label: "GALE-SHAPLEY ENGINE", color: Color(0xFF6366F1), isSolid: true),
            ],
          ),
          const SizedBox(height: 10),

          GlassCard(
            borderColor: const Color(0xFF6366F1).withOpacity(0.4),
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
                            color: const Color(0xFF6366F1).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.people_alt_rounded, color: Color(0xFF6366F1), size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Zero-Conflict Roommate Allotment",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            ),
                            Text(
                              "Gale-Shapley Stable Marriage on Sleep, Study & AC vectors",
                              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "${matchSetting.averageMatchScore}% AVG",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF6366F1)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBlockMetric("Quizzes Done", "${matchSetting.totalQuizSubmissions}"),
                    _buildBlockMetric("Matched Pairs", "${matchSetting.matchedPairsCount}", isHighlight: true),
                    _buildBlockMetric("Zero Conflicts", "100%", isHighlight: true),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Admin Policy Toggle for Student Self-Discovery vs Auto-Allocation
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    "Allow Students to Discover & Pick Roommates Directly",
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  subtitle: const Text(
                    "When ON, students browse compatible profiles & pick. When OFF, Chief Warden auto-allocates via Gale-Shapley.",
                    style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                  ),
                  value: matchSetting.isSelfDiscoveryEnabled,
                  activeColor: const Color(0xFF6366F1),
                  onChanged: (val) {
                    provider.toggleRoommateSelfDiscovery(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val ? "Self-Discovery enabled for students!" : "Self-Discovery locked. Strict Gale-Shapley active."),
                        backgroundColor: const Color(0xFF6366F1),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.runGaleShapleyMatchmaking();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("⚡ Gale-Shapley batch matcher executed! All unallocated hostellers paired."),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.sync_rounded, size: 16),
                    label: const Text("Run Gale-Shapley Stable Marriage Batch"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── 2. AI Predictive Mess Headcount & Food Waste Minimizer ────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "2. AI PREDICTIVE MESS HEADCOUNT RADAR",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              CustomChip(label: "SAVES ₹6-8L/YEAR", color: AppColors.success, isSolid: true),
            ],
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
                          child: const Icon(Icons.soup_kitchen_rounded, color: AppColors.success, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Chef Kitchen Live Predictive Dispatch",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            ),
                            Text(
                              "Synced with Out-Pass Turnstile + 6 PM Student Intent",
                              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "${forecast.expectedDiningCount} DINING",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.success),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBlockMetric("Total Hostellers", "${forecast.totalHostellers}"),
                    _buildBlockMetric("Gate Pass Out", "-${forecast.gatePassOutCount}"),
                    _buildBlockMetric("Skipping Dinner", "-${forecast.voluntarySkippingCount}"),
                    _buildBlockMetric("Food Saved", "${forecast.foodSavedKg} kg", isHighlight: true),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.savings_rounded, color: AppColors.success, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Chef Alert: Cook ${forecast.recommendedRiceKg} kg rice (instead of ${forecast.baselineRiceKg} kg baseline). Saved ₹${forecast.dailyRupeesSaved.toStringAsFixed(0)} tonight (Projected ₹${(forecast.annualProjectedSavings / 100000).toStringAsFixed(1)} Lakh/Year savings)!",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D), height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── 3. Silent Duress Anti-Ragging Threat PIN Radar ───────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "3. SILENT DURESS ANTI-RAGGING PANIC RADAR",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              CustomChip(
                label: isDuress ? "🚨 RED ALARM ACTIVE" : "STANDBY READY",
                color: isDuress ? AppColors.error : AppColors.success,
                isSolid: true,
              ),
            ],
          ),
          const SizedBox(height: 10),

          GlassCard(
            borderColor: isDuress ? AppColors.error : AppColors.borderLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDuress ? AppColors.error : const Color(0xFF0F172A)).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.shield_outlined, color: isDuress ? AppColors.error : const Color(0xFF0F172A), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDuress ? "🚨 ACTIVE SILENT DURESS BEACON!" : "Campus Anti-Ragging Secret Duress Watchdog",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isDuress ? AppColors.error : AppColors.textDark,
                            ),
                          ),
                          Text(
                            isDuress ? "Student under coercion entered Secret PIN 9999" : "Secret PIN 9999 dispatches Chief Warden & QRT without blowing student cover",
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isDuress) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Target: ${duress.studentName} (${duress.studentRoll})",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF991B1B)),
                        ),
                        Text(
                          "Coordinates: ${duress.gpsCoordinates}",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFB91C1C)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Campus Quick Response Team (QRT) dispatched with priority sirens. Student phone is showing dummy notes screen.",
                          style: TextStyle(fontSize: 10.5, color: Color(0xFF7F1D1D)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        provider.resolveSilentDuress();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Silent alarm marked resolved. Area secured by QRT."), backgroundColor: AppColors.success),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Resolve Silent Alarm (Security Cleared)"),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── 4. AI Computer Vision Room Damage & Caution Deposit Audit ─────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "4. AI ROOM ASSET DAMAGE & CAUTION MONEY AUDIT",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              CustomChip(label: "DIGITAL BOND SECURED", color: AppColors.success, isSolid: true),
            ],
          ),
          const SizedBox(height: 10),

          GlassCard(
            borderColor: AppColors.success.withOpacity(0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Room B-304 Asset Differential Audit (Zero Caution Dispute)",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Comparing July 2024 Check-in photos with May 2026 Check-out photos via SHA-256 digital seals.",
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                ...provider.roomAssetInspections.map((a) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(a.assetName, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                        ),
                        const CustomChip(label: "0.00% DAMAGE • SAFE", color: AppColors.success),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Caution Money Approved: ₹5,000 refund certified with zero dispute!"),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.verified_rounded, size: 16),
                    label: const Text("Approve Full ₹5,000 Caution Refund"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── 5. Green Dorm IoT Energy Quota & Eco-Credits Leaderboard ───────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "5. GREEN DORM IOT ENERGY & ECO-CREDITS",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
              ),
              CustomChip(label: "FLOOR 2 CHAMPION", color: AppColors.success, isSolid: true),
            ],
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
                    Text("Monthly Free Quota: ${greenDorm.monthlyQuotaUnits.toInt()} kWh", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    Text("Consumed: ${greenDorm.consumedUnits} kWh", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.success)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: Color(0xFFEAB308), size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Eco-Champion Wing: ${greenDorm.wingRank}\nReward Perk: ${greenDorm.perkReward}",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

