import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/realtime/realtime_sync_controller.dart';
import 'router/app_router.dart';
import 'theme/luqmah_theme.dart';
import 'theme/theme_mode_controller.dart';

class LuqmahApp extends ConsumerWidget {
  const LuqmahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider).mode;
    ref.watch(realtimeSyncControllerProvider);

    return MaterialApp.router(
      title: 'Luqmah',
      debugShowCheckedModeBanner: false,
      theme: buildLuqmahTheme(),
      darkTheme: buildLuqmahDarkTheme(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
