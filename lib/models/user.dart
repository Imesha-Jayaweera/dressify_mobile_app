class User {
  final String id;
  final String name;
  final String email;
  final String? birthDate;
  final String? address;
  final String sex;
  final String userType;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.birthDate,
    this.address,
    required this.sex,
    required this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      birthDate: json['birthDate'],
      address: json['address'],
      sex: json['sex'] ?? 'MALE',
      userType: json['userType'] ?? 'CUSTOMER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birthDate': birthDate,
      'address': address,
      'sex': sex,
      'userType': userType,
    };
  }
}