# 🛣 Estrada

A blazing fast route matcher for Dart.  
Focuses only on **path + query parsing** — no servers, no DI, no middleware.  
You can compose it with any HTTP library, CLI tool, or custom framework.

---

## 🚀 Example

```dart
import 'package:estrada/estrada.dart';

class UserRoute extends EstradaRoute {
  const UserRoute({required super.route});
}

void main() {
  final estrada = Estrada<UserRoute>(
    routes: [
      const UserRoute(route: 'v1/users'),
      const UserRoute(route: 'v1/users/:userId'),
      const UserRoute(route: 'v1/tags/:tagId'),
      const UserRoute(route: 'v1/status'),
    ],
  );

  final samples = [
    'v1/users',
    'v1/users/42',
    'v1/users/42/posts',
    'v1/posts/99',
    'v1/posts/99/comments',
    'v1/tags',
    'v1/tags/123?q=hello',
    'v1/auth/login',
    'v1/auth/logout',
    'v1/status',
  ];

  for (final url in samples) {
    final result = estrada.match(url);
    if (result != null) {
      print('✅ $url → matched ${result.route.route}, '
          'paths: ${result.paths}, queries: ${result.queries}');
    } else {
      print('⛔ $url → not found');
    }
  }
}
```

Output:

```
✅ v1/users → matched v1/users, paths: {}, queries: {}
✅ v1/users/42 → matched v1/users/:userId, paths: {userId: 42}, queries: {}
⛔ v1/users/42/posts → not found
⛔ v1/posts/99 → not found
⛔ v1/posts/99/comments → not found
⛔ v1/tags → not found
✅ v1/tags/123?q=hello → matched v1/tags/:tagId, paths: {tagId: 123}, queries: {q: hello}
⛔ v1/auth/login → not found
⛔ v1/auth/logout → not found
✅ v1/status → matched v1/status, paths: {}, queries: {}
```

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  estrada: ^0.9.7
```

Then run:

```bash
dart pub get
```

---

## 🧱 Philosophy

Estrada does one thing: **route matching**.  
That’s it. No servers, no DI, no middleware.  
You can freely compose it with any HTTP library, CLI tool, or custom framework.

---
