import 'package:flutter/material.dart';
import '../task.dart';

class PriorityBadge extends StatelessWidget {
  final Priority priority;
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (priority) {
      Priority.high => ('High', const Color(0xFFB71C1C), const Color(0xFFFFCDD2)),
      Priority.medium => ('Medium', const Color(0xFFE65100), const Color(0xFFFFE0B2)),
      Priority.low => ('Low', const Color(0xFF1B5E20), const Color(0xFFC8E6C9)),
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
          Icon(Icons.flag_rounded, size: 12, color: fg),
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
