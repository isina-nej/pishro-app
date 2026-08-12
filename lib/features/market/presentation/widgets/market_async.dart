import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/states.dart';

/// Loading / error / data for every Market screen: skeleton while fetching,
/// [ErrorStateView] with retry on failure. Keeps the twelve screens from each
/// re-inventing the same `when(...)`.
class MarketAsync<T> extends StatelessWidget {
  const MarketAsync({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.skeleton,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;
  final Widget? skeleton;

  @override
  Widget build(BuildContext context) => value.when(
    data: (data) => builder(context, data),
    loading: () => skeleton ?? const MarketListSkeleton(),
    error: (error, _) => ErrorStateView(
      message: error is ApiException
          ? error.message
          : 'اطلاعات بازار در دسترس نیست.',
      onRetry: onRetry,
    ),
  );
}

/// The shared list skeleton the deck attaches to Home/Favorites/Search/Alerts.
class MarketListSkeleton extends StatelessWidget {
  const MarketListSkeleton({super.key, this.rows = 6});

  final int rows;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.symmetric(
      horizontal: Space.page,
      vertical: Space.s3,
    ),
    itemCount: rows,
    separatorBuilder: (_, __) => const SizedBox(height: Space.s3),
    itemBuilder: (_, __) => const Row(
      children: [
        Skeleton(width: 30, height: 30, radius: Radii.pill),
        SizedBox(width: Space.s3),
        Expanded(child: Skeleton.line(width: 120)),
        SizedBox(width: Space.s3),
        Skeleton(width: 90, height: 16),
      ],
    ),
  );
}
