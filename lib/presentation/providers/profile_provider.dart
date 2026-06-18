import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/profile/profile_usecases.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final UserProfile? profile;
  final bool isSaved;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.profile,
    this.isSaved = false,
  });

  ProfileState copyWith({bool? isLoading, String? error, UserProfile? profile, bool? isSaved}) =>
      ProfileState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        profile: profile ?? this.profile,
        isSaved: isSaved ?? this.isSaved,
      );
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final SaveProfileUseCase _save;
  final GetProfileUseCase _get;
  final UploadProfilePictureUseCase _upload;

  ProfileNotifier(this._save, this._get, this._upload) : super(const ProfileState());

  Future<void> loadProfile(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _get(uid);
      state = state.copyWith(isLoading: false, profile: profile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    state = state.copyWith(isLoading: true);
    try {
      await _save(profile);
      state = state.copyWith(isLoading: false, profile: profile, isSaved: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> uploadPicture(File image) async {
    state = state.copyWith(isLoading: true);
    try {
      final url = await _upload(image);
      // immediately update profile state with new photo url
      if (state.profile != null) {
        final updated = state.profile!.copyWith(photoUrl: url);
        state = state.copyWith(isLoading: false, profile: updated);
      } else {
        state = state.copyWith(isLoading: false);
      }
      return url;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Image upload failed');
      return null;
    }
  }

  void clearError() => state = state.copyWith(error: null);
}
