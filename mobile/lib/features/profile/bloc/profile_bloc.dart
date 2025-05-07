import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/user_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserService userService;

  ProfileBloc(this.userService) : super(ProfileInitial()) {
    on<FetchProfileFromCacheEvent>(_onFetchProfileFromCache);
    on<FetchProfileEvent>(_onFetchProfile);
    on<LogoutEvent>(_onLogout);
    on<EditProfileEvent>(_onEditProfile);
  }

  Future<void> _onFetchProfileFromCache(
    FetchProfileFromCacheEvent event, Emitter<ProfileState> emit) async {
  emit(ProfileLoadingFromCache()); // Nowy stan
  try {
    final user = await userService.getCachedUserProfile();
    if (user != null) {
      final imageUrl = await userService.getUserImage(user.id);
      emit(ProfileLoaded(user, imageUrl: imageUrl));
    } else {
      emit(ProfileError('No cached profile found.'));
    }
  } catch (e) {
    emit(ProfileError('Error loading cached profile.'));
  }
}


  Future<void> _onFetchProfile(
      FetchProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = await userService.getUserProfile();
      final imageUrl = await userService.getUserImage(user.id);
      emit(ProfileLoaded(user, imageUrl: imageUrl));
    } catch (e) {
      emit(ProfileError('Failed to load profile'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await userService.logout();
      emit(LogoutSuccess());
    } catch (e) {
      emit(ProfileError('Logout failed.'));
    }
  }

  Future<void> _onEditProfile(
      EditProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await userService.editUserProfile(event.updatedProfile);
      await userService.cacheUserProfile(event.updatedProfile);
      final imageUrl = await userService.getUserImage(event.updatedProfile.id);
      emit(ProfileLoaded(event.updatedProfile, imageUrl: imageUrl));
    } catch (e) {
      emit(ProfileError('Failed to edit profile.'));
    }
  }
}
