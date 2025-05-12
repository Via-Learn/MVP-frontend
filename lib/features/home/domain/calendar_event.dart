class CalendarEvent {
  final String id;
  final String summary;
  final DateTime startUtc;
  final DateTime endUtc;
  final String? description;

  CalendarEvent({
    required this.id,
    required this.summary,
    required this.startUtc,
    required this.endUtc,
    this.description,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] ?? '',
      summary: json['summary'] ?? '',
      startUtc: DateTime.parse(json['start']['dateTime'] ?? json['start']['date']),
      endUtc: DateTime.parse(json['end']['dateTime'] ?? json['end']['date']),
      description: json['description'],
    );
  }

  String get localStartTime => _formatTime(startUtc.toLocal());
  String get localEndTime => _formatTime(endUtc.toLocal());

  static String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }
}
