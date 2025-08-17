import 'route.dart';

/// The result of a successful route match.
///
/// Contains:
/// - the matched [route] itself,
/// - extracted [paths] (dynamic segments from the URL),
/// - parsed [queries] (query string parameters).
///
/// Example:
/// ```dart
/// final result = estrada.match('v1/users/42?active=true');
/// print(result?.route.route); // "v1/users/:userId"
/// print(result?.paths);       // { "userId": "42" }
/// print(result?.queries);     // { "active": "true" }
/// ```
final class RouteResult<T extends EstradaRoute> {
  /// The matched route definition.
  final T route;

  /// Query string parameters extracted from the URL.
  ///
  /// Example: `/users/42?active=true` → `{ "active": "true" }`
  final Map<String, String> queries;

  /// Dynamic path parameters extracted from the URL.
  ///
  /// Example: route `users/:id` with request `/users/42` → `{ "id": "42" }`
  final Map<String, String> paths;

  /// Creates an immutable [RouteResult].
  const RouteResult({
    required this.route,
    this.paths = const {},
    this.queries = const {},
  });
}
