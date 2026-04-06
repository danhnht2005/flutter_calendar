import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calender/screens/home_screen/home_screen.dart';
import 'package:calender/screens/login_screen/login_screen.dart';
import 'package:calender/screens/register_screen/register_screen.dart';
import 'package:calender/helpers/token.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) async {
    final String? token = await Token.getToken();
    // final String? token = null;
    final bool loggedIn = token != null && token.isNotEmpty;
    final bool isAuthRoute =
        state.matchedLocation == '/login' || state.matchedLocation == '/register';

    if (!loggedIn && !isAuthRoute) {
      return '/login';
    }

    if (loggedIn && isAuthRoute) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);