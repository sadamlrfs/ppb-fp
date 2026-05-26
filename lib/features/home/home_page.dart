import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../services/quote_service.dart';
import '../../models/mood_model.dart';
import 'mood_chart_widget.dart';
import 'mood_history_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _quoteService = QuoteService();
  String _quoteText = '';
  String _quoteAuthor = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  Future<void> _initData() async {
    final auth = context.read<AuthProvider>();
    if (auth.firebaseUser != null) {
      context.read<MoodProvider>().listenMoods(auth.firebaseUser!.uid);
    }
    final quote = await _quoteService.fetchRandomQuote();
    if (mounted) {
      setState(() {
        _quoteText = quote.text;
        _quoteAuthor = quote.author;
      });
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 17) return 'Selamat Siang';
    if (hour < 20) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final moodProv = context.watch<MoodProvider>();
    final name = auth.userModel?.displayName ?? 'Pengguna';

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          identifier: 'homeTitle',
          child: const Text('MindEase'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _initData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _GreetingCard(greeting: _greeting, name: name),
            const SizedBox(height: 16),
            if (_quoteText.isNotEmpty)
              _QuoteCard(text: _quoteText, author: _quoteAuthor),
            const SizedBox(height: 16),
            _TodayMoodSection(todayMood: moodProv.todayMood),
            const SizedBox(height: 20),
            if (moodProv.moods.isNotEmpty) ...[
              const Text('Tren 7 Hari',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              MoodChartWidget(moods: moodProv.getLast(7)),
              const SizedBox(height: 20),
              const Text('Riwayat Mood',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              MoodHistoryWidget(moods: moodProv.moods.take(5).toList()),
            ],
          ],
        ),
      ),
      floatingActionButton: Semantics(
        identifier: 'addMoodButton',
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.moodInput),
          icon: const Icon(Icons.add),
          label: const Text('Catat Mood'),
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String greeting;
  final String name;
  const _GreetingCard({required this.greeting, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text('Halo, $name!',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(DateFormatter.toDisplay(DateTime.now()),
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String text;
  final String author;
  const _QuoteCard({required this.text, required this.author});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.format_quote, color: AppColors.primary, size: 28),
            const SizedBox(height: 4),
            Text(text,
                style: const TextStyle(
                    fontSize: 14, fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text('— $author',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _TodayMoodSection extends StatelessWidget {
  final MoodModel? todayMood;
  const _TodayMoodSection({this.todayMood});

  @override
  Widget build(BuildContext context) {
    if (todayMood == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.mood, color: AppColors.textHint),
              const SizedBox(width: 12),
              const Expanded(
                  child: Text('Belum ada catatan mood hari ini')),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.moodInput),
                child: const Text('Catat'),
              ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      identifier: 'todayMoodCard',
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.moodDetail,
            arguments: todayMood),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(todayMood!.emoji,
                    style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mood Hari Ini',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      Text(todayMood!.label,
                          style: TextStyle(
                              color: todayMood!.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      if (todayMood!.note.isNotEmpty)
                        Text(todayMood!.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
