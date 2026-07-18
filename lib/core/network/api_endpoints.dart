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
    defaultValue: 'http://192.168.1.10:3000',
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

  // ── Health ──────────────────────────────────────────────────────────────
  static const String health = '/health';
}
