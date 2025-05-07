import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/profile/models/user_model.dart';
import 'package:mobile/features/profile/services/user_service.dart';
import 'package:mobile/shared/themes/styles.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'widgets/edit_profile_dialog.dart';
import 'widgets/profile_item.dart';
import 'package:mobile/shared/widgets/bottom_navigation.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserService _userService = UserService();
  User? userProfile; // Local cache for user profile
  String? userImageUrl; // Cache for the user's image

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Load user profile with cache check
  void _loadUserProfile() async {
  final profileBloc = context.read<ProfileBloc>();

  // Natychmiast załaduj dane z cache
  profileBloc.add(FetchProfileFromCacheEvent());

  // Pobierz dane z API po krótkim opóźnieniu
  Future.delayed(const Duration(milliseconds: 500), () {
    profileBloc.add(FetchProfileEvent());
  });
}


  void _logout() {
    context.read<ProfileBloc>().add(LogoutEvent());
  }

  void _showEditProfileDialog(User profile) {
    showDialog(
      context: context,
      builder: (_) => EditProfileDialog(
        user: profile,
        onSave: (updatedProfile) async {
          setState(() {
            userProfile = updatedProfile; // Update local cache
          });
          context.read<ProfileBloc>().add(EditProfileEvent(updatedProfile));

          // Reload the user image after profile update
          final updatedImageUrl = await _userService.getUserImage(profile.id);
          setState(() {
            userImageUrl = updatedImageUrl; // Update image cache
          });
        },
      ),
    );
  }

Widget _buildPlaceholderProfile() {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          const CircleAvatar(
            radius: 50,
            child: CircularProgressIndicator(),
          ),
          const SizedBox(height: 20),
          Container(
            width: 200,
            height: 24,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 10),
          Container(
            width: 150,
            height: 16,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < 3; i++) ...[
            Container(
              width: double.infinity,
              height: 16,
              color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.read<ProfileBloc>().add(FetchProfileEvent()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('RETRY'),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(decoration: AppStyles.backgroundDecoration),
          ),
          Positioned.fill(
            child: Container(color: AppStyles.filterColor.withOpacity(0.75)),
          ),
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: AppStyles.transparentWhite,
                    child: 
                      BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            if (state is ProfileLoadingFromCache || (state is ProfileLoading && userProfile == null)) {
                              return _buildPlaceholderProfile();
                            } else if (state is ProfileLoaded) {
                              userProfile = state.profile;
                              return _buildProfileContent(userProfile!);
                            } else if (state is LogoutSuccess) {
                              Future.microtask(() {
                                Navigator.pushReplacementNamed(context, '/');
                              });
                              return const SizedBox.shrink();
                            } else if (state is ProfileError && userProfile == null) {
                              return _buildErrorMessage(state.message); 
                            } else if (userProfile != null) {
                              return _buildProfileContent(userProfile!);
                            }
                            return const SizedBox.shrink();
                          },
                        )

                  ),
                ),
                BottomNavigation(onTap: (index) {
                  print("Navigation tapped: $index");
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(User profile) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            userImageUrl != null
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userImageUrl!),
                  )
                : FutureBuilder<String>(
                    future: _loadUserImage(profile.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(
                          radius: 50,
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError || snapshot.data!.isEmpty) {
                        return const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        );
                      } else {
                        userImageUrl = snapshot.data; // Cache the image URL
                        return CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(userImageUrl!),
                        );
                      }
                    },
                  ),
            const SizedBox(height: 20),
            Text(
              '${profile.name} ${profile.surname}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ProfileItem(icon: Icons.email, title: profile.email),
            ProfileItem(icon: Icons.phone, title: profile.telephoneNr),
            ProfileItem(icon: Icons.language, title: profile.preferredLanguage.toUpperCase()),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _showEditProfileDialog(profile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('EDIT PROFILE'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('LOG OUT'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 1, 149, 248),
              foregroundColor: Colors.white,
            ),
            child: const Text('LOG OUT'),
          ),
        ],
      ),
    );
  }

  // Load user image from cache or API
  Future<String> _loadUserImage(int userId) async {
    if (userImageUrl != null) return userImageUrl!;
    try {
      final imageUrl = await _userService.getUserImage(userId);
      userImageUrl = imageUrl; // Cache the result
      return imageUrl;
    } catch (e) {
      return ''; // Return empty if loading fails
    }
  }
}
