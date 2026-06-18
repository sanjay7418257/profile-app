import 'dart:io';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/remote_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final LocalDataSource _local;
  final RemoteDataSource _remote;

  ProfileRepositoryImpl(this._local, this._remote);

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _local.saveProfile(UserProfileModel.fromEntity(profile));
  }

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final model = await _local.getProfile(uid);
    return model?.toEntity();
  }

  @override
  Future<String> uploadProfilePicture(File image) async {
    return await _remote.uploadImage(image);
  }
}
