import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_text_field.dart';
import '../../data/courses_repository.dart';

/// Screen/Courses/Search — «۰۲ · جست‌وجو» · کیبورد باز.
class CoursesSearchScreen extends ConsumerStatefulWidget {
  const CoursesSearchScreen({super.key});

  @override
  ConsumerState<CoursesSearchScreen> createState() =>
      _CoursesSearchScreenState();
}

class _CoursesSearchScreenState extends ConsumerState<CoursesSearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(courseQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String raw) {
    final q = Fmt.toAscii(raw).trim();
    ref.read(courseQueryProvider.notifier).state = q;
    if (q.isNotEmpty) ref.read(recentSearchesProvider.notifier).add(q);
    context.push(Routes.courseSearchResults);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final recents = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جست‌وجو',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'فیلترها',
            onPressed: () => context.push(Routes.courseFilters),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          PishroTextField(
            controller: _controller,
            label: 'جست‌وجوی دوره',
            hint: 'تحلیل تکنیکال، مدیریت ریسک…',
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (v) =>
                ref.read(courseQueryProvider.notifier).state = v.trim(),
          ),
          const SizedBox(height: Space.s3),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => _submit(_controller.text),
              child: Text(
                'مشاهده نتایج',
                style: context.text.bodySmall.copyWith(
                  color: c.actionPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.s5),
          Row(
            children: [
              Text(
                'جست‌وجوهای اخیر',
                style: context.text.bodySmall.copyWith(
                  color: c.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (recents.isNotEmpty)
                TextButton(
                  onPressed: () =>
                      ref.read(recentSearchesProvider.notifier).clear(),
                  child: const Text('پاک کردن'),
                ),
            ],
          ),
          const SizedBox(height: Space.s2),
          if (recents.isEmpty)
            Text(
              'هنوز جست‌وجویی ثبت نشده است.',
              style: context.text.caption.copyWith(color: c.textMuted),
            )
          else
            Wrap(
              spacing: Space.s2,
              runSpacing: Space.s2,
              children: [
                for (final term in recents)
                  ActionChip(
                    label: Text(term),
                    onPressed: () {
                      _controller.text = term;
                      _submit(term);
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
