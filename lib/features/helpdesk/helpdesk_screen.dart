// ============================================================================
// DIGITAL CAMPUS — Multi-Universe Grievance System (UGC 48h SLA)
// Role-Based: Student | Parent | Faculty | Admin
// ============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_chip.dart';
import '../../models/campus_models.dart';
import '../../providers/campus_provider.dart';

class HelpdeskScreen extends StatefulWidget {
  const HelpdeskScreen({super.key});
  @override
  State<HelpdeskScreen> createState() => _HelpdeskScreenState();
}

class _HelpdeskScreenState extends State<HelpdeskScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final role = provider.currentRole;
    final allTickets = provider.grievances;
    final myTickets = _filterForRole(allTickets, role);
    final pendingTickets = myTickets.where((t) => t.status != 'Resolved').toList();
    final resolvedTickets = myTickets.where((t) => t.status == 'Resolved').toList();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: _buildAppBar(context, role, allTickets),
      body: Column(
        children: [
          _RoleBanner(role: role),
          if (role == UserRole.student || role == UserRole.parent)
            const _AntiRaggingStrip(),
          _buildTabBar(pendingTickets.length, resolvedTickets.length),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TicketListView(tickets: pendingTickets, role: role, emptyLabel: "No active grievances", emptyIcon: Icons.check_circle_outline_rounded),
                _TicketListView(tickets: resolvedTickets, role: role, emptyLabel: "No resolved tickets yet", emptyIcon: Icons.inbox_rounded),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _canRaiseTicket(role)
          ? FloatingActionButton.extended(
              onPressed: () => _showRaiseTicketModal(context, provider, role),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_task_rounded, size: 20),
              label: const Text("Raise Grievance", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            )
          : null,
    );
  }

  List<GrievanceTicket> _filterForRole(List<GrievanceTicket> all, UserRole role) {
    switch (role) {
      case UserRole.student:
        return all.where((t) => t.raisedByRole == 'student' && t.studentRoll == 'CS22B045').toList();
      case UserRole.parent:
        return all.where((t) => t.raisedByRole == 'parent' || (t.studentRoll == 'CS22B045' && t.raisedByRole == 'student')).toList();
      case UserRole.faculty:
        return all.where((t) => t.targetRole == 'faculty' || t.raisedByRole == 'faculty').toList();
      case UserRole.admin:
        return all;
    }
  }

  bool _canRaiseTicket(UserRole role) =>
      role == UserRole.student || role == UserRole.parent || role == UserRole.faculty;

  AppBar _buildAppBar(BuildContext context, UserRole role, List<GrievanceTicket> allTickets) {
    final pendingCount = allTickets.where((t) => t.status != 'Resolved').length;
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Grievance Management", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          Text("${AppConstants.institutionShort} • UGC 48h SLA",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
        ],
      ),
      actions: [
        if (role == UserRole.admin)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: pendingCount > 0 ? AppColors.error : AppColors.success,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text("$pendingCount OPEN",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
          ),
        const Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: Center(child: CustomChip(label: "48h Statutory SLA", color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _buildTabBar(int pendingCount, int resolvedCount) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
        tabs: [Tab(text: "ACTIVE ($pendingCount)"), Tab(text: "RESOLVED ($resolvedCount)")],
      ),
    );
  }

  void _showRaiseTicketModal(BuildContext context, CampusProvider provider, UserRole role) {
    String selectedCategory = _categoriesFor(role).first;
    String selectedPriority = "Medium";
    String? selectedTarget;
    final subjectCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.policy_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Submit Grievance Ticket", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                    Text("As: ${role.personaName}", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ]),
                ]),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(labelText: "Category", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                  items: _categoriesFor(role).map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setModal(() => selectedCategory = v ?? selectedCategory),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  decoration: InputDecoration(labelText: "Priority", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                  items: const [
                    DropdownMenuItem(value: "Low", child: Text("Low")),
                    DropdownMenuItem(value: "Medium", child: Text("Medium")),
                    DropdownMenuItem(value: "High", child: Text("High")),
                    DropdownMenuItem(value: "Critical", child: Text("Critical")),
                  ],
                  onChanged: (v) => setModal(() => selectedPriority = v ?? selectedPriority),
                ),
                const SizedBox(height: 12),
                if (role == UserRole.admin || role == UserRole.faculty) ...[
                  DropdownButtonFormField<String>(
                    value: selectedTarget,
                    hint: const Text("Forward to (optional)"),
                    decoration: InputDecoration(labelText: "Route To", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                    items: const [
                      DropdownMenuItem(value: "admin", child: Text("Admin / Dean Office")),
                      DropdownMenuItem(value: "faculty", child: Text("Subject Faculty")),
                    ],
                    onChanged: (v) => setModal(() => selectedTarget = v),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: subjectCtrl,
                  decoration: InputDecoration(labelText: "Subject / Headline", hintText: "Brief, clear summary of the issue", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: "Detailed Description", hintText: "Include dates, locations, and relevant details", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                  child: const Row(children: [
                    Icon(Icons.timer_outlined, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(child: Text("UGC Statutory SLA: 48-hour mandatory resolution window from submission.", style: TextStyle(fontSize: 11, color: AppColors.primary))),
                  ]),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (subjectCtrl.text.trim().isNotEmpty) {
                        provider.submitGrievance(
                          category: selectedCategory,
                          subject: subjectCtrl.text.trim(),
                          description: descCtrl.text.trim().isEmpty ? "Reported via Digital Campus mobile app." : descCtrl.text.trim(),
                          priority: selectedPriority,
                          targetRole: selectedTarget,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Grievance submitted. 48h SLA timer activated."), backgroundColor: AppColors.success),
                        );
                      }
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text("Submit Official Ticket", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _categoriesFor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return ["Academic & Lab", "Academic & Marks", "Hostel & Mess", "Fee & Finance", "Anti-Ragging / Security", "Transport", "Library", "Other"];
      case UserRole.parent:
        return ["Fee & Finance", "Academic Progress", "Hostel & Safety", "Anti-Ragging / Security", "Transportation", "Other"];
      case UserRole.faculty:
        return ["Faculty & Workload", "Infrastructure & Lab", "Academic Administration", "HR & Payroll", "Research Support", "Other"];
      case UserRole.admin:
        return ["Policy & Compliance", "Inter-Department", "Vendor & Procurement", "Audit & Finance", "Other"];
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _RoleBanner extends StatelessWidget {
  final UserRole role;
  const _RoleBanner({required this.role});

  Color get _color {
    switch (role) {
      case UserRole.student: return AppColors.primary;
      case UserRole.parent: return const Color(0xFF7C3AED);
      case UserRole.faculty: return const Color(0xFF0891B2);
      case UserRole.admin: return const Color(0xFFDC2626);
    }
  }

  IconData get _icon {
    switch (role) {
      case UserRole.student: return Icons.school_rounded;
      case UserRole.parent: return Icons.family_restroom_rounded;
      case UserRole.faculty: return Icons.person_rounded;
      case UserRole.admin: return Icons.admin_panel_settings_rounded;
    }
  }

  String get _subtitle {
    switch (role) {
      case UserRole.student: return "View & manage your submitted grievances";
      case UserRole.parent: return "Your grievances + your child's ticket status";
      case UserRole.faculty: return "Student tickets assigned to you + your own grievances";
      case UserRole.admin: return "Full campus oversight — all roles, all tickets";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: _color.withOpacity(0.07), border: Border(bottom: BorderSide(color: _color.withOpacity(0.2)))),
      child: Row(children: [
        Icon(_icon, color: _color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(role.displayName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _color)),
          Text(_subtitle, style: TextStyle(fontSize: 10.5, color: _color.withOpacity(0.8))),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _AntiRaggingStrip extends StatelessWidget {
  const _AntiRaggingStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFECDD3), width: 1.2)),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: const BoxDecoration(color: Color(0xFFE11D48), shape: BoxShape.circle),
          child: const Icon(Icons.shield_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text("Statutory Anti-Ragging Cell", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF881337))),
              SizedBox(width: 6),
              CustomChip(label: "AICTE Mandate", color: Color(0xFFE11D48), isSolid: true),
            ]),
            SizedBox(height: 2),
            Text("Zero-tolerance policy. 24x7 confidential reporting to Dean & Police Liaison. Anonymous filing enabled.",
                style: TextStyle(fontSize: 10.5, color: Color(0xFF9F1239), height: 1.3)),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _TicketListView extends StatelessWidget {
  final List<GrievanceTicket> tickets;
  final UserRole role;
  final String emptyLabel;
  final IconData emptyIcon;
  const _TicketListView({required this.tickets, required this.role, required this.emptyLabel, required this.emptyIcon});

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(emptyIcon, size: 52, color: AppColors.borderLight),
        const SizedBox(height: 12),
        Text(emptyLabel, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      itemCount: tickets.length,
      itemBuilder: (ctx, i) => _TicketCard(ticket: tickets[i], role: role),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _TicketCard extends StatelessWidget {
  final GrievanceTicket ticket;
  final UserRole role;
  const _TicketCard({required this.ticket, required this.role});

  Color get _priorityColor {
    switch (ticket.priority) {
      case "Critical": return const Color(0xFFDC2626);
      case "High": return const Color(0xFFEA580C);
      case "Medium": return const Color(0xFFCA8A04);
      default: return AppColors.textMuted;
    }
  }

  Color get _statusColor {
    switch (ticket.status) {
      case "Resolved": return AppColors.success;
      case "Escalated": return const Color(0xFFDC2626);
      case "Under Review": return const Color(0xFF0891B2);
      default: return AppColors.warning;
    }
  }

  IconData get _raisedByIcon {
    switch (ticket.raisedByRole) {
      case "parent": return Icons.family_restroom_rounded;
      case "faculty": return Icons.person_rounded;
      case "admin": return Icons.admin_panel_settings_rounded;
      default: return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isResolved = ticket.status == 'Resolved';
    return GestureDetector(
      onTap: () => _openDetailSheet(context),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        borderColor: ticket.isEscalated ? const Color(0xFFDC2626).withOpacity(0.5) : isResolved ? AppColors.success.withOpacity(0.3) : AppColors.borderLight,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: CustomChip(label: ticket.category, color: AppColors.primary)),
            Row(children: [
              if (ticket.isEscalated)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(8)),
                  child: const Text("ESCALATED", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                ),
              CustomChip(label: ticket.status.toUpperCase(), color: _statusColor, isSolid: true),
            ]),
          ]),
          const SizedBox(height: 8),
          Text(ticket.subject, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(ticket.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35)),
          const SizedBox(height: 10),
          Row(children: [
            Icon(_raisedByIcon, size: 13, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Expanded(child: Text("${ticket.raisedByName}  →  ${ticket.assignedOfficer}", style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted), overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("${ticket.id}  •  ${ticket.createdAt}", style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Row(children: [
              if (ticket.responses.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.chat_bubble_outline_rounded, size: 11, color: AppColors.primary),
                    const SizedBox(width: 3),
                    Text("${ticket.responses.length}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ]),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _priorityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: _priorityColor.withOpacity(0.3))),
                child: Text(ticket.priority.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _priorityColor)),
              ),
              const SizedBox(width: 6),
              if (!isResolved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ticket.remainingSlaHours < 6 ? AppColors.error.withOpacity(0.1) : AppColors.warningLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ticket.remainingSlaHours < 6 ? AppColors.error.withOpacity(0.4) : AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Text("SLA: ${ticket.remainingSlaHours}h",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: ticket.remainingSlaHours < 6 ? AppColors.error : AppColors.warning)),
                )
              else
                const Text("Resolved within SLA", style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w700)),
            ]),
          ]),
          const SizedBox(height: 10),
          _buildActionRow(context),
        ]),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context, listen: false);
    final isResolved = ticket.status == 'Resolved';

    if (isResolved) {
      return Row(children: [
        const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
        const SizedBox(width: 6),
        const Text("Ticket Closed", style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700)),
        const Spacer(),
        TextButton.icon(
          onPressed: () => _openDetailSheet(context),
          icon: const Icon(Icons.visibility_outlined, size: 14),
          label: const Text("View Thread", style: TextStyle(fontSize: 11)),
          style: TextButton.styleFrom(foregroundColor: AppColors.textMuted, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
        ),
      ]);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _ActionButton(icon: Icons.forum_outlined, label: "View / Reply", onTap: () => _openDetailSheet(context), color: AppColors.primary),
        if (role == UserRole.admin || role == UserRole.faculty)
          _ActionButton(icon: Icons.task_alt_rounded, label: "Resolve", onTap: () => _showResolveDialog(context, provider), color: AppColors.success),
        if (role == UserRole.admin)
          _ActionButton(icon: Icons.assignment_ind_outlined, label: "Assign", onTap: () => _showAssignDialog(context, provider), color: const Color(0xFF0891B2)),
        if (!ticket.isEscalated && role != UserRole.admin)
          _ActionButton(icon: Icons.arrow_upward_rounded, label: "Escalate", onTap: () {
            provider.escalateGrievance(ticket.id);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Escalated to Dean & Director Office."), backgroundColor: Color(0xFFDC2626)));
          }, color: const Color(0xFFDC2626)),
      ]),
    );
  }

  void _openDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _TicketDetailSheet(ticket: ticket, role: role),
    );
  }

  void _showResolveDialog(BuildContext context, CampusProvider provider) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Mark as Resolved", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: TextField(controller: ctrl, maxLines: 3, decoration: InputDecoration(hintText: "Provide official resolution summary...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                provider.resolveGrievance(ticket.id, ctrl.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Grievance officially resolved."), backgroundColor: AppColors.success));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
            child: const Text("Confirm Resolution"),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(BuildContext context, CampusProvider provider) {
    String selectedOfficer = "Dr. Kavita Rathore (Subject Faculty)";
    String selectedTargetRole = "faculty";
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text("Re-Assign Grievance", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              value: selectedOfficer,
              decoration: InputDecoration(labelText: "Assign To", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              items: const [
                DropdownMenuItem(value: "Dr. Kavita Rathore (Subject Faculty)", child: Text("Dr. Kavita Rathore")),
                DropdownMenuItem(value: "Mr. Rajesh Kumar (Lab Admin)", child: Text("Mr. Rajesh Kumar")),
                DropdownMenuItem(value: "Dean of Faculty Affairs", child: Text("Dean of Faculty Affairs")),
                DropdownMenuItem(value: "Finance & Accounts Office", child: Text("Finance & Accounts")),
              ],
              onChanged: (v) => set(() => selectedOfficer = v ?? selectedOfficer),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedTargetRole,
              decoration: InputDecoration(labelText: "Target Role", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              items: const [
                DropdownMenuItem(value: "faculty", child: Text("Faculty")),
                DropdownMenuItem(value: "admin", child: Text("Admin")),
              ],
              onChanged: (v) => set(() => selectedTargetRole = v ?? selectedTargetRole),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                provider.assignGrievance(ticket.id, selectedOfficer, selectedTargetRole);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Assigned to $selectedOfficer"), backgroundColor: const Color(0xFF0891B2)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0891B2), foregroundColor: Colors.white),
              child: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _ActionButton({required this.icon, required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.25))),
        child: Row(children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _TicketDetailSheet extends StatefulWidget {
  final GrievanceTicket ticket;
  final UserRole role;
  const _TicketDetailSheet({required this.ticket, required this.role});
  @override
  State<_TicketDetailSheet> createState() => _TicketDetailSheetState();
}

class _TicketDetailSheetState extends State<_TicketDetailSheet> {
  final TextEditingController _replyCtrl = TextEditingController();

  @override
  void dispose() { _replyCtrl.dispose(); super.dispose(); }

  Color _roleColor(String r) {
    switch (r) {
      case "admin": return const Color(0xFFDC2626);
      case "faculty": return const Color(0xFF0891B2);
      case "parent": return const Color(0xFF7C3AED);
      default: return AppColors.primary;
    }
  }

  IconData _roleIcon(String r) {
    switch (r) {
      case "admin": return Icons.admin_panel_settings_rounded;
      case "faculty": return Icons.person_rounded;
      case "parent": return Icons.family_restroom_rounded;
      default: return Icons.school_rounded;
    }
  }

  String _roleLabel(String r) {
    switch (r) {
      case "admin": return "Admin";
      case "faculty": return "Faculty";
      case "parent": return "Parent";
      default: return "Student";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CampusProvider>(
      builder: (ctx, prov, _) {
        final liveTicket = prov.grievances.firstWhere((t) => t.id == widget.ticket.id, orElse: () => widget.ticket);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (ctx, scroll) => Column(children: [
            Container(margin: const EdgeInsets.symmetric(vertical: 10), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(4))),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    CustomChip(label: liveTicket.category, color: AppColors.primary),
                    CustomChip(
                      label: liveTicket.status.toUpperCase(),
                      color: liveTicket.status == 'Resolved' ? AppColors.success : liveTicket.status == 'Escalated' ? const Color(0xFFDC2626) : AppColors.warning,
                      isSolid: true,
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Text(liveTicket.subject, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  Text(liveTicket.description, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
                    child: Column(children: [
                      _MetaRow(icon: Icons.confirmation_number_outlined, label: "Ticket ID", value: liveTicket.id),
                      _MetaRow(icon: Icons.calendar_today_outlined, label: "Raised On", value: liveTicket.createdAt),
                      _MetaRow(icon: Icons.person_outline_rounded, label: "Raised By", value: "${liveTicket.raisedByName} (${_roleLabel(liveTicket.raisedByRole)})"),
                      _MetaRow(icon: Icons.assignment_ind_outlined, label: "Assigned To", value: liveTicket.assignedOfficer),
                      _MetaRow(icon: Icons.timer_outlined, label: "SLA Remaining", value: liveTicket.status == "Resolved" ? "Resolved within SLA" : "${liveTicket.remainingSlaHours}h remaining"),
                      if (liveTicket.studentRoll != null)
                        _MetaRow(icon: Icons.badge_outlined, label: "Student Roll", value: liveTicket.studentRoll!),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  if (liveTicket.status == 'Resolved' && liveTicket.resolutionSummary != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: AppColors.success.withOpacity(0.07), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.success.withOpacity(0.3))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Row(children: [
                          Icon(Icons.check_circle_rounded, size: 15, color: AppColors.success),
                          SizedBox(width: 6),
                          Text("Official Resolution Summary", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.success)),
                        ]),
                        const SizedBox(height: 6),
                        Text(liveTicket.resolutionSummary!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                      ]),
                    ),
                  const Text("CONVERSATION THREAD", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.7, color: AppColors.textMuted)),
                  const SizedBox(height: 10),
                  _ThreadBubble(
                    authorRole: liveTicket.raisedByRole, authorName: liveTicket.raisedByName,
                    message: liveTicket.description, timestamp: liveTicket.createdAt,
                    isOfficialResolution: false, roleColor: _roleColor(liveTicket.raisedByRole),
                    roleIcon: _roleIcon(liveTicket.raisedByRole), roleLabel: _roleLabel(liveTicket.raisedByRole),
                  ),
                  ...liveTicket.responses.map((r) => _ThreadBubble(
                    authorRole: r.authorRole, authorName: r.authorName,
                    message: r.message, timestamp: r.timestamp,
                    isOfficialResolution: r.isOfficialResolution, roleColor: _roleColor(r.authorRole),
                    roleIcon: _roleIcon(r.authorRole), roleLabel: _roleLabel(r.authorRole),
                  )),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            if (liveTicket.status != 'Resolved')
              Container(
                padding: EdgeInsets.only(left: 14, right: 14, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 14),
                decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.borderLight))),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _replyCtrl,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Reply as ${widget.role.displayName}...",
                        hintStyle: const TextStyle(fontSize: 12.5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (_replyCtrl.text.trim().isNotEmpty) {
                        prov.replyToGrievance(liveTicket.id, _replyCtrl.text.trim());
                        _replyCtrl.clear();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ]),
              ),
          ]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _ThreadBubble extends StatelessWidget {
  final String authorRole, authorName, message, timestamp, roleLabel;
  final bool isOfficialResolution;
  final Color roleColor;
  final IconData roleIcon;
  const _ThreadBubble({required this.authorRole, required this.authorName, required this.message, required this.timestamp, required this.isOfficialResolution, required this.roleColor, required this.roleIcon, required this.roleLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isOfficialResolution ? AppColors.success.withOpacity(0.08) : roleColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isOfficialResolution ? AppColors.success.withOpacity(0.35) : roleColor.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: roleColor.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(roleIcon, size: 13, color: roleColor),
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(authorName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: roleColor)),
            Text(roleLabel, style: TextStyle(fontSize: 10, color: roleColor.withOpacity(0.7))),
          ])),
          if (isOfficialResolution)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(8)),
              child: const Text("OFFICIAL RESOLUTION", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
            ),
        ]),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(fontSize: 12.5, color: AppColors.textDark, height: 1.4)),
        const SizedBox(height: 6),
        Text(timestamp, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _MetaRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 8),
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROLE-AWARE SMART GRIEVANCE SUMMARY CARD (For Dashboards)
// ─────────────────────────────────────────────────────────────────────────────
class GrievanceSummaryCard extends StatelessWidget {
  final UserRole role;

  const GrievanceSummaryCard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final all = provider.grievances;

    List<GrievanceTicket> roleTickets;
    switch (role) {
      case UserRole.student:
        roleTickets = all.where((t) => t.raisedByRole == 'student' && t.studentRoll == 'CS22B045').toList();
        break;
      case UserRole.parent:
        roleTickets = all.where((t) => t.raisedByRole == 'parent' || (t.studentRoll == 'CS22B045' && t.raisedByRole == 'student')).toList();
        break;
      case UserRole.faculty:
        roleTickets = all.where((t) => t.targetRole == 'faculty' || t.raisedByRole == 'faculty').toList();
        break;
      case UserRole.admin:
        roleTickets = all;
        break;
    }

    final activeTickets = roleTickets.where((t) => t.status != 'Resolved').toList();
    final breachedTickets = activeTickets.where((t) => t.remainingSlaHours <= 0 || t.status == 'Escalated').toList();
    final resolvedCount = roleTickets.where((t) => t.status == 'Resolved').length;

    String headerTitle;
    String headerSub;
    Color accentColor;
    IconData headerIcon;

    switch (role) {
      case UserRole.student:
        headerTitle = "Grievance & Redressal Desk";
        headerSub = "UGC 48h Guaranteed Escalation Tracker";
        accentColor = AppColors.primary;
        headerIcon = Icons.support_agent_rounded;
        break;
      case UserRole.faculty:
        headerTitle = "Grievance Redressal Inbox";
        headerSub = "Assigned Student & Departmental Inquiries";
        accentColor = const Color(0xFF6366F1);
        headerIcon = Icons.inbox_rounded;
        break;
      case UserRole.parent:
        headerTitle = "Ward Redressal & Helpdesk";
        headerSub = "Tracking Student & Parent Inquiries";
        accentColor = const Color(0xFF0284C7);
        headerIcon = Icons.family_restroom_rounded;
        break;
      case UserRole.admin:
        headerTitle = "University Grievance Radar";
        headerSub = "Campus-wide Redressal & UGC SLA Compliance";
        accentColor = const Color(0xFFDC2626);
        headerIcon = Icons.shield_outlined;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpdeskScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: breachedTickets.isNotEmpty
                  ? const Color(0xFFFCA5A5)
                  : AppColors.borderLight,
              width: breachedTickets.isNotEmpty ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: breachedTickets.isNotEmpty
                    ? const Color(0xFFEF4444).withOpacity(0.06)
                    : Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(headerIcon, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          headerTitle,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          headerSub,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "View",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: Color(0xFF475569),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: "Active",
                      value: "${activeTickets.length}",
                      color: activeTickets.isNotEmpty
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      label: "SLA Breached",
                      value: "${breachedTickets.length}",
                      color: breachedTickets.isNotEmpty
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF64748B),
                      isAlert: breachedTickets.isNotEmpty,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      label: "Resolved",
                      value: "$resolvedCount",
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              if (breachedTickets.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFDC2626)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "${breachedTickets.length} ticket(s) require urgent action under 48h UGC SLA.",
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isAlert ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAlert ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

