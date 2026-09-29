import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_chip.dart';
import '../../models/campus_models.dart';
import '../../providers/campus_provider.dart';
import '../../core/services/document_download_service.dart';

class FeePaymentScreen extends StatelessWidget {
  const FeePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CampusProvider>(context);
    final fees = provider.fees;
    final totalDues = provider.totalDues;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Fees & Financial Ledger"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: CustomChip(
                label: "Instant GST Invoices",
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
            // Outstanding Balance Hero Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: totalDues > 0 ? AppColors.warning : AppColors.success,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
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
                      const Text(
                        "Net Outstanding Balance",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70),
                      ),
                      CustomChip(
                        label: totalDues > 0 ? "PAYMENT PENDING" : "CLEARED / NO DUES",
                        color: totalDues > 0 ? AppColors.warning : AppColors.success,
                        isSolid: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${totalDues.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: totalDues > 0 ? const Color(0xFFFBBF24) : const Color(0xFF34D399),
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      totalDues > 0
                          ? "Next Due Date: 15 October 2026 • Zero Late Fee Active"
                          : "✓ All academic, hostel, and transit dues are fully cleared.",
                      style: TextStyle(
                        fontSize: 12,
                        color: totalDues > 0 ? Colors.white70 : const Color(0xFFA7F3D0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Fee Items List
            const Text(
              "FEE BREAKDOWN & RECENT TRANSACTIONS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),

            ...fees.map((fee) {
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                borderColor: fee.isPaid ? AppColors.borderLight : AppColors.warning.withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomChip(
                          label: fee.isPaid ? "PAID" : "UNPAID",
                          color: fee.isPaid ? AppColors.success : AppColors.warning,
                          isSolid: true,
                        ),
                        Text(
                          "₹${fee.amount.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fee.title,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fee.isPaid
                          ? "Paid on ${fee.paidDate} • Ref: ${fee.transactionId}"
                          : "Due date: ${fee.dueDate}",
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    if (fee.isPaid)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                DocumentDownloadService.downloadFeeReceiptPdf(
                                  context,
                                  fee,
                                  provider.student,
                                );
                              },
                              icon: const Icon(Icons.download_rounded, size: 16),
                              label: const Text("Download GST Receipt (PDF)"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.borderLight),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showPaymentGatewayModal(context, fee, provider);
                              },
                              icon: const Icon(Icons.payment_rounded, size: 16),
                              label: const Text("Pay Now via Gateway"),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showPaymentGatewayModal(BuildContext context, FeeItem fee, CampusProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Digital Campus Payment Gateway",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                fee.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                "Amount: ₹${fee.amount.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text("Select Instant Payment Mode:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildPaymentMethodTile("UPI (GPay / PhonePe)", Icons.qr_code_scanner_rounded),
                  const SizedBox(width: 10),
                  _buildPaymentMethodTile("Debit / Credit Card", Icons.credit_card_rounded),
                  const SizedBox(width: 10),
                  _buildPaymentMethodTile("Net Banking", Icons.account_balance_rounded),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    provider.payFee(fee.id);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Payment Successful! Paid ₹${fee.amount.toStringAsFixed(0)}. GST Receipt generated."),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Simulate Instant Payment", style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodTile(String title, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textDark, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
