import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';

/// Repositorio de demostración que falla a propósito (Reto 3).
///
/// Las primeras [failures] llamadas lanzan una excepción y las siguientes
/// devuelven los datos de demostración. Sirve para las pruebas de reintento y
/// para capturar las evidencias de carga, error y recuperación:
///
/// ```bash
/// flutter run --dart-define=SIMULAR_ERROR=true
/// ```
class FlakyWalletRepository implements WalletRepository {
  FlakyWalletRepository({
    this.failures = 1,
    this.latency = const Duration(seconds: 2),
    WalletRepository? delegate,
  }) : _delegate = delegate ?? InMemoryWalletRepository(latency: Duration.zero);

  final int failures;
  final Duration latency;
  final WalletRepository _delegate;

  int _calls = 0;

  /// Número de veces que se llamó a [loadSummary].
  int get calls => _calls;

  @override
  Future<WalletSummary> loadSummary() async {
    _calls++;
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
    if (_calls <= failures) {
      throw Exception('Sin conexión (error simulado)');
    }
    return _delegate.loadSummary();
  }
}
