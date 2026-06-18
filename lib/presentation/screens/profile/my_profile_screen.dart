import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../providers/providers.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      Future.microtask(() => ref.read(profileProvider.notifier).loadProfile(uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final profile = state.profile;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text('No profile yet'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await context.push(AppRoutes.editProfile);
                _loadProfile();
              },
              child: const Text('Create Profile'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white24,
                  child: profile.photoUrl != null
                      ? ClipOval(child: _buildPhoto(profile.photoUrl!))
                      : const Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(profile.fullName,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(profile.occupation,
                    style: const TextStyle(color: Colors.white70, fontSize: 15)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoTile(Icons.cake, 'Age', '${profile.age} years'),
                _infoTile(Icons.email, 'Email', profile.email),
                _infoTile(Icons.phone, 'Phone', profile.phone),
                _infoTile(Icons.location_on, 'Location', profile.location),
                _infoTile(Icons.info_outline, 'About Me', profile.aboutMe),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await context.push(AppRoutes.editProfile);
                    _loadProfile();
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto(String photo) {
    if (photo.startsWith('data:image')) {
      final bytes = base64Decode(photo.split(',').last);
      return Image.memory(bytes, width: 100, height: 100, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: photo,
      cacheKey: photo,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorWidget: (ctx, _, e) =>
          const Icon(Icons.person, size: 50, color: Colors.white),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        subtitle: Text(value, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}
