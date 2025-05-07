import 'package:mobile/shared/config/config.dart';

class User {
  final int id;
  final String name;
  final String surname;
  final String email;
  final String telephoneNr;
  final String? password;
  late final String userImageUrl;
  final String preferredLanguage;

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.telephoneNr,
    this.password,
    required this.userImageUrl,
    required this.preferredLanguage,
  });

  // Method to deserialize from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      email: json['mail'],
      telephoneNr: json['telephoneNr'],
      password: json['password'],
      userImageUrl: _getFullImageUrl(json['userImageUrl'] ?? ''),
      preferredLanguage: json['preferredLanguage'] ?? 'en',
    );
  }

  // Method to serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'mail': email,
      'telephoneNr': telephoneNr,
      'password': password,
      'userImageUrl': userImageUrl,
      'preferredLanguage': preferredLanguage,
    };
  }

  // Helper function to construct full image URL
  static String _getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return imagePath;
    }
    return Uri.encodeFull("${AppConfig.s3BaseUrl}/$imagePath");
  }
}
