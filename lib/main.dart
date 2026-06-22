import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/firebase_options.dart';
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/meditation_provider.dart';
import 'providers/chat_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  final notifService = NotificationService();
  await notifService.init();

  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('morning_enabled') ?? true) {
    await notifService.scheduleReminder(
      id: NotificationService.morningId,
      hour: prefs.getInt('morning_hour') ?? 7,
      minute: prefs.getInt('morning_minute') ?? 0,
      messages: NotificationService.morningMessages,
    );
  }
  if (prefs.getBool('evening_enabled') ?? true) {
    await notifService.scheduleReminder(
      id: NotificationService.eveningId,
      hour: prefs.getInt('evening_hour') ?? 19,
      minute: prefs.getInt('evening_minute') ?? 0,
      messages: NotificationService.eveningMessages,
    );
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, JournalProvider>(
          create: (_) => JournalProvider(),
          update: (_, auth, journal) {
            final uid = auth.firebaseUser?.uid ?? '';
            journal!.listenJournals(uid);
            return journal;
          },
        ),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => MeditationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MindEaseApp(),
    ),
  );
}
