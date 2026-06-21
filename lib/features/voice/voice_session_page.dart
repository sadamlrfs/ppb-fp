import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../core/constants/app_colors.dart';
import '../../services/gemini_service.dart';
import '../../services/human_tts_service.dart';

enum _VoiceState { idle, listening, thinking, speaking }

class _VoiceMessage {
  final String text;
  final bool isUser;
  _VoiceMessage({required this.text, required this.isUser});
}

class VoiceSessionPage extends StatefulWidget {
  const VoiceSessionPage({super.key});

  @override
  State<VoiceSessionPage> createState() => _VoiceSessionPageState();
}

class _VoiceSessionPageState extends State<VoiceSessionPage>
    with TickerProviderStateMixin {
  final _stt = SpeechToText();
  final _humanTts = HumanTtsService();
  final _geminiService = GeminiService();
  late final ChatSession _chatSession;

  _VoiceState _state = _VoiceState.idle;
  bool _sttAvailable = false;
  bool _autoListen = true;
  final List<_VoiceMessage> _transcript = [];
  final _scrollCtrl = ScrollController();

  late AnimationController _pulseController;
  late Animation<double> _outerPulse;
  late Animation<double> _innerPulse;

  @override
  void initState() {
    super.initState();
    _chatSession = _geminiService.startChat();
    _setupAnimations();
    _initVoice();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _outerPulse = Tween<double>(begin: 1.0, end: 1.38).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _innerPulse = Tween<double>(begin: 1.0, end: 1.14).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initVoice() async {
    _sttAvailable = await _stt.initialize(
      onError: (_) {
        if (mounted) setState(() => _state = _VoiceState.idle);
      },
    );
    await _humanTts.init();
    _humanTts.setCompletionHandler(_onBotDoneSpeaking);
    if (mounted) setState(() {});
  }

  Future<void> _startListening() async {
    if (!_sttAvailable || _state != _VoiceState.idle) return;
    setState(() => _state = _VoiceState.listening);
    await _stt.listen(
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _stt.stop();
          _handleUserSpeech(result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: 'id_ID',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _stopListening() async {
    await _stt.stop();
    if (mounted) setState(() => _state = _VoiceState.idle);
  }

  Future<void> _handleUserSpeech(String text) async {
    if (!mounted) return;
    setState(() {
      _transcript.add(_VoiceMessage(text: text, isUser: true));
      _state = _VoiceState.thinking;
    });
    _scrollDown();

    try {
      final response = await _geminiService.sendMessage(_chatSession, text);
      if (!mounted) return;
      setState(() {
        _transcript.add(_VoiceMessage(text: response, isUser: false));
        _state = _VoiceState.speaking;
      });
      _scrollDown();
      await _humanTts.speak(response);
    } catch (_) {
      if (mounted) setState(() => _state = _VoiceState.idle);
    }
  }

  void _onBotDoneSpeaking() {
    if (!mounted) return;
    setState(() => _state = _VoiceState.idle);
    if (_autoListen) _startListening();
  }

  Future<void> _handleMainButton() async {
    switch (_state) {
      case _VoiceState.idle:
        _startListening();
      case _VoiceState.listening:
        _stopListening();
      case _VoiceState.speaking:
        await _humanTts.stop();
        if (mounted) {
          setState(() => _state = _VoiceState.idle);
          if (_autoListen) _startListening();
        }
      case _VoiceState.thinking:
        break;
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollCtrl.dispose();
    _stt.stop();
    _humanTts.dispose();
    super.dispose();
  }

  Color get _stateColor {
    switch (_state) {
      case _VoiceState.idle:
        return AppColors.primary;
      case _VoiceState.listening:
        return const Color(0xFF3B82F6);
      case _VoiceState.thinking:
        return const Color(0xFFF59E0B);
      case _VoiceState.speaking:
        return const Color(0xFF10B981);
    }
  }

  String get _statusText {
    switch (_state) {
      case _VoiceState.idle:
        return _sttAvailable ? 'Tap untuk mulai bicara' : 'Mikrofon tidak tersedia';
      case _VoiceState.listening:
        return 'Mendengarkan kamu...';
      case _VoiceState.thinking:
        return 'AI sedang memproses...';
      case _VoiceState.speaking:
        return 'AI sedang menjawab...';
    }
  }

  bool get _isAnimating =>
      _state == _VoiceState.listening || _state == _VoiceState.speaking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Sesi Suara dengan AI'),
        actions: [
          Row(
            children: [
              Text(
                'Auto',
                style: TextStyle(
                    fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
              ),
              Switch(
                value: _autoListen,
                onChanged: (v) => setState(() => _autoListen = v),
                activeThumbColor: AppColors.secondary,
                activeTrackColor: AppColors.secondary.withValues(alpha: 0.5),
                inactiveTrackColor: Colors.white24,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Avatar + status ──────────────────────────────────
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated avatar
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) {
                      return SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_isAnimating)
                              Transform.scale(
                                scale: _outerPulse.value,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _stateColor.withValues(alpha: 0.08),
                                  ),
                                ),
                              ),
                            if (_isAnimating)
                              Transform.scale(
                                scale: _innerPulse.value,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _stateColor.withValues(alpha: 0.15),
                                  ),
                                ),
                              ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _stateColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: _stateColor.withValues(alpha: 0.45),
                                    blurRadius: 32,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: _state == _VoiceState.thinking
                                  ? const Padding(
                                      padding: EdgeInsets.all(34),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : _state == _VoiceState.idle
                                      ? Image.asset(
                                          'assets/images/logo_mark.png',
                                          width: 52,
                                          height: 52,
                                          color: Colors.white,
                                          colorBlendMode: BlendMode.srcIn,
                                        )
                                      : Icon(
                                          _state == _VoiceState.listening
                                              ? Icons.mic
                                              : Icons.record_voice_over,
                                          color: Colors.white,
                                          size: 52,
                                        ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  // Status text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _statusText,
                      key: ValueKey(_state),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _stateColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _state == _VoiceState.speaking
                        ? 'Tap untuk hentikan'
                        : _state == _VoiceState.listening
                            ? 'Tap untuk berhenti'
                            : _autoListen
                                ? 'Akan otomatis lanjut setelah AI selesai'
                                : 'Mode manual aktif',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Transkrip ─────────────────────────────────────────
          if (_transcript.isNotEmpty)
            Container(
              height: 210,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                border: Border(
                  top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      'TRANSKRIP',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      itemCount: _transcript.length,
                      itemBuilder: (_, i) {
                        final msg = _transcript[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 36,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    msg.isUser ? 'Kamu' : 'AI',
                                    style: TextStyle(
                                      color: msg.isUser
                                          ? const Color(0xFF60A5FA)
                                          : const Color(0xFF34D399),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  msg.text,
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.75),
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // ── Tombol kontrol ────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: GestureDetector(
                  onTap: _state == _VoiceState.thinking
                      ? null
                      : _handleMainButton,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _state == _VoiceState.thinking
                          ? Colors.grey.shade800
                          : _stateColor,
                      boxShadow: _state != _VoiceState.thinking
                          ? [
                              BoxShadow(
                                color: _stateColor.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      _state == _VoiceState.idle
                          ? Icons.mic
                          : _state == _VoiceState.listening
                              ? Icons.mic_off
                              : _state == _VoiceState.speaking
                                  ? Icons.stop
                                  : Icons.hourglass_empty,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
