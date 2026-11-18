import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/theme/seed_colors.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

/// Hoja inferior para elegir el color semilla del tema (Reto 4).
///
/// La hoja no guarda qué color está activo: cada muestra lo pregunta al
/// `ThemeCubit` con un `BlocSelector`, de modo que al elegir un color solo se
/// reconstruyen los indicadores de selección.
class SeedColorSheet extends StatelessWidget {
  const SeedColorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const SeedColorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Color del tema',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Se aplica a toda la app, en modo claro y oscuro.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final option in seedColorOptions)
                  _SeedSwatch(option: option),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeedSwatch extends StatelessWidget {
  const _SeedSwatch({required this.option});

  final SeedColorOption option;

  @override
  Widget build(BuildContext context) {
    // Solo esta muestra se reconstruye cuando cambia si está seleccionada.
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.seedColor == option.color,
      builder: (context, selected) {
        final scheme = Theme.of(context).colorScheme;
        final borderColor = selected ? scheme.onSurface : Colors.transparent;
        // El check se dibuja blanco o negro según lo oscuro que sea el color.
        final checkColor =
            ThemeData.estimateBrightnessForColor(option.color) ==
                Brightness.dark
            ? Colors.white
            : Colors.black;

        return MergeSemantics(
          child: Semantics(
            button: true,
            selected: selected,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.read<ThemeCubit>().setSeedColor(option.color),
              child: SizedBox(
                width: 76,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: option.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 3),
                      ),
                      child: selected
                          ? Icon(Icons.check_rounded, color: checkColor)
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
