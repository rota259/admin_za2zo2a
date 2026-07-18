import 'package:flutter/material.dart';

/// Gradient initials avatar, per the design's `avatar()` — the gradient hue is
/// picked deterministically from the name so a given driver always looks the
/// same. If a Cloudinary [photoUrl] exists it's shown instead.
class DriverAvatar extends StatelessWidget {
  const DriverAvatar({
    super.key,
    required this.name,
    required this.initials,
    this.photoUrl,
    this.size = 38,
  });

  final String name;
  final String initials;
  final String? photoUrl;
  final double size;

  static const _hues = [
    [Color(0xFF334155), Color(0xFF1E293B)],
    [Color(0xFF7C2D12), Color(0xFF9A3412)],
    [Color(0xFF155E75), Color(0xFF0E7490)],
    [Color(0xFF4C1D95), Color(0xFF5B21B6)],
    [Color(0xFF065F46), Color(0xFF047857)],
    [Color(0xFF831843), Color(0xFF9D174D)],
  ];

  @override
  Widget build(BuildContext context) {
    final radius = size >= 40 ? 12.0 : 10.0;
    final hue = name.isEmpty
        ? _hues.first
        : _hues[(name.codeUnitAt(0) + name.length) % _hues.length];

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-0.64, -1),
          end: const Alignment(0.64, 1),
          colors: [hue[0], hue[1]],
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: (photoUrl != null && photoUrl!.isNotEmpty)
          ? Image.network(
              photoUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _initials(),
            )
          : _initials(),
    );
  }

  Widget _initials() => Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      );
}
