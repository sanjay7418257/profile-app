import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../providers/providers.dart';
import '../../widgets/profile_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoveryProvider);
    final notifier = ref.read(discoveryProvider.notifier);
    final favorites = notifier.favoriteProfiles;
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryText = colorScheme.onSurface.withValues(alpha: 0.64);

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: secondaryText,
            ),
            const SizedBox(height: 16),
            Text('No saved profiles yet',
                style: TextStyle(color: secondaryText)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: favorites.length,
      itemBuilder: (_, i) {
        final profile = favorites[i];
        return ProfileCard(
          profile: profile,
          isFavorite: state.favoriteIds.contains(profile.id),
          onFavoriteToggle: () => ref.read(discoveryProvider.notifier).toggleFavorite(profile.id),
          onTap: () => context.push(AppRoutes.profileDetail, extra: profile),
        );
      },
    );
  }
}
