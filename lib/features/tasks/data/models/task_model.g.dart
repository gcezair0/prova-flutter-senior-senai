// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => _TaskModel(
  id: (json['id'] as num).toInt(),
  localId: (json['localId'] as num?)?.toInt(),
  todo: json['todo'] as String,
  description: json['description'] as String?,
  completed: json['completed'] as bool,
  userId: (json['userId'] as num).toInt(),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  isSynced: json['isSynced'] as bool? ?? false,
);

Map<String, dynamic> _$TaskModelToJson(_TaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'localId': instance.localId,
      'todo': instance.todo,
      'description': instance.description,
      'completed': instance.completed,
      'userId': instance.userId,
      'completedAt': instance.completedAt?.toIso8601String(),
      'isSynced': instance.isSynced,
    };
