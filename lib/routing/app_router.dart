import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/screens/add_post_screen.dart';
import 'package:social_media_app/screens/comments_screen.dart';
import 'package:social_media_app/screens/explore_screen.dart';
import 'package:social_media_app/screens/full_screen_post_screen.dart';
import 'package:social_media_app/screens/home_screen.dart';
import 'package:social_media_app/screens/login_screen.dart';
import 'package:social_media_app/screens/profile_screen.dart';
import 'package:social_media_app/screens/root_screen.dart';
import 'package:social_media_app/screens/stories_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return RootScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/stories',
            builder: (context, state) => const StoriesScreen(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/comments',
            builder: (context, state) => CommentsScreen(
              post: state.extra as Post,
            ),
          ),
        ],
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
      GoRoute(
        path: '/add-post',
        builder: (context, state) => const AddPostScreen(),
      ),
    ],
  );

  static GoRouter get router => _router;
}
