import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/chat_provider.dart';
import 'chat_bubble_widget.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _stt = SpeechToText();
  final _tts = FlutterTts();

  late String _conversationId;
  bool _initialized = false;
  bool _isListening = false;
  bool _ttsEnabled = true;
  bool _sttAvailable = false;

  @override
  void initState() {
    super.initState();
    _initVoice();
  }

  Future<void> _initVoice() async {
    _sttAvailable = await _stt.initialize(
      onError: (_) => setState(() => _isListening = false),
    );
    await _tts.setLanguage('id-ID');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _conversationId =
          ModalRoute.of(context)!.settings.arguments as String;
      context.read<ChatProvider>().listenMessages(_conversationId);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _tts.stop();
    _stt.stop();
    context.read<ChatProvider>().clearMessages();
    super.dispose();
  }

  Future<void> _toggleListen() async {
    if (_isListening) {
      await _stt.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _stt.listen(
        onResult: (result) {
          setState(() => _inputCtrl.text = result.recognizedWords);
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            setState(() => _isListening = false);
            _send();
          }
        },
        listenOptions: SpeechListenOptions(
          localeId: 'id_ID',
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    final chatProv = context.read<ChatProvider>();
    await chatProv.sendMessage(
      conversationId: _conversationId,
      content: text,
    );
    _scrollToBottom();
    if (!mounted) return;
    if (_ttsEnabled && chatProv.messages.isNotEmpty && !chatProv.messages.last.isUser) {
      await _tts.speak(chatProv.messages.last.content);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ChatProvider>();
    final convTitle = prov.conversations
        .where((c) => c.id == _conversationId)
        .map((c) => c.title)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(convTitle ?? 'AI Companion'),
        actions: [
          IconButton(
            tooltip: _ttsEnabled ? 'Matikan suara bot' : 'Hidupkan suara bot',
            icon: Icon(
              _ttsEnabled ? Icons.volume_up : Icons.volume_off,
              color: _ttsEnabled ? AppColors.primary : Colors.grey,
            ),
            onPressed: () {
              setState(() => _ttsEnabled = !_ttsEnabled);
              if (!_ttsEnabled) _tts.stop();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('AI ini bukan pengganti psikolog profesional'),
                duration: Duration(seconds: 3),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: prov.messages.isEmpty
                ? const _WelcomeHint()
                : ListView.builder(
                    controller: _scrollCtrl,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: prov.messages.length,
                    itemBuilder: (_, i) {
                      final msg =
                          prov.messages[prov.messages.length - 1 - i];
                      return ChatBubbleWidget(message: msg);
                    },
                  ),
          ),
          if (prov.sending) const _TypingIndicator(),
          if (_isListening) const _ListeningIndicator(),
          _InputBar(
            controller: _inputCtrl,
            sending: prov.sending,
            isListening: _isListening,
            sttAvailable: _sttAvailable,
            onSend: _send,
            onMicTap: _toggleListen,
          ),
        ],
      ),
    );
  }
}

class _WelcomeHint extends StatelessWidget {
  const _WelcomeHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_mark.png',
              width: 56,
              height: 56,
              color: AppColors.primary,
              colorBlendMode: BlendMode.srcIn,
            ),
            const SizedBox(height: 16),
            const Text('Halo! Saya MindEase AI.',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Ceritakan apa yang ada di pikiranmu.\nSaya siap mendengarkan — ketik atau tekan mikrofon.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: Image.asset(
              'assets/images/logo_mark.png',
              width: 14,
              height: 14,
              color: Colors.white,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('Mengetik...',
                style: TextStyle(
                    color: Colors.grey, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }
}

class _ListeningIndicator extends StatelessWidget {
  const _ListeningIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic, color: AppColors.primary, size: 16),
          SizedBox(width: 6),
          Text('Sedang mendengarkan...',
              style:
                  TextStyle(color: AppColors.primary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final bool isListening;
  final bool sttAvailable;
  final VoidCallback onSend;
  final VoidCallback onMicTap;

  const _InputBar({
    required this.controller,
    required this.sending,
    required this.isListening,
    required this.sttAvailable,
    required this.onSend,
    required this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            if (sttAvailable)
              GestureDetector(
                onTap: sending ? null : onMicTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isListening
                        ? Colors.red
                        : AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isListening ? Icons.mic_off : Icons.mic,
                    color: isListening ? Colors.white : AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
            if (sttAvailable) const SizedBox(width: 8),
            Expanded(
              child: Semantics(
                identifier: 'chatInputField',
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: sttAvailable
                        ? 'Ketik atau tekan mikrofon...'
                        : 'Tulis pesan...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              identifier: 'sendMessageButton',
              child: GestureDetector(
                onTap: sending ? null : onSend,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: sending ? Colors.grey : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: sending
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send,
                          color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
