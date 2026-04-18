import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_utility_toolkit_hng_14_mobile_stage_0/features/tasks/task.dart';

class TaskNotFoundException implements Exception {
  final Id taskId;
  const TaskNotFoundException(this.taskId);

  @override
  String toString() => 'Task with id $taskId not found';
}

class TaskService extends ChangeNotifier {
  Isar? _isar;
  List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  bool get isInitialized => _isar != null;

  Isar get _db {
    final isar = _isar;
    if (isar == null) {
      throw StateError('TaskService not initialized. Call initialize() first.');
    }
    return isar;
  }

  Future<void> initialize() async {
    if (isInitialized) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([TaskSchema], directory: dir.path);
    _tasks = await _db.tasks.where().findAll();
    notifyListeners();
  }

  Future<void> createTask(Task task) async {
    await _db.writeTxn(() async {
      await _db.tasks.put(task);
    });
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _db.writeTxn(() async {
      final exists = await _db.tasks.get(task.id);
      if (exists == null) throw TaskNotFoundException(task.id);
      await _db.tasks.put(task);
    });

    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
    notifyListeners();
  }

  Future<void> deleteTask(Id taskId) async {
    await _db.writeTxn(() async {
      await _db.tasks.delete(taskId);
    });
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  Future<void> clearAllTasks() async {
    await _db.writeTxn(() async {
      await _db.tasks.clear();
    });
    _tasks.clear();
    notifyListeners();
  }

  Future<int> clearCompletedTasks() async {
    final completed = _tasks
        .where((t) => t.status == Status.completed)
        .map((t) => t.id)
        .toList();
    if (completed.isEmpty) return 0;
    await _db.writeTxn(() async {
      await _db.tasks.deleteAll(completed);
    });
    _tasks.removeWhere((t) => t.status == Status.completed);
    notifyListeners();
    return completed.length;
  }

  Future<void> toggleTaskStatus(Id taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) throw TaskNotFoundException(taskId);

    final task = _tasks[index];
    task.status = switch (task.status) {
      Status.pending => Status.inProgress,
      Status.inProgress => Status.completed,
      Status.completed => Status.pending,
    };

    await _db.writeTxn(() async {
      await _db.tasks.put(task);
    });
    _tasks[index] = task;
    notifyListeners();
  }

  Future<void> refreshTasks() async {
    _tasks = await _db.tasks.where().findAll();
    notifyListeners();
  }

  @override
  void dispose() {
    _isar?.close();
    super.dispose();
  }
}
