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

/// Screen/Account/EditProfile — کد ملی غیرقابل ویرایش.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  var _loading = false;
  String? _error;

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
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    super.dispose();
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
      ref.invalidate(accountProfileProvider);
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
        title: Text(
          'ویرایش پروفایل',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          if (_error != null)
            NoticeBanner(message: _error!, tone: NoticeTone.danger),
          PishroTextField(controller: _first, label: 'نام'),
          const SizedBox(height: Space.s4),
          PishroTextField(controller: _last, label: 'نام خانوادگی'),
          const SizedBox(height: Space.s4),
          PishroTextField(controller: _email, label: 'ایمیل', hint: 'اختیاری'),
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
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: PishroButton(
            label: 'ذخیره',
            loading: _loading,
            onPressed: _save,
          ),
        ),
      ),
    );
  }
}
