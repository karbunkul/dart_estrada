import 'package:test/test.dart';
import 'package:estrada/estrada.dart';

final class Route extends EstradaRoute {
  const Route({required super.route});
}

void main() {
  group('Estrada', () {
    test('matches static route', () {
      final r = Estrada<Route>(routes: [const Route(route: 'v1/status')]);

      final res = r.match('v1/status');

      expect(res, isNotNull);
      expect(res!.route.route, 'v1/status');
      expect(res.paths, isEmpty);
      expect(res.queries, isEmpty);
    });

    test('matches param route & extracts path params', () {
      final r =
          Estrada<Route>(routes: [const Route(route: 'v1/users/:userId')]);

      final res = r.match('v1/users/42');

      expect(res, isNotNull);
      expect(res!.route.route, 'v1/users/:userId');
      expect(res.paths, {'userId': '42'});
    });

    test('parses query params', () {
      final r = Estrada<Route>(routes: [const Route(route: 'v1/tags/:tagId')]);

      final res = r.match('v1/tags/123?q=hello&page=2');

      expect(res, isNotNull);
      expect(res!.queries, {'q': 'hello', 'page': '2'});
      expect(res.paths, {'tagId': '123'});
    });

    test('returns null when no match', () {
      final r = Estrada<Route>(routes: [const Route(route: 'v1/users')]);

      final res = r.match('v1/unknown');

      expect(res, isNull);
    });

    test('prefers more specific route when ambiguous', () {
      final r = Estrada<Route>(
        routes: const [
          Route(route: 'user/:userId'),
          Route(route: 'user/123'),
        ],
      );

      final res = r.match('user/123');

      expect(res, isNotNull);
      expect(res!.route.route, 'user/123'); // static beats param
    });

    test('does not match different segment count', () {
      final r = Estrada<Route>(routes: const [
        Route(route: 'a/b'),
        Route(route: 'a/:x/b'),
      ]);

      expect(r.match('a'), isNull);
      expect(r.match('a/b/c/d'), isNull);
    });

    test('rejects duplicate routes at add time', () {
      final r = Estrada<Route>(routes: const [Route(route: 'v1/status')]);

      expect(
        () => r.addRoute(const Route(route: 'v1/status')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects routes starting with a param', () {
      final r = Estrada<Route>();

      expect(
        () => r.addRoute(const Route(route: ':id/user')),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('supports adding routes after construction', () {
      final r = Estrada<Route>();
      r.addRoute(const Route(route: 'alive'));

      final res = r.match('alive');

      expect(res, isNotNull);
      expect(res!.route.route, 'alive');
    });

    test('handles trailing and leading slashes', () {
      final r = Estrada<Route>(routes: const [
        Route(route: 'api/ping'),
        Route(route: 'api/:v/health'),
      ]);

      expect(r.match('/api/ping'), isNotNull);
      expect(r.match('api/ping/'), isNotNull);
      expect(r.match('/api/v1/health/'), isNotNull);
    });
  });
}
