import 'package:meta/meta.dart';

import 'route.dart';

/// Internal representation of a registered route.
///
/// This class is not intended to be used directly outside of the package.
/// It stores a compiled [pattern], split [segments], and the original [route].
///
/// Used by [Registry] to efficiently match incoming paths.
@internal
@immutable
class RouteInfo<T extends EstradaRoute> {
  /// The original route definition (extends [EstradaRoute]).
  final T route;

  /// Compiled regex pattern used for fast path matching.
  final RegExp pattern;

  /// List of path segments for this route (e.g. `['user', ':id']`).
  final List<String> segments;

  /// Creates a new immutable [RouteInfo].
  const RouteInfo({
    required this.pattern,
    required this.segments,
    required this.route,
  });

  @override
  String toString() => 'RouteInfo(${pattern.pattern})';
}
