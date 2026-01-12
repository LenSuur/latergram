import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/gallery/presentation/screens/gallery_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/reflection/data/models/reflection_model.dart';
import '../../features/reflection/presentation/screens/draft_reflection_screen.dart';
import '../../features/reflection/presentation/screens/reflection_detail_screen.dart';
import '../../features/splash/presentation/screens/splash_screens.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',

    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: '/gallery',
        name: 'gallery',
        builder: (context, state) => const GalleryScreen(),
      ),

      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: '/draft-reflection',
        name: 'draft-reflection',
        builder: (context, state) {
          final extra = state.extra;

          if (extra is String) {
            // photo path
            return DraftReflectionScreen(photoPath: extra);
          } else if (extra is ReflectionModel) {
            // reflection
            return DraftReflectionScreen(existingReflection: extra);
          } else {
            // Coming from "Ava" button - no data
            return DraftReflectionScreen();
          }
        },
      ),

      GoRoute(
        path: '/reflection-detail',
        name: 'reflection-detail',
        builder: (context, state) {
          final reflection = state.extra as ReflectionModel;
          return ReflectionDetailScreen(reflection: reflection);
        },
      ),
    ],
  );
}
