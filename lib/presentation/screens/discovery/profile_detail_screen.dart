import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user_profile.dart';
import '../../providers/providers.dart';

class ProfileDetailScreen extends ConsumerWidget {
  final UserProfile profile;

  const ProfileDetailScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(discoveryProvider).favoriteIds;
    final isFavorite = favoriteIds.contains(profile.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () =>
                    ref.read(discoveryProvider.notifier).toggleFavorite(profile.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: profile.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: profile.photoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (ctx, _) => Container(color: AppColors.primary),
                      errorWidget: (ctx, _, e) => Container(
                        color: AppColors.primary,
                        child: const Icon(Icons.person, size: 80, color: Colors.white),
                      ),
                    )
                  : Container(
                      color: AppColors.primary,
                      child: const Icon(Icons.person, size: 80, color: Colors.white),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.fullName,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(profile.occupation,
                      style: const TextStyle(color: AppColors.primary, fontSize: 16)),
                  const SizedBox(height: 20),
                  _section('Personal Info', [
                    _row(Icons.cake, 'Age', '${profile.age} years'),
                    _row(Icons.location_on, 'Location', profile.location),
                  ]),
                  const SizedBox(height: 16),
                  _section('Contact', [
                    _row(Icons.email, 'Email', profile.email),
                    _row(Icons.phone, 'Phone', profile.phone),
                  ]),
                  const SizedBox(height: 16),
                  _section('About', [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(profile.aboutMe, style: const TextStyle(fontSize: 15, height: 1.5)),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                letterSpacing: 0.5)),
        const Divider(),
        ...children,
      ],
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
