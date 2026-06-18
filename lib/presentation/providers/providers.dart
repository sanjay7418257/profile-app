import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di/injection_container.dart';
import '../../domain/usecases/auth/auth_usecases.dart';
import '../../domain/usecases/discovery/discovery_usecases.dart';
import '../../domain/usecases/profile/profile_usecases.dart';
import 'auth_provider.dart';
import 'discovery_provider.dart';
import 'profile_provider.dart';
import 'theme_provider.dart';

// --- State Notifiers wired via get_it ---
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    sl<LoginUseCase>(),
    sl<RegisterUseCase>(),
    sl<ForgotPasswordUseCase>(),
    sl<LogoutUseCase>(),
  ),
);

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(
    sl<SaveProfileUseCase>(),
    sl<GetProfileUseCase>(),
    sl<UploadProfilePictureUseCase>(),
  ),
);

final discoveryProvider = StateNotifierProvider<DiscoveryNotifier, DiscoveryState>(
  (ref) => DiscoveryNotifier(
    sl<FetchProfilesUseCase>(),
    sl<ToggleFavoriteUseCase>(),
    sl<GetFavoritesUseCase>(),
    sl<GetCachedProfilesUseCase>(),
  ),
);

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>(
  (ref) => ThemeNotifier(sl<SharedPreferences>()),
);
