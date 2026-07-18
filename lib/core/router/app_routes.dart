import 'package:flutter/material.dart';

/// Route paths. Kept as constants so no view builds a path by hand.
class AppRoutes {
  const AppRoutes._();

  static const String login = '/login';
  static const String dashboard = '/';
  static const String drivers = '/drivers';
  static const String driverDetail = '/drivers/:id';
  static const String approval = '/approval';
  static const String selfie = '/selfie';
  static const String riders = '/riders';
  static const String trips = '/trips';
  static const String pricing = '/pricing';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static String driverDetailFor(String id) => '/drivers/$id';
}

/// One sidebar entry. Mirrors the design's `navDef` array, with the crumb
/// titles from its `crumbTitle` map.
class NavItem {
  const NavItem({
    required this.path,
    required this.label,
    required this.icon,
    this.enabled = true,
  });

  final String path;
  final String label;
  final IconData icon;

  /// False for sections whose backend endpoints don't exist yet (Stage 0
  /// found no routes for riders, trips, notifications or settings). They stay
  /// visible but inert rather than leading to a fake screen.
  final bool enabled;

  static const List<NavItem> all = [
    NavItem(
      path: AppRoutes.dashboard,
      label: 'Overview',
      icon: Icons.dashboard_outlined,
    ),
    NavItem(
      path: AppRoutes.drivers,
      label: 'Drivers',
      icon: Icons.directions_car_outlined,
    ),
    NavItem(
      path: AppRoutes.approval,
      label: 'Approval Queue',
      icon: Icons.fact_check_outlined,
    ),
    NavItem(
      path: AppRoutes.selfie,
      label: 'Selfie Review',
      icon: Icons.face_retouching_natural_outlined,
    ),
    NavItem(
      path: AppRoutes.riders,
      label: 'Riders',
      icon: Icons.people_outline,
      enabled: false,
    ),
    NavItem(
      path: AppRoutes.trips,
      label: 'Trips',
      icon: Icons.route_outlined,
      enabled: false,
    ),
    NavItem(
      path: AppRoutes.pricing,
      label: 'Pricing',
      icon: Icons.tune_outlined,
    ),
    NavItem(
      path: AppRoutes.notifications,
      label: 'Notifications',
      icon: Icons.campaign_outlined,
      enabled: false,
    ),
    NavItem(
      path: AppRoutes.settings,
      label: 'Settings',
      icon: Icons.settings_outlined,
      enabled: false,
    ),
  ];

  /// Breadcrumb label for a path, per the design's `crumbTitle` map.
  static String titleFor(String location) {
    if (location.startsWith('/drivers/') && location.length > 9) {
      return 'Driver detail';
    }
    return all
        .firstWhere(
          (n) => n.path == location,
          orElse: () => const NavItem(
            path: '',
            label: 'Overview',
            icon: Icons.dashboard_outlined,
          ),
        )
        .label;
  }
}
