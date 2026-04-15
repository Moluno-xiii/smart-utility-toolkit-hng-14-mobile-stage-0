import 'package:isar/isar.dart';

part 'task.g.dart';

enum Priority { low, medium, high }

enum Status { pending, inProgress, completed }

@collection
class Task {
  Id id = Isar.autoIncrement;
  String title = '';
  String description = '';
  @enumerated
  Priority priority = Priority.medium;
  @enumerated
  Status status = Status.pending;
  List<String> tags = [];
}
