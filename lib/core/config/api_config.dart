class ApiConfig {
  // Legacy API — kept for the old service layer (auth_service, product_api,
  // stripe_api, user_service…). Nothing reads it any more, and the host itself
  // currently answers 502, so treat it as dead.
  static const String baseUrl = 'https://newapi.happer.fr';

  // ── API v1 — every request from ApiClient goes through here ───────────────
  //
  // Verified environments (the backend's `/` route prints its NODE_ENV):
  //   https://api.happer.fr      → HAPPER-V2-production-APP
  //   https://api.dev.happer.fr  → HAPPER-V2-development-APP
  //
  // Currently pointed at DEV, because features land there first — e.g. the
  // purchases list's is_cancellable / is_returnable flags exist on the backend
  // `development` branch but not yet on `production`.
  //
  // Build against production without touching this file:
  //   flutter build apk --dart-define=USE_DEV_API=false
  static const bool useDevApi =
      bool.fromEnvironment('USE_DEV_API', defaultValue: true);

  static const String prodBaseUrl = 'https://api.happer.fr/api/v1';
  static const String devBaseUrl = 'https://api.dev.happer.fr/api/v1';

  static String get newBaseUrl => useDevApi ? devBaseUrl : prodBaseUrl;
}
