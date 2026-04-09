import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/tasks_provider.dart';
import '../widgets/app_bottom_nav.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TasksProvider>();
    final tasks = provider.recurringTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            _TasksHeader(total: tasks.length),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : tasks.isEmpty
                      ? const _EmptyRecurringState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                          itemCount: tasks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            final today = DateTime.now();
                            final isDoneToday = task.isCompletedOn(
                              DateTime(today.year, today.month, today.day),
                            );

                            return _RecurringTaskCard(
                              task: task,
                              recurrenceLabel: provider.recurrenceLabel(task),
                              isDoneToday: isDoneToday,
                              onEdit: () => _showEditDialog(context, task),
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Excluir tarefa'),
                                    content: Text(
                                      'Deseja excluir "${task.title}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Excluir'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  provider.deleteTask(task.id);
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, Task task) async {
    final controller = TextEditingController(text: task.title);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar tarefa'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Título',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isEmpty) return;

              context.read<TasksProvider>().updateTask(
                    task.copyWith(title: title),
                  );

              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _TasksHeader extends StatelessWidget {
  final int total;

  const _TasksHeader({
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      decoration: const BoxDecoration(
        color: Color(0xFF06051B),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tarefas Recorrentes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _RecurringTaskCard extends StatelessWidget {
  final Task task;
  final String recurrenceLabel;
  final bool isDoneToday;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecurringTaskCard({
    required this.task,
    required this.recurrenceLabel,
    required this.isDoneToday,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = isDoneToday ? 'Concluída' : 'Pendente';
    final statusBg = isDoneToday
        ? const Color(0xFFDDF4E4)
        : const Color(0xFFFFEADF);
    final statusFg = isDoneToday
        ? const Color(0xFF168B4A)
        : const Color(0xFFD96A10);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForTask(task.recurrence),
                color: const Color(0xFF5F6480),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniBadge(
                        label: recurrenceLabel,
                        background: const Color(0xFFEDEFF5),
                        foreground: const Color(0xFF06051B),
                      ),
                      _MiniBadge(
                        label: statusText,
                        background: statusBg,
                        foreground: statusFg,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForTask(TaskRecurrence recurrence) {
    switch (recurrence) {
      case TaskRecurrence.unica:
        return Icons.event_note;
      case TaskRecurrence.diaria:
        return Icons.sunny;
      case TaskRecurrence.semanal:
        return Icons.calendar_view_week;
      case TaskRecurrence.mensal:
        return Icons.calendar_month;
      case TaskRecurrence.especifica:
        return Icons.auto_awesome;
    }
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _MiniBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _EmptyRecurringState extends StatelessWidget {
  const _EmptyRecurringState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Nenhuma tarefa recorrente cadastrada.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}