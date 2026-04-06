import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calender/screens/home_screen/home_screen.dart';
import 'package:calender/screens/login_screen/login_screen.dart';
import 'package:calender/helpers/token.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) async {
    // final String? token = await Token.getToken();
    final String? token = null;

    if (token == null || token.isEmpty) {
      return '/login';
    }

    return null;
  },
  routes: [
    // Trang chủ
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    // Trang chi tiết với tham số (params)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);