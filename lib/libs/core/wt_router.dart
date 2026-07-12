// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.2
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/material.dart';
import '../mvc/wt_controller.dart';

typedef WtRouteBuilder = WtController Function(RouteSettings settings);

class WtRoute {
  final String path;
  final WtRouteBuilder builder;

  const WtRoute({required this.path, required this.builder});
}

class WtRouter {
  final List<WtRoute> routes;
  final String initialRoute;
  final Widget Function(BuildContext, RouteSettings)? notFoundPage;

  const WtRouter({
    required this.routes,
    this.initialRoute = '/',
    this.notFoundPage,
  });

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
