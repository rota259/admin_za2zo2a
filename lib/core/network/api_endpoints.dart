/// Every admin endpoint, verified against the live backend
/// (`Za2zoo2a-main/src/routes/adminRoutes.ts` + `pricingRoutes.ts`).
///
/// Base URL follows the mobile app's config pattern — compile-time, never a
/// hardcoded secret:
///   flutter run -d chrome --dart-define=BASE_URL=http://localhost:3000
class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.2:3000',
  );

  // ── Admin auth ──────────────────────────────────────────────────────────
  static const String adminLogin = '/api/admin/auth/login';
  static const String adminMe = '/api/admin/auth/me';

  // ── Pricing ─────────────────────────────────────────────────────────────
  /// Admin read/write. PUT applies live to riders & drivers.
  static const String adminPricing = '/api/admin/pricing';

  /// Public config the rider/driver apps read.
  static const String publicPricingConfig = '/api/pricing/config';

  // ── Drivers ─────────────────────────────────────────────────────────────
  static const String adminDrivers = '/api/admin/drivers';
  static String adminDriver(String id) => '/api/admin/drivers/$id';
  static String adminDriverDocumentReview(String id, String docType) =>
      '/api/admin/drivers/$id/documents/$docType/review';
  static String adminDriverApprove(String id) =>
      '/api/admin/drivers/$id/approve';
  static String adminDriverBlock(String id) => '/api/admin/drivers/$id/block';

  // ── Selfie checks ───────────────────────────────────────────────────────
  static const String adminSelfieChecks = '/api/admin/selfie-checks';
  static String adminSelfieCheckReview(String id) =>
      '/api/admin/selfie-checks/$id/review';

  // ── Notifications (admin) ──────────────────────────────────────────────
  /// POST → send/broadcast. GET → sent history (paginated).
  static const String adminNotifications = '/api/admin/notifications';

  // ── Riders ──────────────────────────────────────────────────────────────
  static const String adminRiders = '/api/admin/riders';
  static String adminRider(String id) => '/api/admin/riders/$id';
  static String adminRiderBlock(String id) => '/api/admin/riders/$id/block';

  // ── Trips ───────────────────────────────────────────────────────────────
  /// `GET ?type=active|history` (omit for all), confirmed live via the
  /// project's Postman collection ("Watch Active Trips" / "View Trip
  /// History" / "View All Trips"). No fare-override endpoint exists yet.
  static const String adminTrips = '/api/admin/trips';
  static String adminTrip(String id) => '/api/admin/trips/$id';

  // ── Vehicles ────────────────────────────────────────────────────────────
  /// Confirmed live ("View Registered Cars") but not yet wired to a screen.
  static const String adminCars = '/api/admin/cars';

  // ── Settings ────────────────────────────────────────────────────────────
  /// Not yet live on the backend — no route in the Postman collection.
  static const String adminSettings = '/api/admin/settings';

  // ── Service zones ───────────────────────────────────────────────────────
  static const String adminZones = '/api/admin/zones';
  static String adminZone(String id) => '/api/admin/zones/$id';

  // ── Support tickets ─────────────────────────────────────────────────────
  static const String adminSupportTickets = '/api/admin/support-tickets';
  static String adminSupportTicket(String id) =>
      '/api/admin/support-tickets/$id';
  static String adminSupportTicketReplies(String id) =>
      '/api/admin/support-tickets/$id/replies';

  // ── Audit log ───────────────────────────────────────────────────────────
  static const String adminAudit = '/api/admin/audit';

  // ── Health ──────────────────────────────────────────────────────────────
  static const String health = '/health';
}
