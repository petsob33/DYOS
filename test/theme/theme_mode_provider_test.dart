import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ouros_app/core/theme/theme_mode_provider.dart';

void main() {
  test('defaults to ThemeMode.system when no preference saved', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final mode = await container.read(themeModeControllerProvider.future);

    expect(mode, ThemeMode.system);
  });

  test('loads a previously saved preference', () async {
    SharedPreferences.setMockInitialValues({'themeMode': 'dark'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final mode = await container.read(themeModeControllerProvider.future);

    expect(mode, ThemeMode.dark);
  });

  test('setMode updates state and persists the choice', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(themeModeControllerProvider.future);

    await container.read(themeModeControllerProvider.notifier).setMode(ThemeMode.dark);

    expect(container.read(themeModeControllerProvider).value, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('themeMode'), 'dark');
  });
}
