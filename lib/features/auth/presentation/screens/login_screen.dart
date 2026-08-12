import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/auth_repository.dart';
import '../widgets/auth_scaffold.dart';

/// Screen/Auth/Login — «ورود».
///
/// Error and Keyboard+Loading deck variants are expressed in-place: a danger
/// [NoticeBanner] + field errors on failed submit, and [PishroButton.loading]
/// while the request is in flight (keyboard rides up via [AuthScaffold] footer).
/// «ورود با اثر انگشت» is the deck’s configured variant — shown in chrome,
/// not wired to a biometric plugin yet.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _bannerError;
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;

    final phone = Fmt.toAscii(_phone.text.trim());
    final password = _password.text;

    setState(() {
      _bannerError = null;
      _phoneError = null;
      _passwordError = null;
    });

    var valid = true;
    if (!_isValidPhone(phone)) {
      _phoneError = 'شماره موبایل واردشده معتبر نیست.';
      valid = false;
    }
    if (password.isEmpty) {
      _passwordError = 'رمز عبور واردشده نادرست است.';
      valid = false;
    }
    if (!valid) {
      setState(() {});
      return;
    }

    setState(() => _loading = true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(phone: phone, password: password);
      await ref
          .read(sessionProvider.notifier)
          .signIn(accessToken: user.token, userId: user.id);
      if (!mounted) return;
      context.go(Routes.homeAfterLogin);
    } on UnauthorizedException {
      if (!mounted) return;
      setState(() {
        _bannerError =
            'شماره موبایل یا رمز عبور نادرست است. ۲ تلاش دیگر باقی مانده است.';
        _passwordError = 'رمز عبور واردشده نادرست است.';
      });
    } on ValidationException catch (e) {
      if (!mounted) return;
      setState(() {
        _phoneError = e.forField('phone');
        _passwordError = e.forField('password');
        if (_phoneError == null && _passwordError == null) {
          _bannerError = e.message;
        }
      });
    } on NetworkException catch (e) {
      if (!mounted) return;
      setState(() => _bannerError = e.message);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _bannerError = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static bool _isValidPhone(String ascii) =>
      RegExp(r'^09\d{9}$').hasMatch(ascii);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AuthScaffold(
      title: 'ورود',
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PishroButton(label: 'ورود', loading: _loading, onPressed: _submit),
          const SizedBox(height: Space.s3 + 2),
          Row(
            children: [
              Expanded(child: Divider(height: 1, color: c.divider)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.s3),
                child: Text(
                  'یا',
                  style: context.text.caption.copyWith(color: c.textMuted),
                ),
              ),
              Expanded(child: Divider(height: 1, color: c.divider)),
            ],
          ),
          const SizedBox(height: Space.s3 + 2),
          // TODO(biometric): wire when device biometric is configured.
          PishroButton(
            label: 'ورود با اثر انگشت',
            variant: PishroButtonVariant.secondary,
            icon: Icons.fingerprint_rounded,
            onPressed: _loading
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'ورود با اثر انگشت هنوز پیکربندی نشده است.',
                        ),
                      ),
                    );
                  },
          ),
          const SizedBox(height: Space.s2),
          SizedBox(
            height: Layout.minTapTarget,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'حساب ندارید؟',
                  style: context.text.bodySmall.copyWith(color: c.textMuted),
                ),
                const SizedBox(width: Space.s1 + 2),
                InkWell(
                  onTap: _loading ? null : () => context.push(Routes.signup),
                  borderRadius: BorderRadius.circular(Radii.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.s1,
                      vertical: Space.s2,
                    ),
                    child: Text(
                      'ساخت حساب جدید',
                      style: context.text.bodySmall.copyWith(
                        color: c.actionPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeadline(
            title: 'خوش برگشتید',
            subtitle: 'برای ادامه، وارد حساب خود شوید.',
          ),
          if (_bannerError != null) ...[
            const SizedBox(height: Space.s5),
            NoticeBanner(message: _bannerError!, tone: NoticeTone.danger),
          ],
          const SizedBox(height: Space.s5 + 2),
          // Deck label is «شماره موبایل یا ایمیل»; API accepts phone only.
          PishroTextField.phone(
            controller: _phone,
            errorText: _phoneError,
            enabled: !_loading,
            onChanged: (_) {
              if (_phoneError != null) setState(() => _phoneError = null);
            },
          ),
          const SizedBox(height: Space.s4),
          _PasswordField(
            controller: _password,
            obscure: _obscure,
            errorText: _passwordError,
            enabled: !_loading,
            onToggleObscure: () => setState(() => _obscure = !_obscure),
            onChanged: (_) {
              if (_passwordError != null) {
                setState(() => _passwordError = null);
              }
            },
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              height: Layout.minTapTarget,
              child: InkWell(
                onTap: _loading
                    ? null
                    : () => context.push(Routes.forgotPassword),
                borderRadius: BorderRadius.circular(Radii.sm),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: Space.s2),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'فراموشی رمز عبور',
                      style: context.text.bodySmall.copyWith(
                        color: c.actionPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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

/// Password row matching deck INPUT (lock + eye toggle). Kept local because
/// [PishroTextField] only accepts a string suffix, not an icon button.
class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    this.errorText,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رمز عبور',
          style: context.text.bodySmall.copyWith(
            color: hasError
                ? c.danger
                : (enabled ? c.textSecondary : c.textMuted),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: Space.s2),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscure,
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          style: context.text.bodyMedium.copyWith(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: '••••••••',
            errorText: null,
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: hasError ? c.danger : c.textMuted,
            ),
            suffixIcon: SizedBox(
              width: Layout.minTapTarget,
              height: Layout.minTapTarget,
              child: IconButton(
                onPressed: enabled ? onToggleObscure : null,
                tooltip: obscure ? 'نمایش رمز عبور' : 'پنهان کردن رمز عبور',
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: obscure ? c.textMuted : c.actionPrimary,
                ),
              ),
            ),
            enabledBorder: hasError
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.input),
                    borderSide: BorderSide(color: c.danger),
                  )
                : null,
            focusedBorder: hasError
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.input),
                    borderSide: BorderSide(color: c.danger),
                  )
                : null,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: Space.s1 + 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.close_rounded, size: 14, color: c.danger),
              const SizedBox(width: Space.s1),
              Expanded(
                child: Text(
                  errorText!,
                  style: context.text.caption.copyWith(color: c.danger),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
