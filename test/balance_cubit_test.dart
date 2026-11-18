import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/flaky_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_state.dart';

/// Repositorio que siempre falla, para probar la rama de error sin emulador.
class _FailingRepository implements WalletRepository {
  int calls = 0;

  @override
  Future<WalletSummary> loadSummary() async {
    calls++;
    throw Exception('sin conexión');
  }
}

/// Pruebas del Reto 3: BalanceCubit con estados de carga, éxito y error.
void main() {
  InMemoryWalletRepository fastRepository() =>
      InMemoryWalletRepository(latency: Duration.zero);

  group('BalanceCubit', () {
    test('inicia en BalanceInitial, sin consultar el repositorio', () {
      final repository = _FailingRepository();
      final cubit = BalanceCubit(repository);

      expect(cubit.state, const BalanceInitial());
      expect(repository.calls, 0);
    });

    blocTest<BalanceCubit, BalanceState>(
      'éxito: emite BalanceLoading y luego BalanceSuccess con el resumen',
      build: () => BalanceCubit(fastRepository()),
      act: (cubit) => cubit.load(),
      expect: () => [
        const BalanceLoading(),
        isA<BalanceSuccess>()
            .having((s) => s.summary.movements, 'movimientos', hasLength(7))
            .having((s) => s.summary.balance, 'saldo', closeTo(1274.60, 0.001)),
      ],
    );

    blocTest<BalanceCubit, BalanceState>(
      'fallo: emite BalanceLoading y luego BalanceFailure con un mensaje',
      build: () => BalanceCubit(_FailingRepository()),
      act: (cubit) => cubit.load(),
      expect: () => const [
        BalanceLoading(),
        BalanceFailure(BalanceCubit.failureMessage),
      ],
    );

    late FlakyWalletRepository flaky;
    blocTest<BalanceCubit, BalanceState>(
      'reintento: tras un fallo vuelve a consultar el repositorio y se recupera',
      build: () {
        flaky = FlakyWalletRepository(failures: 1, latency: Duration.zero);
        return BalanceCubit(flaky);
      },
      act: (cubit) async {
        await cubit.load();
        await cubit.retry();
      },
      expect: () => [
        const BalanceLoading(),
        const BalanceFailure(BalanceCubit.failureMessage),
        const BalanceLoading(),
        isA<BalanceSuccess>(),
      ],
      verify: (_) => expect(flaky.calls, 2),
    );

    late _FailingRepository failing;
    blocTest<BalanceCubit, BalanceState>(
      'reintento con fallo persistente vuelve a mostrar el error',
      build: () {
        failing = _FailingRepository();
        return BalanceCubit(failing);
      },
      act: (cubit) async {
        await cubit.load();
        await cubit.retry();
      },
      expect: () => const [
        BalanceLoading(),
        BalanceFailure(BalanceCubit.failureMessage),
        BalanceLoading(),
        BalanceFailure(BalanceCubit.failureMessage),
      ],
      verify: (_) => expect(failing.calls, 2),
    );

    blocTest<BalanceCubit, BalanceState>(
      'refresh recarga sin volver a BalanceLoading',
      build: () => BalanceCubit(fastRepository()),
      act: (cubit) async {
        await cubit.load();
        await cubit.refresh();
      },
      expect: () => [
        const BalanceLoading(),
        isA<BalanceSuccess>(),
        isA<BalanceSuccess>(),
      ],
    );

    test('no emite después de cerrar el Cubit (isClosed)', () async {
      final cubit = BalanceCubit(
        InMemoryWalletRepository(latency: const Duration(milliseconds: 50)),
      );

      final pending = cubit.load();
      await cubit.close();

      // Sin la verificación de isClosed, emit lanzaría un StateError aquí.
      await expectLater(pending, completes);
    });
  });
}
