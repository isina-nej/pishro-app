import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_chip.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../../../shared/widgets/states.dart';

import '../../data/community_models.dart';
import '../../data/community_repository.dart';

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
          'جستجوی جامعه',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Space.page),
            child: PishroTextField(
              label: 'جستجو',
              hint: 'تحلیلگر یا عنوان',
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
                  return const Center(child: CircularProgressIndicator());
                }
                final r = snap.data!;
                if (r.isEmpty) return const EmptyState(title: 'نتیجه‌ای نیست');
                return ListView(
                  padding: const EdgeInsets.all(Space.page),
                  children: [
                    for (final a in r.analysts)
                      ListTile(
                        title: Text(a.displayName),
                        subtitle: Text(a.specialty),
                        onTap: () => context.push(Routes.analystProfile(a.id)),
                      ),
                    for (final a in r.analyses)
                      ListTile(
                        title: Text(a.title),
                        subtitle: Text(a.assetSymbol),
                        onTap: () => context.push(Routes.analysisDetails(a.id)),
                      ),
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
