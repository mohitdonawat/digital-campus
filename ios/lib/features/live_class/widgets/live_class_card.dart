import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../models/live_class_model.dart';
import '../services/live_class_service.dart';

class LiveClassCard extends StatefulWidget {
  final LiveClassModel liveClass;
  final bool isTeacher;
  final VoidCallback? onEdit;
  final VoidCallback? onDeleted;

  const LiveClassCard({
    super.key,
    required this.liveClass,
    this.isTeacher = false,
    this.onEdit,
    this.onDeleted,
  });

  @override
  State<LiveClassCard> createState() => _LiveClassCardState();
}

class _LiveClassCardState extends State<LiveClassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _launchMeeting(BuildContext context) async {
    final urlStr = widget.liveClass.isCompleted &&
            widget.liveClass.recordingUrl != null &&
            widget.liveClass.recordingUrl!.trim().isNotEmpty
        ? widget.liveClass.recordingUrl!
        : widget.liveClass.meetingUrl;

    if (urlStr.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No meeting or recording URL specified for this class.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Uri? uri;
    try {
      String formatted = urlStr.trim();
      if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
        formatted = 'https://$formatted';
      }
      uri = Uri.parse(formatted);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid meeting link format.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch the live class link.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleLiveStatus() async {
    setState(() => _isActionLoading = true);
    try {
      if (widget.liveClass.isUpcoming) {
        await LiveClassService.updateClassStatus(widget.liveClass.id, 'LIVE');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔴 Class is now LIVE! Students have been notified.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else if (widget.liveClass.isLive) {
        final recController = TextEditingController();
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('End Live Class?', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mark this class as COMPLETED. Optionally provide recording URL for students to watch later:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: recController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Recording URL (Optional)',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    hintText: 'e.g. YouTube recording or Drive link',
                    hintStyle: TextStyle(color: AppColors.textHint, fontSize: 12),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('End Class', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await LiveClassService.updateClassStatus(
            widget.liveClass.id,
            'COMPLETED',
            recordingUrl: recController.text.trim().isNotEmpty ? recController.text.trim() : null,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Class ended and marked completed.'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Class?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to permanently delete "${widget.liveClass.title}"?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await LiveClassService.deleteLiveClass(widget.liveClass.id);
        widget.onDeleted?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Class deleted successfully'),
              backgroundColor: AppColors.surface,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.liveClass;
    final isLive = c.isLive;
    final isUpcoming = c.isUpcoming;
    final isCompleted = c.isCompleted;

    // Platform styling
    Color platformColor = const Color(0xFFEF4444);
    IconData platformIcon = Icons.ondemand_video_rounded;
    if (c.platform == 'meet') {
      platformColor = const Color(0xFF10B981);
      platformIcon = Icons.video_camera_front_rounded;
    } else if (c.platform == 'zoom') {
      platformColor = const Color(0xFF38BDF8);
      platformIcon = Icons.videocam_rounded;
    } else if (c.platform == 'jitsi') {
      platformColor = const Color(0xFF8B5CF6);
      platformIcon = Icons.group_work_rounded;
    }

    final formattedTime = DateFormat('EEE, d MMM • h:mm a').format(c.scheduledStartTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLive
              ? const Color(0xFFEF4444).withOpacity(0.8)
              : isUpcoming
                  ? AppColors.secondary.withOpacity(0.3)
                  : Colors.white.withOpacity(0.06),
          width: isLive ? 2 : 1,
        ),
        boxShadow: [
          if (isLive)
            BoxShadow(
              color: const Color(0xFFEF4444).withOpacity(0.25),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Status Bar with Badges
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isLive
                    ? const Color(0xFFEF4444).withOpacity(0.12)
                    : isUpcoming
                        ? AppColors.secondary.withOpacity(0.08)
                        : Colors.white.withOpacity(0.03),
                border: Border(
                  bottom: BorderSide(
                    color: isLive
                        ? const Color(0xFFEF4444).withOpacity(0.3)
                        : Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Status Badge
                  if (isLive) ...[
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFEF4444),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'LIVE NOW',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ] else if (isUpcoming) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded, color: AppColors.secondary, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'UPCOMING',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            c.recordingUrl != null ? Icons.play_circle_fill_rounded : Icons.check_circle_rounded,
                            color: AppColors.textSecondary,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            c.recordingUrl != null ? 'RECORDED' : 'COMPLETED',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Platform Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: platformColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: platformColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(platformIcon, color: platformColor, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          c.platformName,
                          style: TextStyle(
                            color: platformColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Teacher options menu
                  if (widget.isTeacher) ...[
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, color: Colors.white70, size: 20),
                      color: AppColors.surface,
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (val) {
                        if (val == 'edit') {
                          widget.onEdit?.call();
                        } else if (val == 'delete') {
                          _confirmDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, color: AppColors.secondary, size: 18),
                              SizedBox(width: 10),
                              Text('Edit Class', style: TextStyle(color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                              SizedBox(width: 10),
                              Text('Delete Class', style: TextStyle(color: AppColors.error, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject Tag & Duration
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                        ),
                        child: Text(
                          c.subject.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF93C5FD),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: AppColors.textSecondary, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '${c.durationMinutes} mins',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Class Title
                  Text(
                    c.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),

                  // Description
                  if (c.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      c.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Date, Time & Teacher Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Column(
                      children: [
                        // Scheduled Time Row
                        Row(
                          children: [
                            const Icon(Icons.event_rounded, color: AppColors.secondary, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              formattedTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white10, height: 16),
                        // Teacher & Target Batch Row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.secondary.withOpacity(0.2),
                              child: Text(
                                c.teacherName.isNotEmpty ? c.teacherName.substring(0, 1).toUpperCase() : 'T',
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.teacherDisplay,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    c.targetBadge,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons (PW / Unacademy Style)
                  if (widget.isTeacher) ...[
                    // Teacher Controls Row
                    Row(
                      children: [
                        // Live Toggle Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isActionLoading ? null : _toggleLiveStatus,
                            icon: Icon(
                              isLive
                                  ? Icons.stop_circle_rounded
                                  : isUpcoming
                                      ? Icons.play_arrow_rounded
                                      : Icons.replay_rounded,
                              size: 18,
                            ),
                            label: Text(
                              isLive
                                  ? 'End Live Class'
                                  : isUpcoming
                                      ? 'Start Class (Go Live)'
                                      : 'Re-open Class',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLive
                                  ? AppColors.error
                                  : isUpcoming
                                      ? const Color(0xFFEF4444)
                                      : AppColors.surface,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Join/Preview button
                        OutlinedButton(
                          onPressed: () => _launchMeeting(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: platformColor.withOpacity(0.6)),
                            foregroundColor: platformColor,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Icon(Icons.open_in_new_rounded, size: 18),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Student Action
                    SizedBox(
                      width: double.infinity,
                      child: isLive
                          ? ElevatedButton.icon(
                              onPressed: () => _launchMeeting(context),
                              icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                              label: const Text(
                                'JOIN LIVE CLASS NOW',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                elevation: 6,
                                shadowColor: const Color(0xFFEF4444).withOpacity(0.5),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            )
                          : isUpcoming
                              ? OutlinedButton.icon(
                                  onPressed: () => _launchMeeting(context),
                                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                                  label: const Text(
                                    'Class Link / Waiting Room',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
                                    foregroundColor: AppColors.secondary,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: () => _launchMeeting(context),
                                  icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                                  label: Text(
                                    c.recordingUrl != null ? 'Watch Recorded Lecture' : 'View Class Details',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.surface,
                                    foregroundColor: Colors.white70,
                                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
