class Assignment {
  final int id;
  final String title;
  final String dueDate;
  String status;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    this.status = 'Not Started',
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'],
      dueDate: json['due_date'],
      status: json['status'] ?? 'Not Started',
    );
  }
}
