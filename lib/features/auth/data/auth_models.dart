/// The single payload the auth endpoints actually return an object for.
///
/// Shape verified against `app/api/auth/login/route.ts`, which wraps
/// `{...userData, token}` in the JSend envelope. Every other auth handler
/// returns a trivial `{sent: true}` / `{verified: true}` / `{expiresAt}`
/// acknowledgement, so they need no model.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.phone,
    required this.token,
    this.role,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneVerified = false,
  });

  final String id;
  final String phone;

  /// Bearer token — `createToken({id, phone, role})` on the server.
  final String token;

  final String? role;
  final String? firstName;
  final String? lastName;
  final String? email;
  final bool phoneVerified;

  /// «سارا نمونه» — falls back to the phone number when the profile is empty,
  /// which it is for every account created through the OTP signup flow.
  String get displayName {
    final full = [firstName, lastName].whereType<String>().join(' ').trim();
    return full.isEmpty ? phone : full;
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: '${json['id']}',
    phone: '${json['phone'] ?? ''}',
    token: '${json['token'] ?? ''}',
    role: json['role'] as String?,
    firstName: json['firstName'] as String?,
    lastName: json['lastName'] as String?,
    email: json['email'] as String?,
    phoneVerified: json['phoneVerified'] == true,
  );
}
