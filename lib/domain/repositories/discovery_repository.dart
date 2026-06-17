import '../entities/user_profile.dart';

abstract class DiscoveryRepository {
  Future<List<UserProfile>> fetchProfiles({int page = 1, int results = 20});
  List<String> getFavoriteIds();
  Future<void> toggleFavorite(String id);
  List<UserProfile> getCachedProfiles();
}
