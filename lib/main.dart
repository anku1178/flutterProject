import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/providers/auth_providers.dart';

void main() {
  runApp(const ProviderScope(child: GeneralStoreApp()));
}

class GeneralStoreApp extends ConsumerWidget {
  const GeneralStoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize storage service
    final storageInit = ref.watch(storageInitProvider);

    return storageInit.when(
      data: (_) => const _AppContent(),
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, _) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize app',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppContent extends ConsumerWidget {
  const _AppContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final appSettings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      title: 'General Store',
      debugShowCheckedModeBanner: false,
      theme: appSettings.theme == 'dark'
          ? AppTheme.darkTheme
          : AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
