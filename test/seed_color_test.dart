import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/seed_colors.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

/// Pruebas del Reto 4: color semilla configurable.
void main() {
  const azul = Color(0xFF1F5FA8);

  group('ThemeState con seedColor', () {
    test('por defecto usa el granate institucional', () {
      expect(const ThemeState().seedColor, AppTheme.seed);
    });

    test('seedColor participa en la igualdad del estado', () {
      expect(const ThemeState(seedColor: azul), const ThemeState(seedColor: azul));
      expect(const ThemeState(seedColor: azul), isNot(const ThemeState()));
      expect(const ThemeState().props, [ThemeMode.system, AppTheme.seed]);
    });
  });

  group('ThemeCubit.setSeedColor', () {
    blocTest<ThemeCubit, ThemeState>(
      'cambia el color sin perder el modo oscuro',
      build: () => ThemeCubit(initialMode: ThemeMode.dark),
      act: (cubit) => cubit.setSeedColor(azul),
      expect: () => const [ThemeState(mode: ThemeMode.dark, seedColor: azul)],
    );

    blocTest<ThemeCubit, ThemeState>(
      'el botón de tema y el color conviven: toggle conserva la semilla',
      build: ThemeCubit.new,
      act: (cubit) async {
        cubit.setSeedColor(azul);
        await cubit.toggle(); // system → light
      },
      expect: () => const [
        ThemeState(seedColor: azul),
        ThemeState(mode: ThemeMode.light, seedColor: azul),
      ],
    );
  });

  group('AppTheme parametrizado', () {
    for (final brightness in Brightness.values) {
      test('el primary coincide con ColorScheme.fromSeed ($brightness)', () {
        final theme = brightness == Brightness.light
            ? AppTheme.light(seedColor: azul)
            : AppTheme.dark(seedColor: azul);
        final expected = ColorScheme.fromSeed(
          seedColor: azul,
          brightness: brightness,
        );

        expect(theme.colorScheme.primary, expected.primary);
        expect(theme.colorScheme.brightness, brightness);
      });
    }

    test('cambiar la semilla cambia el primary', () {
      expect(
        AppTheme.light(seedColor: azul).colorScheme.primary,
        isNot(AppTheme.light().colorScheme.primary),
      );
    });

    test('hay al menos cuatro colores y no se repiten', () {
      final colors = seedColorOptions.map((option) => option.color).toSet();

      expect(seedColorOptions.length, greaterThanOrEqualTo(4));
      expect(colors, hasLength(seedColorOptions.length));
      expect(seedColorOptions.first.color, AppTheme.seed);
    });
  });
}
