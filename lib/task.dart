import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  String category;

  @HiveField(3)
  String priority;

  @HiveField(4)
  String location;

  @HiveField(5)
  String assignedTo;

  @HiveField(6)
  String notes;

  @HiveField(7)
  DateTime date;

  Task({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.location,
    required this.assignedTo,
    required this.notes,
    required this.date,
  });
}