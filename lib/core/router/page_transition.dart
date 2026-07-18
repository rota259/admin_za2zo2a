import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared route transition: a quick fade plus a subtle upward slide, matching
/// the design's `zfade` (opacity 0→1, translateY 10px→0). Applied uniformly to
/// every route so navigation feels of a piece.
///
/// Fast on purpose — this is an operator tool, not a marketing site. In is
/// 260ms ease-out; out is 180ms so the outgoing screen clears promptly.
CustomTransitionPage<T> fadeSlidePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: curved,
        child: AnimatedBuilder(
          animation: curved,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, (1 - curved.value) * 10),
            child: child,
          ),
          child: child,
        ),
      );
    },
    child: child,
  );
}
