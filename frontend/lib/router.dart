import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/screens/full_screen_post_screen.dart';
import 'package:social_media_app/screens/home_screen.dart';
import 'package:social_media_app/screens/login_screen.dart';

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
