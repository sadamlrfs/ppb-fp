import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/journal_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/journal_provider.dart';
import 'journal_filter_widget.dart';

class JournalListPage extends StatefulWidget {
  const JournalListPage({super.key});

  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().firebaseUser?.uid ?? '';
      context.read<JournalProvider>().listenJournals(uid);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showFilter(BuildContext context) {
    final prov = context.read<JournalProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => JournalFilterWidget(
        selected: prov.filterCategory,
        onSelected: (cat) {
          prov.setFilter(cat);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journals = context.watch<JournalProvider>().journals;
    final loading = context.watch<JournalProvider>().loading;
    final filter = context.watch<JournalProvider>().filterCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jurnal'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filter != null,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => _showFilter(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: context.read<JournalProvider>().setSearch,
              decoration: InputDecoration(
                hintText: 'Cari jurnal...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<JournalProvider>().setSearch('');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : journals.isEmpty
              ? _EmptyState(
                  onAdd: () =>
                      Navigator.pushNamed(context, AppRoutes.journalForm))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: journals.length,
                  itemBuilder: (_, i) =>
                      _JournalCard(journal: journals[i]),
                ),
      floatingActionButton: Semantics(
        identifier: 'addJournalButton',
        child: FloatingActionButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.journalForm),
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final JournalModel journal;
  const _JournalCard({required this.journal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, AppRoutes.journalDetail,
            arguments: journal),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(journal.category.label,
                        style: const TextStyle(fontSize: 11)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                  ),
                  const Spacer(),
                  Text(DateFormatter.toRelative(journal.createdAt),
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Text(journal.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(journal.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Belum ada jurnal',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          SizedBox(
            width: 200,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Tulis Jurnal'),
            ),
          ),
        ],
      ),
    );
  }
}
