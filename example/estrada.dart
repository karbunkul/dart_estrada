import 'package:estrada/estrada.dart';

final class Route extends EstradaRoute {
  final Function onRequest;

  Route({required super.route, required this.onRequest});
}

void main() {
  final routes = [
    // service
    Route(route: 'v1/health', onRequest: () => print('service alive')),
    Route(route: 'v1/status', onRequest: () => print('service status')),

    // users
    Route(route: 'v1/users', onRequest: () => print('list users')),
    Route(route: 'v1/users/:userId', onRequest: () => print('get user by id')),
    Route(
      route: 'v1/users/:userId/delete',
      onRequest: () => print('delete user'),
    ),
    Route(route: 'v1/users/:userId/edit', onRequest: () => print('edit user')),
    Route(
      route: 'v1/users/:userId/notes',
      onRequest: () => print('list user notes'),
    ),

    // notes
    Route(route: 'v1/notes', onRequest: () => print('list notes')),
    Route(route: 'v1/notes/create', onRequest: () => print('create note')),
    Route(route: 'v1/notes/:noteId', onRequest: () => print('get note')),
    Route(route: 'v1/notes/:noteId/edit', onRequest: () => print('edit note')),
    Route(
      route: 'v1/notes/:noteId/delete',
      onRequest: () => print('delete note'),
    ),

    // tags
    Route(route: 'v1/tags', onRequest: () => print('list tags')),
    Route(route: 'v1/tags/:tagId', onRequest: () => print('get tag')),
    Route(
      route: 'v1/tags/:tagId/notes',
      onRequest: () => print('list notes by tag'),
    ),
  ];

  var router = Estrada(routes: routes);

  final urls = [
    'v1/users',
    'v1/users/42',
    'v1/users/42/posts',
    'v1/posts/99',
    'v1/posts/99/comments',
    'v1/status?q=123',
    'v1/tags',
    'v1/tags/123',
    'v1/auth/login',
    'v1/auth/logout',
    'v1/status?q=1234',
  ];

  for (final url in urls) {
    final stopwatch = Stopwatch();
    stopwatch.start();
    final result = router.match(url);
    stopwatch.stop();

    if (result != null) {
      print(
        '⏱️ ${stopwatch.elapsedMicroseconds} μs url: $url, route: ${result.route.route}, queries: ${result.queries}, paths: ${result.paths}',
      );
    } else {
      print('⏱️ ${stopwatch.elapsedMicroseconds} μs url: $url not found');
    }
  }
}
