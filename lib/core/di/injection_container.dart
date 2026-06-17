import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/discovery_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/auth/auth_usecases.dart';
import '../../domain/usecases/discovery/discovery_usecases.dart';
import '../../domain/usecases/profile/profile_usecases.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  // --- External ---
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  // --- Core ---
  sl.registerLazySingleton(() => DioClient.instance);

  // --- Data Sources ---
  sl.registerLazySingleton<LocalDataSource>(() => LocalDataSource());
  sl.registerLazySingleton<RemoteDataSource>(() => RemoteDataSource(sl()));

  // --- Repositories ---
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl<LocalDataSource>(), sl<RemoteDataSource>()));
  sl.registerLazySingleton<DiscoveryRepository>(
      () => DiscoveryRepositoryImpl(sl<RemoteDataSource>(), sl<LocalDataSource>()));

  // --- Auth Use Cases ---
  sl.registerFactory(() => LoginUseCase(sl()));
  sl.registerFactory(() => RegisterUseCase(sl()));
  sl.registerFactory(() => ForgotPasswordUseCase(sl()));
  sl.registerFactory(() => LogoutUseCase(sl()));

  // --- Profile Use Cases ---
  sl.registerFactory(() => SaveProfileUseCase(sl()));
  sl.registerFactory(() => GetProfileUseCase(sl()));
  sl.registerFactory(() => UploadProfilePictureUseCase(sl()));

  // --- Discovery Use Cases ---
  sl.registerFactory(() => FetchProfilesUseCase(sl()));
  sl.registerFactory(() => ToggleFavoriteUseCase(sl()));
  sl.registerFactory(() => GetFavoritesUseCase(sl()));
  sl.registerFactory(() => GetCachedProfilesUseCase(sl()));
}
