import 'package:hive/hive.dart';
part "task_model.g.dart" ;

@HiveType(typeId: 0)
class TaskModel{

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final DateTime dueDate;
  @HiveField(3)
  late bool isDone;
  //late DateTime lastUpdateDate ;

  TaskModel(  {
    required this.id,
    required this.title,
    required this.dueDate,
    this.isDone = false
  });

  factory TaskModel.fromJson(Map<String,dynamic> json){
    return TaskModel(
        title: json['title'],
        dueDate: DateTime.tryParse(json['dueDate'])!,
        id: json['id'],
        isDone: json['isDone']
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'id': id,
      'isDone': isDone,
      'title':title,
      'dueDate':dueDate.toIso8601String(),
    };
  }

}
