class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String mobNo;
  final String token;

  User({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.mobNo,
    required this.email,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      mobNo: json['mobNo']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'firstName': firstName, 'email': email, 'token': token};
  }
}
