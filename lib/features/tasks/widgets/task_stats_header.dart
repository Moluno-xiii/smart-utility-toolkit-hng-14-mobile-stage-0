import 'package:flutter/material.dart';

class TaskStatsHeader extends StatelessWidget {
  final int pending;
  final int inProgress;
  final int completed;
  final VoidCallback? onClearCompleted;
  final VoidCallback onClearAll;

  const TaskStatsHeader({
    super.key,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.onClearCompleted,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _StatChip(
              label: 'Pending',
              count: pending,
              icon: Icons.schedule_outlined,
              fg: const Color(0xFFB26A00),
              bg: const Color(0xFFFFE0B2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatChip(
              label: 'Active',
              count: inProgress,
              icon: Icons.autorenew_rounded,
              fg: const Color(0xFF0D47A1),
              bg: const Color(0xFFBBDEFB),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatChip(
              label: 'Done',
              count: completed,
              icon: Icons.check_circle_outline,
              fg: const Color(0xFF1B5E20),
              bg: const Color(0xFFC8E6C9),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: PopupMenuButton<String>(
              tooltip: 'Clear tasks',
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: theme.colorScheme.error,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'completed') onClearCompleted?.call();
                if (value == 'all') onClearAll();
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'completed',
                  enabled: onClearCompleted != null,
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 18),
                      SizedBox(width: 10),
                      Text('Clear completed'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever_outlined, size: 18),
                      SizedBox(width: 10),
                      Text('Clear all'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color fg;
  final Color bg;

  const _StatChip({
    required this.label,
    required this.count,
    required this.icon,
    required this.fg,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: fg,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: fg.withValues(alpha: 0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
