import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../task.dart';
import '../task_service.dart';

class TaskFormSheet extends StatefulWidget {
  final Task? task;
  const TaskFormSheet({super.key, this.task});

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagController;
  late Priority _priority;
  late Status _status;
  late List<String> _tags;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _tagController = TextEditingController();
    _priority = widget.task?.priority ?? Priority.medium;
    _status = widget.task?.status ?? Status.pending;
    _tags = List<String>.from(widget.task?.tags ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
      _tagController.clear();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final taskService = context.read<TaskService>();

    if (isEditing) {
      final task = widget.task!
        ..title = _titleController.text.trim()
        ..description = _descriptionController.text.trim()
        ..priority = _priority
        ..status = _status
        ..tags = _tags;
      await taskService.updateTask(task);
    } else {
      final task = Task()
        ..title = _titleController.text.trim()
        ..description = _descriptionController.text.trim()
        ..priority = _priority
        ..status = Status.pending
        ..tags = _tags;
      await taskService.createTask(task);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEditing ? 'Edit Task' : 'New Task',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(height: 16),

              // Priority selector
              Text(
                'Priority',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<Priority>(
                segments: const [
                  ButtonSegment(
                    value: Priority.low,
                    label: Text('Low'),
                    icon: Icon(Icons.flag_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: Priority.medium,
                    label: Text('Medium'),
                    icon: Icon(Icons.flag_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: Priority.high,
                    label: Text('High'),
                    icon: Icon(Icons.flag_rounded, size: 16),
                  ),
                ],
                selected: {_priority},
                onSelectionChanged: (v) => setState(() => _priority = v.first),
              ),
              const SizedBox(height: 16),

              // Status selector (only when editing)
              if (isEditing) ...[
                Text(
                  'Status',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<Status>(
                  segments: const [
                    ButtonSegment(
                      value: Status.pending,
                      label: Text('Pending'),
                    ),
                    ButtonSegment(
                      value: Status.inProgress,
                      label: Text('Active'),
                    ),
                    ButtonSegment(
                      value: Status.completed,
                      label: Text('Done'),
                    ),
                  ],
                  selected: {_status},
                  onSelectionChanged: (v) => setState(() => _status = v.first),
                ),
                const SizedBox(height: 16),
              ],

              // Tags
              Text(
                'Tags',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        labelText: 'Add tag',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addTag,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _tags
                      .map((tag) => Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () =>
                                setState(() => _tags.remove(tag)),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 28),

              // Submit
              FilledButton.icon(
                onPressed: _submit,
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? 'Save Changes' : 'Create Task'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
