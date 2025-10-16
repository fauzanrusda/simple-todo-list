class Task {
  final String id;
  String title;
  bool isDone;

  Task({String? id, required this.title, this.isDone = false}) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();
}