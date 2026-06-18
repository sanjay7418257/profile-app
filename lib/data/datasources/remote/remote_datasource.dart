import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/failures.dart';
import '../../models/user_profile_model.dart';

class RemoteDataSource {
  final Dio _dio;
  RemoteDataSource(this._dio);

  Future<List<UserProfileModel>> fetchProfiles({int page = 1, int results = 20}) async {
    try {
      final response = await _dio.get(
        AppStrings.randomUserApi,
        queryParameters: {'results': results, 'page': page, 'seed': 'profileapp'},
      );
      final List users = response.data['results'];
      return users.map((u) => UserProfileModel.fromRandomUser(u)).toList();
    } on DioException catch (e) {
      throw NetworkFailure(e.message ?? 'Failed to fetch profiles');
    }
  }

  Future<String> uploadImage(File image) async {
    if (AppStrings.cloudinaryCloudName == 'YOUR_CLOUD_NAME') {
      throw NetworkFailure('Cloudinary not configured. Set cloud name and upload preset in app_strings.dart');
    }
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'upload_preset': AppStrings.cloudinaryUploadPreset,
      });
      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/${AppStrings.cloudinaryCloudName}/image/upload',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      if (response.statusCode == 200 && response.data['secure_url'] != null) {
        return response.data['secure_url'] as String;
      }
      throw NetworkFailure('Upload failed: ${response.statusCode}');
    } on DioException catch (e) {
      throw NetworkFailure(e.message ?? 'Image upload failed');
    }
  }
}
