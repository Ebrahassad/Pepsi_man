import 'package:flutter/material.dart';

/// Global navigator key so managers/controllers can trigger navigation
/// (e.g. forcing a return to Main Menu after data corruption) without
/// needing a BuildContext.
class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<T?> push<T>(Widget screen) {
    return navigatorKey.currentState!.push<T>(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static Future<T?> pushReplacement<T>(Widget screen) {
    return navigatorKey.currentState!.pushReplacement<T, T>(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static void pop<T>([T? result]) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState!.pop(result);
    }
  }

  static void popUntilFirst() {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }
}
