import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../data/investment_flow.dart';

/// Screen/Investment/Processing.
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: c.actionPrimary),
            const SizedBox(height: Space.s4),
            Text(
              'در حال ثبت درخواست…',
              style: context.text.h3.copyWith(color: c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
