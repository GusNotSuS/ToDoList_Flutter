import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_occurrence.dart';

class HomeTaskTile extends StatelessWidget {
  final TaskOccurrence occurrence;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;
  final String subtitle;

  const HomeTaskTile({
    super.key,
    required this.occurrence,
    required this.onToggle,
    required this.subtitle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final done = occurrence.isCompleted;
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: IconButton(
          onPressed: onToggle,
          icon: Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? Colors.green : null,
          ),
        ),
        title: Text(
          occurrence.task.title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : null,
            color: done ? theme.disabledColor : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: done ? theme.disabledColor : null,
          ),
        ),
        trailing: onDelete != null
            ? IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              )
            : null,
      ),
    );
  }

  static String formatOccurrenceDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = DateTime(date.year, date.month, date.day);

    if (current == today) return 'Hoje';
    return DateFormat('dd/MM').format(date);
  }
}