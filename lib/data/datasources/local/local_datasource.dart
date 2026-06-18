import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user_profile_model.dart';

class LocalDataSource {
  static const _profileBox = 'profiles';
  static const _favoritesBox = 'favorites';
  static const _cacheBox = 'cache';

  Future<void> saveProfile(UserProfileModel model) async {
    final box = await Hive.openBox<UserProfileModel>(_profileBox);
    await box.put(model.id, model);
  }

  Future<UserProfileModel?> getProfile(String uid) async {
    final box = await Hive.openBox<UserProfileModel>(_profileBox);
    return box.get(uid);
  }

  Future<void> toggleFavorite(String id) async {
    final box = await Hive.openBox<String>(_favoritesBox);
    if (box.values.contains(id)) {
      final key = box.keys.firstWhere((k) => box.get(k) == id);
      await box.delete(key);
    } else {
      await box.add(id);
    }
  }

  List<String> getFavoriteIds() {
    if (!Hive.isBoxOpen(_favoritesBox)) return [];
    final box = Hive.box<String>(_favoritesBox);
    return box.values.toList();
  }

  Future<void> cacheProfiles(List<UserProfileModel> profiles) async {
    final box = await Hive.openBox<UserProfileModel>(_cacheBox);
    await box.clear();
    for (final p in profiles) {
      await box.put(p.id, p);
    }
  }

  List<UserProfileModel> getCachedProfiles() {
    if (!Hive.isBoxOpen(_cacheBox)) return [];
    return Hive.box<UserProfileModel>(_cacheBox).values.toList();
  }

  Future<void> openBoxes() async {
    await Hive.openBox<UserProfileModel>(_profileBox);
    await Hive.openBox<String>(_favoritesBox);
    await Hive.openBox<UserProfileModel>(_cacheBox);
  }
}
