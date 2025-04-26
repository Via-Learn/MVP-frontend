class EventModel {
  final String title;
  final String type;
  final String date;
  final String description; 

  EventModel({
    required this.title,
    required this.type,
    required this.date,
    required this.description, 
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '', // <-- Add this
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'date': date,
      'description': description, // <-- Add this
    };
  }
}
