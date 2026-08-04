import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ouros_app/core/l10n/locale_provider.dart';

void main() {
  test('defaults to null (system) locale when no preference saved', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final locale = await container.read(localeControllerProvider.future);

    expect(locale, isNull);
  });

  test('loads a previously saved preference', () async {
    SharedPreferences.setMockInitialValues({'locale': 'cs'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final locale = await container.read(localeControllerProvider.future);

    expect(locale, const Locale('cs'));
  });

  test('setLocale updates state and persists the choice', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(localeControllerProvider.future);

    await container
        .read(localeControllerProvider.notifier)
        .setLocale(const Locale('cs'));

    expect(container.read(localeControllerProvider).value, const Locale('cs'));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('locale'), 'cs');
  });

  test('setLocale(null) clears the persisted preference', () async {
    SharedPreferences.setMockInitialValues({'locale': 'cs'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(localeControllerProvider.future);

    await container.read(localeControllerProvider.notifier).setLocale(null);

    expect(container.read(localeControllerProvider).value, isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('locale'), isNull);
  });
}
