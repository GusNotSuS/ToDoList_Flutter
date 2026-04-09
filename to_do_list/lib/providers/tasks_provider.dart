import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/task_occurrence.dart';
import '../services/local_storage_service.dart';

enum HomeFilter {
  todas,
  hoje,
  proximas,
}

class TasksProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _storage.loadTasks();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _persist();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((e) => e.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await _persist();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((e) => e.id == id);
    await _persist();
  }

  Future<void> toggleTaskForDate(String taskId, DateTime date) async {
    final index = _tasks.indexWhere((e) => e.id == taskId);
    if (index == -1) return;

    _tasks[index] = _tasks[index].toggleCompletionOn(date);
    await _persist();
  }

  List<TaskOccurrence> getTodayOccurrences() {
    final today = _normalize(DateTime.now());

    return _tasks
        .where((task) => task.occursOn(today))
        .map((task) => TaskOccurrence(task: task, date: today))
        .toList()
      ..sort((a, b) {
        if (a.isCompleted == b.isCompleted) {
          return a.task.title.toLowerCase().compareTo(b.task.title.toLowerCase());
        }
        return a.isCompleted ? 1 : -1;
      });
  }

  List<TaskOccurrence> getUpcomingOccurrences() {
    final today = _normalize(DateTime.now());
    final end = today.add(const Duration(days: 30));

    final List<TaskOccurrence> result = [];

    for (final task in _tasks) {
      for (DateTime d = today.add(const Duration(days: 1));
          !d.isAfter(end);
          d = d.add(const Duration(days: 1))) {
        final normalized = _normalize(d);

        if (task.occursOn(normalized) && !task.isCompletedOn(normalized)) {
          result.add(TaskOccurrence(task: task, date: normalized));
        }
      }
    }

    result.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.task.title.toLowerCase().compareTo(b.task.title.toLowerCase());
    });

    return result;
  }

  List<TaskOccurrence> getHomeOccurrences(HomeFilter filter) {
    final today = getTodayOccurrences();
    final upcoming = getUpcomingOccurrences();

    switch (filter) {
      case HomeFilter.hoje:
        return today;
      case HomeFilter.proximas:
        return upcoming;
      case HomeFilter.todas:
        return [...today, ...upcoming];
    }
  }

  List<Task> get recurringTasks {
    final list = _tasks.where((t) => t.recurrence != TaskRecurrence.unica).toList();
    list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return list;
  }

  int get totalDueToday => getTodayOccurrences().length;

  int get completedToday => getTodayOccurrences().where((e) => e.isCompleted).length;

  double get overallSuccessRate {
    final stats = getOverallStats();
    if (stats.total == 0) return 0;
    return (stats.completed / stats.total) * 100;
  }

  PerformanceStats getOverallStats() {
    if (_tasks.isEmpty) {
      return const PerformanceStats(total: 0, completed: 0);
    }

    final firstDate = _tasks
        .map((e) => _normalize(e.createdAt))
        .reduce((a, b) => a.isBefore(b) ? a : b);

    final today = _normalize(DateTime.now());

    int total = 0;
    int completed = 0;

    for (DateTime d = firstDate; !d.isAfter(today); d = d.add(const Duration(days: 1))) {
      final date = _normalize(d);

      for (final task in _tasks) {
        if (task.occursOn(date)) {
          total++;
          if (task.isCompletedOn(date)) {
            completed++;
          }
        }
      }
    }

    return PerformanceStats(total: total, completed: completed);
  }

  double getMonthlySuccessRate(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);

    int total = 0;
    int completed = 0;

    for (DateTime d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      final date = _normalize(d);

      if (date.isAfter(_normalize(DateTime.now()))) break;

      for (final task in _tasks) {
        if (task.occursOn(date)) {
          total++;
          if (task.isCompletedOn(date)) {
            completed++;
          }
        }
      }
    }

    if (total == 0) return 0;
    return (completed / total) * 100;
  }

  List<double> getCurrentYearMonthlyPerformance() {
    final now = DateTime.now();
    return List.generate(12, (index) {
      final month = index + 1;
      return getMonthlySuccessRate(now.year, month);
    });
  }

  int get pendingCount {
    final stats = getOverallStats();
    return stats.total - stats.completed;
  }

  String recurrenceLabel(Task task) {
    switch (task.recurrence) {
      case TaskRecurrence.unica:
        return 'Única';
      case TaskRecurrence.diaria:
        return 'Diária';
      case TaskRecurrence.semanal:
        return 'Semanal';
      case TaskRecurrence.mensal:
        return 'Mensal';
      case TaskRecurrence.especifica:
        return _specificLabel(task.specificWeekdays);
    }
  }

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  String _specificLabel(List<int> weekdays) {
    const map = {
      1: 'S',
      2: 'T',
      3: 'Q',
      4: 'Q',
      5: 'S',
      6: 'S',
      7: 'D',
    };

    if (weekdays.isEmpty) return 'Específico';
    return weekdays.map((e) => map[e] ?? '?').join(', ');
  }
}

class PerformanceStats {
  final int total;
  final int completed;

  const PerformanceStats({
    required this.total,
    required this.completed,
  });
}