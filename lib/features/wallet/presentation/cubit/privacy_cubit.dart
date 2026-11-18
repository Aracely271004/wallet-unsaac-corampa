import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_state.dart';

/// Cubit que decide si los importes se muestran u ocultan (Reto 2).
///
/// Los widgets no guardan esta bandera: la reciben como parámetro y avisan al
/// Cubit con un callback. El estado vive mientras la app está abierta.
class PrivacyCubit extends Cubit<PrivacyState> {
  PrivacyCubit() : super(const PrivacyState());

  void toggle() => emit(state.copyWith(hidden: !state.hidden));

  void hide() => emit(state.copyWith(hidden: true));

  void show() => emit(state.copyWith(hidden: false));
}
