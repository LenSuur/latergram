import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
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
        builder: (context, state) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/home'),
            ),
            title: Text('Gallery', style: TextStyle(color: Colors.white)),
          ),
          body: Center(
            child: Text(
              'Gallery - Coming Soon',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),

      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/home'),
            ),
            title: Text('Profile', style: TextStyle(color: Colors.white)),
          ),
          body: Center(
            child: Text(
              'Profile - Coming Soon',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),

      GoRoute(
        path: '/create-reflection',
        name: 'create-reflection',
        builder: (context, state) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => context.go('/home'),
            ),
            title: Text(
              'Create Reflection',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: Text(
              'Create Reflection - Coming Soon',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
    ],
  );
}
