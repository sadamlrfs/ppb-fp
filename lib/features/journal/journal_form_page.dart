import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/journal_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/journal_provider.dart';

class JournalFormPage extends StatefulWidget {
  const JournalFormPage({super.key});

  @override
  State<JournalFormPage> createState() => _JournalFormPageState();
}

class _JournalFormPageState extends State<JournalFormPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  JournalCategory _category = JournalCategory.lainnya;
  List<String> _tags = [];
  String? _imagePath;
  bool _saving = false;
  JournalModel? _editJournal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is JournalModel && _editJournal == null) {
      _editJournal = arg;
      _titleCtrl.text = arg.title;
      _contentCtrl.text = arg.content;
      _category = arg.category;
      _tags = List.from(arg.tags);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imagePath = image.path);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Judul tidak boleh kosong')));
      return;
    }
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final prov = context.read<JournalProvider>();
    final uid = auth.firebaseUser?.uid ?? '';

    bool ok;
    if (_editJournal != null) {
      ok = await prov.updateJournal(
        _editJournal!.copyWith(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          category: _category,
          tags: _tags,
        ),
        imagePath: _imagePath,
      );
    } else {
      ok = await prov.createJournal(
        userId: uid,
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        category: _category,
        tags: _tags,
        imagePath: _imagePath,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(prov.error ?? 'Gagal menyimpan')));
    }
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _editJournal != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Jurnal' : 'Tulis Jurnal'),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)))
              : TextButton(
                  onPressed: _save,
                  child: const Text('Simpan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              identifier: 'journalTitleField',
              child: TextField(
                controller: _titleCtrl,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Judul jurnal',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Kategori',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: JournalCategory.values.map((cat) {
                final selected = _category == cat;
                return ChoiceChip(
                  label: Text(cat.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = cat),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  side: BorderSide(
                      color: selected
                          ? AppColors.primary
                          : AppColors.divider),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Semantics(
              identifier: 'journalContentField',
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                minLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Tulis di sini...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textHint),
                ),
                style: const TextStyle(fontSize: 15, height: 1.7),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagCtrl,
                    onSubmitted: (_) => _addTag(),
                    decoration: const InputDecoration(
                      hintText: 'Tambah tag...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppColors.primary),
                    onPressed: _addTag),
              ],
            ),
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 6,
                children: _tags
                    .map((t) => Chip(
                          label: Text(t,
                              style: const TextStyle(fontSize: 12)),
                          onDeleted: () =>
                              setState(() => _tags.remove(t)),
                          deleteIconColor: Colors.grey,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined),
              label: Text(_imagePath != null
                  ? 'Gambar dipilih'
                  : 'Tambah Gambar'),
            ),
            Semantics(
              identifier: 'saveJournalButton',
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
