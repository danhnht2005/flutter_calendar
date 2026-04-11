import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calender/screens/home_screen/home_screen.dart';
import 'package:calender/screens/login_screen/login_screen.dart';
import 'package:calender/screens/register_screen/register_screen.dart';
import 'package:calender/helpers/token.dart';
import 'package:calender/screens/settings_screen/settings_screen.dart';
import 'package:calender/screens/detail_category/detail_category.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) async {
    final String? token = await Token.getToken();
    final bool loggedIn = token != null && token.isNotEmpty;
    final bool isAuthRoute =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!loggedIn && !isAuthRoute) {
      return '/login';
    }

    if (loggedIn && isAuthRoute) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/details-category/:id', // Khai báo param 'id'
      builder: (context, state) {
        // Lấy tham số xuống bằng state.pathParameters
        final String? id = state.pathParameters['id'];
        return DetailCategoryScreen(id: id ?? '');
      },
    ),
  ],
);
