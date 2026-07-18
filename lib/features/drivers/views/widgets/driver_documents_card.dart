import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/z_button.dart';
import '../../../../core/widgets/z_card.dart';
import '../../../../core/widgets/z_reason_dialog.dart';
import '../../cubit/driver_detail_cubit.dart';
import '../../data/models/driver_document.dart';
import '../../data/models/driver_model.dart';
import 'document_tile.dart';

/// The Documents card: a responsive grid of document tiles plus an
/// "approve all" action that verifies the driver in one call.
class DriverDocumentsCard extends StatelessWidget {
  const DriverDocumentsCard({
    super.key,
    required this.driver,
    required this.state,
    required this.cubit,
  });

  final DriverModel driver;
  final DriverDetailState state;
  final DriverDetailCubit cubit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allApproved = driver.documents.every((d) => d.isApproved);

    return ZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Documents', style: theme.textTheme.titleLarge),
              ),
              if (!allApproved)
                ZButton(
                  label: 'Approve all',
                  icon: Icons.done_all,
                  size: ZButtonSize.small,
                  variant: ZButtonVariant.secondary,
                  loading: state.busyApproveAll,
                  onPressed: state.anyActionBusy
                      ? null
                      : () => _approveAll(context),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth < 520 ? 1 : (c.maxWidth < 760 ? 2 : 3);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: driver.documents.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  // image (130) + label + actions + padding.
                  mainAxisExtent: 222,
                ),
                itemBuilder: (context, i) {
                  final doc = driver.documents[i];
                  return DocumentTile(
                    document: doc,
                    busy: state.busyDoc == doc.type,
                    actionsEnabled: !state.anyActionBusy,
                    onApprove: () => cubit.reviewDocument(doc.type, true),
                    onReject: () => _reject(context, doc),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _approveAll(BuildContext context) async {
    final ok = await ZReasonDialog.show(
      context,
      icon: Icons.verified_outlined,
      title: 'Approve this driver?',
      body: 'This marks all five documents approved and verifies the driver. '
          'They can start accepting trips immediately.',
      confirmLabel: 'Approve driver',
    );
    if (ok != null) cubit.approveAll();
  }

  Future<void> _reject(BuildContext context, DriverDocument doc) async {
    final reason = await ZReasonDialog.show(
      context,
      icon: Icons.cancel_outlined,
      title: 'Reject ${doc.type.label}?',
      body: 'The driver will be asked to re-upload. A clear reason speeds up '
          're-submission and is recorded.',
      confirmLabel: 'Reject document',
      requireReason: true,
      reasonHint: 'What was wrong with the document?',
      danger: true,
    );
    if (reason != null) {
      cubit.reviewDocument(doc.type, false, reason: reason);
    }
  }
}
