import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'models/community_post.dart';
import 'screens/create_post_screen.dart';
import 'services/community_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final CommunityService _service = CommunityService.instance;
  List<CommunityPost> _posts = [];
  bool _isLoading = true;
  String _selectedCrop = 'All';

  final List<String> _filterCrops = [
    'All',
    'Tomato',
    'Banana',
    'Mango',
    'Potato',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final list = await _service.getPosts(
      cropType: _selectedCrop == 'All' ? null : _selectedCrop,
    );
    if (mounted) {
      setState(() {
        _posts = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _likePost(CommunityPost post) async {
    final newCount = await _service.likePost(post.id);
    if (mounted) {
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = CommunityPost(
            id: post.id,
            farmerId: post.farmerId,
            farmerName: post.farmerName,
            farmerPhone: post.farmerPhone,
            cropType: post.cropType,
            title: post.title,
            description: post.description,
            imageUrl: post.imageUrl,
            likesCount: newCount,
            createdAt: post.createdAt,
          );
        }
      });
    }
  }

  void _openCreatePost() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(
          initialCrop: _selectedCrop == 'All' ? null : _selectedCrop,
        ),
      ),
    );
    if (created == true) {
      _loadPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F4D33).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.groups_rounded, color: Color(0xFF0F4D33), size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'Farmer Community',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            tooltip: 'Refresh Feed',
            onPressed: _loadPosts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F4D33),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Ask Community',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        ),
        onPressed: _openCreatePost,
      ),
      body: Column(
        children: [
          // Crop Filter Strip
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filterCrops.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final crop = _filterCrops[i];
                  final isSelected = _selectedCrop == crop;
                  return GestureDetector(
                    onTap: () {
                      if (_selectedCrop != crop) {
                        setState(() => _selectedCrop = crop);
                        _loadPosts();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0F4D33) : const Color(0xFFF1F5F2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        crop,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Community Feed
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _posts.isEmpty
                    ? _buildEmptyFeed()
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _loadPosts,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                          itemCount: _posts.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (ctx, i) {
                            final post = _posts[i];
                            return _buildPostCard(post);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFeed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 68, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Community Posts in This Category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Be the first farmer to share an update, ask a disease query, or upload a crop diagnosis!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4D33),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _openCreatePost,
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            label: const Text('Create First Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    final initials = post.farmerName.isNotEmpty
        ? post.farmerName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'F';
    final hasImage = post.imageUrl.isNotEmpty;
    final dateStr = '${post.createdAt.day}/${post.createdAt.month}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF0F4D33),
                  child: Text(
                    initials.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.farmerName,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF1B8755)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Crop pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${post.cropType}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F4D33),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Title & Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.title,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.description,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Attached Photo (from Supabase Storage)
          if (hasImage)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  post.imageUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 220,
                      color: Colors.grey[100],
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    );
                  },
                  errorBuilder: (ctx, error, stack) => Container(
                    height: 160,
                    color: Colors.grey[100],
                    child: const Center(
                      child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),

          if (hasImage) const SizedBox(height: 10),

          // Actions: Like, Comment, Share
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _likePost(post),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded, size: 20, color: Color(0xFFDC2626)),
                      const SizedBox(width: 6),
                      Text(
                        '${post.likesCount}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Row(
                  children: const [
                    Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 6),
                    Text(
                      'Reply',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 19, color: AppColors.textSecondary),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing community post with fellow farmers...')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
