import 'package:equatable/equatable.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';

/// Estados del resumen de la billetera (Reto 3).
///
/// La jerarquía es `sealed`: el compilador conoce todos los subtipos y obliga
/// a la interfaz a cubrir cada caso en un `switch`. Si mañana se agrega un
/// estado nuevo, la pantalla no compila hasta que lo trate.
sealed class BalanceState extends Equatable {
  const BalanceState();

  @override
  List<Object?> get props => const [];
}

/// Antes de la primera carga.
final class BalanceInitial extends BalanceState {
  const BalanceInitial();
}

/// Esperando la respuesta del repositorio.
final class BalanceLoading extends BalanceState {
  const BalanceLoading();
}

/// El repositorio respondió con un resumen.
final class BalanceSuccess extends BalanceState {
  const BalanceSuccess(this.summary);

  final WalletSummary summary;

  @override
  List<Object?> get props => [summary];
}

/// El repositorio falló; [message] es un texto comprensible para el usuario.
final class BalanceFailure extends BalanceState {
  const BalanceFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
