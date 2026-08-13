import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/account_repository.dart';

/// Screen/Account/EditProfile — «۰۳ · ویرایش اطلاعات».
///
/// نام/نام خانوادگی/ایمیل go to `/user/personal`. نام کاربری، شهر و کلیدهای
/// نمایش عمومی endpoint ندارند و از مخزن mock می‌آیند. کد ملی قفل است.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _city = TextEditingController();

  var _loading = false;
  String? _error;
  bool _publicProfile = false;
  bool _avatarPublic = false;

  /// null = not checked yet for the current text.
  bool? _usernameFree;

  @override
  void initState() {
    super.initState();
    ref.listenManual(accountProfileProvider, (_, next) {
      next.whenData((p) {
        _first.text = p.firstName ?? '';
        _last.text = p.lastName ?? '';
        _email.text = p.email ?? '';
      });
    }, fireImmediately: true);

    ref.listenManual(profileExtrasProvider, (_, next) {
      next.whenData((e) {
        _username.text = e.username;
        _city.text = e.city;
        if (mounted) {
          setState(() {
            _publicProfile = e.publicProfile;
            _avatarPublic = e.avatarPublic;
          });
        }
      });
    }, fireImmediately: true);

    _username.addListener(() {
      if (_usernameFree != null) setState(() => _usernameFree = null);
    });
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _username.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _checkUsername() async {
    final free = await ref
        .read(accountMockProvider)
        .isUsernameAvailable(_username.text);
    if (mounted) setState(() => _usernameFree = free);
  }

  Future<void> _save() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(accountRepositoryProvider)
          .updatePersonal(
            firstName: _first.text,
            lastName: _last.text,
            email: _email.text,
          );
      await ref
          .read(accountMockProvider)
          .saveProfileExtras(
            ProfileExtras(
              username: _username.text.trim(),
              city: _city.text.trim(),
              publicProfile: _publicProfile,
              avatarPublic: _avatarPublic,
            ),
          );
      ref.invalidate(accountProfileProvider);
      ref.invalidate(profileExtrasProvider);
      if (mounted) context.pop();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final profile = ref.watch(accountProfileProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => context.pop(),
          child: const Text('انصراف'),
        ),
        leadingWidth: 88,
        title: Text(
          'ویرایش اطلاعات',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          if (_error != null) ...[
            NoticeBanner(message: _error!, tone: NoticeTone.danger),
            const SizedBox(height: Space.s4),
          ],
          PishroTextField(controller: _first, label: 'نام'),
          const SizedBox(height: Space.s4),
          PishroTextField(controller: _last, label: 'نام خانوادگی'),
          const SizedBox(height: Space.s4),
          Text(
            'نام نمایشی: ${profile?.displayName ?? '—'}',
            style: context.text.caption.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.s4),
          PishroTextField(
            controller: _username,
            label: 'نام کاربری',
            hint: 'sample_user',
            helper: switch (_usernameFree) {
              true => 'در دسترس است',
              false => 'این نام کاربری در دسترس نیست',
              null => 'برای بررسی در دسترس بودن، «بررسی» را بزنید.',
            },
          ),
          const SizedBox(height: Space.s2),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: PishroButton(
              label: 'بررسی نام کاربری',
              variant: PishroButtonVariant.ghost,
              onPressed: _checkUsername,
            ),
          ),
          const SizedBox(height: Space.s4),
          PishroTextField(controller: _email, label: 'ایمیل', hint: 'اختیاری'),
          const SizedBox(height: Space.s4),
          PishroTextField(controller: _city, label: 'شهر', hint: 'تهران'),
          const SizedBox(height: Space.s4),
          PishroTextField(
            label: 'شماره موبایل',
            hint: profile?.phone ?? '',
            enabled: false,
          ),
          const SizedBox(height: Space.s4),
          const PishroTextField(
            label: 'کد ملی',
            hint: 'غیرقابل ویرایش',
            helper: 'کد ملی پس از ثبت قابل ویرایش نیست.',
            enabled: false,
          ),
          const SizedBox(height: Space.s5),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _publicProfile,
            onChanged: (v) => setState(() => _publicProfile = v),
            title: Text(
              'نمایش عمومی پروفایل',
              style: context.text.bodySmall.copyWith(color: c.textPrimary),
            ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            // The switch is worded as privacy, so ON must mean *more* private.
            // The stored flag is the opposite (avatarPublic), hence the flip.
            value: !_avatarPublic,
            onChanged: (v) => setState(() => _avatarPublic = !v),
            title: Text(
              'حریم خصوصی تصویر پروفایل',
              style: context.text.bodySmall.copyWith(color: c.textPrimary),
            ),
            subtitle: Text(
              'با روشن‌بودن، تصویر پروفایل فقط برای خود شما نمایش داده می‌شود.',
              style: context.text.caption.copyWith(color: c.textMuted),
            ),
          ),
          const SizedBox(height: Space.s3),
          const NoticeBanner(
            message:
                'نام کاربری، شهر و کلیدهای نمایش عمومی هنوز به سرویس حساب وصل '
                'نیستند و فقط روی همین دستگاه نگهداری می‌شوند.',
            tone: NoticeTone.info,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'ذخیره تغییرات',
            loading: _loading,
            onPressed: _save,
          ),
        ),
      ),
    );
  }
}
