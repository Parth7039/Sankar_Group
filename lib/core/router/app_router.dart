import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../../screens/forgot_password_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/signup_screen.dart';
import '../../screens/solar_plan_details_screen.dart';
import '../../screens/solar_plans_screen.dart';
import '../../screens/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final location = state.matchedLocation;
    final isPublicAuthRoute = location == '/login' ||
        location == '/signup' ||
        location == '/forgot-password';
    final isProtectedRoute = location == '/home' ||
        location == '/plans' ||
        location.startsWith('/plans/');

    if (location == '/') return null;

    if (!AppConfig.isSupabaseConfigured) {
      return isProtectedRoute ? '/login' : null;
    }

    final isSignedIn = Supabase.instance.client.auth.currentSession != null;

    if (!isSignedIn && isProtectedRoute) return '/login';
    if (isSignedIn && isPublicAuthRoute) return '/home';

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/plans',
      builder: (context, state) => SolarPlansScreen(
        initialCategory: state.uri.queryParameters['category'],
      ),
    ),
    GoRoute(
      path: '/plans/:planId',
      builder: (context, state) => SolarPlanDetailsScreen(
        planId: state.pathParameters['planId']!,
      ),
    ),
  ],
);
