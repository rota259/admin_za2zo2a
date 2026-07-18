import 'package:flutter/material.dart';

/// The five document types the backend tracks per driver, in review order.
/// Keys match the backend `documents.<key>` and the `:docType` route param.
enum DocType {
  drivingLicense('drivingLicense', 'Driving License', Icons.badge_outlined),
  carLicense('carLicense', 'Car License', Icons.directions_car_outlined),
  nationalId('nationalId', 'National ID', Icons.contact_page_outlined),
  criminalRecord('criminalRecord', 'Criminal Record', Icons.gavel_outlined),
  profilePhoto('profilePhoto', 'Profile Photo', Icons.person_outline);

  const DocType(this.key, this.label, this.icon);

  final String key;
  final String label;
  final IconData icon;

  static DocType? fromKey(String key) {
    for (final t in values) {
      if (t.key == key) return t;
    }
    return null;
  }
}

/// One driver document: its review status and (when uploaded) its Cloudinary
/// image URL. The backend returns `url` only once the driver has uploaded it.
class DriverDocument {
  const DriverDocument({
    required this.type,
    required this.status,
    this.url,
  });

  final DocType type;

  /// "pending" | "submitted" | "approved" | "rejected".
  final String status;

  /// Cloudinary URL, or null when nothing has been uploaded yet.
  final String? url;

  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get hasImage => url != null && url!.isNotEmpty;

  factory DriverDocument.fromJson(DocType type, Map<String, dynamic>? json) {
    return DriverDocument(
      type: type,
      status: (json?['status'] as String?) ?? 'pending',
      url: json?['url'] as String?,
    );
  }

  DriverDocument copyWith({String? status}) => DriverDocument(
        type: type,
        status: status ?? this.status,
        url: url,
      );
}
