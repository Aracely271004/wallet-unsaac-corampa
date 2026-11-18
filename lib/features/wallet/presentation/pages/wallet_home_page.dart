import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_state.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_state.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/balance_card.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/firebase_status_card.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/movement_tile.dart';

/// Pantalla principal de Wallet UNSAAC (Sesión 1).
///
/// Muestra el resumen de la billetera y permite alternar el tema.
/// Reto 3: la pantalla ya no llama al repositorio ni usa `FutureBuilder`.
/// Escucha a `BalanceCubit` y dibuja cada estado (carga, éxito o error).
class WalletHomePage extends StatelessWidget {
  const WalletHomePage({super.key, required this.firebaseStatus});

  final FirebaseStatus firebaseStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Wallet UNSAAC',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ],
        ),
        actions: [
          // Reto 1: el icono y el tooltip reflejan el modo actual. Solo este
          // botón se reconstruye cuando cambia `mode`.
          BlocSelector<ThemeCubit, ThemeState, ThemeMode>(
            selector: (state) => state.mode,
            builder: (context, mode) {
              final (icon, tooltip) = switch (mode) {
                ThemeMode.light => (
                  Icons.light_mode_outlined,
                  'Tema claro · cambiar a oscuro',
                ),
                ThemeMode.dark => (
                  Icons.dark_mode_outlined,
                  'Tema oscuro · cambiar a sistema',
                ),
                ThemeMode.system => (
                  Icons.brightness_auto_outlined,
                  'Tema del sistema · cambiar a claro',
                ),
              };
              return IconButton(
                tooltip: tooltip,
                icon: Icon(icon),
                onPressed: () => context.read<ThemeCubit>().toggle(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<BalanceCubit, BalanceState>(
        builder: (context, state) => switch (state) {
          BalanceInitial() || BalanceLoading() => const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Cargando el resumen de la billetera',
            ),
          ),
          BalanceFailure(:final message) => _ErrorView(
            message: message,
            onRetry: () => context.read<BalanceCubit>().retry(),
          ),
          BalanceSuccess(:final summary) => RefreshIndicator(
            onRefresh: () => context.read<BalanceCubit>().refresh(),
            // Reto 2: la bandera de privacidad viene del PrivacyCubit.
            child: BlocBuilder<PrivacyCubit, PrivacyState>(
              builder: (context, privacy) => _SummaryView(
                summary: summary,
                hidden: privacy.hidden,
                firebaseStatus: firebaseStatus,
                onToggleVisibility: () =>
                    context.read<PrivacyCubit>().toggle(),
                onComingSoon: (feature) => _showComingSoon(context, feature),
              ),
            ),
          ),
        },
      ),
    );
  }
}

/// Contenido del estado de éxito: saldo, acciones y movimientos.
class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.summary,
    required this.hidden,
    required this.firebaseStatus,
    required this.onToggleVisibility,
    required this.onComingSoon,
  });

  final WalletSummary summary;
  final bool hidden;
  final FirebaseStatus firebaseStatus;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String> onComingSoon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          'Hola, estudiante UNSAAC',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Este es el resumen de tus finanzas en noviembre de 2026.',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        BalanceCard(
          summary: summary,
          hideBalance: hidden,
          onToggleVisibility: onToggleVisibility,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => onComingSoon('Registrar ingreso'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ingreso'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onComingSoon('Registrar egreso'),
                icon: const Icon(Icons.remove_rounded),
                label: const Text('Egreso'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                'Últimos movimientos',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => onComingSoon('El historial completo'),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (summary.isEmpty)
          const _EmptyMovements()
        else
          for (final movement in summary.movements) ...[
            MovementTile(movement: movement, hideAmount: hidden),
            const SizedBox(height: 10),
          ],
        const SizedBox(height: 12),
        FirebaseStatusCard(status: firebaseStatus),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Datos de demostración · Wallet UNSAAC 1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

void _showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('$feature se habilita en la Sesión 2.'),
        duration: const Duration(seconds: 2),
      ),
    );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: scheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Revisa la conexión y vuelve a intentarlo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMovements extends StatelessWidget {
  const _EmptyMovements();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            const Text('Todavía no registraste movimientos.'),
          ],
        ),
      ),
    );
  }
}
