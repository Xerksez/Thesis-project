class LoginResponse {
  final String token;
  final int id;

  LoginResponse({required this.token, required this.id});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      id: json['id'],
    );
  }
}
