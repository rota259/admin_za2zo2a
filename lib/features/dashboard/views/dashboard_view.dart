import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/z_card.dart';
import '../../../core/widgets/z_empty_state.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../shell/views/widgets/admin_page.dart';
import 'widgets/dashboard_header.dart';

/// Overview.
///
/// Intentionally empty below the header: the design's KPIs, revenue chart and
/// activity feed have no backend endpoints (Stage 0 found no stats route), and
/// the brief forbids mock data. The shell, routing and session around it are
/// live — the greeting is the real admin from GET /api/admin/auth/me.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.select((AuthCubit c) => c.state.admin);

    return AdminPage(
      title: 'Overview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(adminName: admin?.name),
          const SizedBox(height: 22),
          const ZCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 380,
              child: ZEmptyState(
                title: 'No dashboard data yet',
                message:
                    'KPIs, the revenue chart and the activity feed need a stats\n'
                    'endpoint the backend does not expose yet. Rather than show\n'
                    'invented numbers, this stays empty until it is wired.',
                icon: Icons.insights_outlined,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
