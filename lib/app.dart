import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class OurOSRoot extends ConsumerWidget {
  const OurOSRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'OurOS',
      themeMode: ThemeMode.light,
      theme: AppTheme.light,
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
