import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contrato para guardar y recuperar el modo de tema (Reto 1).
///
/// El `ThemeCubit` depende de esta abstracción y no de `shared_preferences`.
/// Así se puede probar el Cubit con una implementación falsa y, si mañana el
/// modo se guarda en Firestore, solo cambia la implementación.
abstract interface class ThemePreferences {
  /// Devuelve el último modo guardado o [ThemeMode.system] si no hay ninguno
  /// o si el valor guardado no es válido.
  Future<ThemeMode> loadMode();

  /// Guarda [mode] para el siguiente arranque.
  Future<void> saveMode(ThemeMode mode);
}

/// Convierte el texto guardado en un [ThemeMode].
///
/// Cualquier valor nulo o desconocido (por ejemplo `'morado'`) se traduce a
/// [ThemeMode.system] en lugar de lanzar una excepción.
ThemeMode themeModeFromName(String? name) => ThemeMode.values.firstWhere(
  (mode) => mode.name == name,
  orElse: () => ThemeMode.system,
);

/// Implementación con `shared_preferences`.
///
/// Guarda el nombre del enum (`light`, `dark`, `system`) en lugar del índice:
/// si el orden de `ThemeMode` cambiara en una versión futura de Flutter, el
/// valor guardado seguiría siendo correcto.
class SharedPrefsThemePreferences implements ThemePreferences {
  SharedPrefsThemePreferences(this._prefs);

  static const String storageKey = 'wallet.theme_mode';

  final SharedPreferences _prefs;

  @override
  Future<ThemeMode> loadMode() async {
    try {
      return themeModeFromName(_prefs.getString(storageKey));
    } catch (_) {
      // Si la clave existe con otro tipo (por ejemplo un int), getString
      // lanza un error de tipo. Un valor corrupto nunca debe impedir el
      // arranque: se vuelve al modo del sistema.
      return ThemeMode.system;
    }
  }

  @override
  Future<void> saveMode(ThemeMode mode) async {
    await _prefs.setString(storageKey, mode.name);
  }
}
