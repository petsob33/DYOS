import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouros_app/core/theme/app_theme.dart';

void main() {
  testWidgets('context.colors resolves AppPalette.light under AppTheme.light', (tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) {
          capturedContext = context;
          return const SizedBox();
        },
      ),
    ));

    expect(capturedContext.colors.background, AppPalette.light.background);
    expect(capturedContext.colors.primary, AppPalette.light.primary);
  });

  testWidgets('context.colors resolves AppPalette.dark under AppTheme.dark', (tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark,
      home: Builder(
        builder: (context) {
          capturedContext = context;
          return const SizedBox();
        },
      ),
    ));

    expect(capturedContext.colors.background, AppPalette.dark.background);
    expect(capturedContext.colors.background, isNot(AppPalette.light.background));
  });
}
