/// Build-time configuration.
///
/// Override per environment:
///   flutter run --dart-define=API_BASE_URL=https://pishrosarmaye.com/api
abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // 10.0.2.2 is the Android emulator's alias for the host machine.
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  /// Toggles the mock repositories for modules the backend does not implement
  /// yet (Community, and the KYC / Pishro-Coin / devices / referrals slice of
  /// Account). Flip to false once those endpoints ship.
  static const useMockForMissingApis = bool.fromEnvironment(
    'USE_MOCKS',
    defaultValue: true,
  );
}
