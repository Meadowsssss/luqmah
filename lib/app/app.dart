import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/luqmah_theme.dart';

class LuqmahApp extends ConsumerWidget {
  const LuqmahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Luqmah',
      debugShowCheckedModeBanner: false,
      theme: buildLuqmahTheme(),
      routerConfig: router,
    );
  }
}
