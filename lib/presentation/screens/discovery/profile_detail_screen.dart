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
    final aboutBoxColor = AppColors.primary.withValues(alpha: 0.05);
    final aboutTextColor = _textColorForContainer(context, aboutBoxColor);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              GestureDetector(
                onTap: () => ref
                    .read(discoveryProvider.notifier)
                    .toggleFavorite(profile.id),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.red : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  profile.photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: profile.photoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (ctx, _) => Container(
                              color: AppColors.primary.withValues(alpha: 0.3)),
                          errorWidget: (ctx, _, e) => _headerFallback(),
                        )
                      : _headerFallback(),
                  // gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Color(0xDD000000),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  // name + occupation on photo
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                profile.occupation,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${profile.age} yrs',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick info row
                  Row(
                    children: [
                      _quickInfo(context,
                          Icons.location_on_rounded, profile.location),
                      const SizedBox(width: 12),
                      _quickInfo(context, Icons.email_rounded, profile.email),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // About section
                  _sectionTitle('About Me'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: aboutBoxColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color:
                              AppColors.primary.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      profile.aboutMe,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: aboutTextColor.withValues(alpha: 0.87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Contact details
                  _sectionTitle('Contact & Details'),
                  const SizedBox(height: 10),
                  _detailCard(context, [
                    _detailRow(context, Icons.phone_rounded, 'Phone',
                        profile.phone),
                    _divider(),
                    _detailRow(context, Icons.email_outlined, 'Email',
                        profile.email),
                    _divider(),
                    _detailRow(context, Icons.location_on_outlined, 'Location',
                        profile.location),
                    _divider(),
                    _detailRow(context, Icons.cake_outlined, 'Age',
                        '${profile.age} years old'),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
        ),
      ),
      child: Center(
        child: Text(
          profile.fullName.isNotEmpty
              ? profile.fullName[0].toUpperCase()
              : '?',
          style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Colors.white30),
        ),
      ),
    );
  }

  Widget _quickInfo(BuildContext context, IconData icon, String text) {
    final boxColor = AppColors.surface;
    final textColor = _textColorForContainer(context, boxColor);

    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withValues(alpha: 0.68),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _detailCard(BuildContext context, List<Widget> children) {
    final boxColor = Theme.of(context).cardColor;

    return Container(
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _detailRow(
      BuildContext context, IconData icon, String label, String value) {
    final boxColor = Theme.of(context).cardColor;
    final textColor = _textColorForContainer(context, boxColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withValues(alpha: 0.62),
                  )),
              Text(value,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 64);

  Color _textColorForContainer(BuildContext context, Color containerColor) {
    final effectiveColor = Color.alphaBlend(
      containerColor,
      Theme.of(context).scaffoldBackgroundColor,
    );

    return effectiveColor.computeLuminance() > 0.5
        ? AppColors.textPrimary
        : Colors.white;
  }
}
