import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/seed_colors.dart';

/// Prueba de widget del Reto 4.
void main() {
  testWidgets('el selector aplica el color a toda la app y conserva el modo', (
    tester,
  ) async {
    final azul = seedColorOptions
        .firstWhere((option) => option.name == 'Azul andino')
        .color;

    await tester.pumpWidget(
      const WalletApp(
        firebaseStatus: FirebaseStatus.notConfigured(),
        initialThemeMode: ThemeMode.dark,
      ),
    );
    await tester.pumpAndSettle();

    MaterialApp app() =>
        tester.widget<MaterialApp>(find.byType(MaterialApp));

    await tester.tap(find.byTooltip('Cambiar color del tema'));
    await tester.pumpAndSettle();
    expect(find.text('Color del tema'), findsOneWidget);

    // Al abrir, el granate está marcado como activo.
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('Azul andino'));
    await tester.pumpAndSettle();

    expect(
      app().theme!.colorScheme.primary,
      ColorScheme.fromSeed(seedColor: azul).primary,
    );
    expect(
      app().darkTheme!.colorScheme.primary,
      ColorScheme.fromSeed(seedColor: azul, brightness: Brightness.dark).primary,
    );
    // El modo oscuro no se perdió y sigue habiendo un solo color marcado.
    expect(app().themeMode, ThemeMode.dark);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}
