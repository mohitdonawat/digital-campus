import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _HelpdeskScreenState extends State<HelpdeskScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedCategory = "Academic & Lab";
  final String _selectedPriority = "Medium";

  @override
  void dispose() {
    _subjectController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final tickets = provider.grievances;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Student Helpdesk & Grievance"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: CustomChip(
                label: "48h Statutory SLA",
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
            // Anti-Ragging Statutory Protection Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFECDD3), width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE11D48),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Statutory Anti-Ragging Cell",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF881337)),
                            ),
                            SizedBox(width: 6),
                            CustomChip(label: "AICTE Mandate", color: AppColors.error, isSolid: true),
                          ],
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Zero-tolerance campus safety policy. 24x7 confidential escalation to Dean & Police Liaison officer.",
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF9F1239), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Raise New Grievance Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showRaiseTicketModal(context, provider),
                icon: const Icon(Icons.add_task_rounded, size: 18),
                label: const Text("Raise New Helpdesk Grievance", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Active Grievances List
            const Text(
              "ACTIVE GRIEVANCES & SLA TIMELINES",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),

            ...tickets.map((ticket) {
              final isResolved = ticket.status == "Resolved";
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                borderColor: isResolved ? AppColors.borderLight : AppColors.warning.withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomChip(label: ticket.category, color: AppColors.primary),
                        CustomChip(
                          label: ticket.status.toUpperCase(),
                          color: isResolved ? AppColors.success : AppColors.warning,
                          isSolid: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticket.subject,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.description,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Officer: ${ticket.assignedOfficer}",
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                        ),
                        if (!isResolved)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                            ),
                            child: Text(
                              "SLA: ${ticket.remainingSlaHours}h remaining",
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.warning),
                            ),
                          )
                        else
                          const Text(
                            "Resolved within SLA ✓",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.success),
                          ),
                      ],
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

  void _showRaiseTicketModal(BuildContext context, CampusProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Submit Digital Grievance Ticket",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tracked by University Grievance Cell with strict SLA monitoring.",
                    style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Academic & Lab", child: Text("Academic & Lab")),
                      DropdownMenuItem(value: "Hostel & Mess", child: Text("Hostel & Mess")),
                      DropdownMenuItem(value: "Fee & Finance", child: Text("Fee & Finance")),
                      DropdownMenuItem(value: "Anti-Ragging / Security", child: Text("Anti-Ragging / Security")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => _selectedCategory = val);
                        setState(() => _selectedCategory = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: "Subject / Headline",
                      hintText: "Brief summary of the issue",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Detailed Description",
                      hintText: "Provide all relevant details for faster resolution",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_subjectController.text.isNotEmpty) {
                          provider.submitGrievance(
                            subject: _subjectController.text,
                            description: _descController.text.isEmpty
                                ? "Reported via mobile application"
                                : _descController.text,
                            category: _selectedCategory,
                            priority: _selectedPriority,
                          );
                          _subjectController.clear();
                          _descController.clear();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Grievance ticket created! Statutory 48h SLA timer active."),
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
                      child: const Text("Submit Official Ticket", style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
