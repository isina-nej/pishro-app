import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../data/investment_flow.dart';

/// Screen/Investment/Processing — بدون ثبت تکراری.
class InvestmentProcessingScreen extends ConsumerStatefulWidget {
  const InvestmentProcessingScreen({super.key});

  @override
  ConsumerState<InvestmentProcessingScreen> createState() =>
      _InvestmentProcessingScreenState();
}

class _InvestmentProcessingScreenState
    extends ConsumerState<InvestmentProcessingScreen> {
  var _started = false;
  String? _error;
  var _unknown = false;

  static const _steps = [
    'بررسی اطلاعات',
    'تأیید منبع وجه',
    'ثبت پذیرش قرارداد',
    'ایجاد رکورد سرمایه‌گذاری',
    'بررسی وضعیت فعال‌سازی',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (_started) return;
    _started = true;
    try {
      await ref.read(investmentFlowProvider.notifier).submit();
      if (!mounted) return;
      context.go(Routes.investmentSuccess);
    } on NetworkException {
      if (!mounted) return;
      setState(() => _unknown = true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'ثبت درخواست انجام نشد.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (_unknown) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'وضعیت نامشخص',
            style: context.text.h3.copyWith(color: c.textPrimary),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.hourglass_top_rounded, size: 48, color: c.warning),
              const SizedBox(height: Space.s4),
              Text(
                'وضعیت درخواست هنوز مشخص نشده است.',
                textAlign: TextAlign.center,
                style: context.text.h3.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              Text(
                'نامشخص هرگز به‌عنوان ناموفق نمایش داده نمی‌شود. نیازی به ارسال مجدد نیست.',
                textAlign: TextAlign.center,
                style: context.text.bodySmall.copyWith(color: c.textSecondary),
              ),
              const Spacer(),
              PishroButton(
                label: 'بررسی دوباره',
                onPressed: () {
                  setState(() {
                    _unknown = false;
                    _started = false;
                  });
                  _run();
                },
              ),
            ],
          ),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Space.s6),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium.copyWith(color: c.danger),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.page),
          child: Column(
            children: [
              const Spacer(),
              CircularProgressIndicator(color: c.actionPrimary),
              const SizedBox(height: Space.s5),
              Text(
                'در حال ثبت درخواست',
                style: context.text.h2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s2),
              Text(
                'درخواست شما در حال بررسی و ثبت است.',
                style: context.text.bodySmall.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Space.s6),
              for (var i = 0; i < _steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.s3),
                  child: Row(
                    children: [
                      Icon(
                        i == 0
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: i == 0 ? c.actionPrimary : c.textMuted,
                      ),
                      const SizedBox(width: Space.s3),
                      Text(
                        _steps[i],
                        style: context.text.bodySmall.copyWith(
                          color: i == 0 ? c.textPrimary : c.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
