import 'package:meta/meta.dart';

/// Base class for defining a route in [Estrada].
///
/// Extend this class to add custom metadata to your routes,
/// for example an HTTP method, handler, middleware, etc.
///
/// Example:
/// ```dart
/// final class Route extends EstradaRoute {
///   final String method;
///
///   const Route({required super.route, required this.method});
/// }
/// ```
@immutable
base class EstradaRoute {
  /// The route pattern (e.g. `"user/:userId"`).
  ///
  /// Can include path parameters prefixed with `:`.
  final String route;

  /// Creates a new [EstradaRoute] with the given [route].
  const EstradaRoute({required this.route});
}
