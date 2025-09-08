import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/screens/comments_screen.dart';
import 'package:social_media_app/screens/create_post_screen.dart';
import 'package:social_media_app/screens/home_screen.dart';
import 'package:social_media_app/screens/login_screen.dart';
import 'package:social_media_app/screens/profile_screen.dart';
import 'package:social_media_app/widgets/scaffold_with_nav_bar.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return LoginScreen(auth: FirebaseAuth.instance);
      },
    ),
    GoRoute(
      path: '/create-post',
      builder: (BuildContext context, GoRouterState state) {
        return const CreatePostScreen();
      },
    ),
    GoRoute(
      path: '/comments/:postId',
      builder: (BuildContext context, GoRouterState state) {
        final postId = state.pathParameters['postId']!;
        return CommentsScreen(postId: postId);
      },
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
        ),
      ],
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final bool loggingIn = state.matchedLocation == '/login';

    final isPublicRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/' ||
        state.matchedLocation.startsWith('/comments');

    if (!loggedIn && !isPublicRoute) {
      return '/login';
    }

    if (loggedIn && loggingIn) {
      return '/';
    }

    return null;
  },
);
