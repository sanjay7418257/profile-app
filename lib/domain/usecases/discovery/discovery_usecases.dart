import '../../entities/user_profile.dart';
import '../../repositories/discovery_repository.dart';

class FetchProfilesUseCase {
  final DiscoveryRepository _repo;
  FetchProfilesUseCase(this._repo);
  Future<List<UserProfile>> call({int page = 1}) => _repo.fetchProfiles(page: page);
}

class ToggleFavoriteUseCase {
  final DiscoveryRepository _repo;
  ToggleFavoriteUseCase(this._repo);
  Future<void> call(String id) => _repo.toggleFavorite(id);
}

class GetFavoritesUseCase {
  final DiscoveryRepository _repo;
  GetFavoritesUseCase(this._repo);
  List<String> call() => _repo.getFavoriteIds();
}

class GetCachedProfilesUseCase {
  final DiscoveryRepository _repo;
  GetCachedProfilesUseCase(this._repo);
  List<UserProfile> call() => _repo.getCachedProfiles();
}
