import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/z_badge.dart';
import '../../data/models/driver_document.dart';

/// One document tile: the uploaded image (or an "awaiting upload" placeholder)
/// with a status badge, then the label and per-document Approve / Reject.
///
/// Buttons disable while any action on this driver is in flight; [busy] shows
/// the spinner on the tile currently being reviewed.
class DocumentTile extends StatelessWidget {
  const DocumentTile({
    super.key,
    required this.document,
    required this.busy,
    required this.actionsEnabled,
    required this.onApprove,
    required this.onReject,
  });

  final DriverDocument document;
  final bool busy;
  final bool actionsEnabled;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _image(context),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(document.type.icon, size: 15, color: t.text2),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(document.type.label,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _actions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(BuildContext context) {
    final t = context.tokens;
    return Stack(
      children: [
        Container(
          height: 130,
          width: double.infinity,
          color: t.surface2,
          alignment: Alignment.center,
          child: document.hasImage
              ? Image.network(
                  document.url!,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _noImage(context),
                )
              : _noImage(context),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: ZBadge.forStatus(document.status),
        ),
      ],
    );
  }

  Widget _noImage(BuildContext context) {
    final t = context.tokens;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_not_supported_outlined, size: 22, color: t.text3),
        const SizedBox(height: 6),
        Text('Not uploaded yet',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: t.text3)),
      ],
    );
  }

  Widget _actions(BuildContext context) {
    if (busy) {
      final t = context.tokens;
      return SizedBox(
        height: 32,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(t.accent)),
          ),
        ),
      );
    }
    // Both actions stay available regardless of the current decision, so an
    // admin can re-review and flip an already-approved/rejected document (the
    // backend accepts the change; the status badge shows where it stands).
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: document.isApproved ? 'Approved' : 'Approve',
            tone: context.tokens.green,
            enabled: actionsEnabled,
            filled: document.isApproved,
            onTap: onApprove,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _ActionButton(
            label: document.isRejected ? 'Rejected' : 'Reject',
            tone: context.tokens.danger,
            enabled: actionsEnabled,
            filled: document.isRejected,
            onTap: onReject,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.tone,
    required this.enabled,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final Color tone;
  final bool enabled;
  final VoidCallback onTap;

  /// Solid fill when this is the document's current decision.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : tone;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: filled ? tone : tone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Container(
            height: 32,
            alignment: Alignment.center,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: fg,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
