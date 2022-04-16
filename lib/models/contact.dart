import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;

  const Contact({
    this.id = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.role = '',
  });

  @override
  List<Object?> get props => [id, firstName, lastName, email, phone, role];

  String get initials => _initial(firstName) + _initial(lastName);

  String _initial(String text) => text.isNotEmpty ? text.substring(0, 1) : '';

  Contact.fromJson(String id, Map<Object?, Object?>? json)
      : this(
          id: id,
          firstName: getString(json?['firstName']),
          lastName: getString(json?['lastName']),
          email: getString(json?['email']),
          phone: getString(json?['phone']),
          role: getString(json?['role']),
        );

  Contact.fromMap(Map<Object?, Object?>? map)
      : this(
          id: getString(map?['id']),
          firstName: getString(map?['firstName']),
          lastName: getString(map?['lastName']),
          email: getString(map?['email']),
          phone: getString(map?['phone']),
          role: getString(map?['role']),
        );

  static String getString(dynamic value) => (value ?? '') as String;

  Map<String, Object?> toJson() => {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'role': role,
      };

  Map<String, Object?> toMap({required bool isNew}) {
    final map = toJson();
    map['id'] = id;
    map['isNew'] = isNew;
    return map;
  }

  Contact copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? role,
  }) =>
      Contact(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        role: role ?? this.role,
      );

  Contact trim() => copyWith(
        id: id.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: role.trim(),
      );

  contains(String value) {
    final lowerValue = value.toLowerCase();
    return value.isEmpty ||
        firstName.toLowerCase().contains(lowerValue) ||
        lastName.toLowerCase().contains(lowerValue) ||
        role.toLowerCase().contains(lowerValue);
  }
}
