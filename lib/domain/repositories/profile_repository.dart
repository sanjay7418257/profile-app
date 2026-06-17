import 'dart:io';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<void> saveProfile(UserProfile profile);
  Future<UserProfile?> getProfile(String uid);
  Future<String> uploadProfilePicture(File image);
}
