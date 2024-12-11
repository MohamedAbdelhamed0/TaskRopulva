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
  @HiveField(5)
  final bool isDone;
  @HiveField(6) // Add this field annotation
  final DateTime? createdAt;
  final DateTime? startTime;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate, // New parameter
    this.needsSync = false,
    this.isDone = false,
    this.createdAt, // Add this
    this.startTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(), // Convert DateTime to String
      'needsSync': needsSync,
      'isDone': isDone,
      'createdAt': createdAt?.toIso8601String(),
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
      isDone: json['isDone'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate, // New parameter
    bool? needsSync,
    bool? isDone,
    DateTime? createdAt,
    DateTime? startTime,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate, // Include dueDate
      needsSync: needsSync ?? this.needsSync,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
    );
  }
}
