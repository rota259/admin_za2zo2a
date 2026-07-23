import '../../../../core/network/repository_base.dart';

/// The trimmed rider/driver ref embedded on a trip.
class TripPerson {
  const TripPerson({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.profilePhoto,
  });

  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? profilePhoto;

  String get initials {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  static TripPerson? fromJsonOrNull(Map<String, dynamic>? json) {
    if (json == null) return null;
    return TripPerson(
      id: json.str(['_id', 'id']) ?? '',
      fullName: json.str(['fullName']) ?? '—',
      phone: json.str(['phone']) ?? '',
      email: json.str(['email']),
      profilePhoto: json.str(['profilePhoto']),
    );
  }
}

/// An origin/destination point.
class TripPlace {
  const TripPlace({required this.address, this.lat, this.lng});

  final String address;
  final double? lat;
  final double? lng;

  factory TripPlace.fromJson(Map<String, dynamic>? json) {
    final coords = json?.mapField(['coordinates']);
    return TripPlace(
      address: json?.str(['address']) ?? '—',
      lat: coords?.dbl(['lat']) ?? json?.dbl(['lat']),
      lng: coords?.dbl(['lng']) ?? json?.dbl(['lng']),
    );
  }
}

/// The fare breakdown. List rows only ever populate [total]/[surgeMultiplier];
/// the detail endpoint fills in the rest.
class TripFare {
  const TripFare({
    required this.total,
    this.surgeMultiplier,
    this.baseFare,
    this.distanceFare,
    this.timeFare,
    this.bookingFee,
    this.discount,
  });

  final double total;
  final double? surgeMultiplier;
  final double? baseFare;
  final double? distanceFare;
  final double? timeFare;
  final double? bookingFee;
  final double? discount;

  factory TripFare.fromJson(Map<String, dynamic>? json) => TripFare(
        total: json?.dbl(['total']) ?? 0,
        surgeMultiplier: json?.dbl(['surgeMultiplier']),
        baseFare: json?.dbl(['baseFare']),
        distanceFare: json?.dbl(['distanceFare']),
        timeFare: json?.dbl(['timeFare']),
        bookingFee: json?.dbl(['bookingFee']),
        discount: json?.dbl(['discount']),
      );
}

class TripPayment {
  const TripPayment({required this.method, required this.status, this.transactionId});

  final String method;
  final String status;
  final String? transactionId;

  factory TripPayment.fromJson(Map<String, dynamic>? json) => TripPayment(
        method: json?.str(['method']) ?? '—',
        status: json?.str(['status']) ?? '—',
        transactionId: json?.str(['transactionId']),
      );
}

/// Present only once an admin has manually overridden the fare (§2.3).
class TripFareOverride {
  const TripFareOverride({
    required this.previousTotal,
    required this.newTotal,
    required this.reason,
    this.at,
  });

  final double previousTotal;
  final double newTotal;
  final String reason;
  final DateTime? at;

  static TripFareOverride? fromJsonOrNull(Map<String, dynamic>? json) {
    if (json == null) return null;
    return TripFareOverride(
      previousTotal: json.dbl(['previousTotal']) ?? 0,
      newTotal: json.dbl(['newTotal']) ?? 0,
      reason: json.str(['reason']) ?? '',
      at: json.date(['at']),
    );
  }
}

/// A trip, parsed from `GET /api/admin/trips` / `/trips/:id`.
class TripModel {
  const TripModel({
    required this.id,
    required this.status,
    required this.rider,
    required this.origin,
    required this.destination,
    required this.fare,
    required this.requestedAt,
    this.driver,
    this.distanceKm,
    this.estimatedDurationMin,
    this.actualDurationMin,
    this.payment,
    this.riderRating,
    this.driverRating,
    this.cancellationReason,
    this.cancelledBy,
    this.fareOverride,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
  });

  final String id;

  /// `requested`|`matching`|`accepted`|`driver_en_route`|`arrived`|
  /// `in_progress`|`completed`|`cancelled`.
  final String status;
  final TripPerson rider;
  final TripPerson? driver;
  final TripPlace origin;
  final TripPlace destination;
  final TripFare fare;
  final double? distanceKm;
  final int? estimatedDurationMin;
  final int? actualDurationMin;
  final TripPayment? payment;
  final num? riderRating;
  final num? driverRating;
  final String? cancellationReason;
  final String? cancelledBy;
  final TripFareOverride? fareOverride;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final riderJson = json.mapField(['rider']);
    return TripModel(
      id: json.str(['_id', 'id']) ?? '',
      status: json.str(['status']) ?? 'requested',
      rider: TripPerson.fromJsonOrNull(riderJson) ??
          const TripPerson(id: '', fullName: '—', phone: ''),
      driver: TripPerson.fromJsonOrNull(json.mapField(['driver'])),
      origin: TripPlace.fromJson(json.mapField(['origin'])),
      destination: TripPlace.fromJson(json.mapField(['destination'])),
      fare: TripFare.fromJson(json.mapField(['fare'])),
      distanceKm: json.dbl(['distanceKm']),
      estimatedDurationMin: json.integer(['estimatedDurationMin']),
      actualDurationMin: json.integer(['actualDurationMin']),
      payment: json.mapField(['payment']) == null
          ? null
          : TripPayment.fromJson(json.mapField(['payment'])),
      riderRating: json['riderRating'] as num?,
      driverRating: json['driverRating'] as num?,
      cancellationReason: json.str(['cancellationReason']),
      cancelledBy: json.str(['cancelledBy']),
      fareOverride: TripFareOverride.fromJsonOrNull(json.mapField(['fareOverride'])),
      requestedAt: json.date(['requestedAt']) ?? DateTime.now(),
      acceptedAt: json.date(['acceptedAt']),
      startedAt: json.date(['startedAt']),
      completedAt: json.date(['completedAt']),
      cancelledAt: json.date(['cancelledAt']),
    );
  }

  String get statusLabel => status
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
