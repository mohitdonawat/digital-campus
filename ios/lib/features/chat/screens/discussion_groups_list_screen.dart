import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../models/chat_group_model.dart';
import '../services/chat_service.dart';
import 'group_chat_room_screen.dart';

class DiscussionGroupsListScreen extends StatefulWidget {
  final bool isTeacherOrAdmin;

  const DiscussionGroupsListScreen({super.key, this.isTeacherOrAdmin = false});

  @override
  State<DiscussionGroupsListScreen> createState() =>
      _DiscussionGroupsListScreenState();
}

class _DiscussionGroupsListScreenState
    extends State<DiscussionGroupsListScreen> {
  Map<String, dynamic>? _userData;
  bool _loadingUser = true;
  String _searchQuery = '';
  int _selectedTab = 0; // 0: All, 1: My Batch/Dept, 2: College Wide
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loadingUser = false);
      return;
    }

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          if (doc.exists && doc.data() != null) {
            _userData = doc.data();
          } else {
            _userData = {
              'name': user.displayName ?? (widget.isTeacherOrAdmin ? 'Faculty' : 'Student'),
              'email': user.email ?? '',
              'role': widget.isTeacherOrAdmin ? 'teacher' : 'student',
              'branch': 'Computer Science & Engineering',
              'department': 'Computer Science & Engineering',
              'year': '1st Year',
              'semester': '1st Sem',
              'section': 'A',
            };
          }
          _loadingUser = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _userData = {
            'name': user.displayName ?? (widget.isTeacherOrAdmin ? 'Faculty' : 'Student'),
            'email': user.email ?? '',
            'role': widget.isTeacherOrAdmin ? 'teacher' : 'student',
            'branch': 'Computer Science & Engineering',
            'department': 'Computer Science & Engineering',
            'year': '1st Year',
            'semester': '1st Sem',
            'section': 'A',
          };
          _loadingUser = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = _userData?['role'] ?? (widget.isTeacherOrAdmin ? 'teacher' : 'student');
    final bool isFaculty = widget.isTeacherOrAdmin || role == 'teacher' || role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💬 Class Discussion Groups',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(
              isFaculty ? 'Faculty Hub • All Batches' : '${_userData?['branch'] ?? 'CSE'} • ${_userData?['year'] ?? ''}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        actions: [
          if (isFaculty)
            IconButton(
              icon: const Icon(Icons.group_add_rounded, color: AppColors.secondary),
              tooltip: 'Create Class Group',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.createChatGroup),
            ),
        ],
      ),
      body: _loadingUser
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          : Column(
              children: [
                // Top Search & Filter Bar
                _buildFilterHeader(isFaculty),

                // Groups List
                Expanded(child: _buildGroupsList(isFaculty)),
              ],
            ),
      floatingActionButton: isFaculty
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.createChatGroup),
              backgroundColor: AppColors.secondary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('New Class Group',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }

  Widget _buildFilterHeader(bool isFaculty) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.surface,
      child: Column(
        children: [
          // Search Input
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search subjects, groups or professors...',
                hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(Icons.clear_rounded, color: AppColors.textHint, size: 18),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All Groups', 0),
                const SizedBox(width: 8),
                _filterChip(isFaculty ? 'Department Groups' : 'My Class / Batch', 1),
                const SizedBox(width: 8),
                _filterChip('College Wide', 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, int index) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.secondary : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsList(bool isFaculty) {
    final studentBranch = _userData?['branch'] ?? _userData?['department'] ?? 'Computer Science & Engineering';
    final studentYear = _userData?['year'] ?? '1st Year';
    final studentSemester = _userData?['semester'] ?? '1st Sem';
    final studentSection = _userData?['section'] ?? 'A';

    final Stream<List<ChatGroupModel>> groupStream = isFaculty
        ? ChatService.getAllGroups()
        : ChatService.getGroupsForStudent(
            department: studentBranch,
            year: studentYear,
            semester: studentSemester,
            section: studentSection,
          );

    return StreamBuilder<List<ChatGroupModel>>(
      stream: groupStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
        }

        var groups = snapshot.data ?? [];

        // Apply Tab Filter
        if (_selectedTab == 1) {
          // Department / Class groups only
          groups = groups.where((g) => g.department != 'ALL').toList();
        } else if (_selectedTab == 2) {
          // College-wide only
          groups = groups.where((g) => g.department == 'ALL').toList();
        }

        // Apply Search Filter
        if (_searchQuery.isNotEmpty) {
          groups = groups.where((g) {
            final t = g.title.toLowerCase();
            final d = g.description.toLowerCase();
            final dept = g.department.toLowerCase();
            final prof = g.createdByName.toLowerCase();
            return t.contains(_searchQuery) ||
                d.contains(_searchQuery) ||
                dept.contains(_searchQuery) ||
                prof.contains(_searchQuery);
          }).toList();
        }

        if (groups.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.forum_rounded, size: 48, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'No groups match "$_searchQuery"'
                        : (isFaculty ? 'No Discussion Groups Created Yet' : 'No Class Group Found'),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFaculty
                        ? 'Tap "New Class Group" button below to create a targeted class discussion group for your branch.'
                        : 'Your faculty has not created specific groups for your semester yet. Check College Wide channels!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  if (isFaculty)
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.createChatGroup),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Create Class Group Now', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          itemCount: groups.length,
          itemBuilder: (ctx, i) {
            final g = groups[i];
            return _buildGroupCard(g, isFaculty);
          },
        );
      },
    );
  }

  Widget _buildGroupCard(ChatGroupModel g, bool isFaculty) {
    final senderName = _userData?['name'] ?? (isFaculty ? 'Faculty' : 'Student');
    final senderRole = isFaculty ? 'teacher' : 'student';
    final senderTitle = _userData?['title'] ?? (isFaculty ? 'Prof' : '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.35),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupChatRoomScreen(
                  group: g,
                  currentUserRole: senderRole,
                  currentUserName: senderName,
                  currentUserTitle: senderTitle,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title + Faculty In-charge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.groups_rounded, color: AppColors.secondary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Coordinator: ${g.createdByTitle} ${g.createdByName}'.trim(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textHint),
                  ],
                ),

                const SizedBox(height: 10),

                // Target Batch Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school_outlined, size: 13, color: AppColors.info),
                      const SizedBox(width: 6),
                      Text(
                        g.targetBadge,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Last message snippet
                Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, size: 13, color: AppColors.textHint),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        g.lastMessage != null
                            ? '${g.lastMessageSender}: ${g.lastMessage}'
                            : 'No messages yet. Tap to start discussion!',
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (g.lastMessageTime != null)
                      Text(
                        DateFormat('hh:mm a').format(g.lastMessageTime!),
                        style: const TextStyle(color: AppColors.textHint, fontSize: 10),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
