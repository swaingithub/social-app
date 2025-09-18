import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jivvi/features/user/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jivvi/features/post/models/post.dart';
import 'package:jivvi/features/auth/models/user.dart';
import 'package:jivvi/providers/user_provider.dart';
import 'package:jivvi/features/post/screens/add_post_screen.dart';
import 'package:jivvi/features/post/screens/comments_screen.dart';
import 'package:jivvi/features/user/screens/edit_profile_screen.dart';
import 'package:jivvi/features/misc/screens/explore_screen.dart';
import 'package:jivvi/features/home/screens/home_screen.dart';
import 'package:jivvi/features/auth/screens/login_screen.dart';
import 'package:jivvi/features/user/screens/profile_screen.dart';
import 'package:jivvi/features/misc/screens/root_screen.dart';
import 'package:jivvi/features/auth/screens/signup_screen.dart';
import 'package:jivvi/features/auth/screens/splash_screen.dart';
import 'package:jivvi/features/misc/screens/stories_screen.dart';
import 'package:jivvi/features/misc/screens/chat_screen.dart' as chat;
import 'package:jivvi/features/misc/widgets/conversations_list.dart';
import 'package:provider/provider.dart';
import 'package:jivvi/providers/chat_provider.dart';
import 'package:jivvi/features/post/screens/post_detail_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
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
            path: '/add-post',
            builder: (context, state) => const AddPostScreen(),
          ),
          GoRoute(
            path: '/profile',
            redirect: (context, state) {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              final myUserId = userProvider.user?.id;
              
              if (myUserId == null) {
                return '/login';
              }
              
              // Redirect to the profile with the user ID
              return '/profile/$myUserId';
            },
          ),
          GoRoute(
            path: '/profile/:userId',
            builder: (context, state) {
              final userId = state.pathParameters['userId'];
              if (userId == null || userId.isEmpty) {
                return const Scaffold(
                  body: Center(child: Text('User ID is missing')),
                );
              }
              return ProfileScreen(userId: userId);
            },
          ),
          GoRoute(
            path: '/comments',
            builder: (context, state) {
              final post = state.extra as Post?;
              if (post == null) {
                return const Scaffold(
                  body: Center(child: Text('No post selected')),
                );
              }
              return CommentsScreen(
                post: post,
              );
            },
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) {
              final conversationId = state.extra as String?;
              if (conversationId == null || conversationId.isEmpty) {
                return const Scaffold(
                  body: Center(child: Text('No conversation selected')),
                );
              }
              return chat.ChatScreen(conversationId: conversationId);
            },
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) {
              return ChangeNotifierProvider(
                create: (_) => ChatProvider()..loadConversations(),
                child: const Scaffold(
                  appBar: _MessagesAppBar(),
                  body: ConversationsList(),
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          final user = (state.extra as User?) ?? userProvider.user;
          if (user == null) {
            return const Scaffold(
              body: Center(child: Text('No user to edit')),
            );
          }
          return EditProfileScreen(
            user: user,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final postId = state.pathParameters['id']!;
          return PostDetailScreen(postId: postId);
        },
      ),
    ],
  );

  static GoRouter get router => _router;
}

class _MessagesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MessagesAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Messages'),
    );
  }
}
