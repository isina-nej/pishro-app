import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../routing/routes.dart';
import '../../../../shared/widgets/pishro_badge.dart';
import '../../../../shared/widgets/pishro_button.dart';
import '../../../../shared/widgets/states.dart';
import '../../data/courses_repository.dart';

/// Screen/Course/VIPInstructorChat — نشان VIP طلا، بقیه سبز.
class VIPInstructorChatScreen extends ConsumerStatefulWidget {
  const VIPInstructorChatScreen({super.key, this.id = ''});

  final String id;

  @override
  ConsumerState<VIPInstructorChatScreen> createState() =>
      _VIPInstructorChatScreenState();
}

class _VIPInstructorChatScreenState
    extends ConsumerState<VIPInstructorChatScreen> {
  final _input = TextEditingController();
  final _messages = <_ChatMsg>[
    const _ChatMsg(
      mine: true,
      text: 'سلام، در ارتباط با تعیین حد ضرر در فصل دوم سؤال داشتم.',
      time: '۱۰:۲۴',
    ),
    const _ChatMsg(
      mine: false,
      text:
          'سلام، حتماً. لطفاً اسکرین‌شات نمودار موردنظرتان را ارسال کنید تا دقیق‌تر راهنمایی کنم.',
      time: '۱۰:۳۱',
    ),
    const _ChatMsg(
      mine: true,
      text: 'حتماً، الان ارسال می‌کنم.',
      time: '۱۰:۳۲',
    ),
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enrollment = ref.watch(enrollmentProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          enrollment.valueOrNull?.course.instructorName ?? 'گفت‌وگو با مدرس',
          style: context.text.h3.copyWith(color: c.textPrimary),
        ),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: Space.s4),
            child: PishroBadge.vip(),
          ),
        ],
      ),
      body: enrollment.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorStateView(
          onRetry: () => ref.invalidate(enrollmentProvider(widget.id)),
        ),
        data: (enrolled) {
          if (enrolled == null || !enrolled.hasInstructorChat) {
            return Padding(
              padding: const EdgeInsets.all(Space.page),
              child: Column(
                children: [
                  const Spacer(),
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 40,
                    color: c.textMuted,
                  ),
                  const SizedBox(height: Space.s4),
                  Text(
                    'گفت‌وگوی مدرس فقط روی دوره VIP',
                    textAlign: TextAlign.center,
                    style: context.text.h3.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: Space.s2),
                  Text(
                    'با ارتقا به بسته VIP می‌توانید مستقیم از مدرس بپرسید.',
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  PishroButton(
                    label: 'مشاهده بسته‌ها',
                    variant: PishroButtonVariant.premium,
                    onPressed: () =>
                        context.push(Routes.packageComparison(widget.id)),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.page,
                  Space.s3,
                  Space.page,
                  Space.s2,
                ),
                child: Column(
                  children: [
                    Text(
                      'میانگین زمان پاسخ‌گویی: کمتر از یک روز کاری',
                      style: context.text.caption.copyWith(color: c.textMuted),
                    ),
                    const SizedBox(height: Space.s2),
                    Text(
                      'این گفت‌وگو بخشی از بسته VIP شماست.',
                      style: context.text.caption.copyWith(
                        color: c.actionPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_messages.isEmpty)
                Expanded(
                  child: EmptyState(
                    title: 'هنوز پیامی ردوبدل نشده است.',
                    message:
                        'سؤال خود را درباره این دوره برای مدرس ارسال کنید.',
                    icon: Icons.chat_bubble_outline_rounded,
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(Space.page),
                    itemCount: _messages.length + 1,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Space.s3),
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return Center(
                          child: Text(
                            'امروز',
                            style: context.text.caption.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        );
                      }
                      return _Bubble(msg: _messages[i - 1]);
                    },
                  ),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.page,
                    Space.s2,
                    Space.page,
                    Space.s3,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: 'پیام خود را بنویسید…',
                            hintStyle: context.text.bodySmall.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Space.s2),
                      IconButton(
                        tooltip: 'ارسال',
                        onPressed: _send,
                        icon: Icon(Icons.send_rounded, color: c.actionPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(mine: true, text: text, time: 'الان'));
      _input.clear();
    });
  }
}

class _ChatMsg {
  const _ChatMsg({required this.mine, required this.text, required this.time});
  final bool mine;
  final String text;
  final String time;
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});
  final _ChatMsg msg;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Align(
      alignment: msg.mine ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.all(Space.s3),
          decoration: BoxDecoration(
            color: msg.mine ? c.surfaceSelected : c.surfaceSecondary,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(
              color: msg.mine ? c.borderActive : c.borderDefault,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                msg.text,
                style: context.text.bodySmall.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: Space.s1),
              Text(
                msg.time,
                style: context.text.micro.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
