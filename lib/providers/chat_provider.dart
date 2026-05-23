import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_conversation_model.dart';
import '../models/chat_message_model.dart';
import '../services/gemini_service.dart';

class ChatProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _gemini = GeminiService();

  List<ChatConversationModel> _conversations = [];
  List<ChatMessageModel> _messages = [];
  ChatSession? _chatSession;
  // ignore: prefer_final_fields
  bool _loading = false;
  bool _sending = false;

  List<ChatConversationModel> get conversations => _conversations;
  List<ChatMessageModel> get messages => _messages;
  bool get loading => _loading;
  bool get sending => _sending;

  void listenConversations(String userId) {
    _db
        .collection('chatConversations')
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snap) {
      _conversations = snap.docs
          .map((d) => ChatConversationModel.fromMap(d.data(), d.id))
          .toList();
      notifyListeners();
    });
  }

  void listenMessages(String conversationId) {
    _chatSession = _gemini.startChat();
    _db
        .collection('chatConversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snap) {
      _messages = snap.docs
          .map((d) => ChatMessageModel.fromMap(d.data(), d.id))
          .toList();
      notifyListeners();
    });
  }

  Future<String> createConversation(String userId) async {
    final now = DateTime.now();
    final ref = await _db.collection('chatConversations').add(
          ChatConversationModel(
            id: '',
            userId: userId,
            title: 'Percakapan ${now.day}/${now.month}',
            createdAt: now,
            updatedAt: now,
          ).toMap(),
        );
    return ref.id;
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    if (content.trim().isEmpty || _chatSession == null) return;
    _sending = true;
    notifyListeners();

    final messagesRef = _db
        .collection('chatConversations')
        .doc(conversationId)
        .collection('messages');

    await messagesRef.add(ChatMessageModel(
      id: '',
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
    ).toMap());

    try {
      final reply = await _gemini.sendMessage(_chatSession!, content);
      await messagesRef.add(ChatMessageModel(
        id: '',
        role: MessageRole.assistant,
        content: reply,
        timestamp: DateTime.now(),
      ).toMap());
      await _db.collection('chatConversations').doc(conversationId).update({
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (_) {
      await messagesRef.add(ChatMessageModel(
        id: '',
        role: MessageRole.assistant,
        content: 'Maaf, terjadi kesalahan. Coba lagi.',
        timestamp: DateTime.now(),
      ).toMap());
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  Future<bool> renameConversation(String id, String title) async {
    try {
      await _db
          .collection('chatConversations')
          .doc(id)
          .update({'title': title});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteConversation(String id) async {
    try {
      final msgs = await _db
          .collection('chatConversations')
          .doc(id)
          .collection('messages')
          .get();
      for (final doc in msgs.docs) {
        await doc.reference.delete();
      }
      await _db.collection('chatConversations').doc(id).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  void clearMessages() {
    _messages = [];
    _chatSession = null;
    notifyListeners();
  }
}
