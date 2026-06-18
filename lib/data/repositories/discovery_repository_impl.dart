import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/remote_datasource.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final RemoteDataSource _remote;
  final LocalDataSource _local;

  DiscoveryRepositoryImpl(this._remote, this._local);

  @override
  Future<List<UserProfile>> fetchProfiles({int page = 1, int results = 20}) async {
    final models = await _remote.fetchProfiles(page: page, results: results);
    await _local.cacheProfiles(models);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  List<UserProfile> getCachedProfiles() {
    return _local.getCachedProfiles().map((m) => m.toEntity()).toList();
  }

  @override
  List<String> getFavoriteIds() => _local.getFavoriteIds();

  @override
  Future<void> toggleFavorite(String id) async {
    await _local.toggleFavorite(id);
  }
}
