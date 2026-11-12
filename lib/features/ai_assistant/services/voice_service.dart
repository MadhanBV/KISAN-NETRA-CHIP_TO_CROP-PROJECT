import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/config/app_config.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isSpeechInitialized = false;
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  final ValueNotifier<bool> speakingNotifier = ValueNotifier<bool>(false);

  Future<void> init() async {
    try {
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        speakingNotifier.value = false;
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        _isSpeaking = false;
        speakingNotifier.value = false;
      });
    } catch (e) {
      debugPrint('VoiceService init error: $e');
    }
  }

  /// Converts regional language code to BCP-47 for Flutter TTS / Sarvam.
  String mapToLocale(String? lang) {
    if (lang == null || lang.isEmpty) return 'hi-IN';
    final l = lang.toLowerCase();
    if (l.contains('hi')) return 'hi-IN';
    if (l.contains('te')) return 'te-IN';
    if (l.contains('ta')) return 'ta-IN';
    if (l.contains('kn')) return 'kn-IN';
    if (l.contains('mr')) return 'mr-IN';
    if (l.contains('bn')) return 'bn-IN';
    if (l.contains('gu')) return 'gu-IN';
    if (l.contains('pa')) return 'pa-IN';
    if (l.contains('ml')) return 'ml-IN';
    if (l.contains('en')) return 'en-IN';
    return 'hi-IN';
  }

  /// Clean text of markdown characters for speech synthesis.
  String cleanText(String text) {
    return text
        .replaceAll(RegExp(r'#+\s*'), '')
        .replaceAll(RegExp(r'\*+'), '')
        .replaceAll(RegExp(r'[-•]\s*'), '')
        .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Synthesizes and speaks text aloud using Sarvam TTS (with offline fallback).
  Future<void> speak(String text, {String? languageCode}) async {
    await stop();

    final cleaned = cleanText(text);
    if (cleaned.isEmpty) return;

    final targetLocale = mapToLocale(languageCode);
    _isSpeaking = true;
    speakingNotifier.value = true;

    // 1. Attempt Sarvam TTS via backend
    bool sarvamSuccess = false;
    try {
      final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/voice/tts');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': cleaned.length > 450 ? '${cleaned.substring(0, 450)}.' : cleaned,
          'language_code': targetLocale,
          'speaker': 'ritu',
        }),
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final b64Audio = data['audio_base64'] as String?;
        if (b64Audio != null && b64Audio.isNotEmpty) {
          final Uint8List bytes = base64Decode(b64Audio);
          await _audioPlayer.play(BytesSource(bytes));
          sarvamSuccess = true;
        }
      }
    } catch (e) {
      debugPrint('Sarvam TTS network error, using device TTS fallback: $e');
    }

    // 2. Fallback to Flutter device TTS if Sarvam quota exhausted or unavailable
    if (!sarvamSuccess) {
      try {
        await _flutterTts.setLanguage(targetLocale);
        await _flutterTts.speak(cleaned);
      } catch (e) {
        debugPrint('Device TTS failed: $e');
        _isSpeaking = false;
        speakingNotifier.value = false;
      }
    }
  }

  /// Stops any currently playing audio.
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      await _flutterTts.stop();
    } catch (_) {}
    _isSpeaking = false;
    speakingNotifier.value = false;
  }

  /// Initializes Speech Recognition for live microphone transcription.
  Future<bool> initSpeech() async {
    if (_isSpeechInitialized) return true;
    try {
      _isSpeechInitialized = await _speech.initialize(
        onError: (err) => debugPrint('STT error: $err'),
        onStatus: (status) => debugPrint('STT status: $status'),
      );
      return _isSpeechInitialized;
    } catch (e) {
      debugPrint('STT init exception: $e');
      return false;
    }
  }

  /// Starts listening for speech with live transcription stream.
  Future<void> startListening({
    required Function(String liveWords) onResult,
    required Function(String finalWords) onComplete,
    String? languageCode,
  }) async {
    final available = await initSpeech();
    if (!available) {
      onComplete('');
      return;
    }

    await stop();

    final localeId = mapToLocale(languageCode);

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          onComplete(result.recognizedWords);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: false,
        partialResults: true,
      ),
      localeId: localeId,
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 3),
    );
  }

  /// Stops microphone listening.
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  bool get isListening => _speech.isListening;
}
