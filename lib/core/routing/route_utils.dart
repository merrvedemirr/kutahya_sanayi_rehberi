import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class RouteUtils {
  RouteUtils._();

  /// Prevent open-redirects.
  /// Only allows internal app paths like `/ekle` or `/dukkan/123`.
  static String? safeRedirect(String? raw) {
    final r = raw?.trim();
    if (r == null || r.isEmpty) return null;
    if (!r.startsWith('/')) return null;
    if (r.startsWith('//')) return null;
    if (r.startsWith('/login') || r.startsWith('/register')) return null;
    return r;
  }

  /// AppBar "back" that always works.
  /// Pops if possible; otherwise navigates to [fallback].
  static void back(BuildContext context, {String fallback = '/'}) {
    final nav = Navigator.maybeOf(context);
    if (nav?.canPop() == true) {
      nav!.pop();
      return;
    }

    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }

    router.go(fallback);
  }
}

