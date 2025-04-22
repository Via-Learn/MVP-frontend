// features/plan/domain/event_model.dart
class EventModel {
  final String title;
  final String type;
  final String date;

  EventModel({required this.title, required this.type, required this.date});

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
