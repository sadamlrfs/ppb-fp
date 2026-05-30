import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import '../core/config/tts_config.dart';

/// TTS service dengan dua mode:
/// - ElevenLabs API  → suara sangat realistis (butuh ELEVENLABS_API_KEY di .env)
/// - flutter_tts     → fallback ke TTS bawaan device jika API key kosong
class HumanTtsService {
  static const _baseUrl = 'https://api.elevenlabs.io/v1/text-to-speech';

  final _player = AudioPlayer();
  final _fallback = FlutterTts();
  VoidCallback? _onComplete;

  Future<void> init() async {
    await _fallback.setLanguage(TtsConfig.fallbackLanguage);
    await _fallback.setSpeechRate(TtsConfig.fallbackSpeechRate);
    await _fallback.setPitch(1.0);
    _fallback.setCompletionHandler(() => _onComplete?.call());
    _player.onPlayerComplete.listen((_) => _onComplete?.call());
  }

  void setCompletionHandler(VoidCallback handler) {
    _onComplete = handler;
  }

  Future<void> speak(String text) async {
    if (TtsConfig.apiKey.isNotEmpty) {
      await _speakWithElevenLabs(text);
    } else {
      await _fallback.speak(text);
    }
  }

  Future<void> _speakWithElevenLabs(String text) async {
    try {
      final uri = Uri.parse(
          '$_baseUrl/${TtsConfig.voiceId}?output_format=mp3_44100_128');

      final response = await http.post(
        uri,
        headers: {
          'xi-api-key': TtsConfig.apiKey,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: jsonEncode({
          'text': text,
          'model_id': TtsConfig.modelId,
          'voice_settings': {
            'stability': TtsConfig.stability,
            'similarity_boost': TtsConfig.similarityBoost,
            'style': 0.0,
            'use_speaker_boost': true,
          },
        }),
      );

      if (response.statusCode == 200) {
        await _player.play(BytesSource(response.bodyBytes));
      } else {
        debugPrint(
            '[HumanTts] ElevenLabs error ${response.statusCode}: ${response.body}');
        await _fallback.speak(text);
      }
    } catch (e) {
      debugPrint('[HumanTts] Exception, fallback ke device TTS: $e');
      await _fallback.speak(text);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    await _fallback.stop();
  }

  void dispose() {
    _player.dispose();
    _fallback.stop();
  }
}
