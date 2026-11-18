import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/flaky_wallet_repository.dart';

/// Pruebas de widget del Reto 3.
void main() {
  testWidgets('muestra el indicador de carga y luego el resumen (éxito)', (
    tester,
  ) async {
    await tester.pumpWidget(
      const WalletApp(firebaseStatus: FirebaseStatus.notConfigured()),
    );

    // El repositorio en memoria tarda 350 ms: primero se ve la carga.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('S/ 1,274.60'), findsOneWidget);
    expect(find.text('Sueldo de prácticas'), findsOneWidget);
  });

  testWidgets('el error muestra Reintentar y el reintento recupera los datos', (
    tester,
  ) async {
    await tester.pumpWidget(
      WalletApp(
        firebaseStatus: const FirebaseStatus.notConfigured(),
        walletRepository: FlakyWalletRepository(
          failures: 1,
          latency: Duration.zero,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudo cargar el resumen de la billetera.'),
      findsOneWidget,
    );
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Reintentar'), findsNothing);
    expect(find.text('S/ 1,274.60'), findsOneWidget);
  });
}
