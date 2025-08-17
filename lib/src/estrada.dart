import 'package:meta/meta.dart';

import 'registry.dart';
import 'route.dart';
import 'route_result.dart';

/// A lightweight and generic router that resolves paths
/// against a set of [EstradaRoute] definitions.
///
/// The router itself is generic, so you can extend [EstradaRoute]
/// to store any additional metadata you need (e.g. HTTP method, handler).
///
/// Example:
/// ```dart
/// final router = Estrada(
///   routes: [
///     EstradaRoute(route: 'alive'),
///     EstradaRoute(route: 'user/:userId'),
///   ],
/// );
///
/// final result = router.match('user/42');
/// print(result?.paths); // {userId: 42}
/// ```
@immutable
final class Estrada<T extends EstradaRoute> {
  /// The list of registered routes.
  ///
  /// You can provide routes on initialization or add them later
  /// using [addRoute].
  final List<T> routes;

  /// Internal registry for managing route patterns and resolution.
  final Registry<T> _registry;

  /// Creates a new [Estrada] router.
  ///
  /// If [routes] is not provided, it defaults to an empty list.
  Estrada({this.routes = const []}) : _registry = Registry<T>() {
    for (final route in routes) {
      _registry.add(route);
    }
  }

  /// Adds a new [route] to the router at runtime.
  ///
  /// Throws an [ArgumentError] if the route already exists.
  void addRoute(T route) {
    _registry.add(route);
  }

  /// Resolves the given [path] against the registered routes.
  ///
  /// Returns a [RouteResult] if a matching route is found,
  /// otherwise returns `null`.
  RouteResult<T>? match(String path) {
    return _registry.resolve(path: path);
  }
}
