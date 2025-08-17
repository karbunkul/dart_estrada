import 'package:meta/meta.dart';

import 'route.dart';
import 'route_info.dart';
import 'route_result.dart';

/// Internal registry that stores and resolves routes.
///
/// This is the core engine behind [Estrada].
/// - Keeps a map of routes indexed by their segment count.
/// - Provides fast lookup for incoming requests.
/// - Ensures routes are unique and valid.
@internal
final class Registry<T extends EstradaRoute> {
  /// Registry organized by number of path segments.
  ///
  /// Example:
  /// - `v1/users` -> 2 segments
  /// - `v1/users/:userId` -> 3 segments
  final Map<int, List<RouteInfo<T>>> _registry = {};

  /// A flat set of all registered patterns, used to prevent duplicates.
  final Set<String> _routes = {};

  /// Adds a new [route] into the registry.
  ///
  /// Throws [ArgumentError] if:
  /// - route starts with a dynamic variable (e.g. `:id`),
  /// - route with the same pattern already exists.
  void add(T route) {
    final urlPattern =
        _normalizePath(route.route).replaceFirst(RegExp(r'\?.*'), '');

    if (urlPattern.startsWith(':')) {
      throw ArgumentError('Route cannot start with dynamic variable');
    }

    if (_routes.contains(urlPattern)) {
      throw ArgumentError('Route "${route.route}" already exists in registry');
    }

    final segments = urlPattern.split('/');
    final count = segments.length;
    final pattern = RegExp(
      '^${urlPattern.replaceAllMapped(RegExp(r':[^/]+'), (match) => '([^/]+)')}\$',
    );

    final node = _registry[count];

    if (node == null) {
      _registry[count] = <RouteInfo<T>>[];
    }

    final info = RouteInfo(pattern: pattern, segments: segments, route: route);

    _registry[count]!.add(info);
    _routes.add(urlPattern);
  }

  /// Normalizes a path by:
  /// - trimming whitespace from both ends
  /// - removing the leading `/`
  /// - removing the trailing `/`
  ///
  /// Example:
  /// ```dart
  /// _normalizePath('/api/ping/') // -> 'api/ping'
  /// _normalizePath('  /v1/users  ') // -> 'v1/users'
  /// ```
  String _normalizePath(String value) {
    return value
        .trim()
        .replaceFirst(RegExp(r'^/'), '')
        .replaceFirst(RegExp(r'\/$'), '');
  }

  /// Resolves an incoming [path] into a [RouteResult].
  ///
  /// - Returns `null` if no match is found.
  /// - Automatically strips trailing slash (`/`) and parses query parameters.
  RouteResult<T>? resolve({required String path}) {
    final q = path.indexOf('?');
    final hasQuery = q != -1;

    final rawPath = hasQuery ? path.substring(0, q) : path;
    final clearedPath = _normalizePath(rawPath);
    final segments =
        clearedPath.isEmpty ? const <String>[] : clearedPath.split('/');

    final count = segments.length;

    if (_registry[count] == null) {
      return null;
    }

    // First filter: only routes that share the same first segment.
    final node = _registry[count]!.where(
      (e) => e.segments.first == segments.first,
    );

    final candidates = <RouteInfo<T>>[];

    for (final route in node) {
      if (route.pattern.hasMatch(clearedPath)) {
        candidates.add(route);
      }
    }

    final queries = hasQuery ? _parseQs(path, q + 1) : const <String, String>{};

    return _findRoute(
      segments: segments,
      candidates: candidates,
      queries: queries,
    );
  }

  /// Parses a query string into a map of key–value pairs.
  ///
  /// - [s] is the full URL string (or its query part).
  /// - [start] is the index in [s] where the query string begins (typically after `?`).
  ///
  /// The method:
  ///  * Iterates through the string looking for `&` and `=`.
  ///  * Decodes percent-encoded keys and values using [Uri.decodeQueryComponent].
  ///  * Stores the result in a map where duplicate keys overwrite previous values.
  ///
  /// Returns an empty map if there are no query parameters.
  Map<String, String> _parseQs(String s, int start) {
    if (start >= s.length) return const {};
    final out = <String, String>{};
    var i = start;

    while (i < s.length) {
      final amp = s.indexOf('&', i);
      final eq = s.indexOf('=', i);
      final end = amp == -1 ? s.length : amp;
      if (eq != -1 && eq < end) {
        final k = Uri.decodeQueryComponent(s.substring(i, eq));
        final v = Uri.decodeQueryComponent(s.substring(eq + 1, end));
        out[k] = v;
      }
      i = end + 1;
    }
    return out;
  }

  /// Picks the best candidate among matched routes.
  ///
  /// - If only one candidate → return immediately.
  /// - If multiple → choose by [_calcSuggestedWeight].
  RouteResult<T>? _findRoute({
    required List<String> segments,
    required List<RouteInfo<T>> candidates,
    required Map<String, String> queries,
  }) {
    if (candidates.isEmpty) {
      return null;
    }

    if (candidates.length == 1) {
      final route = candidates.first;
      return RouteResult<T>(
        route: route.route,
        queries: queries,
        paths: _parsePaths(segments: segments, route: route),
      );
    }

    candidates.sort((a, b) {
      final aWeight = _calcSuggestedWeight(segments: segments, route: a);
      final bWeight = _calcSuggestedWeight(segments: segments, route: b);
      return bWeight.compareTo(aWeight);
    });
    final best = candidates.first;

    return RouteResult<T>(
      route: best.route,
      queries: queries,
      paths: _parsePaths(segments: segments, route: best),
    );
  }

  /// Extracts dynamic variables from the path.
  ///
  /// Example:
  /// - Route: `user/:id`
  /// - Request: `/user/42`
  /// → `{ 'id': '42' }`
  Map<String, String> _parsePaths({
    required List<String> segments,
    required RouteInfo<T> route,
  }) {
    final res = <String, String>{};

    for (var i = 0; i < segments.length; i++) {
      if (route.segments[i].startsWith(':')) {
        res[route.segments[i].substring(1)] = segments[i];
      }
    }

    return res;
  }

  /// Calculates a "weight" for candidate route based on similarity.
  ///
  /// - Exact match → +400
  /// - Dynamic segment (e.g. `:id`) → +100
  /// - Mismatch → -400
  int _calcSuggestedWeight({
    required List<String> segments,
    required RouteInfo<T> route,
  }) {
    var weight = 0;
    for (var i = 0; i < segments.length; i++) {
      final seg = route.segments[i];
      if (segments[i] == seg) {
        weight += 400;
      } else if (seg.isNotEmpty && seg.codeUnitAt(0) == 58) {
        // seg starts with ':' (ASCII 58)
        weight += 100;
      } else {
        weight -= 400;
      }
    }
    return weight;
  }
}
