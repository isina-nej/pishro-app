import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/token_storage.dart';

/// Authentication state, owned here rather than in the Auth feature because
/// the router and every authenticated repository depend on it.
@immutable
class SessionState {
  const SessionState({
    required this.isResolved,
    required this.isAuthenticated,
    this.userId,
  });

  /// Before the stored token has been read, the router must not redirect —
  /// otherwise a signed-in user flashes the welcome screen on cold start.
  const SessionState.unresolved()
    : isResolved = false,
      isAuthenticated = false,
      userId = null;

  final bool isResolved;
  final bool isAuthenticated;
  final String? userId;
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier(this._tokens) : super(const SessionState.unresolved()) {
    _restore();
  }

  final TokenStorage _tokens;

  Future<void> _restore() async {
    final hasSession = await _tokens.hasSession;
    if (!mounted) return;
    state = SessionState(isResolved: true, isAuthenticated: hasSession);
  }

  Future<void> signIn({
    required String accessToken,
    String? refreshToken,
    String? userId,
  }) async {
    await _tokens.save(accessToken: accessToken, refreshToken: refreshToken);
    state = SessionState(
      isResolved: true,
      isAuthenticated: true,
      userId: userId,
    );
  }

  Future<void> signOut() async {
    await _tokens.clear();
    state = const SessionState(isResolved: true, isAuthenticated: false);
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>(
  (ref) => SessionNotifier(ref.watch(tokenStorageProvider)),
);
