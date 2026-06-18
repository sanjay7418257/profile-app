import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 0)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String fullName;
  @HiveField(2)
  final int age;
  @HiveField(3)
  final String email;
  @HiveField(4)
  final String phone;
  @HiveField(5)
  final String occupation;
  @HiveField(6)
  final String location;
  @HiveField(7)
  final String aboutMe;
  @HiveField(8)
  final String? photoUrl;

  UserProfileModel({
    required this.id,
    required this.fullName,
    required this.age,
    required this.email,
    required this.phone,
    required this.occupation,
    required this.location,
    required this.aboutMe,
    this.photoUrl,
  });

  factory UserProfileModel.fromEntity(UserProfile e) => UserProfileModel(
        id: e.id,
        fullName: e.fullName,
        age: e.age,
        email: e.email,
        phone: e.phone,
        occupation: e.occupation,
        location: e.location,
        aboutMe: e.aboutMe,
        photoUrl: e.photoUrl,
      );

  UserProfile toEntity() => UserProfile(
        id: id,
        fullName: fullName,
        age: age,
        email: email,
        phone: phone,
        occupation: occupation,
        location: location,
        aboutMe: aboutMe,
        photoUrl: photoUrl,
      );

  // For remote API (randomuser.me response)
  factory UserProfileModel.fromRandomUser(Map<String, dynamic> json) {
    final name = json['name'];
    final loc = json['location'];
    return UserProfileModel(
      id: json['login']['uuid'],
      fullName: '${name['first']} ${name['last']}',
      age: json['dob']['age'] as int,
      email: json['email'],
      phone: json['phone'],
      occupation: _randomOccupation(json['login']['uuid']),
      location: '${loc['city']}, ${loc['country']}',
      aboutMe: 'Hi! I\'m ${name['first']}, a passionate professional.',
      photoUrl: json['picture']['large'],
    );
  }

  static String _randomOccupation(String seed) {
    const occupations = [
      'Software Engineer', 'Designer', 'Product Manager',
      'Data Analyst', 'Marketing Lead', 'Teacher', 'Doctor',
      'Architect', 'Entrepreneur', 'Photographer',
    ];
    return occupations[seed.codeUnitAt(0) % occupations.length];
  }
}
