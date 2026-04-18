import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../task.dart';
import '../task_service.dart';
import '../widgets/task_card.dart';
import '../widgets/task_empty_views.dart';
import '../widgets/task_filter_bar.dart';
import '../widgets/task_form_sheet.dart';
import '../widgets/task_stats_header.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<Priority> _priorityFilters = {};
  final Set<Status> _statusFilters = {};
  final Set<String> _tagFilters = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _priorityFilters.isNotEmpty ||
      _statusFilters.isNotEmpty ||
      _tagFilters.isNotEmpty ||
      _searchQuery.trim().isNotEmpty;

  void _clearFilters() {
    setState(() {
      _priorityFilters.clear();
      _statusFilters.clear();
      _tagFilters.clear();
      _searchController.clear();
      _searchQuery = '';
    });
  }

  List<Task> _applyFilters(List<Task> tasks) {
    final query = _searchQuery.trim().toLowerCase();
    return tasks.where((t) {
      if (query.isNotEmpty) {
        final matchTitle = t.title.toLowerCase().contains(query);
        final matchDesc = t.description.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc) return false;
      }
      if (_priorityFilters.isNotEmpty &&
          !_priorityFilters.contains(t.priority)) {
        return false;
      }
      if (_statusFilters.isNotEmpty && !_statusFilters.contains(t.status)) {
        return false;
      }
      if (_tagFilters.isNotEmpty &&
          !_tagFilters.any((tag) => t.tags.contains(tag))) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final taskService = context.watch<TaskService>();
    final allTasks = taskService.tasks;

    if (allTasks.isEmpty) {
      return EmptyTasksView(onCreate: () => _showTaskForm(context));
    }

    final pendingCount = allTasks
        .where((t) => t.status == Status.pending)
        .length;
    final inProgressCount = allTasks
        .where((t) => t.status == Status.inProgress)
        .length;
    final completedCount = allTasks
        .where((t) => t.status == Status.completed)
        .length;

    final allTags = <String>{for (final t in allTasks) ...t.tags}.toList()
      ..sort();

    final filtered = _applyFilters(allTasks);
    final sortedTasks = [...filtered]
      ..sort((a, b) => a.status.index.compareTo(b.status.index));

    return Column(
      children: [
        TaskStatsHeader(
          pending: pendingCount,
          inProgress: inProgressCount,
          completed: completedCount,
          onClearCompleted: completedCount == 0
              ? null
              : () => _confirmClearCompleted(context, taskService),
          onClearAll: () => _confirmClearAll(context, taskService),
        ),
        TaskFilterBar(
          controller: _searchController,
          onQueryChanged: (q) => setState(() => _searchQuery = q),
          priorityFilters: _priorityFilters,
          statusFilters: _statusFilters,
          tagFilters: _tagFilters,
          availableTags: allTags,
          onPriorityToggle: (p) => setState(() {
            _priorityFilters.contains(p)
                ? _priorityFilters.remove(p)
                : _priorityFilters.add(p);
          }),
          onStatusToggle: (s) => setState(() {
            _statusFilters.contains(s)
                ? _statusFilters.remove(s)
                : _statusFilters.add(s);
          }),
          onTagToggle: (tag) => setState(() {
            _tagFilters.contains(tag)
                ? _tagFilters.remove(tag)
                : _tagFilters.add(tag);
          }),
          onClearAll: _hasActiveFilters ? _clearFilters : null,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => taskService.refreshTasks(),
            child: sortedTasks.isEmpty
                ? NoMatchesView(onClearFilters: _clearFilters)
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: sortedTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final task = sortedTasks[index];
                      return TaskCard(
                        task: task,
                        onToggleStatus: () =>
                            taskService.toggleTaskStatus(task.id),
                        onEdit: () => _showTaskForm(context, task: task),
                        onDelete: () =>
                            _deleteWithUndo(context, taskService, task),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteWithUndo(
    BuildContext context,
    TaskService service,
    Task task,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    await service.deleteTask(task.id);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Deleted "${task.title}"'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => service.createTask(task),
        ),
      ),
    );
  }

  Future<void> _confirmClearCompleted(
    BuildContext context,
    TaskService service,
  ) async {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Completed'),
        content: const Text(
          'Delete all completed tasks? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Clear',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final removed = await service.clearCompletedTasks();
      if (removed == 0) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Cleared $removed completed task${removed == 1 ? '' : 's'}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    TaskService service,
  ) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Tasks'),
        content: const Text(
          'This will permanently delete every task. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Clear All',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await service.clearAllTasks();
    }
  }

  void _showTaskForm(BuildContext context, {Task? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TaskFormSheet(task: task),
    );
  }
}
