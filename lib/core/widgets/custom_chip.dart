import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool isSolid;

  const CustomChip({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primary,
    this.isSolid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSolid ? color : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSolid ? color : color.withOpacity(0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: isSolid ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSolid ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}
