import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/journal_model.dart';

class JournalFilterWidget extends StatefulWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;

  const JournalFilterWidget({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<JournalFilterWidget> createState() => _JournalFilterWidgetState();
}

class _JournalFilterWidgetState extends State<JournalFilterWidget> {
  late String? _current;

  @override
  void initState() {
    super.initState();
    _current = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Filter Kategori',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          _FilterTile(
            label: 'Semua',
            value: null,
            selected: _current,
            onTap: (v) {
              setState(() => _current = v);
              widget.onSelected(v);
            },
          ),
          ...JournalCategory.values.map((cat) => _FilterTile(
                label: cat.label,
                value: cat.name,
                selected: _current,
                onTap: (v) {
                  setState(() => _current = v);
                  widget.onSelected(v);
                },
              )),
        ],
      ),
    );
  }
}

class _FilterTile extends StatelessWidget {
  final String label;
  final String? value;
  final String? selected;
  final ValueChanged<String?> onTap;

  const _FilterTile({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return ListTile(
      title: Text(label),
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? AppColors.primary : Colors.grey,
      ),
      onTap: () => onTap(value),
    );
  }
}
