import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/screens/home_screen.dart';
import 'package:social_media_app/screens/login_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'home',
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
      ],
    ),
  ],
);
