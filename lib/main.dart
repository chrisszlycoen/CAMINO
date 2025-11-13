import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CaminoApp(),
    ),
  ); 
}

class CaminoApp extends ConsumerWidget {
  const CaminoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For this build, we use ThemeMode.system
    // But Parent routes will force Light Theme, Student/Staff will force Dark Theme
    // within their respective scaffolds if needed. For now, general theme setup.
    return MaterialApp.router(
      title: 'CAMINO',

      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeProvider),
      routerConfig: appRouter,
    );
  }
}
