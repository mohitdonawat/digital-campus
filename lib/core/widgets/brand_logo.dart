import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Ultra-crisp, Modern Brand Logo & Emblem for Digital Campus SaaS Platform
class BrandLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showTenant;
  final bool isDark;
  final String? tenantText;

  const BrandLogo({
    super.key,
    this.size = 40.0,
    this.showText = false,
    this.showTenant = false,
    this.isDark = false,
    this.tenantText,
  });

  const BrandLogo.compact({
    super.key,
    this.size = 36.0,
  })  : showText = false,
        showTenant = false,
        isDark = false,
        tenantText = null;

  const BrandLogo.banner({
    super.key,
    this.size = 42.0,
    this.isDark = false,
    this.tenantText,
  })  : showText = true,
        showTenant = true;

  const BrandLogo.hero({
    super.key,
    this.size = 96.0,
    this.isDark = false,
    this.tenantText,
  })  : showText = true,
        showTenant = true;

  @override
  Widget build(BuildContext context) {
    final emblem = _buildModernEmblem(size);

    if (!showText) {
      return emblem;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emblem,
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "DIGITAL",
                  style: TextStyle(
                    fontSize: size * 0.40,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "CAMPUS",
                  style: TextStyle(
                    fontSize: size * 0.40,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryLight,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "SaaS ERP",
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            if (showTenant) ...[
              const SizedBox(height: 2),
              Text(
                tenantText ?? "${AppConstants.institutionShort} • Smart Campus Cloud",
                style: TextStyle(
                  fontSize: (size * 0.26).clamp(10.0, 12.0),
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildModernEmblem(double s) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(s * 0.28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.25),
            blurRadius: s * 0.3,
            offset: Offset(0, s * 0.08),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Geometric inner glow / diamond
          Transform.rotate(
            angle: 0.785398, // 45 degrees
            child: Container(
              width: s * 0.55,
              height: s * 0.55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(s * 0.12),
                color: Colors.white.withOpacity(0.12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 0.8,
                ),
              ),
            ),
          ),
          // Academic Cap & AI Spark Core Icon
          Center(
            child: Icon(
              Icons.school_rounded,
              size: s * 0.52,
              color: Colors.white,
            ),
          ),
          // Small golden tech-node accent at top right
          Positioned(
            top: s * 0.16,
            right: s * 0.16,
            child: Container(
              width: s * 0.16,
              height: s * 0.16,
              decoration: BoxDecoration(
                color: const Color(0xFFFFBE0B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFBE0B).withOpacity(0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
