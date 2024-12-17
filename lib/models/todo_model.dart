class Todo {
  int? id;
  String title;
  String description;
  bool isCompleted;

  final DateTime? dueDate;

  final DateTime createdAt;

  Todo({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.dueDate,
   required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      createdAt:
           DateTime.parse(map['createdAt']) ,
    );
  }
}
