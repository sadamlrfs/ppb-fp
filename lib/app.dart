import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/auth/forgot_password_page.dart';
import 'features/journal/journal_form_page.dart';
import 'features/journal/journal_detail_page.dart';
import 'features/home/mood_input_page.dart';
import 'features/home/mood_detail_page.dart';
import 'features/meditation/session_player_page.dart';
import 'features/meditation/session_history_page.dart';
import 'features/meditation/add_session_page.dart';
import 'features/voice/voice_session_page.dart';
import 'features/chat/chat_room_page.dart';
import 'features/profile/edit_profile_page.dart';
import 'features/profile/notification_settings_page.dart';
import 'widgets/bottom_nav_bar.dart';

class MindEaseApp extends StatelessWidget {
  const MindEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindEase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordPage(),
        AppRoutes.home: (_) => const MainNavigation(),
        AppRoutes.moodInput: (_) => const MoodInputPage(),
        AppRoutes.moodDetail: (_) => const MoodDetailPage(),
        AppRoutes.journalForm: (_) => const JournalFormPage(),
        AppRoutes.journalDetail: (_) => const JournalDetailPage(),
        AppRoutes.sessionPlayer: (_) => const SessionPlayerPage(),
        AppRoutes.sessionHistory: (_) => const SessionHistoryPage(),
        AppRoutes.addSession: (_) => const AddSessionPage(),
        AppRoutes.voiceSession: (_) => const VoiceSessionPage(),
        AppRoutes.chatRoom: (_) => const ChatRoomPage(),
        AppRoutes.editProfile: (_) => const EditProfilePage(),
        AppRoutes.notificationSettings: (_) =>
            const NotificationSettingsPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_mark.png',
              width: 80,
              height: 80,
              color: Colors.white,
              colorBlendMode: BlendMode.srcIn,
            ),
            const SizedBox(height: 16),
            Text(
              'MindEase',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Mental Wellness Companion',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white54,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
