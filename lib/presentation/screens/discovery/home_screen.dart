import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../domain/entities/user_profile.dart';
import '../../providers/discovery_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/profile_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isGridView = false;
  bool _showSavedOnly = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(discoveryProvider.notifier).loadProfiles(refresh: true));
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      final state = ref.read(discoveryProvider);
      if (!_showSavedOnly && !state.isLoading && state.hasMore) {
        ref.read(discoveryProvider.notifier).loadProfiles();
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    double minAge = 18;
    double maxAge = 60;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Filter Profiles',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('Filter by age range',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ageBadge('Min Age', minAge.round()),
                  _ageBadge('Max Age', maxAge.round()),
                ],
              ),
              const SizedBox(height: 8),
              RangeSlider(
                values: RangeValues(minAge, maxAge),
                min: 18,
                max: 80,
                divisions: 62,
                activeColor: AppColors.primary,
                onChanged: (v) => setModalState(() {
                  minAge = v.start;
                  maxAge = v.end;
                }),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(discoveryProvider.notifier).clearFilter();
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        side:
                            const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(discoveryProvider.notifier)
                            .filterByAge(
                                minAge.round(), maxAge.round());
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Apply Filter'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ageBadge(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          Text('$value',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoveryProvider);

    ref.listen(discoveryProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            expandedHeight: 224,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroHeader(state),
            ),
          ),
        ],
        body: _buildBody(state),
      ),
    );
  }

  Widget _buildHeroHeader(DiscoveryState state) {
    final visibleCount = _visibleProfiles(state).length;
    final savedCount = state.favoriteIds.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF082B6F),
            Color(0xFF0D47A1),
            Color(0xFF18A0FB),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover People',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Find people worth starting a conversation with',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _iconBtn(
                        _isGridView
                            ? Icons.view_list_rounded
                            : Icons.grid_view_rounded,
                        () => setState(() => _isGridView = !_isGridView),
                      ),
                      const SizedBox(width: 8),
                      _iconBtn(Icons.tune_rounded, _showFilterSheet),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  cursorColor: AppColors.primary,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search name, job, location...',
                    hintStyle: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.primary, size: 21),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 48, minHeight: 52),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                color: AppColors.textSecondary, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              ref.read(discoveryProvider.notifier).search('');
                              setState(() {});
                            },
                          )
                        : null,
                    suffixIconConstraints:
                        const BoxConstraints(minWidth: 48, minHeight: 52),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (v) {
                    ref.read(discoveryProvider.notifier).search(v);
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _heroStat(
                      Icons.groups_2_rounded,
                      '$visibleCount',
                      'Showing now',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _heroStat(
                      Icons.favorite_rounded,
                      '$savedCount',
                      'Saved',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _heroStat(
                      _isGridView
                          ? Icons.grid_view_rounded
                          : Icons.view_agenda_rounded,
                      _isGridView ? 'Grid' : 'List',
                      'View mode',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<UserProfile> _visibleProfiles(DiscoveryState state) {
    if (!_showSavedOnly) return state.filtered;

    return state.filtered
        .where((profile) => state.favoriteIds.contains(profile.id))
        .toList();
  }

  Widget _heroStat(IconData icon, String value, String label) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildBody(DiscoveryState state) {
    final profiles = _visibleProfiles(state);

    // Only full-screen loader on initial load
    if (state.isLoading && state.profiles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Finding profiles...',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    if (profiles.isEmpty && !state.isLoading && !_showSavedOnly) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_showSavedOnly
                ? Icons.favorite_border_rounded
                : Icons.search_off_rounded,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(_showSavedOnly ? 'No saved profiles yet' : 'No profiles found',
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref
          .read(discoveryProvider.notifier)
          .loadProfiles(refresh: true),
      child:
          _isGridView ? _buildGrid(state, profiles) : _buildList(state, profiles),
    );
  }

  Widget _buildList(DiscoveryState state, List<UserProfile> profiles) {
    final showEmptySaved = _showSavedOnly && profiles.isEmpty && !state.isLoading;

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      // no extra +1 when already loading profiles — avoids double spinner
      itemCount: profiles.length +
          1 +
          (showEmptySaved ? 1 : 0) +
          (!_showSavedOnly && state.isLoading && state.profiles.isNotEmpty
              ? 1
              : 0),
      itemBuilder: (_, i) {
        if (i == 0) {
          return _discoveryIntro(state);
        }

        final profileIndex = i - 1;
        if (showEmptySaved && profileIndex == 0) {
          return _emptySavedPrompt(state);
        }

        if (profileIndex == profiles.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2)),
          );
        }
        final profile = profiles[profileIndex];
        return ProfileCard(
          profile: profile,
          isFavorite:
              ref.watch(discoveryProvider).favoriteIds.contains(profile.id),
          onFavoriteToggle: () =>
              ref.read(discoveryProvider.notifier).toggleFavorite(profile.id),
          onTap: () => context.push(AppRoutes.profileDetail, extra: profile),
        );
      },
    );
  }

  Widget _buildGrid(DiscoveryState state, List<UserProfile> profiles) {
    return CustomScrollView(
      controller: _scrollCtrl,
      slivers: [
        SliverToBoxAdapter(child: _discoveryIntro(state)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final profile = profiles[i];
                return ProfileGridCard(
                  profile: profile,
                  isFavorite: ref
                      .watch(discoveryProvider)
                      .favoriteIds
                      .contains(profile.id),
                  onFavoriteToggle: () => ref
                      .read(discoveryProvider.notifier)
                      .toggleFavorite(profile.id),
                  onTap: () =>
                      context.push(AppRoutes.profileDetail, extra: profile),
                );
              },
              childCount: profiles.length,
            ),
          ),
        ),
        if (_showSavedOnly && profiles.isEmpty && !state.isLoading)
          SliverToBoxAdapter(child: _emptySavedPrompt(state)),
        if (!_showSavedOnly && state.isLoading && state.profiles.isNotEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2)),
            ),
          ),
      ],
    );
  }

  Widget _discoveryIntro(DiscoveryState state) {
    final hasSearch = state.searchQuery.trim().isNotEmpty;
    final visibleCount = _visibleProfiles(state).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _showSavedOnly ? 'Saved profiles' : 'Today\'s matches',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasSearch
                          ? 'Filtered by "${state.searchQuery}"'
                          : _showSavedOnly
                              ? 'People you liked are here'
                              : 'Fresh profiles selected for you',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.14),
                  ),
                ),
                child: Text(
                  '$visibleCount profiles',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterPill(
                  Icons.auto_awesome_rounded,
                  'Best matches',
                  isActive: !_showSavedOnly,
                  onTap: () => setState(() => _showSavedOnly = false),
                ),
                const SizedBox(width: 8),
                _filterPill(
                  Icons.favorite_rounded,
                  'Saved ${state.favoriteIds.length}',
                  isActive: _showSavedOnly,
                  onTap: () => setState(() => _showSavedOnly = true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptySavedPrompt(DiscoveryState state) {
    final hasSearch = state.searchQuery.trim().isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final bodyTextColor = colorScheme.onSurface.withValues(alpha: 0.64);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              hasSearch ? 'No saved match found' : 'No saved profiles yet',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasSearch
                  ? 'Try another search or switch back to Best matches.'
                  : 'Tap the heart on profiles you like, then they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: bodyTextColor,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterPill(
    IconData icon,
    String label, {
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveBg = isDark ? AppColors.darkCard : Colors.white;
    final inactiveText = colorScheme.onSurface.withValues(alpha: 0.72);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : inactiveBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : inactiveText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
