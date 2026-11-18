import 'package:flutter/material.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';

/// Opción de color semilla que se ofrece al usuario (Reto 4).
class SeedColorOption {
  const SeedColorOption(this.name, this.color);

  final String name;
  final Color color;
}

/// Colores disponibles en el selector. El primero es el institucional.
///
/// Solo se define la semilla: `ColorScheme.fromSeed` calcula primary,
/// surface, onPrimary y el resto de roles con contraste adecuado.
const List<SeedColorOption> seedColorOptions = [
  SeedColorOption('Granate UNSAAC', AppTheme.seed),
  SeedColorOption('Azul andino', Color(0xFF1F5FA8)),
  SeedColorOption('Verde quinua', Color(0xFF2E7D32)),
  SeedColorOption('Dorado inca', Color(0xFFC8932B)),
  SeedColorOption('Morado maíz', Color(0xFF6A1B9A)),
];
