// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.3
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/material.dart';
import '../mvc/wt_controller.dart';

/// Builds the [WtController] for a matched route from its [RouteSettings].
typedef WtRouteBuilder = WtController Function(RouteSettings settings);

/// A single route: a [path] pattern (supports `:param` segments) and the
/// [builder] that creates its controller.
class WtRoute {
  /// Path pattern, e.g. `/ad/:id`. `:name` segments are dynamic.
  final String path;

  /// Creates the controller for this route.
  final WtRouteBuilder builder;

  /// Creates a route binding [path] to [builder].
  const WtRoute({required this.path, required this.builder});
}

/// Matches route names to [WtRoute]s and generates their pages.
class WtRouter {
  /// The registered routes, matched in order.
  final List<WtRoute> routes;

  /// Route shown first when the app starts.
  final String initialRoute;

  /// Optional custom page for unmatched routes (defaults to a built-in 404).
  final Widget Function(BuildContext, RouteSettings)? notFoundPage;

  /// Creates a router over [routes] with an [initialRoute].
  const WtRouter({
    required this.routes,
    this.initialRoute = '/',
    this.notFoundPage,
  });

  /// `onGenerateRoute` handler: resolves [settings] to a page or the 404.
  Route<dynamic>? dispatch(RouteSettings settings) {
    final routeName = settings.name ?? '/';

    for (final route in routes) {
      if (_matchRoute(route.path, routeName)) {
        final controller = route.builder(settings);
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => controller.render(context),
        );
      }
    }

    return MaterialPageRoute(
      builder: (context) =>
          notFoundPage?.call(context, settings) ??
          const _DefaultNotFoundPage(),
    );
  }

  bool _matchRoute(String pattern, String path) {
    if (pattern == path) return true;
    final patternParts = pattern.split('/');
    final pathParts = path.split('/');
    if (patternParts.length != pathParts.length) return false;
    for (int i = 0; i < patternParts.length; i++) {
      if (patternParts[i].startsWith(':')) continue;
      if (patternParts[i] != pathParts[i]) return false;
    }
    return true;
  }

  /// Extracts `:param` values from [path] using the route [pattern].
  static Map<String, String> getParams(String pattern, String path) {
    final params = <String, String>{};
    final patternParts = pattern.split('/');
    final pathParts = path.split('/');
    for (int i = 0; i < patternParts.length; i++) {
      if (patternParts[i].startsWith(':')) {
        params[patternParts[i].substring(1)] = pathParts[i];
      }
    }
    return params;
  }
}

class _DefaultNotFoundPage extends StatelessWidget {
  const _DefaultNotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404', style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
            const Text('Page Not Found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
