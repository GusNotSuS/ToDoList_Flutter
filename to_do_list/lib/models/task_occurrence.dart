import 'task.dart';

class TaskOccurrence {
  final Task task;
  final DateTime date;

  TaskOccurrence({
    required this.task,
    required this.date,
  });

  bool get isCompleted => task.isCompletedOn(date);
}