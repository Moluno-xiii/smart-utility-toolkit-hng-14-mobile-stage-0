import 'package:flutter/material.dart';
import '../task.dart';

class StatusBadge extends StatelessWidget {
  final Status status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, icon, fg, bg) = switch (status) {
      Status.pending => (
          'Pending',
          Icons.schedule_rounded,
          const Color(0xFF5D4037),
          const Color(0xFFD7CCC8),
        ),
      Status.inProgress => (
          'In Progress',
          Icons.autorenew_rounded,
          const Color(0xFF0D47A1),
          const Color(0xFFBBDEFB),
        ),
      Status.completed => (
          'Completed',
          Icons.check_circle_outline_rounded,
          const Color(0xFF1B5E20),
          const Color(0xFFC8E6C9),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
