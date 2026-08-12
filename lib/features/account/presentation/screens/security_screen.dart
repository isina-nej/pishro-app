import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/account_repository.dart';

class AccountSecurityScreen extends ConsumerStatefulWidget {
  const AccountSecurityScreen({super.key});
  @override
  ConsumerState<AccountSecurityScreen> createState() =>
      _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends ConsumerState<AccountSecurityScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  var _loading = false;
  String? _error;
  String? _ok;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _error = null;
      _ok = null;
    });
    try {
      await ref
          .read(accountRepositoryProvider)
          .changePassword(
            currentPassword: _current.text,
            newPassword: _next.text,
          );
      setState(() => _ok = 'رمز عبور به‌روز شد.');
      _current.clear();
      _next.clear();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'امنیت',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          if (_error != null)
            NoticeBanner(message: _error!, tone: NoticeTone.danger),
          if (_ok != null)
            NoticeBanner(message: _ok!, tone: NoticeTone.success),
          PishroTextField(
            controller: _current,
            label: 'رمز فعلی',
            obscure: true,
          ),
          const SizedBox(height: Space.s4),
          PishroTextField(controller: _next, label: 'رمز جدید', obscure: true),
          const SizedBox(height: Space.s5),
          PishroButton(label: 'تغییر رمز', loading: _loading, onPressed: _save),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('دستگاه‌های فعال'),
            trailing: const Icon(Icons.chevron_left_rounded),
            onTap: () => context.push(Routes.devices),
          ),
        ],
      ),
    );
  }
}
