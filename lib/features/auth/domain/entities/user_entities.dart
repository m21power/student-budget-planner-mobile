// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserEntities {
  final String id;
  final String email;
  final String name;
  final String password;
  final List<String> badges;

  UserEntities(
      {required this.id,
      required this.email,
      required this.name,
      required this.badges,
      required this.password});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
      'password': password,
      'badges': badges,
    };
  }

  factory UserEntities.fromMap(Map<String, dynamic> map) {
    return UserEntities(
        id: map['id'] as String,
        email: map['email'] as String,
        name: map['name'] as String,
        password: map['password'] as String,
        badges: List<String>.from(
          (map['badges'] as List<String>),
        ));
  }

  String toJson() => json.encode(toMap());

  factory UserEntities.fromJson(String source) =>
      UserEntities.fromMap(json.decode(source) as Map<String, dynamic>);
}
