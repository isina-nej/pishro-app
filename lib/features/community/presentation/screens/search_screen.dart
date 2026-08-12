import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/common.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';
import '../widgets/analysis_card.dart';

/// Screen/Community/Search — همه / تحلیلگران / تحلیل‌ها.
class CommunitySearchScreen extends ConsumerStatefulWidget {
  const CommunitySearchScreen({super.key});

  @override
  ConsumerState<CommunitySearchScreen> createState() =>
      _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends ConsumerState<CommunitySearchScreen> {
  var _q = '';
  var _scope = SearchScope.all;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جستجو در جامعه',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.page,
              Space.s3,
              Space.page,
              Space.s2,
            ),
            child: PishroTextField(
              label: 'جستجو',
              hint: 'نام تحلیلگر، ارز یا موضوع…',
              onChanged: (v) => setState(() => _q = v.trim()),
            ),
          ),
          PishroChipBar(
            labels: [for (final s in SearchScope.values) s.label],
            selectedIndex: _scope.index,
            onSelected: (i) => setState(() => _scope = SearchScope.values[i]),
          ),
          Expanded(
            child: FutureBuilder(
              future: ref
                  .read(communityRepositoryProvider)
                  .search(_q, scope: _scope),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return ListView(
                    padding: const EdgeInsets.all(Space.page),
                    children: const [
                      Skeleton.box(height: 88),
                      SizedBox(height: Space.s3),
                      Skeleton.box(height: 88),
                    ],
                  );
                }
                final r = snap.data!;
                if (r.isEmpty) {
                  return const EmptyState(
                    title: 'نتیجه‌ای پیدا نشد',
                    message:
                        'عبارت دیگری امتحان کنید یا محدوده جستجو را عوض کنید.',
                    icon: Icons.search_off_rounded,
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(Space.page),
                  children: [
                    if (r.analysts.isNotEmpty) ...[
                      Text(
                        'تحلیلگران',
                        style: context.text.bodyMedium.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Space.s3),
                      for (final a in r.analysts)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Space.s3),
                          child: PishroCard(
                            onTap: () =>
                                context.push(Routes.analystProfile(a.id)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.displayName,
                                  style: context.text.bodyMedium.copyWith(
                                    color: c.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  a.specialty,
                                  style: context.text.caption.copyWith(
                                    color: c.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                    if (r.analyses.isNotEmpty) ...[
                      Text(
                        'تحلیل‌ها',
                        style: context.text.bodyMedium.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Space.s3),
                      for (final a in r.analyses) ...[
                        AnalysisCard(a),
                        const SizedBox(height: Space.s3),
                      ],
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
