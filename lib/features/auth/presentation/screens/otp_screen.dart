import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/auth_repository.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/otp_box_input.dart';

/// Screen/Auth/OTP — «کد تأیید».
///
/// Live 120s countdown matches server OTP validity (`AuthRepository.sendOtp`).
/// Error / Disabled / Expired frames from the Auth deck are expressed as
/// interactive states on this single screen.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});

  /// Phone that received the code — ASCII or Persian digits are both accepted;
  /// the repository normalises with [Fmt.toAscii] before the API call.
  final String phone;

  /// Server + deck validity window («ریست ۱۲۰ ثانیه»).
  static const validity = Duration(minutes: 2);

  /// Deck: «پس از ۵ تلاش نادرست، حساب موقتاً قفل می‌شود.»
  static const maxAttempts = 5;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _code = TextEditingController();

  Timer? _ticker;
  late int _secondsLeft;
  bool _verifying = false;
  bool _resending = false;
  bool _hasError = false;
  int _failedAttempts = 0;
  String? _networkError;

  bool get _expired => _secondsLeft <= 0;
  bool get _locked => _failedAttempts >= OtpScreen.maxAttempts;
  bool get _codeComplete => _code.text.length == 6;

  /// Confirm is enabled only with a full, non-expired, non-errored code.
  /// Deck Error+Disabled keeps the CTA grey after a wrong 6-digit attempt.
  bool get _canConfirm =>
      _codeComplete && !_expired && !_hasError && !_locked && !_verifying;

  @override
  void initState() {
    super.initState();
    _secondsLeft = OtpScreen.validity.inSeconds;
    _startTicker();
    _code.addListener(_onCodeEdited);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _code
      ..removeListener(_onCodeEdited)
      ..dispose();
    super.dispose();
  }

  void _onCodeEdited() {
    if (!_hasError && _networkError == null) {
      setState(() {});
      return;
    }
    setState(() {
      _hasError = false;
      _networkError = null;
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 0) {
        _ticker?.cancel();
        setState(() {});
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  void _resetCountdown() {
    _ticker?.cancel();
    setState(() {
      _secondsLeft = OtpScreen.validity.inSeconds;
      _hasError = false;
      _networkError = null;
      _code.clear();
    });
    _startTicker();
  }

  String get _maskedPhone {
    final digits = Fmt.toAscii(widget.phone).replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return Fmt.fa(digits);
    final head = digits.substring(0, 4);
    final tail = digits.substring(digits.length - 4);
    return '${Fmt.fa(head)} ••• ${Fmt.fa(tail)}';
  }

  String get _countdownLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return 'ارسال دوباره کد تا ${Fmt.fa('$m:$s')}';
  }

  Future<void> _verify([String? raw]) async {
    if (_verifying || _expired || _locked) return;
    final code = Fmt.toAscii(raw ?? _code.text).replaceAll(RegExp(r'\D'), '');
    if (code.length != 6) return;

    setState(() {
      _verifying = true;
      _hasError = false;
      _networkError = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .verifyOtp(phone: widget.phone, code: code);
      if (!mounted) return;
      // API returns `{verified: true}` with no session token — deck prototype
      // jumps to Courses/Home; we land on Login so the user can obtain one.
      context.go(Routes.login);
    } on ValidationException {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _hasError = true;
        _failedAttempts += 1;
      });
    } on NetworkException catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _networkError = e.message;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _hasError = true;
        _failedAttempts += 1;
        _networkError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _hasError = true;
        _failedAttempts += 1;
      });
    }
  }

  Future<void> _resend() async {
    if (_resending || (!_expired && _secondsLeft > 0)) return;

    setState(() {
      _resending = true;
      _networkError = null;
    });

    try {
      await ref.read(authRepositoryProvider).sendOtp(widget.phone);
      if (!mounted) return;
      setState(() => _resending = false);
      _resetCountdown();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _resending = false;
        _networkError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _resending = false;
        _networkError = 'خطایی رخ داد. لطفاً دوباره تلاش کنید.';
      });
    }
  }

  void _changeNumber() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.signup);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final resendReady = _expired || _secondsLeft <= 0;

    return AuthScaffold(
      title: 'تأیید شماره موبایل',
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PishroButton(
            label: 'تأیید و ادامه',
            loading: _verifying,
            onPressed: _canConfirm ? () => _verify() : null,
          ),
          const SizedBox(height: Space.s3),
          SizedBox(
            height: 40,
            child: Center(
              child: Text(
                _hasError || _locked
                    ? 'پس از ۵ تلاش نادرست، حساب موقتاً قفل می‌شود.'
                    : 'با تأیید، قوانین استفاده و سیاست حریم خصوصی را پذیرفته‌اید.',
                textAlign: TextAlign.center,
                style: context.text.caption.copyWith(
                  color: c.textMuted,
                  height: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'کد شش‌رقمی را وارد کنید',
            style: context.text.h2.copyWith(
              color: c.textPrimary,
              fontSize: 22,
              height: 1.5,
            ),
          ),
          if (_expired) ...[
            const SizedBox(height: Space.s3 + 2),
            const NoticeBanner(
              tone: NoticeTone.warning,
              // TODO(token): deck expired banner body uses warm #E7DCC4;
              // NoticeBanner maps copy to textSecondary.
              message:
                  'مدت اعتبار کد تأیید به پایان رسیده است. کد جدید دریافت کنید.',
            ),
          ] else ...[
            const SizedBox(height: Space.s2 + 2),
            Text(
              'کد تأیید به شماره زیر ارسال شد.',
              style: context.text.bodyMedium.copyWith(
                color: c.textMuted,
                height: 1.9,
              ),
            ),
          ],
          const SizedBox(height: Space.s2 + 2),
          _PhoneCard(maskedPhone: _maskedPhone, onChangeNumber: _changeNumber),
          const SizedBox(height: Space.s6 + 2),
          OtpBoxInput(
            controller: _code,
            enabled: !_expired && !_locked && !_verifying,
            hasError: _hasError,
            onCompleted: _verify,
          ),
          if (_hasError) ...[
            const SizedBox(height: Space.s3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 16, color: c.danger),
                const SizedBox(width: Space.s2 - 1),
                Flexible(
                  child: Text(
                    'کد واردشده نادرست است. دوباره تلاش کنید.',
                    style: context.text.bodySmall.copyWith(color: c.danger),
                  ),
                ),
              ],
            ),
          ] else if (!_expired) ...[
            const SizedBox(height: Space.s3 + 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.content_paste_rounded, size: 15, color: c.textMuted),
                const SizedBox(width: Space.s2),
                Text(
                  'کد کپی‌شده به‌صورت خودکار جای‌گذاری می‌شود',
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
              ],
            ),
          ],
          if (_networkError != null) ...[
            const SizedBox(height: Space.s3),
            NoticeBanner(tone: NoticeTone.danger, message: _networkError!),
          ],
          const SizedBox(height: Space.s6 + 2),
          _ResendRow(
            ready: resendReady,
            resending: _resending,
            label: _resending
                ? 'در حال ارسال…'
                : (resendReady ? 'ارسال دوباره کد' : _countdownLabel),
            onTap: resendReady && !_resending ? _resend : null,
          ),
        ],
      ),
    );
  }
}

class _PhoneCard extends StatelessWidget {
  const _PhoneCard({required this.maskedPhone, required this.onChangeNumber});

  final String maskedPhone;
  final VoidCallback onChangeNumber;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.s3 + 2,
        vertical: Space.s3,
      ),
      decoration: BoxDecoration(
        // Deck phone strip sits on Neutral/900 (#101318) ≈ surfacePrimary.
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.borderDefault.withValues(alpha: 0.85)),
      ),
      child: Row(
        children: [
          Icon(Icons.smartphone_rounded, size: 18, color: c.textMuted),
          const SizedBox(width: Space.s2 + 2),
          Expanded(
            child: Text(
              maskedPhone,
              style: context.text.numeric.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: c.textPrimary,
              ),
            ),
          ),
          InkWell(
            onTap: onChangeNumber,
            borderRadius: BorderRadius.circular(Radii.sm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: Layout.minTapTarget,
                minHeight: Layout.minTapTarget,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  'تغییر شماره',
                  style: context.text.bodySmall.copyWith(
                    color: c.actionPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.ready,
    required this.resending,
    required this.label,
    required this.onTap,
  });

  final bool ready;
  final bool resending;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = ready && !resending ? c.actionPrimary : c.textMuted;
    final icon = ready ? Icons.refresh_rounded : Icons.schedule_rounded;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Layout.minTapTarget),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (resending)
              SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: color,
                ),
              )
            else
              Icon(icon, size: 17, color: color),
            const SizedBox(width: Space.s2),
            Text(
              label,
              style: context.text.bodyMedium.copyWith(
                color: color,
                fontWeight: ready && !resending
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
