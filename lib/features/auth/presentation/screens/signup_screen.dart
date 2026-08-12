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
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/auth_repository.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/consent_checkbox.dart';

/// Screen/Auth/Signup — «ثبت‌نام».
///
/// Deck rule: «دو تیک را بزنید تا دکمه فعال شود» — both consents must be
/// checked before the CTA enables. Backend `/auth/signup` only reads
/// `phone` + `password`; name/email/referral stay local for the deck UI.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordAgain = TextEditingController();
  final _referral = TextEditingController();

  bool _obscure = true;
  bool _obscureAgain = true;
  bool _terms = false;
  bool _privacy = false;
  bool _submitted = false;
  bool _loading = false;
  bool _showReferral = false;

  String? _bannerError;
  String? _phoneError;
  String? _passwordError;
  String? _passwordAgainError;

  bool get _consentsOk => _terms && _privacy;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _passwordAgain.dispose();
    _referral.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() {
      _submitted = true;
      _bannerError = null;
      _phoneError = null;
      _passwordError = null;
      _passwordAgainError = null;
    });
    if (!_consentsOk) return;

    final phone = Fmt.toAscii(_phone.text.trim());
    final password = _password.text;
    final again = _passwordAgain.text;

    var valid = true;
    if (!_isValidPhone(phone)) {
      _phoneError = 'شماره موبایل واردشده معتبر نیست.';
      valid = false;
    }
    if (password.length < 8 ||
        !RegExp(r'[A-Za-z\u0600-\u06FF]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password)) {
      _passwordError = 'حداقل ۸ کاراکتر، شامل حرف و عدد';
      valid = false;
    }
    if (again != password) {
      _passwordAgainError = 'تکرار رمز عبور با رمز عبور یکسان نیست.';
      valid = false;
    }
    if (!valid) {
      setState(() {});
      return;
    }

    setState(() => _loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signup(phone: phone, password: password);
      if (!mounted) return;
      context.push('${Routes.otp}?phone=${Uri.encodeComponent(phone)}');
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
    final ctaEnabled = _consentsOk && !_loading;

    return AuthScaffold(
      title: 'ساخت حساب',
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PishroButton(
            label: 'ساخت حساب',
            loading: _loading,
            onPressed: ctaEnabled ? _submit : null,
          ),
          if (!_consentsOk) ...[
            const SizedBox(height: Space.s2),
            Text(
              'برای ادامه، هر دو مورد را بپذیرید.',
              textAlign: TextAlign.center,
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
          ],
          SizedBox(
            height: Layout.minTapTarget,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'حساب دارید؟',
                  style: context.text.bodySmall.copyWith(color: c.textMuted),
                ),
                const SizedBox(width: Space.s1 + 2),
                InkWell(
                  onTap: _loading ? null : () => context.push(Routes.login),
                  borderRadius: BorderRadius.circular(Radii.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.s1,
                      vertical: Space.s2,
                    ),
                    child: Text(
                      'ورود',
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
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AuthScaffold.gutter,
          Space.s4,
          AuthScaffold.gutter,
          Space.s4,
        ),
        children: [
          if (_bannerError != null) ...[
            NoticeBanner(message: _bannerError!, tone: NoticeTone.danger),
            const SizedBox(height: Space.s4),
          ],
          Row(
            children: [
              Expanded(
                child: PishroTextField(
                  controller: _firstName,
                  label: 'نام',
                  hint: 'سارا',
                  enabled: !_loading,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: Space.s3),
              Expanded(
                child: PishroTextField(
                  controller: _lastName,
                  label: 'نام خانوادگی',
                  hint: 'نمونه',
                  enabled: !_loading,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.s4),
          PishroTextField.phone(
            controller: _phone,
            errorText: _phoneError,
            enabled: !_loading,
            onChanged: (_) {
              if (_phoneError != null) setState(() => _phoneError = null);
            },
          ),
          const SizedBox(height: Space.s4),
          PishroTextField(
            controller: _email,
            label: 'ایمیل',
            hint: 'sample@example.com',
            keyboardType: TextInputType.emailAddress,
            enabled: !_loading,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: Space.s4),
          _SignupPasswordField(
            label: 'رمز عبور',
            helper: 'حداقل ۸ کاراکتر، شامل حرف و عدد',
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
          const SizedBox(height: Space.s4),
          _SignupPasswordField(
            label: 'تکرار رمز عبور',
            controller: _passwordAgain,
            obscure: _obscureAgain,
            errorText: _passwordAgainError,
            enabled: !_loading,
            onToggleObscure: () =>
                setState(() => _obscureAgain = !_obscureAgain),
            onChanged: (_) {
              if (_passwordAgainError != null) {
                setState(() => _passwordAgainError = null);
              }
            },
          ),
          const SizedBox(height: Space.s3),
          if (!_showReferral)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                height: Layout.minTapTarget,
                child: InkWell(
                  onTap: _loading
                      ? null
                      : () => setState(() => _showReferral = true),
                  borderRadius: BorderRadius.circular(Radii.sm),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: Space.s2),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'افزودن کد معرف (اختیاری)',
                        style: context.text.bodySmall.copyWith(
                          color: c.actionPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else ...[
            PishroTextField(
              controller: _referral,
              label: 'کد معرف (اختیاری)',
              enabled: !_loading,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: Space.s3),
          ],
          ConsentCheckbox(
            value: _terms,
            showRequired: _submitted,
            onChanged: (v) => setState(() => _terms = v),
            label: 'قوانین و شرایط استفاده را مطالعه کرده‌ام و می‌پذیرم',
          ),
          ConsentCheckbox(
            value: _privacy,
            showRequired: _submitted,
            onChanged: (v) => setState(() => _privacy = v),
            label: 'سیاست حریم خصوصی را می‌پذیرم',
          ),
        ],
      ),
    );
  }
}

/// Local password row — [PishroTextField] only accepts a string suffix.
class _SignupPasswordField extends StatelessWidget {
  const _SignupPasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    this.helper,
    this.errorText,
    this.enabled = true,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String? helper;
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
          label,
          style: context.text.bodySmall.copyWith(
            color: enabled ? c.textSecondary : c.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: Space.s2),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscure,
          onChanged: onChanged,
          style: context.text.bodyMedium.copyWith(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: '••••••••',
            errorText: null,
            suffixIcon: IconButton(
              tooltip: obscure ? 'نمایش رمز' : 'پنهان‌کردن رمز',
              onPressed: enabled ? onToggleObscure : null,
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: c.textMuted,
              ),
            ),
            enabledBorder: hasError
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.input),
                    borderSide: BorderSide(color: c.danger),
                  )
                : null,
          ),
        ),
        if (hasError || helper != null) ...[
          const SizedBox(height: Space.s1 + 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasError) ...[
                Icon(Icons.close_rounded, size: 14, color: c.danger),
                const SizedBox(width: Space.s1),
              ],
              Expanded(
                child: Text(
                  hasError ? errorText! : helper!,
                  style: context.text.caption.copyWith(
                    color: hasError ? c.danger : c.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
