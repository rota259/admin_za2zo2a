import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/z_button.dart';
import '../../../../core/widgets/z_card.dart';
import '../../../../core/widgets/z_reason_dialog.dart';
import '../../../drivers/data/models/driver_document.dart';
import '../../../drivers/data/models/driver_model.dart';
import '../../../drivers/views/widgets/document_tile.dart';
import '../../../drivers/views/widgets/driver_avatar.dart';
import '../../cubit/approval_cubit.dart';

/// One driver awaiting approval: header + top actions + a grid of document
/// tiles for granular review.
class ApprovalCard extends StatelessWidget {
  const ApprovalCard({
    super.key,
    required this.driver,
    required this.state,
    required this.cubit,
  });

  final DriverModel driver;
  final ApprovalState state;
  final ApprovalCubit cubit;

  bool get _busy => state.busyDriverId == driver.id;
  bool get _anyBusy => state.busyDriverId != null;

  @override
  Widget build(BuildContext context) {
    return ZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth < 520 ? 1 : (c.maxWidth < 780 ? 2 : 3);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: driver.documents.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  mainAxisExtent: 222,
                ),
                itemBuilder: (context, i) {
                  final doc = driver.documents[i];
                  return DocumentTile(
                    document: doc,
                    busy: _busy && state.busyDoc == doc.type,
                    actionsEnabled: !_anyBusy,
                    onApprove: () =>
                        cubit.reviewDocument(driver, doc.type, true),
                    onReject: () => _rejectDoc(context, doc),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context);

    final actions = Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        ZButton(
          label: 'Reject',
          icon: Icons.close,
          variant: ZButtonVariant.secondary,
          size: ZButtonSize.small,
          onPressed: _anyBusy ? null : () => _rejectAll(context),
        ),
        ZButton(
          label: 'Approve driver',
          icon: Icons.check,
          size: ZButtonSize.small,
          loading: _busy && state.busyDoc == null,
          onPressed: _anyBusy ? null : () => _approve(context),
        ),
      ],
    );

    final identity = Row(
      children: [
        DriverAvatar(
            name: driver.fullName,
            initials: driver.initials,
            photoUrl: driver.profilePhoto,
            size: 44),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(driver.fullName,
                  style: theme.textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis),
              Text(
                '${driver.vehicle.display} · ${driver.phone}',
                style: theme.textTheme.bodySmall?.copyWith(color: t.text2),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    // Narrow: stack the actions under the identity; wide: actions on the right.
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              identity,
              const SizedBox(height: AppSpacing.md),
              actions,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: identity),
            const SizedBox(width: AppSpacing.md),
            actions,
          ],
        );
      },
    );
  }

  Future<void> _approve(BuildContext context) async {
    final ok = await ZReasonDialog.show(
      context,
      icon: Icons.verified_outlined,
      title: 'Approve ${driver.fullName}?',
      body: 'This verifies the driver and approves all documents. They can '
          'start accepting trips immediately.',
      confirmLabel: 'Approve driver',
    );
    if (ok != null) cubit.approveDriver(driver);
  }

  Future<void> _rejectAll(BuildContext context) async {
    final reason = await ZReasonDialog.show(
      context,
      icon: Icons.cancel_outlined,
      title: 'Reject this application?',
      body: 'Every document not yet approved will be rejected. The driver is '
          'asked to re-upload. A reason is required and recorded.',
      confirmLabel: 'Reject documents',
      requireReason: true,
      reasonHint: 'Why is this application being rejected?',
      danger: true,
    );
    if (reason != null) cubit.rejectApplication(driver, reason);
  }

  Future<void> _rejectDoc(BuildContext context, DriverDocument doc) async {
    final reason = await ZReasonDialog.show(
      context,
      icon: Icons.cancel_outlined,
      title: 'Reject ${doc.type.label}?',
      body: 'The driver will be asked to re-upload this document.',
      confirmLabel: 'Reject document',
      requireReason: true,
      reasonHint: 'What was wrong with the document?',
      danger: true,
    );
    if (reason != null) {
      cubit.reviewDocument(driver, doc.type, false, reason: reason);
    }
  }
}
