import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/balance_card.dart';

/// Prueba de widget del Reto 2: el ojo oculta y restaura todos los importes.
void main() {
  testWidgets('el botón de ojo oculta y muestra todos los importes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const WalletApp(firebaseStatus: FirebaseStatus.notConfigured()),
    );
    await tester.pumpAndSettle();

    // Visibles: saldo, ingresos, egresos y el primer movimiento.
    expect(find.text('S/ 1,274.60'), findsOneWidget);
    expect(find.text('S/ 1,770.00'), findsOneWidget);
    expect(find.text('S/ 495.40'), findsOneWidget);
    expect(find.text('+ S/ 1,200.00'), findsOneWidget);

    await tester.tap(find.byTooltip('Ocultar saldo'));
    await tester.pumpAndSettle();

    // Ocultos: ningún importe real queda en pantalla.
    expect(find.text('S/ 1,274.60'), findsNothing);
    expect(find.text('S/ 1,770.00'), findsNothing);
    expect(find.text('S/ 495.40'), findsNothing);
    expect(find.text('+ S/ 1,200.00'), findsNothing);
    expect(find.text(BalanceCard.mask), findsNWidgets(3));
    expect(find.byTooltip('Mostrar saldo'), findsOneWidget);

    await tester.tap(find.byTooltip('Mostrar saldo'));
    await tester.pumpAndSettle();

    // Restaurados con los valores exactos, sin recargar el repositorio.
    expect(find.text('S/ 1,274.60'), findsOneWidget);
    expect(find.text('+ S/ 1,200.00'), findsOneWidget);
    expect(find.byTooltip('Ocultar saldo'), findsOneWidget);
  });
}
