import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/discovery/discovery_usecases.dart';

class DiscoveryState {
  final List<UserProfile> profiles;
  final List<UserProfile> filtered;
  final List<String> favoriteIds;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final int currentPage;
  final bool hasMore;

  const DiscoveryState({
    this.profiles = const [],
    this.filtered = const [],
    this.favoriteIds = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.currentPage = 1,
    this.hasMore = true,
  });

  DiscoveryState copyWith({
    List<UserProfile>? profiles,
    List<UserProfile>? filtered,
    List<String>? favoriteIds,
    bool? isLoading,
    String? error,
    String? searchQuery,
    int? currentPage,
    bool? hasMore,
  }) =>
      DiscoveryState(
        profiles: profiles ?? this.profiles,
        filtered: filtered ?? this.filtered,
        favoriteIds: favoriteIds ?? this.favoriteIds,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        searchQuery: searchQuery ?? this.searchQuery,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
      );
}

class DiscoveryNotifier extends StateNotifier<DiscoveryState> {
  final FetchProfilesUseCase _fetch;
  final ToggleFavoriteUseCase _toggleFavorite;
  final GetFavoritesUseCase _getFavorites;
  final GetCachedProfilesUseCase _getCached;

  DiscoveryNotifier(this._fetch, this._toggleFavorite, this._getFavorites, this._getCached)
      : super(const DiscoveryState());

  Future<void> loadProfiles({bool refresh = false}) async {
    if (state.isLoading) return;
    final page = refresh ? 1 : state.currentPage;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _fetch(page: page);
      final favorites = _getFavorites();
      final allProfiles = refresh ? results : [...state.profiles, ...results];
      state = state.copyWith(
        profiles: allProfiles,
        filtered: _applyFilter(allProfiles, state.searchQuery),
        favoriteIds: favorites,
        isLoading: false,
        currentPage: page + 1,
        hasMore: results.length >= 20,
      );
    } catch (e) {
      final cached = _getCached();
      state = state.copyWith(
        isLoading: false,
        error: 'No internet. Showing cached profiles.',
        profiles: cached,
        filtered: _applyFilter(cached, state.searchQuery),
      );
    }
  }

  void search(String query) {
    state = state.copyWith(
      searchQuery: query,
      filtered: _applyFilter(state.profiles, query),
    );
  }

  void filterByAge(int min, int max) {
    final result = state.profiles.where((p) => p.age >= min && p.age <= max).toList();
    state = state.copyWith(filtered: result);
  }

  void clearFilter() {
    state = state.copyWith(
      filtered: state.profiles,
      searchQuery: '',
    );
  }

  Future<void> toggleFavorite(String id) async {
    await _toggleFavorite(id);
    final favorites = _getFavorites();
    state = state.copyWith(favoriteIds: favorites);
  }

  List<UserProfile> get favoriteProfiles =>
      state.profiles.where((p) => state.favoriteIds.contains(p.id)).toList();

  List<UserProfile> _applyFilter(List<UserProfile> profiles, String query) {
    if (query.isEmpty) return profiles;
    final q = query.toLowerCase();
    return profiles.where((p) =>
        p.fullName.toLowerCase().contains(q) ||
        p.occupation.toLowerCase().contains(q) ||
        p.location.toLowerCase().contains(q)).toList();
  }
}
