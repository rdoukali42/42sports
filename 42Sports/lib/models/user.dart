class User {
  final String id;
  final String login;
  final String email;
  final String firstName;
  final String lastName;
  final String? imageUrl;
  int tokens;

  User({
    required this.id,
    required this.login,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.imageUrl,
    this.tokens = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      login: json['login'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      imageUrl: json['image']?['link'],
      tokens: json['tokens'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'image': {'link': imageUrl},
      'tokens': tokens,
    };
  }

  String get fullName => '$firstName $lastName';

  User copyWith({int? tokens}) {
    return User(
      id: id,
      login: login,
      email: email,
      firstName: firstName,
      lastName: lastName,
      imageUrl: imageUrl,
      tokens: tokens ?? this.tokens,
    );
  }
}
