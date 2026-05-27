import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
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
  await NotificationService().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => MeditationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MindEaseApp(),
    ),
  );
}
