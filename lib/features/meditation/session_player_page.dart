import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/meditation_session_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meditation_provider.dart';
import '../../services/human_tts_service.dart';

class SessionPlayerPage extends StatefulWidget {
  const SessionPlayerPage({super.key});

  @override
  State<SessionPlayerPage> createState() => _SessionPlayerPageState();
}

class _SessionPlayerPageState extends State<SessionPlayerPage> {
  final _player = AudioPlayer();
  final _humanTts = HumanTtsService();
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _completed = false;
  bool _ttsPlaying = false;

  int _rating = 4;
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  late MeditationSessionModel _session;
  bool _sessionLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_sessionLoaded) {
      _session = ModalRoute.of(context)!.settings.arguments
          as MeditationSessionModel;
      _sessionLoaded = true;
      _initPlayer();
    }
  }

  void _initPlayer() {
    _player.onPlayerStateChanged
        .listen((s) => mounted ? setState(() => _playerState = s) : null);
    _player.onPositionChanged
        .listen((p) => mounted ? setState(() => _position = p) : null);
    _player.onDurationChanged
        .listen((d) => mounted ? setState(() => _duration = d) : null);
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _completed = true);
    });

    _humanTts.init();
    _humanTts.setCompletionHandler(() {
      if (mounted) setState(() { _completed = true; _ttsPlaying = false; });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _humanTts.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String _getMeditationScript() {
    switch (_session.category) {
      case MeditationCategory.breathing:
        return 'Selamat datang di sesi pernapasan. '
            '${_session.description}. '
            'Temukan posisi yang nyaman, duduk atau berbaring. '
            'Sekarang, tarik napas perlahan melalui hidung selama empat hitungan. '
            'Satu... dua... tiga... empat. '
            'Tahan napas selama tujuh hitungan. '
            'Satu... dua... tiga... empat... lima... enam... tujuh. '
            'Hembuskan perlahan melalui mulut selama delapan hitungan. '
            'Satu... dua... tiga... empat... lima... enam... tujuh... delapan. '
            'Bagus sekali. Ulangi tiga kali lagi. '
            'Rasakan ketenangan mengalir di seluruh tubuhmu. '
            'Kamu melakukan dengan sangat baik.';
      case MeditationCategory.sleep:
        return 'Selamat datang di sesi tidur. '
            '${_session.description}. '
            'Berbaring dengan nyaman. Pejamkan matamu. '
            'Rasakan beban tubuhmu melebur ke tempat tidur. '
            'Mulai dari ujung jari kaki, lepaskan semua ketegangan. '
            'Naik perlahan ke betis, paha, perut... biarkan semuanya rileks. '
            'Bahu, lengan, dan tanganmu menjadi ringan. '
            'Wajahmu terasa sejuk dan tenang. '
            'Napas pelan dan teratur. '
            'Biarkan rasa kantuk membawamu ke tidur yang nyenyak dan menyegarkan.';
      case MeditationCategory.focus:
        return 'Selamat datang di sesi fokus. '
            '${_session.description}. '
            'Duduklah dengan tegak dan nyaman. Pejamkan mata. '
            'Pusatkan seluruh perhatianmu pada napas. '
            'Rasakan udara masuk dan keluar dari hidungmu. '
            'Jika pikiran mulai melayang, itu wajar. '
            'Perlahan kembalikan fokus ke napas. '
            'Setiap napas membawa kejernihan. '
            'Setiap hembusan melepaskan gangguan. '
            'Kamu kini siap untuk fokus dan berkarya dengan baik.';
      case MeditationCategory.anxiety:
        return 'Selamat datang di sesi meredakan kecemasan. '
            '${_session.description}. '
            'Kamu aman di sini. Kamu baik-baik saja. '
            'Mari kita gunakan teknik grounding bersama-sama. '
            'Perhatikan lima hal yang bisa kamu lihat di sekitarmu. '
            'Sekarang, empat hal yang bisa kamu sentuh. '
            'Tiga hal yang bisa kamu dengar. '
            'Dua hal yang bisa kamu cium. '
            'Satu hal yang bisa kamu rasakan. '
            'Tarik napas dalam. Tahan. Hembuskan. '
            'Kamu ada di sini, di momen ini. Kamu kuat. Kamu mampu melewati ini.';
    }
  }

  Future<void> _togglePlay() async {
    if (_ttsPlaying) {
      await _humanTts.stop();
      setState(() => _ttsPlaying = false);
    } else if (_playerState == PlayerState.playing) {
      await _player.pause();
    } else {
      if (_session.audioUrl.isNotEmpty) {
        await _player.play(UrlSource(_session.audioUrl));
      } else {
        setState(() => _ttsPlaying = true);
        await _humanTts.speak(_getMeditationScript());
      }
    }
  }

  Future<void> _seek(double val) async {
    final pos = Duration(seconds: val.toInt());
    await _player.seek(pos);
  }

  Future<void> _skip(int seconds) async {
    final newPos = _position + Duration(seconds: seconds);
    await _player.seek(newPos.isNegative ? Duration.zero : newPos);
  }

  Future<void> _saveSession() async {
    setState(() => _saving = true);
    final uid = context.read<AuthProvider>().firebaseUser?.uid ?? '';
    final ok = await context.read<MeditationProvider>().saveUserSession(
          userId: uid,
          sessionId: _session.id,
          rating: _rating,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _isPlaying =>
      _playerState == PlayerState.playing || _ttsPlaying;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_session.title)),
      body: _completed ? _buildRatingForm() : _buildPlayer(),
    );
  }

  Widget _buildPlayer() {
    final maxSec =
        _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: _ttsPlaying
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 8,
                      )
                    ]
                  : [],
            ),
            child: Icon(
              _ttsPlaying ? Icons.record_voice_over : Icons.self_improvement,
              color: Colors.white,
              size: 80,
            ),
          ),
          const SizedBox(height: 16),
          if (_ttsPlaying)
            const Text(
              'Panduan suara sedang diputar...',
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic),
            ),
          const SizedBox(height: 16),
          Text(_session.title,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(_session.description,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          if (_session.audioUrl.isNotEmpty) ...[
            Slider(
              value: _position.inSeconds.toDouble().clamp(0, maxSec),
              max: maxSec,
              onChanged: _seek,
              activeColor: AppColors.primary,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position),
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(_formatDuration(_duration),
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.replay_10),
                  onPressed: () => _skip(-10),
                ),
                const SizedBox(width: 16),
                _PlayButton(isPlaying: _isPlaying, onTap: _togglePlay),
                const SizedBox(width: 16),
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.forward_10),
                  onPressed: () => _skip(10),
                ),
              ],
            ),
          ] else ...[
            _PlayButton(isPlaying: _isPlaying, onTap: _togglePlay),
          ],
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => setState(() => _completed = true),
            child: const Text('Tandai Selesai'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Icon(Icons.check_circle,
                color: AppColors.secondary, size: 72),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('Sesi Selesai!',
                style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 32),
          const Text('Beri Rating Sesi Ini',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => IconButton(
                icon: Icon(
                  i < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 36,
                ),
                onPressed: () => setState(() => _rating = i + 1),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _saveSession,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan Sesi'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  const _PlayButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }
}
