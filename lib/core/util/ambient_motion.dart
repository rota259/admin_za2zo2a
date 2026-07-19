/// Global switch for the app's *ambient, looping* animations — the login
/// brand-panel glow and the empty/error-state pulse.
///
/// Production leaves it on. Tests turn it off so `pumpAndSettle` actually
/// settles (a perpetual animation would otherwise time out) and golden frames
/// are deterministic. One-shot transitions (page fades, button press) are
/// unaffected — they settle on their own.
class AmbientMotion {
  const AmbientMotion._();

  static bool enabled = true;
}
