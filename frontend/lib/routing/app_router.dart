
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/providers/user_provider.dart';
import 'package:social_media_app/screens/add_post_screen.dart';
import 'package:social_media_app/screens/comments_screen.dart';
import 'package:social_media_app/screens/explore_screen.dart';
import 'package:social_media_app/screens/home_screen.dart';
import 'package:social_media_app/screens/login_screen.dart';
import 'package:social_media_app/screens/profile_screen.dart';
import 'package:social_media_app/screens/root_screen.dart';
import 'package:social_media_app/screens/signup_screen.dart';
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
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
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
        path: '/add-post',
        builder: (context, state) => const AddPostScreen(),
      ),
    ],
    redirect: (context, state) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final loggedIn = token != null;

      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';

      if (!loggedIn && !isLoggingIn && !isSigningUp) {
        return '/login';
      }

      if (loggedIn && (isLoggingIn || isSigningUp)) {
        if (userProvider.user == null) {
          await userProvider.getMe();
        }
        return '/';
      }

      return null;
    },
  );

  static GoRouter get router => _router;
}
