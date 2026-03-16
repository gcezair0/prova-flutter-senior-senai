// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskModel {

 int get id; int? get localId; String get todo; String? get description; bool get completed; int get userId; DateTime? get completedAt; bool get isSynced;
/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskModelCopyWith<TaskModel> get copyWith => _$TaskModelCopyWithImpl<TaskModel>(this as TaskModel, _$identity);

  /// Serializes this TaskModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskModel&&(identical(other.id, id) || other.id == id)&&(identical(other.localId, localId) || other.localId == localId)&&(identical(other.todo, todo) || other.todo == todo)&&(identical(other.description, description) || other.description == description)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,localId,todo,description,completed,userId,completedAt,isSynced);

@override
String toString() {
  return 'TaskModel(id: $id, localId: $localId, todo: $todo, description: $description, completed: $completed, userId: $userId, completedAt: $completedAt, isSynced: $isSynced)';
}


}

/// @nodoc
abstract mixin class $TaskModelCopyWith<$Res>  {
  factory $TaskModelCopyWith(TaskModel value, $Res Function(TaskModel) _then) = _$TaskModelCopyWithImpl;
@useResult
$Res call({
 int id, int? localId, String todo, String? description, bool completed, int userId, DateTime? completedAt, bool isSynced
});




}
/// @nodoc
class _$TaskModelCopyWithImpl<$Res>
    implements $TaskModelCopyWith<$Res> {
  _$TaskModelCopyWithImpl(this._self, this._then);

  final TaskModel _self;
  final $Res Function(TaskModel) _then;

/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? localId = freezed,Object? todo = null,Object? description = freezed,Object? completed = null,Object? userId = null,Object? completedAt = freezed,Object? isSynced = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,localId: freezed == localId ? _self.localId : localId // ignore: cast_nullable_to_non_nullable
as int?,todo: null == todo ? _self.todo : todo // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskModel].
extension TaskModelPatterns on TaskModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskModel value)  $default,){
final _that = this;
switch (_that) {
case _TaskModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskModel value)?  $default,){
final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? localId,  String todo,  String? description,  bool completed,  int userId,  DateTime? completedAt,  bool isSynced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that.id,_that.localId,_that.todo,_that.description,_that.completed,_that.userId,_that.completedAt,_that.isSynced);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? localId,  String todo,  String? description,  bool completed,  int userId,  DateTime? completedAt,  bool isSynced)  $default,) {final _that = this;
switch (_that) {
case _TaskModel():
return $default(_that.id,_that.localId,_that.todo,_that.description,_that.completed,_that.userId,_that.completedAt,_that.isSynced);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? localId,  String todo,  String? description,  bool completed,  int userId,  DateTime? completedAt,  bool isSynced)?  $default,) {final _that = this;
switch (_that) {
case _TaskModel() when $default != null:
return $default(_that.id,_that.localId,_that.todo,_that.description,_that.completed,_that.userId,_that.completedAt,_that.isSynced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskModel implements TaskModel {
  const _TaskModel({required this.id, this.localId, required this.todo, this.description, required this.completed, required this.userId, this.completedAt, this.isSynced = false});
  factory _TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);

@override final  int id;
@override final  int? localId;
@override final  String todo;
@override final  String? description;
@override final  bool completed;
@override final  int userId;
@override final  DateTime? completedAt;
@override@JsonKey() final  bool isSynced;

/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskModelCopyWith<_TaskModel> get copyWith => __$TaskModelCopyWithImpl<_TaskModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskModel&&(identical(other.id, id) || other.id == id)&&(identical(other.localId, localId) || other.localId == localId)&&(identical(other.todo, todo) || other.todo == todo)&&(identical(other.description, description) || other.description == description)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,localId,todo,description,completed,userId,completedAt,isSynced);

@override
String toString() {
  return 'TaskModel(id: $id, localId: $localId, todo: $todo, description: $description, completed: $completed, userId: $userId, completedAt: $completedAt, isSynced: $isSynced)';
}


}

/// @nodoc
abstract mixin class _$TaskModelCopyWith<$Res> implements $TaskModelCopyWith<$Res> {
  factory _$TaskModelCopyWith(_TaskModel value, $Res Function(_TaskModel) _then) = __$TaskModelCopyWithImpl;
@override @useResult
$Res call({
 int id, int? localId, String todo, String? description, bool completed, int userId, DateTime? completedAt, bool isSynced
});




}
/// @nodoc
class __$TaskModelCopyWithImpl<$Res>
    implements _$TaskModelCopyWith<$Res> {
  __$TaskModelCopyWithImpl(this._self, this._then);

  final _TaskModel _self;
  final $Res Function(_TaskModel) _then;

/// Create a copy of TaskModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? localId = freezed,Object? todo = null,Object? description = freezed,Object? completed = null,Object? userId = null,Object? completedAt = freezed,Object? isSynced = null,}) {
  return _then(_TaskModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,localId: freezed == localId ? _self.localId : localId // ignore: cast_nullable_to_non_nullable
as int?,todo: null == todo ? _self.todo : todo // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
