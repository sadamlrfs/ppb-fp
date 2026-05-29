import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/mood_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';

class MoodInputPage extends StatefulWidget {
  const MoodInputPage({super.key});

  @override
  State<MoodInputPage> createState() => _MoodInputPageState();
}

class _MoodInputPageState extends State<MoodInputPage> {
  int _selectedLevel = 3;
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  // Existing mood passed for editing
  MoodModel? _editMood;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is MoodModel && _editMood == null) {
      _editMood = arg;
      _selectedLevel = arg.moodLevel;
      _noteCtrl.text = arg.note;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final moodProv = context.read<MoodProvider>();
    final uid = auth.firebaseUser?.uid ?? '';

    bool ok;
    if (_editMood != null) {
      ok = await moodProv.updateMood(_editMood!.copyWith(
        moodLevel: _selectedLevel,
        emoji: MoodModel.emojis[_selectedLevel - 1],
        note: _noteCtrl.text,
      ));
    } else {
      ok = await moodProv.createMood(
        userId: uid,
        moodLevel: _selectedLevel,
        note: _noteCtrl.text,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(moodProv.error ?? 'Gagal menyimpan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _editMood != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Mood' : 'Catat Mood')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bagaimana perasaanmu hari ini?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) {
                final level = i + 1;
                final selected = _selectedLevel == level;
                return Semantics(
                  identifier: 'moodEmojiLevel$level',
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedLevel = level),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: selected
                            ? _moodColor(level).withValues(alpha: 0.2)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? _moodColor(level)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          MoodModel.emojis[i],
                          style: TextStyle(fontSize: selected ? 32 : 26),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                MoodModel.labels[_selectedLevel - 1],
                style: TextStyle(
                    color: _moodColor(_selectedLevel),
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _noteCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Tambahkan catatan (opsional)...',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            Semantics(
              identifier: 'saveMoodButton',
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Simpan Mood'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _moodColor(int level) {
    switch (level) {
      case 1: return AppColors.mood1;
      case 2: return AppColors.mood2;
      case 3: return AppColors.mood3;
      case 4: return AppColors.mood4;
      case 5: return AppColors.mood5;
      default: return AppColors.mood3;
    }
  }
}
