class User {
  final String id;
  final String email;
  final String passwordHash;
  final UserRole role;
  final String firstName;
  final String lastName;
  final String phone;
  final DateTime? dateOfBirth;
  final String? profileImage;
  final String? specialization; // Pour les professionnels
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.dateOfBirth,
    this.profileImage,
    this.specialization,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'passwordHash': passwordHash,
      'role': role.toString().split('.').last,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'profileImage': profileImage,
      'specialization': specialization,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
      ),
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      profileImage: json['profileImage'],
      specialization: json['specialization'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? passwordHash,
    UserRole? role,
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
    String? profileImage,
    String? specialization,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImage: profileImage ?? this.profileImage,
      specialization: specialization ?? this.specialization,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum UserRole {
  patient,
  professional,
  admin,
}
