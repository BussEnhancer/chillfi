class UserModel {
  final String id;
  final String? name;
  final String? email;
  final String phone;
  final String? avatarUrl;
  final String role;

  UserModel({
    required this.id,
    this.name,
    this.email,
    required this.phone,
    this.avatarUrl,
    this.role = 'customer',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        avatarUrl: json['avatar_url'],
        role: json['role'] ?? 'customer',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatar_url': avatarUrl,
        'role': role,
      };
}
