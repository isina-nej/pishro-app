/// Normalised failure surface. Every repository throws one of these, so UI
/// never has to know Dio exists.
sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// No usable connection, DNS failure, or timeout.
class NetworkException extends ApiException {
  const NetworkException([super.message = 'اتصال اینترنت برقرار نیست.']);
}

/// 401/403 — the session is gone or was never valid.
class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'دسترسی شما منقضی شده است.']);
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'موردی یافت نشد.']);
}

/// JSend `status: "fail"` — per-field validation errors.
class ValidationException extends ApiException {
  const ValidationException(super.message, this.fieldErrors);

  /// Maps a form field name to its first error string.
  final Map<String, String> fieldErrors;

  String? forField(String field) => fieldErrors[field];
}

/// JSend `status: "error"`, or any unexpected 5xx.
class ServerException extends ApiException {
  const ServerException([
    super.message = 'خطایی رخ داد. لطفاً دوباره تلاش کنید.',
    this.code,
  ]);
  final String? code;
}
