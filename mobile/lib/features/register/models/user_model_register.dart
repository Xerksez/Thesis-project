class User {
  final int id;
  final String name;
  final String surname;
  final String mail;
  final String telephoneNr;
  final String password;
  final String userImageUrl;
  final String preferredLanguage;
  final int roleId;
  final String roleName;
  final int powerLevel;

  User({
    this.id = 0,
    required this.name,
    required this.surname,
    required this.mail,
    required this.telephoneNr,
    required this.password,
    this.userImageUrl = "string",
    this.preferredLanguage = "string",
    this.roleId = 0,
    this.roleName = "string",
    this.powerLevel = 0,
  });

  // Conversion to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "surname": surname,
      "mail": mail,
      "telephoneNr": telephoneNr,
      "password": password,
      "userImageUrl": userImageUrl,
      "preferredLanguage": preferredLanguage,
      "roleId": roleId,
      "roleName": roleName,
      "powerLevel": powerLevel,
    };
  }

  // Conversion from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'],
      surname: json['surname'],
      mail: json['mail'],
      telephoneNr: json['telephoneNr'],
      password: json['password'],
      userImageUrl: json['userImageUrl'] ?? "string",
      preferredLanguage: json['preferredLanguage'] ?? "string",
      roleId: json['roleId'] ?? 0,
      roleName: json['roleName'] ?? "string",
      powerLevel: json['powerLevel'] ?? 0,
    );
  }
}
