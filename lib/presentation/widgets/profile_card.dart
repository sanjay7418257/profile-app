import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/user_profile.dart';

class ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _avatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(profile.occupation,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(profile.location,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : AppColors.textSecondary,
                ),
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar() {
    return CircleAvatar(
      radius: 30,
      backgroundColor: AppColors.surface,
      child: profile.photoUrl != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: profile.photoUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (ctx, _) =>
                    const CircularProgressIndicator(strokeWidth: 2),
                errorWidget: (ctx, _, e) =>
                    const Icon(Icons.person, size: 30),
              ),
            )
          : const Icon(Icons.person, size: 30),
    );
  }
}
