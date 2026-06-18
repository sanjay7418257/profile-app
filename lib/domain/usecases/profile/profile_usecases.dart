import 'dart:io';
import '../../entities/user_profile.dart';
import '../../repositories/profile_repository.dart';

class SaveProfileUseCase {
  final ProfileRepository _repo;
  SaveProfileUseCase(this._repo);
  Future<void> call(UserProfile profile) => _repo.saveProfile(profile);
}

class GetProfileUseCase {
  final ProfileRepository _repo;
  GetProfileUseCase(this._repo);
  Future<UserProfile?> call(String uid) => _repo.getProfile(uid);
}

class UploadProfilePictureUseCase {
  final ProfileRepository _repo;
  UploadProfilePictureUseCase(this._repo);
  Future<String> call(File image) => _repo.uploadProfilePicture(image);
}
