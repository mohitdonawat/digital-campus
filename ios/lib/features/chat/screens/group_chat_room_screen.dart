import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/chat_group_model.dart';
import '../models/chat_message_model.dart';
import '../services/chat_service.dart';

class GroupChatRoomScreen extends StatefulWidget {
  final ChatGroupModel group;
  final String currentUserRole; // 'teacher', 'student', 'admin'
  final String currentUserName;
  final String currentUserTitle;

  const GroupChatRoomScreen({
    super.key,
    required this.group,
    required this.currentUserRole,
    required this.currentUserName,
    this.currentUserTitle = '',
  });

  @override
  State<GroupChatRoomScreen> createState() => _GroupChatRoomScreenState();
}

class _GroupChatRoomScreenState extends State<GroupChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  String get _currentUid =>
      FirebaseAuth.instance.currentUser?.uid ??
      'usr_${widget.currentUserName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}';

  // Reply tracking
  ChatMessageModel? _replyingTo;

  // Editing state
  ChatMessageModel? _editingMessage;
  final _editController = TextEditingController();

  // Optimistic local messages for instantaneous rendering
  final List<ChatMessageModel> _optimisticMessages = [];

  // Periodic ticker to refresh 60-second countdown for edit buttons
  Timer? _countdownTimer;

  bool get _isFaculty =>
      widget.currentUserRole == 'teacher' || widget.currentUserRole == 'admin';

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage([String? quickText]) async {
    final text = (quickText ?? _messageController.text).trim();
    if (text.isEmpty) return;

    _messageController.clear();

    final reply = _replyingTo;
    setState(() => _replyingTo = null);

    // Create optimistic local message so it shows immediately
    final tempMsg = ChatMessageModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      groupId: widget.group.id,
      senderId: _currentUid,
      senderName: widget.currentUserName,
      senderRole: widget.currentUserRole,
      senderTitle: widget.currentUserTitle,
      text: text,
      replyToMessageId: reply?.id,
      replyToSenderName: reply?.senderName,
      replyToText: reply?.text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _optimisticMessages.insert(0, tempMsg);
    });
    _scrollToBottom();

    final success = await ChatService.sendMessage(
      groupId: widget.group.id,
      senderId: _currentUid,
      senderName: widget.currentUserName,
      senderRole: widget.currentUserRole,
      senderTitle: widget.currentUserTitle,
      text: text,
      replyToMessageId: reply?.id,
      replyToSenderName: reply?.senderName,
      replyToText: reply?.text,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Message delivery delayed. Retrying in background...'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveEditedMessage(ChatMessageModel msg) async {
    final newText = _editController.text.trim();
    if (newText.isEmpty || newText == msg.text) {
      setState(() => _editingMessage = null);
      return;
    }

    final success = await ChatService.editMessage(
      groupId: widget.group.id,
      messageId: msg.id,
      newText: newText,
      currentUserId: _currentUid,
    );

    if (!mounted) return;

    setState(() => _editingMessage = null);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ 60-second edit window expired! Message cannot be edited.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _startEditing(ChatMessageModel msg) {
    if (!msg.canEdit(_currentUid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Edit time expired (1 minute limit reached).'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    setState(() {
      _editingMessage = msg;
      _editController.text = msg.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.group.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${widget.group.targetBadge} • Coordinator: ${widget.group.createdByTitle} ${widget.group.createdByName}'.trim(),
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 20),
            tooltip: 'Group Info',
            onPressed: _showGroupInfoDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Notice: Anti-Tamper & 60s edit rule
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            color: const Color(0xFF130826),
            child: Row(
              children: const [
                Icon(Icons.shield_outlined, size: 14, color: Color(0xFFA78BFA)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Anti-Tamper: Deletion & Forwarding blocked. Edit allowed within 60s only.',
                    style: TextStyle(color: Color(0xFFC4B5FD), fontSize: 10),
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: ChatService.getGroupMessages(widget.group.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _optimisticMessages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.secondary),
                  );
                }

                // Merge server stream messages and local optimistic messages
                final serverMessages = snapshot.data ?? [];
                final Set<String> serverTexts = serverMessages.map((m) => '${m.senderId}_${m.text}').toSet();

                // Prune local messages that have arrived from server
                _optimisticMessages.removeWhere((local) =>
                    serverTexts.contains('${local.senderId}_${local.text}'));

                final allMessages = [..._optimisticMessages, ...serverMessages];

                if (snapshot.hasError && allMessages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off_rounded, size: 42, color: AppColors.warning),
                          const SizedBox(height: 10),
                          const Text('Connecting to discussion feed...',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Tap below to refresh and send a message',
                              style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => setState(() {}),
                            icon: const Icon(Icons.refresh_rounded, color: AppColors.secondary),
                            label: const Text('Refresh', style: TextStyle(color: AppColors.secondary)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (allMessages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.forum_outlined, size: 48, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        const Text(
                          'No messages yet!',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start discussion for ${widget.group.title}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _starterChip('👋 Hello everyone!'),
                            _starterChip('📚 Any updates on notes?'),
                            if (_isFaculty) _starterChip('📢 Class Announcement'),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  itemCount: allMessages.length,
                  itemBuilder: (ctx, i) {
                    final msg = allMessages[i];
                    final isMe = msg.senderId == _currentUid;
                    return _buildMessageBubble(msg, isMe);
                  },
                );
              },
            ),
          ),

          // Reply Bar Preview
          if (_replyingTo != null) _buildReplyPreview(),

          // Quick Subject & Doubt Chips
          _buildQuickActionChips(),

          // Input Bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _starterChip(String text) {
    return ActionChip(
      backgroundColor: AppColors.surfaceVariant,
      side: BorderSide(color: AppColors.secondary.withOpacity(0.4)),
      label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      onPressed: () => _sendMessage(text),
    );
  }

  Widget _buildQuickActionChips() {
    final chips = _isFaculty
        ? ['📢 Assignment Update', '📖 Material Uploaded', '⏰ Lab Today', '💡 Doubt Clearing']
        : ['❓ Ask Question', '📅 Submission Date?', '📖 Notes Needed', '🙋 Attendance Query'];

    return Container(
      height: 34,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (ctx, i) {
          return GestureDetector(
            onTap: () {
              _messageController.text = chips[i];
              _messageController.selection = TextSelection.fromPosition(
                TextPosition(offset: _messageController.text.length),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Center(
                child: Text(
                  chips[i],
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel msg, bool isMe) {
    final bool isFaculty = msg.senderRole == 'teacher' || msg.senderRole == 'admin';
    final bool canStillEdit = msg.canEdit(_currentUid);
    final int secondsLeft = msg.secondsLeftToEdit();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.80,
            ),
            decoration: BoxDecoration(
              gradient: isMe
                  ? const LinearGradient(
                      colors: [Color(0xFF1E3A5F), Color(0xFF2A5298)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : isFaculty
                      ? const LinearGradient(
                          colors: [Color(0xFF3B1E08), Color(0xFF5D2E0C)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF1A2A3A), Color(0xFF243447)],
                        ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isMe ? 14 : 2),
                bottomRight: Radius.circular(isMe ? 2 : 14),
              ),
              border: Border.all(
                color: isFaculty
                    ? AppColors.secondary.withOpacity(0.5)
                    : isMe
                        ? const Color(0xFF60A5FA).withOpacity(0.3)
                        : Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender Header
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isMe ? 'You' : '${msg.senderTitle} ${msg.senderName}'.trim(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isFaculty
                              ? AppColors.secondary
                              : isMe
                                  ? const Color(0xFF93C5FD)
                                  : Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: (isFaculty ? AppColors.secondary : const Color(0xFF06B6D4)).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isFaculty ? '👨‍🏫 FACULTY' : '🎓 STUDENT',
                          style: TextStyle(
                            color: isFaculty ? AppColors.secondary : const Color(0xFF38BDF8),
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Quoted Reply
                  if (msg.replyToText != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(6),
                        border: const Border(
                          left: BorderSide(color: AppColors.secondary, width: 3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.replyToSenderName ?? 'Replied',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                          Text(
                            msg.replyToText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 5),

                  // Message Text or Inline Edit Form
                  if (_editingMessage?.id == msg.id)
                    _buildInlineEditForm(msg)
                  else
                    SelectableText(
                      msg.text,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.35),
                    ),

                  const SizedBox(height: 4),

                  // Footer: Edited tag + Timestamp + Reply Button + 60s Edit countdown
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (msg.isEdited)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Text(
                            'edited',
                            style: TextStyle(
                              fontSize: 9,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      Text(
                        DateFormat('hh:mm a').format(msg.createdAt),
                        style: const TextStyle(fontSize: 9, color: AppColors.textHint),
                      ),
                      const SizedBox(width: 8),

                      // Reply button
                      GestureDetector(
                        onTap: () => setState(() => _replyingTo = msg),
                        child: const Icon(Icons.reply_rounded, size: 14, color: AppColors.textHint),
                      ),

                      // 60-second Edit Button (only visible to sender if within 60s)
                      if (isMe && canStillEdit) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _startEditing(msg),
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 11, color: Color(0xFF60A5FA)),
                              const SizedBox(width: 2),
                              Text(
                                '${secondsLeft}s',
                                style: const TextStyle(
                                  color: Color(0xFF60A5FA),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineEditForm(ChatMessageModel msg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _editController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            fillColor: Colors.black38,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.secondary),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => setState(() => _editingMessage = null),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textHint, fontSize: 11)),
            ),
            const SizedBox(width: 14),
            GestureDetector(
              onTap: () => _saveEditedMessage(msg),
              child: const Text(
                'Save (60s limit)',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 3,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyingTo!.senderName}',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _replyingTo!.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textHint),
            onPressed: () => setState(() => _replyingTo = null),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: _replyingTo != null
                      ? 'Type reply...'
                      : 'Message ${widget.group.title}...',
                  hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppColors.secondary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _sendMessage(),
                child: const Padding(
                  padding: EdgeInsets.all(11),
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupInfoDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.groups_rounded, color: AppColors.secondary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.group.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.group.description.isNotEmpty) ...[
                Text(widget.group.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                const SizedBox(height: 12),
              ],
              _infoRow(Icons.school_rounded, 'Target Batch', widget.group.targetBadge),
              _infoRow(Icons.person_rounded, 'Coordinator', '${widget.group.createdByTitle} ${widget.group.createdByName}'),
              _infoRow(Icons.security_rounded, 'Anti-Tamper Rule', 'Replies allowed • Edits within 60s • Deletion permanently blocked'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String title, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
                Text(val, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
