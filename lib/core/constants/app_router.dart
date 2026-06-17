import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';
import '../../domain/entities/user_profile.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/discovery/profile_detail_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (ctx, _) => const SplashScreen()),
    GoRoute(path: AppRoutes.login, builder: (ctx, _) => const LoginScreen()),
    GoRoute(path: AppRoutes.register, builder: (ctx, _) => const RegisterScreen()),
    GoRoute(path: AppRoutes.forgotPassword, builder: (ctx, _) => const ForgotPasswordScreen()),
    GoRoute(path: AppRoutes.home, builder: (ctx, _) => const MainShell()),
    GoRoute(path: AppRoutes.editProfile, builder: (ctx, _) => const EditProfileScreen()),
    GoRoute(
      path: AppRoutes.profileDetail,
      builder: (_, state) => ProfileDetailScreen(profile: state.extra as UserProfile),
    ),
  ],
);
