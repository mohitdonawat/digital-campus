import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';

class AnnouncementsFeedScreen extends StatefulWidget {
  final bool isFaculty;
  const AnnouncementsFeedScreen({super.key, this.isFaculty = false});

  @override
  State<AnnouncementsFeedScreen> createState() =>
      _AnnouncementsFeedScreenState();
}

class _AnnouncementsFeedScreenState extends State<AnnouncementsFeedScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted && doc.exists) {
      setState(() {
        _userProfile = doc.data();
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = _userProfile?['role'] ?? (widget.isFaculty ? 'teacher' : 'student');
    final bool canPost = role == 'teacher' || role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📢 Campus Announcements'),
        backgroundColor: AppColors.surface,
        actions: [
          if (canPost)
            IconButton(
              icon: const Icon(Icons.add_alert_rounded, color: AppColors.secondary),
              tooltip: 'Post Announcement',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.postAnnouncement),
            ),
        ],
      ),
      body: _isLoadingUser
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondary))
          : _buildFeed(canPost),
      floatingActionButton: canPost
          ? FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.postAnnouncement),
              backgroundColor: AppColors.secondary,
              icon: const Icon(Icons.campaign_rounded, color: Colors.white),
              label: const Text('New Notice',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }

  Widget _buildFeed(bool canPost) {
    final Stream<List<AnnouncementModel>> stream = canPost
        ? AnnouncementService.getAllAnnouncements()
        : AnnouncementService.getStudentAnnouncements(
            branch: _userProfile?['branch'] ?? '',
            year: _userProfile?['year'] ?? '',
            semester: _userProfile?['semester'] ?? '1st Sem',
            section: _userProfile?['section'] ?? '',
          );

    return StreamBuilder<List<AnnouncementModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          );
        }

        final notices = snapshot.data ?? [];

        if (notices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_off_outlined,
                      size: 48, color: AppColors.textHint),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Announcements Right Now',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  'All notices published by your faculty or college will appear here.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: notices.length,
          itemBuilder: (ctx, i) {
            return _buildNoticeCard(notices[i]);
          },
        );
      },
    );
  }

  Widget _buildNoticeCard(AnnouncementModel a) {
    final bool isUrgent = a.priority == 'URGENT';
    final bool isImportant = a.priority == 'IMPORTANT';
    final Color priorityColor = isUrgent
        ? AppColors.error
        : isImportant
            ? AppColors.warning
            : AppColors.info;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? AppColors.error.withOpacity(0.5)
              : AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Author & Time & Priority
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.secondary.withOpacity(0.15),
                  child: Icon(
                    a.authorRole == 'admin'
                        ? Icons.admin_panel_settings_rounded
                        : Icons.person_4_rounded,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.authorDisplay,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      Text(
                        '${DateFormat('dd MMM yyyy, hh:mm a').format(a.createdAt)}',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
                if (a.priority != 'NORMAL')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: priorityColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      a.priority,
                      style: TextStyle(
                          color: priorityColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Target Audience Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                a.targetBadge,
                style: const TextStyle(color: AppColors.info, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 8),

            // Title
            Text(
              a.title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),

            const SizedBox(height: 6),

            // Message Body
            Text(
              a.message,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),

            // External Link Button (if present)
            if (a.linkUrl != null && a.linkUrl!.isNotEmpty) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final uri = Uri.parse(a.linkUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF60A5FA).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link_rounded, size: 16, color: Color(0xFF60A5FA)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          a.linkUrl!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF93C5FD),
                              fontSize: 12,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      const Icon(Icons.open_in_new_rounded,
                          size: 14, color: Color(0xFF60A5FA)),
                    ],
                  ),
                ),
              ),
            ],

            // PDF / File Download Box (if present)
            if (a.fileUrl != null && a.fileUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded,
                          color: AppColors.secondary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.fileName ?? 'Attached Document.pdf',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'Click to download & open',
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _downloadFile(a.fileUrl!, a.fileName ?? 'notice.pdf'),
                      icon: const Icon(Icons.download_rounded, size: 14),
                      label: const Text('Download', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(String fileUrl, String fileName) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              SizedBox(width: 10),
              Text('Opening attachment...'),
            ],
          ),
          backgroundColor: AppColors.info,
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');

      if (fileUrl.startsWith('data:')) {
        final commaIdx = fileUrl.indexOf(',');
        final b64 = commaIdx != -1 ? fileUrl.substring(commaIdx + 1) : fileUrl;
        final bytes = base64Decode(b64);
        await file.writeAsBytes(bytes);
      } else {
        final response = await http.get(Uri.parse(fileUrl));
        await file.writeAsBytes(response.bodyBytes);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Ready: $fileName'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () => OpenFile.open(file.path),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: $e'), backgroundColor: AppColors.error),
      );
    }
  }
}
