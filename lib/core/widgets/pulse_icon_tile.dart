import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../util/ambient_motion.dart';

/// A rounded icon tile with a slow "breathing" glow ring behind it — the small
/// ambient touch on empty and error states so they don't read as flat.
///
/// Cheap: only opacity + scale animate, and the loop is slow (3.4s).
class PulseIconTile extends StatefulWidget {
  const PulseIconTile({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  State<PulseIconTile> createState() => _PulseIconTileState();
}

class _PulseIconTileState extends State<PulseIconTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );

  late final Animation<double> _pulse =
      CurvedAnimation(parent: _c, curve: Curves.easeInOut);

  @override
  void initState() {
    super.initState();
    if (AmbientMotion.enabled) _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Center(
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final v = _pulse.value; // 0..1
            return Stack(
              alignment: Alignment.center,
              children: [
                // Expanding, fading halo.
                Transform.scale(
                  scale: 1.0 + 0.35 * v,
                  child: Opacity(
                    opacity: 0.35 * (1 - v),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                    ),
                  ),
                ),
                child!,
              ],
            );
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: widget.background,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Icon(widget.icon, color: widget.color, size: 26),
          ),
        ),
      ),
    );
  }
}
