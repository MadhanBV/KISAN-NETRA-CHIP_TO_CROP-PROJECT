import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/local_db_service.dart';
import '../../ai_assistant/services/voice_service.dart';
import '../../ai_assistant/widgets/clean_ai_text_view.dart';

class MyConversationsScreen extends StatefulWidget {
  const MyConversationsScreen({super.key});

  @override
  State<MyConversationsScreen> createState() => _MyConversationsScreenState();
}

class _MyConversationsScreenState extends State<MyConversationsScreen> {
  final VoiceService _voiceService = VoiceService();
  List<SavedConversation> _conversations = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'chat', 'voice'
  int? _currentlyPlayingId;

  @override
  void initState() {
    super.initState();
    _voiceService.speakingNotifier.addListener(_onSpeakingChanged);
    _loadConversations();
  }

  void _onSpeakingChanged() {
    if (mounted && !_voiceService.speakingNotifier.value) {
      setState(() => _currentlyPlayingId = null);
    }
  }

  @override
  void dispose() {
    _voiceService.speakingNotifier.removeListener(_onSpeakingChanged);
    _voiceService.stop();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    final filter = _selectedFilter == 'all' ? null : _selectedFilter;
    final list = await LocalDbService.instance.getAllConversations(filterType: filter);
    if (mounted) {
      setState(() {
        _conversations = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteConversation(int id) async {
    await LocalDbService.instance.deleteConversation(id);
    _loadConversations();
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Conversations?'),
        content: const Text('This will delete all saved chat and voice conversation history from your device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await LocalDbService.instance.clearAllConversations();
      _loadConversations();
    }
  }

  Future<void> _togglePlayAdvisory(SavedConversation c) async {
    if (_currentlyPlayingId == c.id) {
      await _voiceService.stop();
      setState(() => _currentlyPlayingId = null);
      return;
    }

    setState(() => _currentlyPlayingId = c.id);
    await _voiceService.speak(c.response, languageCode: c.language);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Conversations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (_conversations.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.textSecondary),
              tooltip: 'Clear History',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('💬 AI Chat', 'chat'),
                const SizedBox(width: 8),
                _buildFilterChip('🎙️ Voice Assistant', 'voice'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _conversations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _loadConversations,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _conversations.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (ctx, i) {
                            final c = _conversations[i];
                            return _buildConversationCard(c);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        if (_selectedFilter != value) {
          setState(() => _selectedFilter = value);
          _loadConversations();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F4D33) : const Color(0xFFF1F5F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 68, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Conversations Yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Ask agricultural questions in AI Chat or use AI Voice Assistant. Your conversations will be automatically saved here for easy review.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(SavedConversation c) {
    final isVoice = c.type == 'voice';
    final dateStr = '${c.createdAt.day}/${c.createdAt.month} ${c.createdAt.hour.toString().padLeft(2, '0')}:${c.createdAt.minute.toString().padLeft(2, '0')}';
    final isPlaying = _currentlyPlayingId == c.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Type badge, Date, Delete button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isVoice ? const Color(0xFFEFF6FF) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVoice ? Icons.mic_rounded : Icons.chat_rounded,
                      size: 13,
                      color: isVoice ? const Color(0xFF2563EB) : const Color(0xFF059669),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVoice ? 'Voice Advisory' : 'AI Chat',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isVoice ? const Color(0xFF2563EB) : const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
              if (c.crop.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${c.crop}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _deleteConversation(c.id),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // User Query Bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c.query,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // AI Response
          CleanAiTextView(text: c.response),

          const SizedBox(height: 10),

          // Action row: Listen button
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _togglePlayAdvisory(c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isPlaying ? const Color(0xFFFEE2E2) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPlaying ? const Color(0xFFDC2626) : const Color(0xFF1B8755),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                      size: 14,
                      color: isPlaying ? const Color(0xFFDC2626) : const Color(0xFF1B8755),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPlaying ? 'Stop' : 'Listen',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isPlaying ? const Color(0xFFDC2626) : const Color(0xFF1B8755),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

