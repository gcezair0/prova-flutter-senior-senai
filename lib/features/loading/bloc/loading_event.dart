import '../../shared/data/models/user_model.dart';

abstract class LoadingEvent {}

class LoadingStarted extends LoadingEvent {
  final UserModel user;
  LoadingStarted(this.user);
}