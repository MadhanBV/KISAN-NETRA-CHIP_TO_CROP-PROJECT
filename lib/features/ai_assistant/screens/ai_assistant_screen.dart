import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/database/local_db_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/locale_controller.dart';
import '../../crop_disease/models/crop_disease_models.dart';
import '../../crop_disease/services/crop_disease_service.dart';
import '../services/voice_service.dart';
import '../widgets/clean_ai_text_view.dart';

/// Full-featured AI Bot interface with dual options:
/// 1. AI Chat: Text-based grounded conversational RAG
/// 2. AI Voice Assistant: Live voice query transcription & spoken RAG responses
class AiAssistantScreen extends StatefulWidget {
  final String? initialQuestion;
  final String? crop;

  const AiAssistantScreen({
    super.key,
    this.initialQuestion,
    this.crop,
  });

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen>
    with SingleTickerProviderStateMixin {
  final CropDiseaseService _service = CropDiseaseService();
  final VoiceService _voiceService = VoiceService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _selectedTab = 0; // 0: Chat, 1: Voice

  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  // Voice state
  bool _isListening = false;
  bool _isProcessingVoice = false;
  bool _isPlayingVoice = false;
  String _voiceTranscript = '';
  String _voiceAiResponse = '';
  late String _selectedVoiceLang;
  late final AnimationController _pulseController;

  final Map<String, String> _voiceLanguages = {
    'hi': 'हिन्दी (Hindi)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'te': 'తెలుగు (Telugu)',
    'ta': 'தமிழ் (Tamil)',
    'en': 'English',
    'mr': 'मराठी (Marathi)',
    'bn': 'বাংলা (Bengali)',
    'gu': 'ગુજરાતી (Gujarati)',
    'pa': 'ਪੰਜਾਬੀ (Punjabi)',
    'ml': 'മലയാളം (Malayalam)',
    'or': 'ଓଡ଼ಿଆ (Odia)',
    'as': 'অসমীয়া (Assamese)',
    'ur': 'اردو (Urdu)',
  };

  final List<String> _quickPrompts = [
    'How to prevent tomato early blight?',
    'Best organic treatment for mango anthracnose?',
    'Why is soil testing important before fertilizer?',
    'How to prevent potato dry rot during storage?',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    LocaleController.instance.addListener(_onLocaleChanged);
    final appLang = LocaleController.instance.currentLanguage.languageCode;
    _selectedVoiceLang = _voiceLanguages.containsKey(appLang) ? appLang : 'kn';

    _voiceService.speakingNotifier.addListener(_onSpeakingChanged);

    // Initial greeting
    _messages.add(
      _ChatMessage(
        text: 'Namaste! I am your Kisan Netra AI Farming Assistant. '
            'Ask me anything about crop diseases, organic remedies, soil health, or mandi prices.',
        isUser: false,
        sources: const [],
        timestamp: DateTime.now(),
      ),
    );

    if (widget.initialQuestion != null && widget.initialQuestion!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSendMessage(widget.initialQuestion!);
      });
    }
  }

  void _onLocaleChanged() {
    if (mounted) {
      final code = LocaleController.instance.currentLanguage.languageCode;
      setState(() {
        _selectedVoiceLang = _voiceLanguages.containsKey(code) ? code : code;
      });
    }
  }

  void _onSpeakingChanged() {
    if (mounted) {
      setState(() {
        _isPlayingVoice = _voiceService.speakingNotifier.value;
      });
    }
  }

  @override
  void dispose() {
    LocaleController.instance.removeListener(_onLocaleChanged);
    _voiceService.speakingNotifier.removeListener(_onSpeakingChanged);
    _voiceService.stop();
    _voiceService.stopListening();
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(
        _ChatMessage(
          text: query,
          isUser: true,
          sources: const [],
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final lang = LocaleController.instance.currentLanguage.languageCode;

      final res = await _service.askAssistant(
        question: query,
        crop: widget.crop,
        language: lang,
      );

      final answer = res['answer'] as String? ?? 'No response received.';
      final rawSources = res['knowledge_sources'] as List? ?? [];
      final sources = rawSources
          .map((s) => KnowledgeSource.fromJson(s as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text: answer,
            isUser: false,
            sources: sources,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();

      LocalDbService.instance.saveConversation(
        type: 'chat',
        query: query,
        response: answer,
        crop: widget.crop,
        language: lang,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text: 'I could not retrieve an answer at this moment. Please check server connectivity. ($e)',
            isUser: false,
            sources: const [],
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleVoiceRecording() async {
    if (_isPlayingVoice) {
      await _voiceService.stop();
      if (mounted) {
        setState(() => _isPlayingVoice = false);
      }
      return;
    }

    if (_isListening) {
      await _voiceService.stopListening();
      if (mounted) {
        setState(() => _isListening = false);
      }
      if (_voiceTranscript.trim().isNotEmpty) {
        _processVoiceQuery(_voiceTranscript.trim());
      }
      return;
    }

    // Stop prior audio & start fresh listening session
    await _voiceService.stop();
    setState(() {
      _isListening = true;
      _voiceTranscript = '';
      _voiceAiResponse = '';
    });

    try {
      await _voiceService.startListening(
        languageCode: _selectedVoiceLang,
        onResult: (liveWords) {
          if (mounted) {
            setState(() {
              _voiceTranscript = liveWords;
            });
          }
        },
        onComplete: (finalWords) {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
            if (finalWords.trim().isNotEmpty) {
              setState(() {
                _voiceTranscript = finalWords.trim();
              });
              _processVoiceQuery(finalWords.trim());
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListening = false;
          _voiceTranscript = 'Microphone not available: $e';
        });
      }
    }
  }

  Future<void> _processVoiceQuery(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isProcessingVoice = true;
      _voiceAiResponse = '';
    });

    try {
      final lang = LocaleController.instance.currentLanguage.languageCode;
      final res = await _service.askAssistant(
        question: query,
        crop: widget.crop,
        language: lang,
      );

      final answer = res['answer'] as String? ?? 'No response received from Kisan Netra repository.';
      final rawSources = res['knowledge_sources'] as List? ?? [];
      final sources = rawSources
          .map((s) => KnowledgeSource.fromJson(s as Map<String, dynamic>))
          .toList();

      if (!mounted) return;

      setState(() {
        _isProcessingVoice = false;
        _voiceAiResponse = answer;
        _messages.add(
          _ChatMessage(
            text: query,
            isUser: true,
            sources: const [],
            timestamp: DateTime.now(),
          ),
        );
        _messages.add(
          _ChatMessage(
            text: answer,
            isUser: false,
            sources: sources,
            timestamp: DateTime.now(),
          ),
        );
      });

      // Automatically speak the response aloud in the farmer's language
      await _voiceService.speak(answer, languageCode: lang);

      LocalDbService.instance.saveConversation(
        type: 'voice',
        query: query,
        response: answer,
        crop: widget.crop,
        language: lang,
      );

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessingVoice = false;
        _voiceAiResponse = 'Could not retrieve advisory: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF0F4D33),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.spa_rounded, color: Color(0xFF5AB688), size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Kisan Netra AI Bot',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Voice & Chat Brain',
                    style: TextStyle(
                      color: Color(0xFF5AB688),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Switch Language',
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF1EC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF5AB688).withValues(alpha: 0.45)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, size: 15, color: Color(0xFF0F4D33)),
                  const SizedBox(width: 4),
                  Text(
                    LocaleController.instance.currentLanguage.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F4D33),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_rounded, size: 16, color: Color(0xFF0F4D33)),
                ],
              ),
            ),
            onSelected: (code) async {
              final appLang = AppLanguage.fromCode(code);
              await LocaleController.instance.setLanguage(appLang);
              if (mounted) {
                setState(() => _selectedVoiceLang = code);
                if (_isPlayingVoice) {
                  _voiceService.stop();
                }
              }
            },
            itemBuilder: (ctx) => _voiceLanguages.entries.map((e) {
              final isCurrent = LocaleController.instance.currentLanguage.languageCode == e.key;
              return PopupMenuItem<String>(
                value: e.key,
                child: Row(
                  children: [
                    if (isCurrent)
                      const Icon(Icons.check_rounded, color: Color(0xFF0F4D33), size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(
                      e.value,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                        color: isCurrent ? const Color(0xFF0F4D33) : AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF1EC),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSegmentButton(
                    title: 'AI Chat',
                    icon: Icons.chat_bubble_outline_rounded,
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                ),
                Expanded(
                  child: _buildSegmentButton(
                    title: 'AI Voice Assistant',
                    icon: Icons.mic_none_rounded,
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _selectedTab == 0 ? _buildChatTab() : _buildVoiceTab(),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F4D33) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================== 1. CHAT TAB ======================
  Widget _buildChatTab() {
    return Column(
      children: [
        // Message list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            itemCount: _messages.length,
            itemBuilder: (ctx, i) => _buildMessageBubble(_messages[i]),
          ),
        ),

        // Loading indicator
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F4D33)),
                ),
                SizedBox(width: 8),
                Text(
                  'Consulting Kisan Netra agricultural documents...',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),

        // Quick prompts carousel
        if (_messages.length <= 2)
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickPrompts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () => _handleSendMessage(_quickPrompts[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF5AB688).withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _quickPrompts[i],
                    style: const TextStyle(fontSize: 12, color: Color(0xFF0F4D33), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),

        const SizedBox(height: 8),

        // Bottom Input bar
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F5F3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Ask about crop care, remedies...',
                        hintStyle: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: _handleSendMessage,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _handleSendMessage(_textController.text),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F4D33),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF0F4D33),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.spa_rounded, color: Color(0xFF5AB688), size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF0F4D33) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CleanAiTextView(
                    text: msg.text,
                    isUser: isUser,
                  ),
                  if (msg.sources.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: msg.sources
                          .take(2)
                          .map(
                            (s) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF1EC),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '📚 ${s.section}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF0F4D33),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (!isUser) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => _voiceService.speak(msg.text, languageCode: _selectedVoiceLang),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.volume_up_rounded, size: 14, color: Color(0xFF0F4D33)),
                                SizedBox(width: 4),
                                Text(
                                  'Listen',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF0F4D33), fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ====================== 2. VOICE TAB ======================
  Widget _buildVoiceTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // 1. Language Selector Capsule
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF5AB688).withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language_rounded, size: 18, color: Color(0xFF0F4D33)),
                const SizedBox(width: 8),
                const Text(
                  'Language: ',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedVoiceLang,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF0F4D33)),
                    items: _voiceLanguages.entries.map((e) {
                      return DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(
                          e.value,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F4D33)),
                        ),
                      );
                    }).toList(),
                    onChanged: (newLang) async {
                      if (newLang != null) {
                        final appLang = AppLanguage.fromCode(newLang);
                        await LocaleController.instance.setLanguage(appLang);
                        setState(() => _selectedVoiceLang = newLang);
                        if (_isPlayingVoice) {
                          _voiceService.stop();
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // 2. Animated Microphone / Soundwave Circle
          GestureDetector(
            onTap: _toggleVoiceRecording,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (ctx, child) {
                final scale = (_isListening || _isPlayingVoice)
                    ? 1.0 + (_pulseController.value * 0.1)
                    : 1.0;
                Color btnColor = const Color(0xFF0F4D33);
                IconData btnIcon = Icons.mic_rounded;

                if (_isProcessingVoice) {
                  btnColor = const Color(0xFF2563EB);
                  btnIcon = Icons.hourglass_top_rounded;
                } else if (_isListening) {
                  btnColor = const Color(0xFFD9534F);
                  btnIcon = Icons.stop_rounded;
                } else if (_isPlayingVoice) {
                  btnColor = const Color(0xFF16A34A);
                  btnIcon = Icons.volume_up_rounded;
                }

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: btnColor,
                      boxShadow: [
                        BoxShadow(
                          color: btnColor.withValues(alpha: 0.38),
                          blurRadius: 28,
                          spreadRadius: (_isListening || _isPlayingVoice) ? 6 : 2,
                        ),
                      ],
                    ),
                    child: _isProcessingVoice
                        ? const Center(
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            ),
                          )
                        : Icon(btnIcon, color: Colors.white, size: 48),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 3. Status Title
          Text(
            _isProcessingVoice
                ? 'Consulting Agricultural RAG...'
                : _isListening
                    ? 'Listening... Speak Now'
                    : _isPlayingVoice
                        ? 'Speaking Advisory (Tap to stop)'
                        : 'Tap to Speak',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),

          const SizedBox(height: 6),

          Text(
            _isListening
                ? 'Speak in your selected language'
                : 'Ask questions about pests, fertilizers, remedies',
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 28),

          // 4. Live Speech Transcript Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isListening ? Icons.graphic_eq_rounded : Icons.record_voice_over_outlined,
                      size: 18,
                      color: _isListening ? const Color(0xFFD9534F) : const Color(0xFF0F4D33),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isListening ? 'Live Transcription' : 'Your Spoken Question',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const Divider(height: 18),
                Text(
                  _voiceTranscript.isNotEmpty
                      ? _voiceTranscript
                      : '“e.g. How to prevent mango fruit drop organically?”',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontStyle: _voiceTranscript.isEmpty ? FontStyle.italic : FontStyle.normal,
                    color: _voiceTranscript.isNotEmpty ? AppColors.textPrimary : AppColors.textMuted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          // 5. Spoken AI Advisory Response Card
          if (_voiceAiResponse.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBF8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF5AB688).withValues(alpha: 0.35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.spa_rounded, color: Color(0xFF0F4D33), size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'AI Agricultural Advisory',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F4D33)),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isPlayingVoice ? Icons.stop_circle_rounded : Icons.replay_circle_filled_rounded,
                          color: const Color(0xFF0F4D33),
                          size: 22,
                        ),
                        tooltip: _isPlayingVoice ? 'Stop' : 'Listen Again',
                        onPressed: () {
                          if (_isPlayingVoice) {
                            _voiceService.stop();
                          } else {
                            _voiceService.speak(_voiceAiResponse, languageCode: _selectedVoiceLang);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CleanAiTextView(
                    text: _voiceAiResponse,
                    isUser: false,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final List<KnowledgeSource> sources;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.sources,
    required this.timestamp,
  });
}
