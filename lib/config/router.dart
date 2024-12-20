import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:social_feed_app/bloc/auth/auth_bloc.dart';
import 'package:social_feed_app/bloc/auth/auth_state.dart';
import 'package:social_feed_app/bloc/signup/signup_bloc.dart';
import 'package:social_feed_app/bloc/signup/signup_state.dart';
import 'package:social_feed_app/config/route_names.dart';
import 'package:social_feed_app/config/router_refresh_stream.dart';
import 'package:social_feed_app/views/auth/signup_screen.dart';
import 'package:social_feed_app/views/feed/feed_screen.dart';
import 'package:social_feed_app/views/auth/login_screen.dart';
import 'package:social_feed_app/views/post/add_post_screen.dart';
import 'package:social_feed_app/views/profile_screen.dart';
import 'package:social_feed_app/services/auth_storage_service.dart';

// lib/config/router.dart
class AppRouter {
  static GoRouter getRouter(BuildContext context) {
    return GoRouter(
      initialLocation: RouteNames.login,
      refreshListenable: GoRouterRefreshStream(
          context.read<AuthBloc>().stream, context.read<SignupBloc>().stream),
      redirect: (BuildContext context, GoRouterState state) {
        // todo: is there a more efficient way to access auth storage service
        final isAuthenticated = AuthStorageService().isUserAuthenticated();

        final currentPath = state.uri.path;
        final isLoginRoute = currentPath == RouteNames.login;
        final isSignupRoute = currentPath == RouteNames.signup;

        if (!isAuthenticated && !isLoginRoute && !isSignupRoute) {
          return RouteNames.login;
        }
        if (isAuthenticated && (isLoginRoute || isSignupRoute)) {
          return RouteNames.feed;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteNames.signup,
          builder: (context, state) => SignupScreen(),
        ),
        GoRoute(
          path: RouteNames.addPost,
          builder: (context, state) => AddPostScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return ScaffoldWithNavBar(child: child);
          },
          routes: [
            GoRoute(
              path: RouteNames.feed,
              builder: (context, state) => const FeedScreen(),
            ),
            GoRoute(
              path: RouteNames.profile,
              builder: (context, state) => ProfileScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.feed),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/feed')) return 0;
    if (location.startsWith('/profile')) return 1;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/feed');
        break;
      case 1:
        context.go('/profile');
        break;
    }
  }
}
