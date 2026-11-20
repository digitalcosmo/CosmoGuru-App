import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/planner_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/report_controller.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/dates.dart';
import '../../../models/five_d.dart';
import '../../../models/zone.dart';
import '../../../routes/app_routes.dart';
import '../../../ui/brand.dart';
import '../../../ui/controls.dart';
import '../../../ui/dim_bars.dart';
import '../../../ui/glass.dart';
import '../../../ui/links.dart';
import '../../../ui/motion.dart';
import '../../../ui/pal.dart';
import '../../../ui/states.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/tab_page.dart';
import '../../../ui/tokens.dart';
import '../../../ui/zone_icon.dart';
import '../../rashi/views/rashi_tab.dart';

/// Home: the client's own day first (planner + rashi), then what CosmoGuru
/// is and offers — content from cosmoguru.net, built natively (no webviews).
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = Get.find<ReportController>();
    return TabPage(
      gap: 28,
      onRefresh: () async => reports.load(),
      children: const [
        _TopBar(),
        _Hero(),
        _MyDay(),
        _RashiTeaser(),
        _Problems(),
        _CvptSection(),
        _ZonesSection(),
        _FiveDSection(),
        _ReportsSection(),
        _CosmoMeet(),
        _CourseSection(),
        _FounderSection(),
        _StatsAndReviews(),
        _CosmoTv(),
        _BeginSection(),
      ],
    );
  }
}

// ─────────────────────────── top ───────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final p = Get.find<ProfileController>();
    return Row(
      children: [
        const BrandMark(size: 38),
        const Spacer(),
        Pressable(
          onTap: () => Get.toNamed(AppRoutes.profile),
          child: Obx(() {
            final n = p.displayName.trim();
            return Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.redSoft,
                border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
              ),
              alignment: Alignment.center,
              child: n.isEmpty
                  ? const StrokeIcon(Ic.user, color: AppColors.red, size: 19)
                  : Text(n[0].toUpperCase(), style: T.h3.copyWith(color: AppColors.red)),
            );
          }),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final p = Get.find<ProfileController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final first = p.firstName.value.trim();
          return Text(
            '${_greeting()}${first.isEmpty ? '' : ', $first'} · ${fmtDayLong(DateTime.now())}',
            style: T.small.copyWith(fontWeight: FontWeight.w600, color: AppColors.tx2),
          );
        }),
        const SizedBox(height: 14),
        Text('SEE THE PATTERN. THEN DECIDE.', style: T.eyebrow),
        const SizedBox(height: 8),
        Text('Know the timing\nof your life', style: T.h1.copyWith(fontSize: 34, height: 1.08)),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(style: T.muted.copyWith(fontSize: 15), children: const [
            TextSpan(text: 'Before a job, an investment, a marriage or a new beginning — know the '),
            TextSpan(text: 'When', style: TextStyle(color: AppColors.tx, fontWeight: FontWeight.w700)),
            TextSpan(text: ', '),
            TextSpan(text: 'How', style: TextStyle(color: AppColors.tx, fontWeight: FontWeight.w700)),
            TextSpan(text: ' and '),
            TextSpan(text: 'What', style: TextStyle(color: AppColors.tx, fontWeight: FontWeight.w700)),
            TextSpan(text: ' of it, and plan with clarity.'),
          ]),
        ),
      ],
    );
  }
}

/// The client's planner for today, or a pointer to get one.
class _MyDay extends StatelessWidget {
  const _MyDay();

  @override
  Widget build(BuildContext context) {
    final reports = Get.find<ReportController>();
    final planner = Get.find<PlannerController>();
    final home = Get.find<HomeController>();
    return Obx(() {
      final rep = reports.selected.value;
      if (rep != null && rep.coversToday) {
        final res = planner.dailyOf(today());
        return Pressable(
          onTap: () {
            planner.openDay(today());
            home.changeNav(HomeController.tabPlanner);
          },
          child: Glass(
            dark: true,
            padding: const EdgeInsets.all(20),
            child: Builder(builder: (context) {
              final p = Pal.of(context);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('CK PLANNER · TODAY', style: T.cap.copyWith(color: AppColors.orange))),
                      Text(rep.name, style: T.small.copyWith(color: p.tx3)),
                      const SizedBox(width: 6),
                      StrokeIcon(Ic.chevRight, color: p.tx3, size: 16),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Your day across five areas', style: T.h3),
                  const SizedBox(height: 18),
                  ResultSwitch(
                    result: res,
                    onRetry: () => planner.ensureDaily(today(), force: true),
                    builder: (ok) => DimBars(ok.data!),
                  ),
                ],
              );
            }),
          ),
        );
      }
      // No live planner: explain what it is and where to get it.
      return Glass(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('YOUR CK PLANNER', style: T.eyebrow),
            const SizedBox(height: 8),
            Text(
              rep == null ? 'Plan by your pattern, not the calendar' : '${rep.name}\'s planner isn\'t running today',
              style: T.h3,
            ),
            const SizedBox(height: 8),
            Text(
              rep == null
                  ? 'The calendar gives everyone the same dates. Your planner shows which ones are yours — '
                      'day by day, week by week and month by month.'
                  : 'It covers ${fmtDayShort(rep.start)} ${rep.start.year} – ${fmtDayShort(rep.end)} ${rep.end.year}. '
                      'Open it to browse any day in that range.',
              style: T.muted,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (rep != null)
                  SecondaryButton(
                    label: 'Open planner',
                    onTap: () => home.changeNav(HomeController.tabPlanner),
                  )
                else if (showPurchaseLinks)
                  SecondaryButton(label: 'Get my report', onTap: () => openWebsite(Brand.reportsUrl))
                else
                  SecondaryButton(
                    label: 'Talk to us',
                    onTap: () => home.changeNav(HomeController.tabContact),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _RashiTeaser extends StatelessWidget {
  const _RashiTeaser();

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          eyebrow: 'RASHI BHAVISHYA',
          title: 'Your rashi, today',
          action: 'All rashis',
          onAction: () => home.changeNav(HomeController.tabRashi),
        ),
        const SizedBox(height: 14),
        const RashiPicker(),
        const SizedBox(height: 14),
        const RashiReadingCard(compact: true),
      ],
    );
  }
}

// ─────────────────────────── about CosmoGuru ───────────────────────────

class _SectionTitle extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;
  const _SectionTitle({required this.eyebrow, required this.title, this.subtitle, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eyebrow, style: T.eyebrow),
                  const SizedBox(height: 6),
                  Text(title, style: T.h2),
                ],
              ),
            ),
            if (action != null) LinkText(action!, onTap: onAction),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: T.muted),
        ],
      ],
    );
  }
}

class _Problems extends StatelessWidget {
  const _Problems();

  static const _items = [
    ('Doing everything right — at the wrong time?', 'Effort works best when timing is with you. Know the window before you act.'),
    ('The same problem, again and again?', 'That is a pattern — and a pattern can be read, understood and worked with.'),
    ('A big decision, and no clarity?', 'See the When, How and What of the result first. Then decide — with confidence.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('WHY PEOPLE COME TO COSMOGURU™', style: T.eyebrow),
        const SizedBox(height: 8),
        Text.rich(TextSpan(style: T.h2, children: const [
          TextSpan(text: 'Destiny draws the pattern.\n'),
          TextSpan(text: 'Your decisions write the story.', style: TextStyle(color: AppColors.red)),
        ])),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 250,
              child: Glass(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_items[i].$1, style: T.h3.copyWith(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(_items[i].$2, style: T.muted.copyWith(fontSize: 13.5)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Glass(
          dark: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WE ARE PATTERN SPECIALISTS', style: T.cap.copyWith(color: AppColors.orange)),
              const SizedBox(height: 8),
              Text('We read the pattern behind what keeps happening.', style: T.h3),
              const SizedBox(height: 6),
              Builder(
                builder: (context) => Text(
                  'Your career, money, health and relationships move in cycles. We map them, so nothing feels random again.',
                  style: T.muted.copyWith(color: Pal.of(context).tx2, fontSize: 13.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Glass(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WE ARE DECISION STRATEGISTS', style: T.eyebrow.copyWith(fontSize: 11)),
              const SizedBox(height: 8),
              Text('We turn your pattern into your next right move.', style: T.h3),
              const SizedBox(height: 6),
              Text('What to push, what to pause, and when. You still make the decision — now with a strategy behind it.',
                  style: T.muted.copyWith(fontSize: 13.5)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CvptSection extends StatelessWidget {
  const _CvptSection();

  static const _qs = [
    ('When', 'Time', 'When is it likely to happen? The window to act — or to wait.', 'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM12 7v5l3 2'),
    ('How', 'Trend', 'How will it unfold? Smoothly, slowly or with resistance.', 'M3 17l6-6 4 4 8-8M15 7h6v6'),
    ('What', 'Trigger', 'What can set it off? The area, person or event to watch.', 'M13 3L4 14h7l-1 7 9-11h-7z'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(
          eyebrow: 'CVPT™ · COSMOLOGICAL VIBRATION PREDICTIVE TECHNOLOGY',
          title: 'Three clear answers for every result',
          subtitle: 'Ask about any result — a job, a deal, a marriage, a move. CVPT™ answers three questions.',
        ),
        const SizedBox(height: 14),
        for (final q in _qs) ...[
          Glass(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: AppColors.redSoft, borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.center,
                  child: StrokeIcon(q.$4, color: AppColors.red, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(style: T.h3.copyWith(fontSize: 16), children: [
                        TextSpan(text: q.$1),
                        TextSpan(text: '  ·  ${q.$2}', style: T.small.copyWith(fontWeight: FontWeight.w600)),
                      ])),
                      const SizedBox(height: 4),
                      Text(q.$3, style: T.muted.copyWith(fontSize: 13.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 4),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (i, s) in ['Pattern', 'Diagnosis', 'Remedies', 'Outcome'].indexed) ...[
              if (i > 0) Text('→', style: T.small),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(s, style: T.small.copyWith(color: AppColors.tx, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'CVPT does not predict how big a result will be, and is no substitute for medical, legal or financial advice.',
          style: T.small.copyWith(fontSize: 11.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ZonesSection extends StatelessWidget {
  const _ZonesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(
          eyebrow: 'SITUATION · AROUND YOU',
          title: 'Seven zones, seven actions',
          subtitle: 'Every reading falls into one of seven zones — and each zone comes with a clear action.',
        ),
        const SizedBox(height: 14),
        Glass(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              for (final (i, z) in Zone.values.reversed.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    border: i == 6 ? null : const Border(bottom: BorderSide(color: AppColors.line)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: ZoneIcon(z, size: 22),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 82,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(z.label, style: T.strong.copyWith(fontSize: 14, color: z.ink)),
                            Text('${z.from}–${z.to}%', style: T.small.copyWith(fontSize: 11.5)),
                          ],
                        ),
                      ),
                      Expanded(child: Text(z.advice, style: T.muted.copyWith(fontSize: 13.5, color: AppColors.tx))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FiveDSection extends StatelessWidget {
  const _FiveDSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(
          eyebrow: '5D',
          title: 'Read across the 5 dimensions of life',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final d in kDims)
              SizedBox(
                width: (MediaQuery.of(context).size.width - 40 - 10) / 2,
                child: Glass(
                  padding: const EdgeInsets.all(14),
                  radius: 20,
                  child: Row(
                    children: [
                      DimBadge(d, size: 34),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.label, style: T.strong.copyWith(fontSize: 14)),
                            Text(d.meaning, style: T.small.copyWith(fontSize: 11.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text('Daily 5D is for routine events, weekly for frequent events and monthly for rare events.',
            style: T.small, textAlign: TextAlign.center),
      ],
    );
  }
}

// ─────────────────────────── offerings ───────────────────────────

class _ReportsSection extends StatelessWidget {
  const _ReportsSection();

  static const _plans = [
    ('CK Planner', 'Daily Sentiment and Situation', 'from ₹900'),
    ('CK Planner Plus', 'Adds monthly 5D Situation', 'from ₹2,200'),
    ('CK Planner Max', '5D daily, weekly and monthly', 'from ₹4,500'),
  ];

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(
          eyebrow: 'PREDICTION REPORTS',
          title: 'Plan by your pattern, not the calendar',
          subtitle: 'The calendar gives everyone the same dates. Your pattern shows which ones are yours.',
        ),
        const SizedBox(height: 14),
        Glass(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Column(
            children: [
              for (final (i, p) in _plans.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: i == _plans.length - 1 ? null : const Border(bottom: BorderSide(color: AppColors.line)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: [AppColors.orange, AppColors.red, AppColors.navy][i],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.$1, style: T.strong),
                            Text(p.$2, style: T.small),
                          ],
                        ),
                      ),
                      if (showPurchaseLinks) Text(p.$3, style: T.strong.copyWith(fontSize: 13.5, color: AppColors.red)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (showPurchaseLinks)
          PrimaryButton(label: 'Get my report', onTap: () => openWebsite(Brand.reportsUrl))
        else
          Center(child: LinkText('Questions about reports? Talk to us', onTap: () => home.changeNav(HomeController.tabContact))),
      ],
    );
  }
}

class _CosmoMeet extends StatelessWidget {
  const _CosmoMeet();

  @override
  Widget build(BuildContext context) {
    return Glass(
      dark: true,
      padding: const EdgeInsets.all(20),
      child: Builder(builder: (context) {
        final p = Pal.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COSMO MEET', style: T.cap.copyWith(color: AppColors.orange)),
            const SizedBox(height: 8),
            Text('Talk to a Cosmologer™', style: T.h2),
            const SizedBox(height: 6),
            Text('Your decision strategist for one big question — 20 minutes. Audio or video, in English, ગુજરાતી or हिंदी, with a certified CVPT™ Cosmologer™.',
                style: T.muted.copyWith(color: p.tx2, fontSize: 13.5)),
            const SizedBox(height: 16),
            Row(
              children: [
                PrimaryButton(
                  label: 'Book on WhatsApp',
                  expand: false,
                  icon: 'M21 12a9 9 0 0 1-13.5 7.8L3 21l1.2-4.5A9 9 0 1 1 21 12z',
                  color: AppColors.whatsapp,
                  onTap: () => openWhatsApp('Hi CosmoGuru, I would like to book a Cosmo Meet consultation.'),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _CourseSection extends StatelessWidget {
  const _CourseSection();

  static const _tracks = [
    ('Fast', '2 Sundays, LIVE', '₹9,000'),
    ('Regular', '12 weeks · next batch Jan', '₹9,000'),
    ('Flexi', 'Recorded, any day', '₹4,500'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(
          eyebrow: 'LEARN · CVPT™ JYOTISH GYATA',
          title: 'Jyotish that finally makes sense',
          subtitle: '16 modules, from zero — one clear method instead of a hundred confusing rules. '
              'Learn to read patterns, for yourself and for others.',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final (i, t) in _tracks.indexed) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: Glass(
                  padding: const EdgeInsets.all(14),
                  radius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.$1, style: T.h3.copyWith(fontSize: 15.5)),
                      const SizedBox(height: 4),
                      Text(t.$2, style: T.small.copyWith(fontSize: 11.5)),
                      if (showPurchaseLinks) ...[
                        const SizedBox(height: 10),
                        Text(t.$3, style: T.strong.copyWith(fontSize: 14, color: AppColors.red)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const _Pill('LIVE classes'),
            const SizedBox(width: 8),
            const _Pill('Certificate'),
            const SizedBox(width: 8),
            const _Pill('4.9 · 5,000+ students'),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Join a free class',
                expand: true,
                onTap: () => openWhatsApp('Hi CosmoGuru, I would like to join a free CVPT™ class.'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: T.small.copyWith(fontSize: 11, color: AppColors.green, fontWeight: FontWeight.w600)),
    );
  }
}

class _FounderSection extends StatelessWidget {
  const _FounderSection();

  static const _facts = [
    ('Faculty', 'Jyotish and Vastu — Gujarat University, L J University, KP Global University, Bharatiya Vidya Bhavan'),
    ('Recognition', 'Pride of Gujarat — Most Trusted Astrology Guru (Divya Bhaskar Group)'),
    ('Research', 'Head of R&D, Cosmo Research Foundation'),
    ('Author', 'Shree Ram 7119 BCE and other books'),
  ];

  @override
  Widget build(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FOUNDER', style: T.eyebrow),
          const SizedBox(height: 10),
          Text('“Human life is a continuous series of decisions.”', style: T.h2.copyWith(fontSize: 20)),
          const SizedBox(height: 12),
          Text('Maulik Bhatt', style: T.strong),
          Text('CosmoGURU™ · Founder, CVPT™ · Researching since 1999', style: T.small),
          const SizedBox(height: 10),
          Text(
            'Since 1999 he has chased one question: can Jyotish be made precise, testable and teachable? '
            'CVPT™ is his answer — now learnt by 5,000+ students.',
            style: T.muted.copyWith(fontSize: 13.5),
          ),
          const SizedBox(height: 14),
          for (final f in _facts)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 92, child: Text(f.$1, style: T.small.copyWith(fontWeight: FontWeight.w700, color: AppColors.tx))),
                  Expanded(child: Text(f.$2, style: T.small.copyWith(color: AppColors.tx2))),
                ],
              ),
            ),
          const SizedBox(height: 4),
          LinkText('Talk to Maulik Bhatt', onTap: () => openWhatsApp('Hi CosmoGuru, I would like to talk to Maulik Bhatt.')),
        ],
      ),
    );
  }
}

class _StatsAndReviews extends StatelessWidget {
  const _StatsAndReviews();

  static const _stats = [
    ('5,000+', 'Students trained'),
    ('5,000+', 'Predictions on record'),
    ('Since 1999', '27+ years of practice'),
    ('4.9★', 'Google · 146 reviews'),
  ];

  static const _reviews = [
    ('Best teaching method & easy to understand. Maulik sir and all mentors are very supportive.', 'Shruti Shah', 'Google'),
    ('I had been a student at three different institutes… at COSMOGURU it is truly worth it.', 'Deval Bhatt', 'Justdial'),
  ];

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - 40 - 10) / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final s in _stats)
              SizedBox(
                width: w,
                child: Glass(
                  padding: const EdgeInsets.all(16),
                  radius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.$1, style: T.h2.copyWith(fontSize: 21)),
                      const SizedBox(height: 2),
                      Text(s.$2, style: T.small),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 22),
        const _SectionTitle(eyebrow: 'REVIEWS', title: 'Real people, real clarity'),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _reviews.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final r = _reviews[i];
              return SizedBox(
                width: 280,
                child: Glass(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('“${r.$1}”', style: T.body.copyWith(fontSize: 14), maxLines: 4, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.redSoft,
                            child: Text(r.$2.split(' ').map((e) => e[0]).take(2).join(),
                                style: T.small.copyWith(fontSize: 10.5, color: AppColors.red, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 8),
                          Text(r.$2, style: T.strong.copyWith(fontSize: 13)),
                          const Spacer(),
                          Text(r.$3, style: T.small),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CosmoTv extends StatelessWidget {
  const _CosmoTv();

  @override
  Widget build(BuildContext context) {
    Widget channel(String name, String handle, String about, String url) => Expanded(
          child: Pressable(
            onTap: () => openWebsite(url),
            child: Glass(
              padding: const EdgeInsets.all(14),
              radius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 26,
                    decoration: BoxDecoration(color: const Color(0xFFFF0000), borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.center,
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(name, style: T.strong.copyWith(fontSize: 14)),
                  Text(handle, style: T.small.copyWith(fontSize: 11.5)),
                  const SizedBox(height: 4),
                  Text(about, style: T.small.copyWith(fontSize: 11.5, color: AppColors.tx2)),
                ],
              ),
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(
          eyebrow: 'COSMO TV',
          title: 'Free wisdom, every week',
          subtitle: 'With notes in English, ગુજરાતી and हिंदी.',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            channel('CosmoGuru', '@CosmoGuruGL', 'Jyotish for everyone', Brand.youtubeCosmoGuru),
            const SizedBox(width: 10),
            channel('CVPT', '@CVPTOfficial', 'The CVPT™ method', Brand.youtubeCvpt),
          ],
        ),
      ],
    );
  }
}

class _BeginSection extends StatelessWidget {
  const _BeginSection();

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    Widget option(String title, String sub, String icon, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Pressable(
            onTap: onTap,
            child: Glass(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: AppColors.redSoft, borderRadius: BorderRadius.circular(13)),
                    alignment: Alignment.center,
                    child: StrokeIcon(icon, color: AppColors.red, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: T.strong),
                        Text(sub, style: T.small),
                      ],
                    ),
                  ),
                  const StrokeIcon(Ic.chevRight, color: AppColors.tx3, size: 18),
                ],
              ),
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(eyebrow: 'WHERE TO BEGIN', title: 'Pick the one that sounds like you'),
        const SizedBox(height: 14),
        option('I want to know my future', 'Open your CK Planner', Ic.calendar,
            () => home.changeNav(HomeController.tabPlanner)),
        option('I want to learn Jyotish', 'CVPT™ Jyotish Gyata', Ic.book,
            () => openWhatsApp('Hi CosmoGuru, I want to learn CVPT™ Jyotish.')),
        option('I have one big question', 'Talk to a Cosmologer™', Ic.phone,
            () => openWhatsApp('Hi CosmoGuru, I would like to book a Cosmo Meet consultation.')),
        const SizedBox(height: 8),
        Center(child: Text('CosmoGuru · Guiding Life since 1999', style: T.small)),
      ],
    );
  }
}
