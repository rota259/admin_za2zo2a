import 'package:flutter_test/flutter_test.dart';
import 'package:za2zo2a_admin/features/pricing/data/models/pricing_config.dart';

/// Captured from the live backend `GET /api/admin/pricing`.
Map<String, dynamic> _config() => {
      '_id': '6a55222b7e616e4bcaa1c6d2',
      'baseFare': 5,
      'pickupSurcharge': 2,
      'minFare': 15,
      'surgeMultiplier': 1.5,
      'waitingPerMin': 0.75,
      'cancellationFee': 10,
      'currency': 'EGP',
      'perKmTiers': [
        {'uptoKm': 5, 'pricePerKm': 2},
        {'uptoKm': 15, 'pricePerKm': 1.5},
        {'uptoKm': null, 'pricePerKm': 1},
      ],
      'updatedBy': '6a5517048b362575a4309c12',
    };

void main() {
  group('PricingConfig.fromJson', () {
    test('parses the real shape', () {
      final c = PricingConfig.fromJson(_config());
      expect(c.baseFare, 5);
      expect(c.pickupSurcharge, 2);
      expect(c.minFare, 15);
      expect(c.surgeMultiplier, 1.5);
      expect(c.waitingPerMin, 0.75);
      expect(c.cancellationFee, 10);
      expect(c.currency, 'EGP');
      expect(c.perKmTiers.length, 3);
      expect(c.perKmTiers.last.isOpenEnded, isTrue);
      expect(c.perKmTiers.first.uptoKm, 5);
      expect(c.perKmTiers.first.pricePerKm, 2);
    });
  });

  group('toUpdateJson (PUT body)', () {
    test('sends the mutable fields and omits currency', () {
      final body = PricingConfig.fromJson(_config()).toUpdateJson();
      expect(body.keys, containsAll(<String>[
        'baseFare', 'pickupSurcharge', 'minFare', 'surgeMultiplier',
        'waitingPerMin', 'cancellationFee', 'perKmTiers',
      ]));
      // The backend PUT does not accept currency.
      expect(body.containsKey('currency'), isFalse);
      final tiers = body['perKmTiers'] as List;
      expect(tiers.last, {'uptoKm': null, 'pricePerKm': 1});
    });
  });

  group('validationError (mirrors backend)', () {
    PricingConfig base() => PricingConfig.fromJson(_config());

    test('valid config → null', () {
      expect(base().validationError(), isNull);
    });

    test('surge below 1 is rejected', () {
      expect(base().copyWith(surgeMultiplier: 0.9).validationError(),
          contains('Surge'));
    });

    test('negative fare is rejected', () {
      expect(base().copyWith(baseFare: -1).validationError(), isNotNull);
    });

    test('empty tiers rejected', () {
      expect(base().copyWith(perKmTiers: const []).validationError(),
          contains('tier'));
    });

    test('negative per-km rate rejected', () {
      final c = base().copyWith(
          perKmTiers: [const PerKmTier(uptoKm: 5, pricePerKm: -2)]);
      expect(c.validationError(), isNotNull);
    });
  });

  group('dirty tracking via equality', () {
    test('editing a field makes the draft unequal to the original', () {
      final original = PricingConfig.fromJson(_config());
      final draft = original.copyWith(baseFare: 6);
      expect(draft == original, isFalse);
      expect(draft.copyWith(baseFare: 5) == original, isTrue);
    });

    test('editing a tier price makes it unequal', () {
      final original = PricingConfig.fromJson(_config());
      final tiers = [...original.perKmTiers];
      tiers[0] = tiers[0].copyWith(pricePerKm: 3);
      expect(original.copyWith(perKmTiers: tiers) == original, isFalse);
    });
  });
}
