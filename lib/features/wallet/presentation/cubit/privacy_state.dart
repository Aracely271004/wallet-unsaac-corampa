import 'package:equatable/equatable.dart';

/// Estado de privacidad de los importes (Reto 2).
///
/// Es un estado de presentación: no cambia los datos, solo cómo se muestran.
/// Por eso vive en `presentation/` y no en el dominio ni en el repositorio.
class PrivacyState extends Equatable {
  const PrivacyState({this.hidden = false});

  /// `true` cuando los importes deben mostrarse enmascarados.
  final bool hidden;

  PrivacyState copyWith({bool? hidden}) =>
      PrivacyState(hidden: hidden ?? this.hidden);

  @override
  List<Object?> get props => [hidden];
}
