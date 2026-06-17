import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_router.dart';
import 'core/constants/app_theme.dart';
import 'core/di/injection_container.dart';
import 'data/datasources/local/local_datasource.dart';
import 'data/models/user_profile_model.dart';
import 'presentation/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileModelAdapter());
  await LocalDataSource().openBoxes();

  // Initialize dependency injection
  await setupDI();

  runApp(
    const ProviderScope(
      child: ProfileApp(),
    ),
  );
}

class ProfileApp extends ConsumerWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    return MaterialApp.router(
      title: 'Profile Discovery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
