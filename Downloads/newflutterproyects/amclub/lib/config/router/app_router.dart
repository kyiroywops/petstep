// router.dart
import 'package:amclub/screens/screens/auth_page.dart';
import 'package:amclub/screens/screens/basescreen.dart';
import 'package:amclub/screens/screens/drinkwater_screen.dart';
import 'package:amclub/screens/screens/home_page.dart';
import 'package:amclub/screens/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthCheckScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: '/basescreen',
      builder: (context, state) => BaseScreen(),
      ),
       GoRoute(
          path: '/drink',
          builder: (context, state) => DrinkScreen(),
        ),
    
    ],
redirect: (BuildContext context, GoRouterState state) async {
  final isLoggedIn = FirebaseAuth.instance.currentUser != null;
  final isLoggingIn = state.matchedLocation == '/login';

  if (!isLoggedIn && !isLoggingIn) return '/login';
  if (isLoggedIn && isLoggingIn) return '/home';

  return null;
},
  );
}
