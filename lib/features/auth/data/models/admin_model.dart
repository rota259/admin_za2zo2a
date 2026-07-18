import 'package:equatable/equatable.dart';

import '../../../../core/network/repository_base.dart';

/// The admin profile.
///
/// Shape differs between the two endpoints that return it, so parsing stays
/// tolerant (verified against the live backend):
///   POST /api/admin/auth/login → { id, name, email }        (no role)
///   GET  /api/admin/auth/me    → { id, name, email, role }
class AdminModel extends Equatable {
  const AdminModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  final String id;
  final String name;
  final String email;
  final String? role;

  factory AdminModel.fromJson(Map<String, dynamic> json) => AdminModel(
        id: json.str(['id', '_id']) ?? '',
        name: json.str(['name', 'fullName']) ?? '',
        email: json.str(['email']) ?? '',
        role: json.str(['role']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (role != null) 'role': role,
      };

  /// Initials for the top-bar avatar ("System Admin" → "SA").
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  List<Object?> get props => [id, name, email, role];
}
