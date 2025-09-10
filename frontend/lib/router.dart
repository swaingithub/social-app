import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jivvi/screens/full_screen_post_screen.dart';
import 'package:jivvi/screens/home_screen.dart';
import 'package:jivvi/screens/login_screen.dart';
import 'package:jivvi/screens/signup_screen.dart';

final router = GoRouter(
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
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/post',
      builder: (context, state) {
        final post = state.extra as Map<String, String>;
        return FullScreenPostScreen(
          username: post['username']!,
          avatarUrl: post['avatarUrl']!,
          imageUrl: post['imageUrl']!,
          caption: post['caption']!,
        );
      },
    ),
  ],
);
