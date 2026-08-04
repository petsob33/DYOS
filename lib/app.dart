import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/l10n/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'l10n/generated/app_localizations.dart';

class OurOSRoot extends ConsumerStatefulWidget {
  const OurOSRoot({super.key});

  @override
  ConsumerState<OurOSRoot> createState() => _OurOSRootState();
}

class _OurOSRootState extends ConsumerState<OurOSRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize push/local notifications globally (not only on Home screen).
      ref.read(notificationServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode =
        ref.watch(themeModeControllerProvider).valueOrNull ?? ThemeMode.system;
    final locale = ref.watch(localeControllerProvider).valueOrNull;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'OurOS',
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale != null) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == deviceLocale.languageCode) {
              return supported;
            }
          }
        }
        return const Locale('en');
      },
      routerConfig: router,
      builder: (context, child) {
        final textTheme = Theme.of(
          context,
        ).textTheme.apply(fontFamily: GoogleFonts.inter().fontFamily);
        return DefaultTextStyle(
          style: textTheme.bodyMedium ?? const TextStyle(),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
