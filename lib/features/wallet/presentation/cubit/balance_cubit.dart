import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_state.dart';

/// Cubit que carga el resumen de la billetera (Reto 3).
///
/// Reemplaza al `FutureBuilder` de la pantalla: aquí vive la llamada al
/// repositorio, el manejo de errores y el reintento. La pantalla solo dibuja
/// el estado que recibe.
class BalanceCubit extends Cubit<BalanceState> {
  BalanceCubit(this._repository) : super(const BalanceInitial());

  final WalletRepository _repository;

  static const String failureMessage =
      'No se pudo cargar el resumen de la billetera.';

  /// Carga inicial: muestra el indicador y consulta el repositorio.
  Future<void> load() async {
    emit(const BalanceLoading());
    await _fetch();
  }

  /// Botón «Reintentar»: mismo flujo que la carga inicial.
  Future<void> retry() => load();

  /// Deslizar para recargar: no emite `BalanceLoading` porque el
  /// `RefreshIndicator` ya muestra su propio indicador y así la lista no
  /// desaparece mientras se espera.
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    try {
      final summary = await _repository.loadSummary();
      // Mientras se esperaba, la pantalla pudo cerrarse. Emitir en un Cubit
      // cerrado lanza un StateError.
      if (isClosed) return;
      emit(BalanceSuccess(summary));
    } on Exception {
      if (isClosed) return;
      emit(const BalanceFailure(failureMessage));
    }
  }
}
