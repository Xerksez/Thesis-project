import 'package:equatable/equatable.dart';
import 'package:mobile/features/profile/models/user_model.dart';
import 'dart:io';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProfileEvent extends ProfileEvent {}

class FetchProfileFromCacheEvent extends ProfileEvent {}

class LogoutEvent extends ProfileEvent {}

class EditProfileEvent extends ProfileEvent {
  final User updatedProfile;

  EditProfileEvent(this.updatedProfile);

  @override
  List<Object?> get props => [updatedProfile];
}

class UploadUserImageEvent extends ProfileEvent {
  final int userId;
  final File image;

  UploadUserImageEvent(this.userId, this.image);

  @override
  List<Object?> get props => [userId, image];
}
