/// Formats [date] as a 24-hour "HH:mm" time string.
String formatTime24h(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
