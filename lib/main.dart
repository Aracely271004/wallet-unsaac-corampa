import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_bootstrap.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/flaky_wallet_repository.dart';

/// Reto 3: `flutter run --dart-define=SIMULAR_ERROR=true` arranca con un
/// repositorio que falla la primera vez, para capturar carga, error y
/// recuperación con el botón «Reintentar».
const bool _simulateError = bool.fromEnvironment('SIMULAR_ERROR');

/// Punto de entrada de Wallet UNSAAC.
///
/// Orden obligatorio:
/// 1. `WidgetsFlutterBinding.ensureInitialized()` habilita los canales de
///    plataforma antes de tocar servicios nativos.
/// 2. La inicialización de Firebase se intenta antes de `runApp`, pero nunca
///    bloquea el arranque: si el proyecto aún no tiene credenciales, la app
///    abre en modo local con datos de demostración.
/// 3. Reto 1: el modo de tema guardado se lee antes de `runApp`. Así el primer
///    fotograma ya se pinta con el tema correcto y no hay un parpadeo de claro
///    a oscuro al abrir la app.
/// 4. `runApp` construye el árbol de widgets.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseStatus = await FirebaseBootstrap.initialize();

  final prefs = await SharedPreferences.getInstance();
  final themePreferences = SharedPrefsThemePreferences(prefs);
  final initialThemeMode = await themePreferences.loadMode();

  runApp(
    WalletApp(
      firebaseStatus: firebaseStatus,
      themePreferences: themePreferences,
      initialThemeMode: initialThemeMode,
      walletRepository: _simulateError ? FlakyWalletRepository() : null,
    ),
  );
}
