class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String roverKey;
  final bool emailVerified;
  final bool phoneVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.roverKey,
    required this.emailVerified,
    required this.phoneVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      roverKey: json['rover_key'],
      emailVerified: json['email_verified'] ?? false,
      phoneVerified: json['phone_verified'] ?? false,
    );
  }
}
