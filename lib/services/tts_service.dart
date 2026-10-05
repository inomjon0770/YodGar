import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> _initTts() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSynthCompletion(true);
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  /// Speak text out loud in English, Russian, or Uzbek
  static Future<void> speak(String text, {String language = 'en', double rate = 0.48}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    await _initTts();

    try {
      await _flutterTts.stop();
      await _flutterTts.setSpeechRate(rate);

      final lowerLang = language.toLowerCase();
      String ttsLang = 'en-US';
      if (lowerLang.contains('ru') || lowerLang.contains('rus')) {
        ttsLang = 'ru-RU';
      } else if (lowerLang.contains('uz') || lowerLang.contains('o\'zbek')) {
        ttsLang = 'tr-TR'; // Closest Turkic phonetics available on all standard TTS engines
      } else {
        ttsLang = 'en-US';
      }

      await _flutterTts.setLanguage(ttsLang);
      await _flutterTts.speak(cleanText);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  /// Speak specifically in English with natural learner speed
  static Future<void> speakEnglish(String text, {bool slow = false}) async {
    await speak(text, language: 'en', rate: slow ? 0.32 : 0.48);
  }

  /// Speak specifically in Russian
  static Future<void> speakRussian(String text, {bool slow = false}) async {
    await speak(text, language: 'ru', rate: slow ? 0.35 : 0.50);
  }

  /// Stop any ongoing speech
  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }
}
