import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_tokens.dart';

/// Shimmering placeholder, mirroring the design's `--skeleton` gradient and
/// its `zshimmer` keyframe. Used as the loading state on every fetching screen.
class ZSkeleton extends StatefulWidget {
  const ZSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = AppRadii.xs,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<ZSkeleton> createState() => _ZSkeletonState();
}

class _ZSkeletonState extends State<ZSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              colors: [t.skeletonBase, t.skeletonHighlight, t.skeletonBase],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1 - 2 * (1 - _c.value), 0),
              end: Alignment(1 + 2 * _c.value, 0),
            ),
          ),
        );
      },
    );
  }
}

/// A few stacked skeleton lines — the default "loading" body for lists.
class ZSkeletonList extends StatelessWidget {
  const ZSkeletonList({super.key, this.rows = 5});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        rows,
        (i) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            children: [
              ZSkeleton(width: 38, height: 38, radius: AppRadii.sm),
              SizedBox(width: AppSpacing.md),
              Expanded(child: ZSkeleton(height: 12)),
              SizedBox(width: AppSpacing.xxl),
              ZSkeleton(width: 80, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
