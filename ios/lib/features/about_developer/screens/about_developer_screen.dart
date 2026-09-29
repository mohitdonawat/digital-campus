import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  Future<void> _launchExternalUrl(BuildContext context, String urlString) async {
    try {
      String formatted = urlString.trim();
      if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
        formatted = 'https://$formatted';
      }
      final uri = Uri.parse(formatted);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $urlString'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _searchGoogle(BuildContext context, String query) {
    final searchUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
    _launchExternalUrl(context, searchUrl);
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Interactive Modal for Yansmap
  void _showYansmapDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProjectDetailsSheet(
        title: 'YANSMAP',
        tagline: 'Interactive Geolocation & Digital Discovery Platform',
        websiteUrl: 'https://yansmap.web.app',
        searchQuery: 'what is Yansmap web app Mohit Donawat',
        badgeColor: const Color(0xFF10B981),
        icon: Icons.map_rounded,
        description:
            'YANSMAP is a cutting-edge web platform conceived, architected, and built by Mr. Mohit Donawat.\n\n'
            'Designed with advanced mapping algorithms, spatial interactivity, and seamless web experiences, '
            'YANSMAP solves navigation, local discovery, and real-time visualization challenges with high performance.',
        keyFeatures: const [
          'High-performance interactive digital map engine',
          'Modern web architecture built on scalable cloud infrastructure',
          'Sleek, fluid UI with intuitive touch and geospatial interactions',
          'Developed independently as part of Mohit\'s visionary portfolio',
        ],
        onLaunchUrl: (url) => _launchExternalUrl(context, url),
        onSearchGoogle: (q) => _searchGoogle(context, q),
        onCopy: (url) => _copyToClipboard(context, url, 'YANSMAP URL'),
      ),
    );
  }

  /// Interactive Modal for Wildus
  void _showWildusDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProjectDetailsSheet(
        title: 'WILDUS',
        tagline: 'Flagship Technology Venture & Cloud Operating Platform',
        websiteUrl: 'https://wildus.app',
        searchQuery: 'Wildus app Mohit Donawat CEO Architect',
        badgeColor: const Color(0xFF6366F1),
        icon: Icons.hub_rounded,
        description:
            'WILDUS is the flagship technology company and digital ecosystem founded by Mr. Mohit Donawat.\n\n'
            'As Solo Founder, CEO & Lead Architect, Mohit directs the vision, system engineering, and user '
            'experience design across modern web, distributed cloud apps, and next-generation utility systems.',
        keyFeatures: const [
          'Unified suite of enterprise and digital lifestyle solutions',
          'Microservice architecture engineered for high concurrency',
          'Zero-compromise design aesthetics and fluid micro-animations',
          'Pioneering independent technology from Bhopal to the global stage',
        ],
        onLaunchUrl: (url) => _launchExternalUrl(context, url),
        onSearchGoogle: (q) => _searchGoogle(context, q),
        onCopy: (url) => _copyToClipboard(context, url, 'WILDUS URL'),
      ),
    );
  }

  /// Interactive Modal for Wingman AI
  void _showWingmanDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProjectDetailsSheet(
        title: 'Wingman AI',
        tagline: 'Autonomous AI Copilot & Productivity Intelligence',
        websiteUrl: 'https://mohitdonawat.wildus.app',
        searchQuery: 'Wingman AI Mohit Donawat',
        badgeColor: const Color(0xFFF59E0B),
        icon: Icons.psychology_rounded,
        description:
            'Wingman AI is an innovative artificial intelligence assistant engineered by Mohit Donawat to '
            'serve as a proactive copilot for creators, developers, and students.\n\n'
            'It combines natural language understanding, context awareness, and predictive tooling to supercharge everyday workflows.',
        keyFeatures: const [
          'Intelligent conversational copilot with contextual memory',
          'Smart workflow automation for developers and learners',
          'Clean, minimalist interface with rapid response latency',
          'Engineered using cutting-edge LLM pipelines and prompt topologies',
        ],
        onLaunchUrl: (url) => _launchExternalUrl(context, url),
        onSearchGoogle: (q) => _searchGoogle(context, q),
        onCopy: (url) => _copyToClipboard(context, url, 'Wingman AI Portfolio Link'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header Sliver with Gradient & Avatar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3B0764),
                      Color(0xFF1E1B4B),
                      Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Glow Circles
                    Positioned(
                      top: 40,
                      right: 20,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondary.withOpacity(0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF6366F1).withOpacity(0.12),
                        ),
                      ),
                    ),

                    // Profile Content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Avatar with Founder Glow Ring
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF6366F1)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: AppColors.surface,
                            child: const Text(
                              'MD',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.secondary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Name
                        const Text(
                          'Mr. Mohit Donawat',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Title / Role Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, color: AppColors.secondary, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'Solo Founder, CEO & System Architect',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),

                        // University & Degree
                        Text(
                          'IES University, Bhopal • BCA 3rd Sem',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Samarpan & Heartfelt College Dedication Card
                  _buildDedicationCard(context),

                  const SizedBox(height: 24),

                  // Quick Action Buttons (Portfolio, Google Search)
                  Row(
                    children: [
                      // Open Portfolio Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchExternalUrl(context, 'https://mohitdonawat.wildus.app'),
                          icon: const Icon(Icons.language_rounded, size: 18),
                          label: const Text(
                            'Portfolio',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.black,
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Search Google Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _searchGoogle(context, 'Mohit Donawat Wildus IES'),
                          icon: const Icon(Icons.search_rounded, size: 18),
                          label: const Text(
                            'Google Search',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Section Title: Ventures & Creations
                  const Text(
                    'Ventures & Digital Innovations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap any project to inspect description, launch directly, or search on Google.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Project 1: YANSMAP
                  _buildProjectCard(
                    context,
                    title: 'YANSMAP',
                    badge: 'MAPS & DISCOVERY',
                    url: 'yansmap.web.app',
                    accentColor: const Color(0xFF10B981),
                    icon: Icons.map_rounded,
                    shortDesc: 'Interactive spatial navigation and dynamic web discovery platform.',
                    onTap: () => _showYansmapDetails(context),
                  ),

                  const SizedBox(height: 12),

                  // Project 2: WILDUS
                  _buildProjectCard(
                    context,
                    title: 'WILDUS',
                    badge: 'FLAGSHIP VENTURE',
                    url: 'wildus.app',
                    accentColor: const Color(0xFF6366F1),
                    icon: Icons.hub_rounded,
                    shortDesc: 'Next-gen cloud ecosystems, digital operating systems & modern architecture.',
                    onTap: () => _showWildusDetails(context),
                  ),

                  const SizedBox(height: 12),

                  // Project 3: Wingman AI
                  _buildProjectCard(
                    context,
                    title: 'Wingman AI',
                    badge: 'AI COPILOT',
                    url: 'mohitdonawat.wildus.app',
                    accentColor: const Color(0xFFF59E0B),
                    icon: Icons.psychology_rounded,
                    shortDesc: 'Autonomous intelligence assistant and contextual productivity copilot.',
                    onTap: () => _showWingmanDetails(context),
                  ),

                  const SizedBox(height: 28),

                  // Section: The Vision & Architecture Story
                  _buildStoryCard(context),

                  const SizedBox(height: 28),

                  // Direct Links List
                  _buildLinksSection(context),

                  const SizedBox(height: 40),

                  // Footer Copyright & College Pride
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
                          ),
                          child: ClipOval(
                            child: Image.asset('assets/logo.webp', fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          AppStrings.collegeName,
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Empowering Education Digitally • Crafted with Passion & Pride',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dedication / Samarpan Card
  Widget _buildDedicationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF831843), Color(0xFF4C0519), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFB7185).withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBE123C).withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFB7185).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded, color: Color(0xFFFB7185), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'College Ke Liye Samarpan & Pyar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Initiative & Vision behind IES E Campus',
                      style: TextStyle(color: Color(0xFFFDA4AF), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '“IES E Campus is not just an app — it is a heartfelt tribute and dedicated technological gift to my beloved college, teachers, and fellow students.\n\n'
            'As a student of BCA 3rd Semester at IES University, I saw the challenges our campus faced in attendance tracking, timetables, live streaming, quizzes, and notice distribution. Instead of waiting for third-party corporate vendors, I took the initiative to architect a complete, world-class digital campus ecosystem from scratch — out of pure respect and dedication for IES.”',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.55,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— Mr. Mohit Donawat (Creator & Architect)',
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Project Showcase Card
  Widget _buildProjectCard(
    BuildContext context, {
    required String title,
    required String badge,
    required String url,
    required Color accentColor,
    required IconData icon,
    required String shortDesc,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shortDesc,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.link_rounded, color: accentColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        url,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Tap to inspect',
                        style: TextStyle(color: AppColors.textHint, fontSize: 11),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Story & Architecture Card
  Widget _buildStoryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.engineering_rounded, color: AppColors.secondary, size: 20),
              SizedBox(width: 8),
              Text(
                'Engineering & Architecture Behind IES E Campus',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'As Solo Founder & CEO of WILDUS, Mohit Donawat leveraged enterprise design patterns to build IES E Campus with:\n\n'
            '• Real-time Firebase Cloud Datastores with anti-tamper security rules\n'
            '• Role-based access control (Student, Faculty, HOD & College Admin)\n'
            '• 100% Free Live Streaming studio with YouTube Live & Jitsi Meet\n'
            '• Automated PDF Bonafide certificate generation & digital dispatch\n'
            '• Smart attendance calculation with 75% threshold alerts\n'
            '• Targeted batch filters for seamless campus-wide notifications',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  /// Direct Links List
  Widget _buildLinksSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Official Links & Profiles',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _linkRow(
            context,
            title: 'Personal Portfolio',
            url: 'https://mohitdonawat.wildus.app',
            icon: Icons.person_pin_rounded,
          ),
          const Divider(color: Colors.white10, height: 16),
          _linkRow(
            context,
            title: 'WILDUS Portal',
            url: 'https://wildus.app',
            icon: Icons.business_center_rounded,
          ),
          const Divider(color: Colors.white10, height: 16),
          _linkRow(
            context,
            title: 'YANSMAP Web App',
            url: 'https://yansmap.web.app',
            icon: Icons.travel_explore_rounded,
          ),
        ],
      ),
    );
  }

  Widget _linkRow(BuildContext context, {required String title, required String url, required IconData icon}) {
    return InkWell(
      onTap: () => _launchExternalUrl(context, url),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(url, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _copyToClipboard(context, url, title),
            icon: const Icon(Icons.copy_rounded, color: Colors.white60, size: 16),
            tooltip: 'Copy link',
          ),
          const Icon(Icons.open_in_new_rounded, color: AppColors.secondary, size: 16),
        ],
      ),
    );
  }
}

/// Project Bottom Sheet Modal
class _ProjectDetailsSheet extends StatelessWidget {
  final String title;
  final String tagline;
  final String websiteUrl;
  final String searchQuery;
  final Color badgeColor;
  final IconData icon;
  final String description;
  final List<String> keyFeatures;
  final ValueChanged<String> onLaunchUrl;
  final ValueChanged<String> onSearchGoogle;
  final ValueChanged<String> onCopy;

  const _ProjectDetailsSheet({
    required this.title,
    required this.tagline,
    required this.websiteUrl,
    required this.searchQuery,
    required this.badgeColor,
    required this.icon,
    required this.description,
    required this.keyFeatures,
    required this.onLaunchUrl,
    required this.onSearchGoogle,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: badgeColor.withOpacity(0.4)),
                    ),
                    child: Icon(icon, color: badgeColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          tagline,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white60),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // URL Banner with Copy
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, color: AppColors.secondary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        websiteUrl,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => onCopy(websiteUrl),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.copy_rounded, color: Colors.white70, size: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Description
              const Text(
                'About this Project',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
              ),

              const SizedBox(height: 16),

              // Highlights
              const Text(
                'Key Architectural Highlights',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...keyFeatures.map((feat) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feat,
                            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 24),

              // Action Buttons: Direct Open & Google Search
              Row(
                children: [
                  // Direct Open
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onLaunchUrl(websiteUrl);
                      },
                      icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                      label: Text(
                        'Open $title',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: badgeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Google Search Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onSearchGoogle(searchQuery);
                      },
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: const Text(
                        'Search Google',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
