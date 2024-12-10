import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class TaskModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final DateTime? dueDate; // New field
  @HiveField(4)
  bool needsSync;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate, // New parameter
    this.needsSync = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(), // Convert DateTime to String
      'needsSync': needsSync,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      needsSync: json['needsSync'] as bool? ?? false,
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate, // New parameter
    bool? needsSync,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate, // Include dueDate
      needsSync: needsSync ?? this.needsSync,
    );
  }
}
