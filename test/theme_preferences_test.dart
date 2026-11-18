import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';

/// Pruebas del Reto 1: tema persistente entre sesiones.
void main() {
  // shared_preferences usa un canal de plataforma; en pruebas se reemplaza
  // por un almacén en memoria con setMockInitialValues.
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPrefsThemePreferences> buildPreferences() async =>
      SharedPrefsThemePreferences(await SharedPreferences.getInstance());

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('SharedPrefsThemePreferences', () {
    test('sin valor guardado devuelve ThemeMode.system', () async {
      final preferences = await buildPreferences();

      expect(await preferences.loadMode(), ThemeMode.system);
    });

    test('guarda y recupera el modo elegido', () async {
      final preferences = await buildPreferences();

      await preferences.saveMode(ThemeMode.dark);

      expect(await preferences.loadMode(), ThemeMode.dark);
    });

    test('un texto desconocido se interpreta como ThemeMode.system', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SharedPrefsThemePreferences.storageKey: 'morado',
      });
      final preferences = await buildPreferences();

      expect(await preferences.loadMode(), ThemeMode.system);
    });

    test('un valor de otro tipo no rompe el arranque', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SharedPrefsThemePreferences.storageKey: 42,
      });
      final preferences = await buildPreferences();

      expect(await preferences.loadMode(), ThemeMode.system);
    });
  });

  group('themeModeFromName', () {
    test('reconoce los tres nombres válidos', () {
      expect(themeModeFromName('light'), ThemeMode.light);
      expect(themeModeFromName('dark'), ThemeMode.dark);
      expect(themeModeFromName('system'), ThemeMode.system);
    });

    test('nulo o desconocido devuelve system', () {
      expect(themeModeFromName(null), ThemeMode.system);
      expect(themeModeFromName(''), ThemeMode.system);
    });
  });

  group('ThemeCubit con persistencia', () {
    test('cada cambio se guarda y sobrevive a un reinicio simulado', () async {
      final preferences = await buildPreferences();
      final cubit = ThemeCubit(
        initialMode: await preferences.loadMode(),
        preferences: preferences,
      );

      await cubit.toggle(); // system → light
      await cubit.toggle(); // light → dark
      await cubit.close();

      // "Reabrir la app": un Cubit nuevo que lee lo guardado, como en main.
      final reopened = ThemeCubit(
        initialMode: await preferences.loadMode(),
        preferences: preferences,
      );

      expect(reopened.state.mode, ThemeMode.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(SharedPrefsThemePreferences.storageKey), 'dark');
      await reopened.close();
    });
  });
}
