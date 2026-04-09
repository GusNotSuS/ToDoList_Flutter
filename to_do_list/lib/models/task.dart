import 'dart:convert';

enum TaskRecurrence {
  unica,
  diaria,
  semanal,
  mensal,
  especifica,
}

class Task {
  final String id;
  final String title;
  final TaskRecurrence recurrence;
  final DateTime createdAt;

  // para tarefa única
  final DateTime? dueDate;

  // para semanal
  final int? weeklyDay; // 1=seg ... 7=dom

  // para mensal
  final int? monthlyDay; // dia do mês

  // para específico
  final List<int> specificWeekdays; // 1=seg ... 7=dom

  // datas concluídas: yyyy-MM-dd
  final List<String> completedDates;

  Task({
    required this.id,
    required this.title,
    required this.recurrence,
    required this.createdAt,
    this.dueDate,
    this.weeklyDay,
    this.monthlyDay,
    this.specificWeekdays = const [],
    this.completedDates = const [],
  });

  Task copyWith({
    String? id,
    String? title,
    TaskRecurrence? recurrence,
    DateTime? createdAt,
    DateTime? dueDate,
    int? weeklyDay,
    int? monthlyDay,
    List<int>? specificWeekdays,
    List<String>? completedDates,
    bool clearDueDate = false,
    bool clearWeeklyDay = false,
    bool clearMonthlyDay = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      recurrence: recurrence ?? this.recurrence,
      createdAt: createdAt ?? this.createdAt,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      weeklyDay: clearWeeklyDay ? null : (weeklyDay ?? this.weeklyDay),
      monthlyDay: clearMonthlyDay ? null : (monthlyDay ?? this.monthlyDay),
      specificWeekdays: specificWeekdays ?? this.specificWeekdays,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  bool isCompletedOn(DateTime date) {
    return completedDates.contains(_dateKey(date));
  }

  Task toggleCompletionOn(DateTime date) {
    final key = _dateKey(date);
    final updated = List<String>.from(completedDates);

    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }

    return copyWith(completedDates: updated);
  }

  bool occursOn(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final created = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (normalized.isBefore(created)) return false;

    switch (recurrence) {
      case TaskRecurrence.unica:
        if (dueDate == null) return false;
        final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
        return due == normalized;

      case TaskRecurrence.diaria:
        return true;

      case TaskRecurrence.semanal:
        return weeklyDay == normalized.weekday;

      case TaskRecurrence.mensal:
        final targetDay = monthlyDay ?? created.day;
        final lastDay = DateTime(normalized.year, normalized.month + 1, 0).day;
        return normalized.day == (targetDay > lastDay ? lastDay : targetDay);

      case TaskRecurrence.especifica:
        return specificWeekdays.contains(normalized.weekday);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'recurrence': recurrence.name,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'weeklyDay': weeklyDay,
      'monthlyDay': monthlyDay,
      'specificWeekdays': specificWeekdays,
      'completedDates': completedDates,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      recurrence: TaskRecurrence.values.firstWhere(
        (e) => e.name == map['recurrence'],
      ),
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      weeklyDay: map['weeklyDay'],
      monthlyDay: map['monthlyDay'],
      specificWeekdays: List<int>.from(map['specificWeekdays'] ?? []),
      completedDates: List<String>.from(map['completedDates'] ?? []),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(jsonDecode(source));
}

String _dateKey(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  return d.toIso8601String().split('T').first;
}