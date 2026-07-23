import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/z_filter_tabs.dart';
import '../../../injection_container.dart';
import '../../shell/views/widgets/admin_page.dart';
import '../cubit/audit_cubit.dart';
import '../cubit/commission_cubit.dart';
import '../cubit/support_tickets_cubit.dart';
import '../cubit/zones_cubit.dart';
import 'widgets/audit_section.dart';
import 'widgets/commission_section.dart';
import 'widgets/support_tickets_section.dart';
import 'widgets/zones_section.dart';

enum _SettingsTab { commission, zones, support, audit }

extension on _SettingsTab {
  String get label => switch (this) {
        _SettingsTab.commission => 'Commission',
        _SettingsTab.zones => 'Service zones',
        _SettingsTab.support => 'Support tickets',
        _SettingsTab.audit => 'Audit log',
      };
}

/// Settings — four sub-areas per `docs/backend-admin-api-spec.md` §4:
/// commission, service zones, support tickets, audit log. Each sub-area owns
/// its own cubit; all four load once and stay alive under an [IndexedStack] so
/// switching tabs doesn't re-fetch.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CommissionCubit>()..load()),
        BlocProvider(create: (_) => sl<ZonesCubit>()..load()),
        BlocProvider(create: (_) => sl<SupportTicketsCubit>()..load()),
        BlocProvider(create: (_) => sl<AuditCubit>()..load()),
      ],
      child: const _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatefulWidget {
  const _SettingsBody();

  @override
  State<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<_SettingsBody> {
  var _tab = _SettingsTab.commission;

  @override
  void initState() {
    super.initState();
    context
        .read<CommissionCubit>()
        .results
        .listen((r) => _toast(r.message, r.isError));
    context
        .read<ZonesCubit>()
        .results
        .listen((r) => _toast(r.message, r.isError));
    context
        .read<SupportTicketsCubit>()
        .results
        .listen((r) => _toast(r.message, r.isError));
  }

  void _toast(String message, bool isError) {
    if (!mounted) return;
    final t = context.tokens;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? t.danger : t.toastBg,
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;

    return AdminPage(
      title: 'Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings',
              style: theme.textTheme.displaySmall
                  ?.copyWith(fontSize: 26, letterSpacing: -0.65)),
          const SizedBox(height: AppSpacing.xs),
          Text('Commission, service zones, support tickets, and the audit log.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: t.text2, fontSize: 14.5)),
          const SizedBox(height: AppSpacing.xl),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ZFilterTabs<_SettingsTab>(
              values: _SettingsTab.values,
              current: _tab,
              labelFor: (v) => v.label,
              countFor: (_) => 0,
              showCount: false,
              onSelect: (v) => setState(() => _tab = v),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          IndexedStack(
            index: _tab.index,
            children: const [
              CommissionSection(),
              ZonesSection(),
              SupportTicketsSection(),
              AuditSection(),
            ],
          ),
        ],
      ),
    );
  }
}
