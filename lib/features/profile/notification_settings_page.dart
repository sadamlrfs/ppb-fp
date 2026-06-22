import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../services/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _morningEnabled = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  bool _eveningEnabled = true;
  TimeOfDay _eveningTime = const TimeOfDay(hour: 19, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _morningEnabled = prefs.getBool('morning_enabled') ?? true;
      _morningTime = TimeOfDay(
        hour: prefs.getInt('morning_hour') ?? 7,
        minute: prefs.getInt('morning_minute') ?? 0,
      );
      _eveningEnabled = prefs.getBool('evening_enabled') ?? true;
      _eveningTime = TimeOfDay(
        hour: prefs.getInt('evening_hour') ?? 19,
        minute: prefs.getInt('evening_minute') ?? 0,
      );
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('morning_enabled', _morningEnabled);
    await prefs.setInt('morning_hour', _morningTime.hour);
    await prefs.setInt('morning_minute', _morningTime.minute);
    await prefs.setBool('evening_enabled', _eveningEnabled);
    await prefs.setInt('evening_hour', _eveningTime.hour);
    await prefs.setInt('evening_minute', _eveningTime.minute);

    final svc = NotificationService();
    await svc.cancelReminder(NotificationService.morningId);
    await svc.cancelReminder(NotificationService.eveningId);

    if (_morningEnabled) {
      await svc.scheduleReminder(
        id: NotificationService.morningId,
        hour: _morningTime.hour,
        minute: _morningTime.minute,
        messages: NotificationService.morningMessages,
      );
    }
    if (_eveningEnabled) {
      await svc.scheduleReminder(
        id: NotificationService.eveningId,
        hour: _eveningTime.hour,
        minute: _eveningTime.minute,
        messages: NotificationService.eveningMessages,
      );
    }
  }

  Future<void> _pickTime(bool isMorning) async {
    final initial = isMorning ? _morningTime : _eveningTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isMorning) {
        _morningTime = picked;
      } else {
        _eveningTime = picked;
      }
    });
    await _save();
    if (mounted) _showSavedSnackbar();
  }

  Future<void> _toggleMorning(bool value) async {
    setState(() => _morningEnabled = value);
    await _save();
    if (mounted) _showSavedSnackbar();
  }

  Future<void> _toggleEvening(bool value) async {
    setState(() => _eveningEnabled = value);
    await _save();
    if (mounted) _showSavedSnackbar();
  }

  Future<void> _sendTest() async {
    await NotificationService().scheduleTestReminder();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi akan muncul dalam 10 detik'),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSavedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan notifikasi disimpan'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Notifikasi')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ReminderCard(
                  icon: Icons.wb_sunny_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Pengingat Pagi',
                  subtitle: 'Tanyakan kabarmu di pagi hari',
                  enabled: _morningEnabled,
                  time: _formatTime(_morningTime),
                  onToggle: _toggleMorning,
                  onTimeTap: _morningEnabled ? () => _pickTime(true) : null,
                ),
                const SizedBox(height: 12),
                _ReminderCard(
                  icon: Icons.nights_stay_outlined,
                  iconColor: const Color(0xFF6366F1),
                  title: 'Pengingat Malam',
                  subtitle: 'Tanyakan kabarmu di malam hari',
                  enabled: _eveningEnabled,
                  time: _formatTime(_eveningTime),
                  onToggle: _toggleEvening,
                  onTimeTap: _eveningEnabled ? () => _pickTime(false) : null,
                ),
                const SizedBox(height: 24),
                _PreviewCard(
                  morningEnabled: _morningEnabled,
                  morningTime: _formatTime(_morningTime),
                  eveningEnabled: _eveningEnabled,
                  eveningTime: _formatTime(_eveningTime),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _sendTest,
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Uji Notifikasi Sekarang'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool enabled;
  final String time;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onTimeTap;

  const _ReminderCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.time,
    required this.onToggle,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: onToggle,
                ),
              ],
            ),
            if (enabled) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              InkWell(
                onTap: onTimeTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      const Text('Ubah',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.primary)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right,
                          size: 18, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final bool morningEnabled;
  final String morningTime;
  final bool eveningEnabled;
  final String eveningTime;

  const _PreviewCard({
    required this.morningEnabled,
    required this.morningTime,
    required this.eveningEnabled,
    required this.eveningTime,
  });

  @override
  Widget build(BuildContext context) {
    final active = [
      if (morningEnabled) '🌞 $morningTime — Pengingat pagi',
      if (eveningEnabled) '🌙 $eveningTime — Pengingat malam',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text('Jadwal aktif',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          if (active.isEmpty)
            const Text('Tidak ada pengingat aktif.',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary))
          else
            ...active.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(s,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textPrimary)),
                )),
        ],
      ),
    );
  }
}
