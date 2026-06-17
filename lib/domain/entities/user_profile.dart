class UserProfile {
  final String id;
  final String fullName;
  final int age;
  final String email;
  final String phone;
  final String occupation;
  final String location;
  final String aboutMe;
  final String? photoUrl;

  const UserProfile({
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

  UserProfile copyWith({
    String? fullName,
    int? age,
    String? email,
    String? phone,
    String? occupation,
    String? location,
    String? aboutMe,
    String? photoUrl,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      occupation: occupation ?? this.occupation,
      location: location ?? this.location,
      aboutMe: aboutMe ?? this.aboutMe,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
