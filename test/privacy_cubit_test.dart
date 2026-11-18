import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_state.dart';

/// Pruebas del Reto 2: PrivacyCubit.
void main() {
  group('PrivacyCubit', () {
    test('inicia con los importes visibles', () {
      expect(PrivacyCubit().state, const PrivacyState(hidden: false));
    });

    blocTest<PrivacyCubit, PrivacyState>(
      'toggle oculta los importes',
      build: PrivacyCubit.new,
      act: (cubit) => cubit.toggle(),
      expect: () => const [PrivacyState(hidden: true)],
    );

    blocTest<PrivacyCubit, PrivacyState>(
      'un segundo toggle vuelve a mostrar los importes',
      build: PrivacyCubit.new,
      act: (cubit) {
        cubit.toggle();
        cubit.toggle();
      },
      expect: () => const [
        PrivacyState(hidden: true),
        PrivacyState(hidden: false),
      ],
    );

    blocTest<PrivacyCubit, PrivacyState>(
      'hide y show fijan el estado de forma explícita',
      build: PrivacyCubit.new,
      act: (cubit) {
        cubit.hide();
        cubit.show();
      },
      expect: () => const [
        PrivacyState(hidden: true),
        PrivacyState(hidden: false),
      ],
    );

    test('PrivacyState compara por valor', () {
      expect(const PrivacyState(hidden: true), const PrivacyState(hidden: true));
      expect(
        const PrivacyState().copyWith(hidden: true),
        const PrivacyState(hidden: true),
      );
    });
  });
}
