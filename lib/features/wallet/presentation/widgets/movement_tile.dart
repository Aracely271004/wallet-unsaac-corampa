import 'package:flutter/material.dart';
import 'package:wallet_unsaac/core/utils/money.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';

/// Fila de un movimiento financiero.
///
/// Reto 2: [hideAmount] enmascara el importe. El título, la categoría y la
/// fecha siguen visibles porque no revelan cuánto dinero hay.
class MovementTile extends StatelessWidget {
  const MovementTile({
    super.key,
    required this.movement,
    this.hideAmount = false,
  });

  final Movement movement;
  final bool hideAmount;

  static const String mask = '••••';

  static const Color _incomeLight = Color(0xFF2E7D32);
  static const Color _incomeDark = Color(0xFF81C784);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = movement.isIncome
        ? (isDark ? _incomeDark : _incomeLight)
        : scheme.error;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: 0.12),
          child: Icon(
            movement.isIncome
                ? Icons.south_west_rounded
                : Icons.north_east_rounded,
            color: accent,
            size: 20,
          ),
        ),
        title: Text(
          movement.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${movement.category} · ${formatShortDate(movement.date)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          hideAmount
              ? mask
              : '${movement.isIncome ? '+' : '-'} '
                    '${MoneyFormat.soles(movement.amount)}',
          semanticsLabel: hideAmount ? 'Importe oculto' : null,
          style: TextStyle(color: accent, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
