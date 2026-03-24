class Task {
  final int id;
  final String title;
  final String description;
  final String dueDate;
  final String status;
  final int? blockedBy;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedBy,
  });

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'],
        title: j['title'],
        description: j['description'] ?? '',
        dueDate: j['due_date'],
        status: j['status'],
        blockedBy: j['blocked_by'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'due_date': dueDate,
        'status': status,
        'blocked_by': blockedBy,
      };
}