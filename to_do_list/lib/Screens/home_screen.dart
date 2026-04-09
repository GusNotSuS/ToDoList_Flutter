import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_occurrence.dart';
import '../providers/tasks_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/home_task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeFilter _selectedFilter = HomeFilter.todas;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TasksProvider>();
    final items = provider.getHomeOccurrences(_selectedFilter);
    final completedToday = provider.completedToday;
    final totalToday = provider.totalDueToday;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF06051B),
        foregroundColor: Colors.white,
        onPressed: () => Navigator.pushReplacementNamed(context, '/add'),
        child: const Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: SafeArea(
        child: Column(
          children: [
            _HomeHeader(
              completedToday: completedToday,
              totalToday: totalToday,
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() => _selectedFilter = filter);
              },
            ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? const _EmptyState(
                          title: 'Nenhuma tarefa encontrada',
                          subtitle: 'Adicione uma tarefa ou troque o filtro.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final occurrence = items[index];
                            final subtitle = _buildSubtitle(_selectedFilter, occurrence);

                            return HomeTaskTile(
                              occurrence: occurrence,
                              subtitle: subtitle,
                              onToggle: () {
                                provider.toggleTaskForDate(
                                  occurrence.task.id,
                                  occurrence.date,
                                );
                              },
                              onDelete: () async {
                                final confirm = await _confirmDelete(context);
                                if (confirm == true) {
                                  provider.deleteTask(occurrence.task.id);
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

  String _buildSubtitle(HomeFilter filter, TaskOccurrence occurrence) {
    switch (filter) {
      case HomeFilter.hoje:
        return 'Hoje';
      case HomeFilter.proximas:
        return HomeTaskTile.formatOccurrenceDate(occurrence.date);
      case HomeFilter.todas:
        final label = HomeTaskTile.formatOccurrenceDate(occurrence.date);
        return label;
    }
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: const Text('Tem certeza que deseja excluir esta tarefa?'),
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
  }
}

class _HomeHeader extends StatelessWidget {
  final int completedToday;
  final int totalToday;
  final HomeFilter selectedFilter;
  final ValueChanged<HomeFilter> onFilterChanged;

  const _HomeHeader({
    required this.completedToday,
    required this.totalToday,
    required this.selectedFilter,
    required this.onFilterChanged,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Minhas Tarefas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$completedToday de $totalToday concluídas',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _FilterChipButton(
                label: 'Todas',
                selected: selectedFilter == HomeFilter.todas,
                onTap: () => onFilterChanged(HomeFilter.todas),
              ),
              const SizedBox(width: 10),
              _FilterChipButton(
                label: 'Hoje',
                selected: selectedFilter == HomeFilter.hoje,
                onTap: () => onFilterChanged(HomeFilter.hoje),
              ),
              const SizedBox(width: 10),
              _FilterChipButton(
                label: 'Próximas',
                selected: selectedFilter == HomeFilter.proximas,
                onTap: () => onFilterChanged(HomeFilter.proximas),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? Colors.white : Colors.white.withOpacity(0.10);
    final fg = selected ? const Color(0xFF06051B) : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}