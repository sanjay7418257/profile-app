import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../providers/providers.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/profile_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(discoveryProvider.notifier).loadProfiles(refresh: true));
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      final state = ref.read(discoveryProvider);
      if (!state.isLoading && state.hasMore) {
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter by Age', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              RangeSlider(
                values: RangeValues(minAge, maxAge),
                min: 18,
                max: 80,
                divisions: 62,
                labels: RangeLabels('${minAge.round()}', '${maxAge.round()}'),
                activeColor: AppColors.primary,
                onChanged: (v) => setModalState(() {
                  minAge = v.start;
                  maxAge = v.end;
                }),
              ),
              Text('Age: ${minAge.round()} – ${maxAge.round()}',
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(discoveryProvider.notifier).clearFilter();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(discoveryProvider.notifier).filterByAge(minAge.round(), maxAge.round());
                        Navigator.pop(ctx);
                      },
                      child: const Text('Apply'),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoveryProvider);

    ref.listen(discoveryProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), behavior: SnackBarBehavior.floating),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: _showFilterSheet),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by name, occupation, location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(discoveryProvider.notifier).search('');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => ref.read(discoveryProvider.notifier).search(v),
            ),
          ),
          Expanded(
            child: LoadingOverlay(
              isLoading: state.isLoading && state.profiles.isEmpty,
              child: state.filtered.isEmpty && !state.isLoading
                  ? const Center(child: Text('No profiles found'))
                  : RefreshIndicator(
                      onRefresh: () => ref.read(discoveryProvider.notifier).loadProfiles(refresh: true),
                      child: ListView.builder(
                        controller: _scrollCtrl,
                        itemCount: state.filtered.length + (state.isLoading ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == state.filtered.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final profile = state.filtered[i];
                          return ProfileCard(
                            profile: profile,
                            isFavorite: state.favoriteIds.contains(profile.id),
                            onFavoriteToggle: () =>
                                ref.read(discoveryProvider.notifier).toggleFavorite(profile.id),
                            onTap: () => context.push(AppRoutes.profileDetail, extra: profile),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
