import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanayi_websites/core/routing/route_utils.dart';
import 'package:sanayi_websites/screens/add/add_dukkan_screen.dart';
import 'package:sanayi_websites/screens/add/edit_dukkan_screen.dart';
import 'package:sanayi_websites/screens/auth/login_screen.dart';
import 'package:sanayi_websites/screens/auth/register_screen.dart';
import 'package:sanayi_websites/screens/detail/detail_screen.dart';
import 'package:sanayi_websites/screens/home/home_screen.dart';
import 'package:sanayi_websites/screens/user/user_home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(_supabase.auth.onAuthStateChange),
  redirect: (context, state) {
    final loggedIn = _supabase.auth.currentSession != null;
    final isLogin = state.matchedLocation == '/login';
    final isRegister = state.matchedLocation == '/register';
    final path = state.uri.path;
    final needsAuth =
        path == '/ekle' || path == '/user' || path.endsWith('/edit');

    final isUserHome = state.matchedLocation == '/user';

    if (!loggedIn && isUserHome) return '/';

    if (!loggedIn && needsAuth) {
      final redirectTo = Uri.encodeComponent(state.uri.toString());
      return '/login?redirect=$redirectTo';
    }

    if (loggedIn && (isLogin || isRegister)) {
      final safe = RouteUtils.safeRedirect(
        state.uri.queryParameters['redirect'],
      );
      return safe ?? '/user';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/user', builder: (context, state) => const UserHome()),
    GoRoute(
      path: '/login',
      builder: (context, state) =>
          LoginScreen(redirectTo: state.uri.queryParameters['redirect']),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) =>
          RegisterScreen(redirectTo: state.uri.queryParameters['redirect']),
    ),
    GoRoute(
      path: '/dukkan/:id',
      builder: (context, state) =>
          DetailScreen(dukkanId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/dukkan/:id/edit',
      builder: (context, state) =>
          EditDukkanScreen(dukkanId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/ekle',
      builder: (context, state) => const AddDukkanScreen(),
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
