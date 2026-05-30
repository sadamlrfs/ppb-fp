import 'package:flutter_dotenv/flutter_dotenv.dart';

class TtsConfig {
  static String get apiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';

  // Voice ID dari ElevenLabs — Rachel (perempuan, calm, cocok untuk Bahasa Indonesia)
  // Ganti voice ID lain dari: elevenlabs.io/voice-library
  // Contoh lain:
  //   'EXAVITQu4vr4xnSDxMaL' → Bella (perempuan, lembut)
  //   'pNInz6obpgDQGcFmaJgB' → Adam (laki-laki, natural)
  static const voiceId = '21m00Tcm4TlvDq8ikWAM';

  // eleven_multilingual_v2 mendukung Bahasa Indonesia
  static const modelId = 'eleven_multilingual_v2';

  // Stability: 0.0-1.0 (lebih tinggi = lebih konsisten, lebih rendah = lebih ekspresif)
  static const stability = 0.45;

  // Similarity boost: seberapa mirip ke voice aslinya
  static const similarityBoost = 0.80;

  // Fallback flutter_tts
  static const fallbackLanguage = 'id-ID';
  static const fallbackSpeechRate = 0.48;
}
