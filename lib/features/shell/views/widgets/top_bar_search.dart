import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';

/// The top bar's search field with its ⌘K hint chip.
///
/// DISABLED on purpose: the backend exposes no admin search endpoint, and a
/// box that looks live but does nothing is worse than one that says so. The
/// visual treatment matches the design exactly; the tooltip explains why it's
/// inert. Wire it the day a search route exists.
class TopBarSearch extends StatelessWidget {
  const TopBarSearch({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    return Tooltip(
      message: 'Search is not available yet — the backend has no admin '
          'search endpoint.',
      child: Opacity(
        opacity: 0.6,
        child: MouseRegion(
          cursor: SystemMouseCursors.basic,
          child: Container(
            height: 40,
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
              color: t.searchBg,
              border: Border.all(color: t.border),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: t.text3),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Search drivers, riders, trips…',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: t.text3),
                  ),
                ),
                const _ShortcutChip(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The ⌘K affordance — 11px JetBrains Mono in a hairline chip.
class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      child: Text(
        '⌘K',
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: t.text3, fontFamily: 'JetBrains Mono'),
      ),
    );
  }
}
