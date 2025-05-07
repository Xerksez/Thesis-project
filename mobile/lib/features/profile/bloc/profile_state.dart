import 'package:mobile/features/profile/models/user_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User profile;
  final String imageUrl;

  ProfileLoaded(this.profile, {required this.imageUrl});
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
class ProfileLoadingFromCache extends ProfileState {}

class LogoutSuccess extends ProfileState {}
