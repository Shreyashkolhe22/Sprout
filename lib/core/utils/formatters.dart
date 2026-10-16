import 'dates.dart';

/// "512 B", "86 KB", "2.4 MB".
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  final mb = bytes / (1024 * 1024);
  return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
}

/// "Today, 14:05", "Yesterday", "12 Oct" or "12 Oct 2025".
String formatNoteDate(DateTime date, DateTime now) {
  final day = dateOnly(date);
  final today = dateOnly(now);
  if (day == today) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return 'Today, $h:$m';
  }
  if (day == addDays(today, -1)) return 'Yesterday';
  final base = '${date.day} ${monthShort[date.month - 1]}';
  return date.year == now.year ? base : '$base ${date.year}';
}
