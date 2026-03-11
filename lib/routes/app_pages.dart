import 'package:go_router/go_router.dart';
import 'package:projects/data/repositories/authentication_repository.dart';
import 'package:projects/features/authentication/screens/login/login.dart';
import 'package:projects/features/shop/screens/home/home.dart';
import 'package:projects/init/injection.dart';
import 'package:projects/routes/routes.dart';

class AppPages {
  static final router = GoRouter(
    initialLocation: TRoutes.login,
    redirect: (context, state) async {
      final authRepository = getIt<AuthenticationRepository>();
      final loggedIn = await authRepository.isLoggedIn();
      
      // If the user is logged in and trying to go to login, send them home
      final isLoggingIn = state.matchedLocation == TRoutes.login;
      
      if (loggedIn && isLoggingIn) {
        return TRoutes.home;
      }
      
      return null; // No redirect
    },
    routes: [
      GoRoute(
        path: TRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: TRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
