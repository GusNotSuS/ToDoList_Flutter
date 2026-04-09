import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/tasks_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/recurrence_card.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _titleController = TextEditingController();

  TaskRecurrence _selectedRecurrence = TaskRecurrence.unica;

  DateTime? _dueDate;
  int _weeklyDay = DateTime.now().weekday;
  int _monthlyDay = DateTime.now().day;
  List<int> _specificDays = [];

  @override
  void initState() {
    super.initState();
    _dueDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            const _AddHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Título da Tarefa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Digite o título da tarefa...',
                        filled: true,
                        fillColor: const Color(0xFFF7F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Recorrência',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        RecurrenceCard(
                          label: 'Única',
                          icon: Icons.calendar_month,
                          selected: _selectedRecurrence == TaskRecurrence.unica,
                          onTap: () => setState(() {
                            _selectedRecurrence = TaskRecurrence.unica;
                          }),
                        ),
                        const SizedBox(width: 12),
                        RecurrenceCard(
                          label: 'Diária',
                          icon: Icons.sunny,
                          selected: _selectedRecurrence == TaskRecurrence.diaria,
                          onTap: () => setState(() {
                            _selectedRecurrence = TaskRecurrence.diaria;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        RecurrenceCard(
                          label: 'Semanal',
                          icon: Icons.calendar_view_week,
                          selected: _selectedRecurrence == TaskRecurrence.semanal,
                          onTap: () => setState(() {
                            _selectedRecurrence = TaskRecurrence.semanal;
                          }),
                        ),
                        const SizedBox(width: 12),
                        RecurrenceCard(
                          label: 'Mensal',
                          icon: Icons.calendar_today,
                          selected: _selectedRecurrence == TaskRecurrence.mensal,
                          onTap: () => setState(() {
                            _selectedRecurrence = TaskRecurrence.mensal;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() {
                          _selectedRecurrence = TaskRecurrence.especifica;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: _selectedRecurrence == TaskRecurrence.especifica
                                ? const Color(0xFF06051B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: _selectedRecurrence == TaskRecurrence.especifica
                                    ? Colors.white
                                    : const Color(0xFF5F6480),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Específico',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _selectedRecurrence == TaskRecurrence.especifica
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildConditionalFields(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF8B8B97),
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _saveTask,
                            icon: const Icon(Icons.check),
                            label: const Text(
                              'Adicionar',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/');
                            },
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionalFields() {
    switch (_selectedRecurrence) {
      case TaskRecurrence.unica:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data da tarefa',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDueDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _dueDate == null
                      ? 'Selecionar data'
                      : '${_dueDate!.day.toString().padLeft(2, '0')}/${_dueDate!.month.toString().padLeft(2, '0')}/${_dueDate!.year}',
                ),
              ),
            ),
          ],
        );

      case TaskRecurrence.diaria:
        return const SizedBox.shrink();

      case TaskRecurrence.semanal:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dia da semana',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                final weekday = index + 1;
                final selected = _weeklyDay == weekday;

                return ChoiceChip(
                  label: Text(_weekdayLabel(weekday)),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _weeklyDay = weekday);
                  },
                );
              }),
            ),
          ],
        );

      case TaskRecurrence.mensal:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dia do mês',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _monthlyDay,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                31,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('Dia ${index + 1}'),
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _monthlyDay = value);
                }
              },
            ),
          ],
        );

      case TaskRecurrence.especifica:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dias específicos',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final weekday = index + 1;
                final selected = _specificDays.contains(weekday);

                return FilterChip(
                  label: Text(_weekdayLabel(weekday)),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _specificDays.remove(weekday);
                      } else {
                        _specificDays.add(weekday);
                        _specificDays.sort();
                      }
                    });
                  },
                );
              }),
            ),
          ],
        );
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showMessage('Informe o título da tarefa.');
      return;
    }

    if (_selectedRecurrence == TaskRecurrence.especifica && _specificDays.isEmpty) {
      _showMessage('Selecione ao menos um dia específico.');
      return;
    }

    final now = DateTime.now();

    final task = Task(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      recurrence: _selectedRecurrence,
      createdAt: now,
      dueDate: _selectedRecurrence == TaskRecurrence.unica ? _dueDate : null,
      weeklyDay: _selectedRecurrence == TaskRecurrence.semanal ? _weeklyDay : null,
      monthlyDay: _selectedRecurrence == TaskRecurrence.mensal ? _monthlyDay : null,
      specificWeekdays:
          _selectedRecurrence == TaskRecurrence.especifica ? _specificDays : const [],
      completedDates: const [],
    );

    await context.read<TasksProvider>().addTask(task);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _weekdayLabel(int weekday) {
    const map = {
      1: 'Seg',
      2: 'Ter',
      3: 'Qua',
      4: 'Qui',
      5: 'Sex',
      6: 'Sáb',
      7: 'Dom',
    };

    return map[weekday] ?? '?';
  }
}

class _AddHeader extends StatelessWidget {
  const _AddHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      decoration: const BoxDecoration(
        color: Color(0xFF06051B),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nova Tarefa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Adicione uma nova tarefa à sua lista',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}