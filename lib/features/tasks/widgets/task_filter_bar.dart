import 'package:flutter/material.dart';
import '../task.dart';

class TaskFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final Set<Priority> priorityFilters;
  final Set<Status> statusFilters;
  final Set<String> tagFilters;
  final List<String> availableTags;
  final ValueChanged<Priority> onPriorityToggle;
  final ValueChanged<Status> onStatusToggle;
  final ValueChanged<String> onTagToggle;
  final VoidCallback? onClearAll;

  const TaskFilterBar({
    super.key,
    required this.controller,
    required this.onQueryChanged,
    required this.priorityFilters,
    required this.statusFilters,
    required this.tagFilters,
    required this.availableTags,
    required this.onPriorityToggle,
    required this.onStatusToggle,
    required this.onTagToggle,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Search tasks',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        controller.clear();
                        onQueryChanged('');
                      },
                    ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final s in Status.values)
                  _chip(
                    label: _statusLabel(s),
                    selected: statusFilters.contains(s),
                    onTap: () => onStatusToggle(s),
                  ),
                const _ChipDivider(),
                for (final p in Priority.values)
                  _chip(
                    label: _priorityLabel(p),
                    selected: priorityFilters.contains(p),
                    onTap: () => onPriorityToggle(p),
                  ),
                if (availableTags.isNotEmpty) ...[
                  const _ChipDivider(),
                  for (final tag in availableTags)
                    _chip(
                      label: '#$tag',
                      selected: tagFilters.contains(tag),
                      onTap: () => onTagToggle(tag),
                    ),
                ],
                if (onClearAll != null) ...[
                  const _ChipDivider(),
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      avatar: Icon(
                        Icons.clear_all,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        'Clear',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      onPressed: onClearAll,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  static String _statusLabel(Status s) => switch (s) {
    Status.pending => 'Pending',
    Status.inProgress => 'Active',
    Status.completed => 'Done',
  };

  static String _priorityLabel(Priority p) => switch (p) {
    Priority.low => 'Low',
    Priority.medium => 'Medium',
    Priority.high => 'High',
  };
}

class _ChipDivider extends StatelessWidget {
  const _ChipDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: VerticalDivider(
        width: 1,
        thickness: 1,
        color: Theme.of(context).dividerColor,
      ),
    );
  }
}
