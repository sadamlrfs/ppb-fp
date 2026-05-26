import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/config/gemini_config.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: GeminiConfig.model,
      apiKey: GeminiConfig.apiKey,
      systemInstruction: Content.system(GeminiConfig.systemPrompt),
    );
  }

  ChatSession startChat({List<Content>? history}) =>
      _model.startChat(history: history ?? []);

  Future<String> sendMessage(ChatSession session, String message) async {
    final response = await session.sendMessage(Content.text(message));
    return response.text ?? 'Maaf, saya tidak bisa merespons saat ini.';
  }
}
