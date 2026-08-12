import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import 'auth_models.dart';

/// Auth endpoints, all live — there is no mock variant for this module.
///
/// Every method normalises phone/OTP input with [Fmt.toAscii] first: the
/// backend regexes are `^09\d{9}$` on ASCII digits and a Persian keyboard
/// emits «۰۹۱۲…», which would fail validation server-side.
class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  /// `POST /auth/login` → `{...user, token}`.
  ///
  /// Bad credentials come back as HTTP 401, which [ApiClient] maps to
  /// `UnauthorizedException`; an unverified phone or a malformed field comes
  /// back as JSend `fail` → `ValidationException.fieldErrors`.
  Future<AuthUser> login({
    required String phone,
    required String password,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      body: {'phone': Fmt.toAscii(phone), 'password': password},
    );
    return AuthUser.fromJson(data);
  }

  /// `POST /auth/signup` — stores a TempUser and texts an OTP. It does NOT
  /// create the account; `/otp/verify` does. Only `phone` and `password` are
  /// read by the handler.
  Future<void> signup({required String phone, required String password}) async {
    await _api.post<Map<String, dynamic>>(
      '/auth/signup',
      body: {'phone': Fmt.toAscii(phone), 'password': password},
    );
  }

  /// `POST /otp/send` — re-sends the signup code. Server validity is 2 minutes.
  Future<void> sendOtp(String phone) async {
    await _api.post<Map<String, dynamic>>(
      '/otp/send',
      body: {'phone': Fmt.toAscii(phone)},
    );
  }

  /// `POST /otp/verify` — promotes the TempUser to a real User.
  ///
  /// Returns `{verified: true}` and no token, so the caller has to log in
  /// afterwards to obtain a session.
  Future<void> verifyOtp({required String phone, required String code}) async {
    await _api.post<Map<String, dynamic>>(
      '/otp/verify',
      body: {'phone': Fmt.toAscii(phone), 'code': Fmt.toAscii(code)},
    );
  }

  /// `POST /auth/forgot-password/request` → `{expiresAt}` (ISO-8601).
  Future<DateTime> requestPasswordReset(String phone) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/forgot-password/request',
      body: {'phone': Fmt.toAscii(phone)},
    );
    final raw = data['expiresAt'];
    return raw is String
        ? DateTime.parse(raw)
        : DateTime.now().add(const Duration(minutes: 2));
  }

  /// `POST /auth/forgot-password/reset` → `{success: true}`.
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    await _api.post<Map<String, dynamic>>(
      '/auth/forgot-password/reset',
      body: {
        'phone': Fmt.toAscii(phone),
        'code': Fmt.toAscii(code),
        'newPassword': newPassword,
      },
    );
  }

  /// `POST /auth/send-sms-otp` → `{token, method}`.
  ///
  /// This is the IPPanel two-factor bridge, keyed by an IPPanel session token
  /// rather than a phone number — it is not part of the signup/reset flow the
  /// deck draws, and no screen calls it yet.
  Future<String> sendSmsOtpForToken(String token) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/send-sms-otp',
      body: {'token': token},
    );
    return '${data['token']}';
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);
