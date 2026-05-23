import 'package:intl/intl.dart';

class DateFormatter {
  static String toDisplay(DateTime date) =>
      DateFormat('dd MMM yyyy', 'id').format(date);

  static String toDisplayWithTime(DateTime date) =>
      DateFormat('dd MMM yyyy, HH:mm', 'id').format(date);

  static String toDateOnly(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static String toTime(DateTime date) => DateFormat('HH:mm').format(date);

  static String toRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return toDisplay(date);
  }
}
