import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

/// `Cubit` que gobierna el tema claro/oscuro.
///
/// Un Cubit es un BLoC sin eventos explícitos: la interfaz invoca métodos y el
/// Cubit emite estados. Es la opción recomendada cuando la lógica es simple y
/// no requiere trazabilidad de eventos.
///
/// Reto 1: el modo inicial llega ya leído desde `main` y cada cambio se guarda
/// a través de [ThemePreferences]. Si no se inyectan preferencias (pruebas
/// antiguas), el Cubit funciona igual pero sin persistir.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({
    ThemeMode initialMode = ThemeMode.system,
    ThemePreferences? preferences,
  }) : _preferences = preferences,
       super(ThemeState(mode: initialMode));

  final ThemePreferences? _preferences;

  /// Recorre los modos en el orden claro → oscuro → sistema → claro.
  Future<void> toggle() => setMode(switch (state.mode) {
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
    ThemeMode.system => ThemeMode.light,
  });

  /// Emite el nuevo modo y luego lo guarda.
  ///
  /// Se emite primero para que la interfaz responda de inmediato; la escritura
  /// en disco ocurre después, con `await`, para que las pruebas puedan
  /// esperar a que termine.
  Future<void> setMode(ThemeMode mode) async {
    emit(state.copyWith(mode: mode));
    await _preferences?.saveMode(mode);
  }

  Future<void> useSystemMode() => setMode(ThemeMode.system);

  /// Reto 4: cambia el color semilla sin tocar el modo claro/oscuro.
  void setSeedColor(Color color) => emit(state.copyWith(seedColor: color));
}
