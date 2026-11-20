import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/planner_controller.dart';
import '../../../controllers/report_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/dates.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/five_d.dart';
import '../../../ui/links.dart';
import '../../../models/load_result.dart';
import '../../../models/planner_report.dart';
import '../../../models/zone.dart';
import '../../../ui/controls.dart';
import '../../../ui/glass.dart';
import '../../../ui/motion.dart';
import '../../../ui/pal.dart';
import '../../../ui/states.dart';
import '../../../ui/stroke_icon.dart';
import '../../../ui/tab_page.dart';
import '../../../ui/tokens.dart';
import '../../../ui/zone_sky.dart';
import '../../reports/views/report_tile.dart';

const double _gap = 16;

/// CV Planner: 5D for a day (routine events), a week (frequent events) and a
/// month (rare events), for whichever report is selected.
class PlannerTab extends StatelessWidget {
  const PlannerTab({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = Get.find<ReportController>();
    final p = Get.find<PlannerController>();
    final home = Get.find<HomeController>();

    return Obx(() {
      final status = reports.status.value;
      final rep = reports.selected.value;

      if (status == LoadStatus.loading && rep == null) {
        return const TabPage(children: [
          _Title(),
          Skeleton(height: 50, radius: 16),
          Glass(child: DimBarsSkeleton()),
        ]);
      }
      if (status == LoadStatus.error && rep == null) {
        return TabPage(onRefresh: reports.load, children: [
          const _Title(),
          Glass(child: InlineNotice.error(reports.message.value, reports.load)),
        ]);
      }
      if (rep == null) {
        return TabPage(onRefresh: reports.load, children: [
          const _Title(),
          EmptyState(
            title: 'No planner yet',
            message: 'Your CK Planner shows your 5D day by day, week by week and month by month. '
                'Once you buy one with this mobile number, it appears here.',
            icon: Ic.calendar,
            actionLabel: showPurchaseLinks ? 'Get my report' : 'Talk to CosmoGuru',
            onAction: () => showPurchaseLinks
                ? openWebsite(Brand.reportsUrl)
                : home.changeNav(HomeController.tabContact),
          ),
        ]);
      }

      return TabPage(
        gap: 20,
        onRefresh: () async {
          await reports.load();
          p.retryVisible();
        },
        children: [
          _Title(report: rep),
          Obx(() => Segmented(
                labels: const ['Daily', 'Weekly', 'Monthly'],
                index: p.period.value.index,
                onChanged: (i) {
                  HapticFeedback.selectionClick();
                  p.setPeriod(PlannerPeriod.values[i]);
                },
              )),
          Obx(() {
            final per = p.period.value;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: kEase,
              switchOutCurve: Curves.easeIn,
              layoutBuilder: (cur, prev) => Stack(
                alignment: Alignment.topCenter,
                children: [...prev, if (cur != null) cur],
              ),
              transitionBuilder: (child, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(a),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(per),
                child: switch (per) {
                  PlannerPeriod.daily => const _DailyView(),
                  PlannerPeriod.weekly => const _WeeklyView(),
                  PlannerPeriod.monthly => const _MonthlyView(),
                },
              ),
            );
          }),
        ],
      );
    });
  }
}

// ───────────────────────── header ─────────────────────────

class _Title extends StatelessWidget {
  final PlannerReport? report;
  const _Title({this.report});

  @override
  Widget build(BuildContext context) {
    final reports = Get.find<ReportController>();
    final r = report;
    final many = reports.reports.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Planner', style: T.h1),
        if (r != null) ...[
          const SizedBox(height: 16),
          Pressable(
            onTap: many ? () => _showReportSheet(context) : null,
            child: Glass(
              padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
              radius: 18,
              child: Row(
                children: [
                  ReportAvatar(r, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name, style: T.strong, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          '${r.months}-month · ${fmtDayShort(r.start)} ${r.start.year} – ${fmtDayShort(r.end)} ${r.end.year}',
                          style: T.small.copyWith(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  if (many) ...[
                    Text('Switch', style: T.small.copyWith(color: AppColors.sun2, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const StrokeIcon(Ic.chevDown, color: AppColors.sun2, size: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

void _showReportSheet(BuildContext context) {
  final reports = Get.find<ReportController>();
  showGlassSheet(context, builder: (ctx) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Whose planner?', style: T.h2),
        const SizedBox(height: 6),
        Text('CK Planners bought for this mobile number.', style: T.small),
        const SizedBox(height: 16),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: reports.reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final r = reports.reports[i];
              return FadeSlideIn(
                delay: Duration(milliseconds: 50 * i),
                child: ReportTile(
                  report: r,
                  showProgress: false,
                  selected: reports.selected.value?.rId == r.rId,
                  onTap: () {
                    reports.select(r);
                    Navigator.of(ctx).pop();
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  });
}

// ───────────────────────── shared pieces ─────────────────────────

/// The 5D card for the current day / week / month. Swipe it sideways to go
/// to the previous or next period; the content slides in that direction.
class _FiveDCard extends StatelessWidget {
  final String title;
  final String note;
  final String actions;
  final Object periodKey;
  final FiveDResult? result;
  final VoidCallback onRetry;

  const _FiveDCard({
    required this.title,
    required this.note,
    required this.actions,
    required this.periodKey,
    required this.result,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    return SwipeArea(
      onSwipe: p.swipe,
      canSwipe: p.canSwipe,
      child: Glass(
        dark: true,
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CardHeader(title, note: note),
            ),
            const SizedBox(height: 8),
            // The sky stays in place; planets glide to the new values.
            ResultSwitch(
              result: result,
              onRetry: onRetry,
              loading: const Skeleton(height: 420, radius: 16),
              builder: (ok) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ZoneSky(ok.data!),
                  const SizedBox(height: 14),
                  ZoneActions(ok.data!, caption: actions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── daily ─────────────────────────

class _DailyView extends StatelessWidget {
  const _DailyView();

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    return Obx(() {
      final rep = p.report;
      if (rep == null) return const SizedBox.shrink();
      final d = p.day.value;
      final res = p.dailyOf(d);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: staggered(gap: _gap, stepMs: 60, [
          const _DateOrbit(),
          _FiveDCard(
            title: 'Daily 5D',
            note: 'for routine events',
            actions: sameDay(d, today()) ? 'What to do today' : 'What to do this day',
            periodKey: d,
            result: res,
            onRetry: () => p.ensureDaily(d, force: true),
          ),
        ]),
      );
    });
  }
}

/// Day picker as an orbit: five days on an arc with the selected one at
/// the top, previous / next at the ends, and the full date below (tap it
/// for the calendar).
class _DateOrbit extends StatelessWidget {
  const _DateOrbit();

  static const double _h = 100;

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    return Obx(() {
      final rep = p.report;
      if (rep == null) return const SizedBox.shrink();
      final d = p.day.value;
      final isToday = sameDay(d, today());
      return Column(
        children: [
          SizedBox(
            height: _h,
            child: LayoutBuilder(builder: (context, c) {
              final w = c.maxWidth;
              final beads = <Widget>[];
              for (var k = -2; k <= 2; k++) {
                final day = addDays(d, k);
                final on = k == 0;
                final size = on ? 52.0 : 42.0;
                final a = k * 0.1745; // 10° per day along the arc
                const r = 300.0;
                final x = w / 2 + r * _sin(a) - size / 2;
                final y = 4 + r * (1 - _cos(a)) - (on ? 2 : 0);
                beads.add(AnimatedPositioned(
                  key: ValueKey(day),
                  duration: const Duration(milliseconds: 420),
                  curve: kEase,
                  left: x,
                  top: y,
                  width: size,
                  height: size + 10,
                  child: _Bead(day: day, selected: on, enabled: rep.contains(day)),
                ));
              }
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: CustomPaint(painter: _ArcPainter())),
                  ...beads,
                  Positioned(
                    left: 0,
                    top: 40,
                    child: RoundIconButton(
                      icon: Ic.chevLeft,
                      size: 40,
                      enabled: p.canShiftDay(-1),
                      tooltip: 'Previous day',
                      onTap: () => p.shiftDay(-1),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 40,
                    child: RoundIconButton(
                      icon: Ic.chevRight,
                      size: 40,
                      enabled: p.canShiftDay(1),
                      tooltip: 'Next day',
                      onTap: () => p.shiftDay(1),
                    ),
                  ),
                ],
              );
            }),
          ),
          Pressable(
            onTap: () => _showDayPicker(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${DateFormat('EEEE, d MMMM').format(d)}${isToday ? ' · Today' : ''}',
                    style: T.small.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.tx2),
                  ),
                  const SizedBox(width: 4),
                  const StrokeIcon(Ic.chevDown, color: AppColors.tx2, size: 14),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  static double _sin(double a) => math.sin(a);
  static double _cos(double a) => math.cos(a);
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lineStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()
      ..moveTo(size.width * 0.17, 52)
      ..quadraticBezierTo(size.width / 2, -2, size.width * 0.83, 52);
    // Dashed: walk the path in 3 px dashes with 5 px gaps.
    for (final m in path.computeMetrics()) {
      for (var t = 0.0; t < m.length; t += 8) {
        canvas.drawPath(m.extractPath(t, math.min(t + 3, m.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Bead extends StatelessWidget {
  final DateTime day;
  final bool selected;
  final bool enabled;
  const _Bead({required this.day, required this.selected, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    final isToday = sameDay(day, today());
    return Semantics(
      button: true,
      selected: selected,
      label: '${DateFormat('EEEE d MMMM').format(day)}${isToday ? ', today' : ''}',
      child: Pressable(
        onTap: enabled && !selected
            ? () {
                HapticFeedback.selectionClick();
                p.selectDay(day);
              }
            : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: enabled ? 1 : 0.3,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: kEase,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: selected ? AppColors.red : Colors.white,
              border: selected
                  ? null
                  : Border.all(color: isToday ? AppColors.red : AppColors.line, width: isToday ? 1.5 : 1),
              boxShadow: [
                BoxShadow(
                  color: selected ? AppColors.red.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.06),
                  blurRadius: selected ? 18 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(kWeekdayShort[day.weekday - 1],
                    style: T.small.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white.withValues(alpha: 0.8) : AppColors.tx3)),
                Text('${day.day}',
                    style: T.h3.copyWith(fontSize: selected ? 17 : 15, color: selected ? Colors.white : AppColors.tx)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showDayPicker(BuildContext context) {
  showGlassSheet(context, builder: (_) => const _DayPickerSheet());
}

class _DayPickerSheet extends StatefulWidget {
  const _DayPickerSheet();
  @override
  State<_DayPickerSheet> createState() => _DayPickerSheetState();
}

class _DayPickerSheetState extends State<_DayPickerSheet> {
  final p = Get.find<PlannerController>();
  late DateTime _month = DateTime(p.day.value.year, p.day.value.month, 1);

  @override
  Widget build(BuildContext context) {
    final rep = p.report;
    if (rep == null) return const SizedBox.shrink();
    final months = rep.monthStarts;
    final idx = months.indexWhere((m) => sameMonth(m, _month));
    final canP = idx > 0, canN = idx >= 0 && idx < months.length - 1;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              RoundIconButton(
                icon: Ic.chevLeft,
                enabled: canP,
                tooltip: 'Previous month',
                onTap: () => setState(() => _month = months[idx - 1]),
              ),
              Expanded(child: Center(child: Text(fmtMonthYear(_month), style: T.h2.copyWith(fontSize: 20)))),
              RoundIconButton(
                icon: Ic.chevRight,
                enabled: canN,
                tooltip: 'Next month',
                onTap: () => setState(() => _month = months[idx + 1]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: months.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Chip2(
                label: '${fmtMonShortYear(months[i]).substring(0, 3)} ${'${months[i].year}'.substring(2)}',
                selected: sameMonth(months[i], _month),
                onTap: () => setState(() => _month = months[i]),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _MonthGrid(
            key: ValueKey(_month),
            month: _month,
            cell: (day) {
              final ok = rep.contains(day);
              final sel = sameDay(day, p.day.value);
              return _CalCell(
                day: day,
                enabled: ok,
                background: sel ? AppColors.red : (ok ? AppColors.card2 : Colors.transparent),
                textColor: sel ? Colors.white : (ok ? AppColors.tx : AppColors.tx3.withValues(alpha: 0.4)),
                isToday: sameDay(day, today()),
                onTap: () {
                  p.selectDay(day);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
          if (rep.coversToday) ...[
            const SizedBox(height: 18),
            SecondaryButton(
              label: 'Jump to today',
              expand: true,
              onTap: () {
                p.goToday();
                Navigator.of(context).pop();
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Mo–Su calendar grid for one month.
class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final Widget Function(DateTime day) cell;
  const _MonthGrid({super.key, required this.month, required this.cell});

  @override
  Widget build(BuildContext context) {
    final n = DateTime(month.year, month.month + 1, 0).day;
    final offset = DateTime(month.year, month.month, 1).weekday - 1;
    final total = ((offset + n) / 7).ceil() * 7;
    return Column(
      children: [
        Row(
          children: [
            for (final w in kWeekdayShort)
              Expanded(child: Center(child: Text(w, style: T.small.copyWith(fontWeight: FontWeight.w600, color: Pal.of(context).tx3)))),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          padding: EdgeInsets.zero,
          children: [
            for (var i = 0; i < total; i++)
              if (i < offset || i >= offset + n)
                const SizedBox.shrink()
              else
                PopIn(
                  delay: Duration(milliseconds: 10 * (i - offset)),
                  child: cell(DateTime(month.year, month.month, i - offset + 1)),
                ),
          ],
        ),
      ],
    );
  }
}

class _CalCell extends StatelessWidget {
  final DateTime day;
  final bool enabled;
  final Color background;
  final Color textColor;
  final bool isToday;
  final VoidCallback onTap;

  const _CalCell({
    required this.day,
    required this.enabled,
    required this.background,
    required this.textColor,
    required this.onTap,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: enabled ? onTap : null,
      pressedScale: 0.9,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: kEase,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(11),
          border: isToday
                  ? Border.all(color: Pal.of(context).dark ? Colors.white.withValues(alpha: 0.6) : AppColors.red, width: 1.4)
                  : null,
        ),
        alignment: Alignment.center,
        child: Text('${day.day}', style: T.small.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
      ),
    );
  }
}

// ───────────────────────── weekly ─────────────────────────

class _WeeklyView extends StatelessWidget {
  const _WeeklyView();

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    return Obx(() {
      final rep = p.report;
      if (rep == null) return const SizedBox.shrink();
      final w = p.week.value;
      final weeks = rep.weeks;
      final i = weeks.indexWhere((x) => sameDay(x, w));
      final isThisWeek = sameDay(w, mondayOf(today()));
      final res = p.weeklyOf(w);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: staggered(gap: _gap, stepMs: 60, [
          _PeriodNav(
            title: fmtWeekRange(w),
            subtitle: isThisWeek ? 'This week' : 'Week ${i + 1} of ${weeks.length}',
            canPrev: p.canShiftWeek(-1),
            canNext: p.canShiftWeek(1),
            onPrev: () => p.shiftWeek(-1),
            onNext: () => p.shiftWeek(1),
            onPick: () => _showWeekPicker(context),
          ),
          _FiveDCard(
            title: 'Weekly 5D',
            note: 'for frequent events',
            actions: isThisWeek ? 'What to do this week' : 'What to do that week',
            periodKey: w,
            result: res,
            onRetry: () => p.ensureWeekly(w, force: true),
          ),
          _WeekDetail(days: p.daysOfWeek(w)),
        ]),
      );
    });
  }
}

class _PeriodNav extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPick;

  const _PeriodNav({
    required this.title,
    required this.subtitle,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundIconButton(icon: Ic.chevLeft, enabled: canPrev, onTap: onPrev, tooltip: 'Previous'),
        const SizedBox(width: 8),
        Expanded(
          child: Pressable(
            onTap: onPick,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(title, key: ValueKey(title), style: T.h3.copyWith(fontSize: 19)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const StrokeIcon(Ic.chevDown, color: AppColors.tx2, size: 15),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: T.small, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        RoundIconButton(icon: Ic.chevRight, enabled: canNext, onTap: onNext, tooltip: 'Next'),
      ],
    );
  }
}

void _showWeekPicker(BuildContext context) {
  final p = Get.find<PlannerController>();
  final rep = p.report;
  if (rep == null) return;
  final weeks = rep.weeks;
  final selKey = GlobalKey();

  showGlassSheet(context, builder: (ctx) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = selKey.currentContext;
      if (c != null) Scrollable.ensureVisible(c, alignment: 0.35);
    });
    final children = <Widget>[];
    int? lastMonth;
    for (var i = 0; i < weeks.length; i++) {
      final w = weeks[i];
      if (w.month != lastMonth) {
        lastMonth = w.month;
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(2, 16, 0, 8),
          child: Text(fmtMonthYear(w).toUpperCase(), style: T.cap),
        ));
      }
      final sel = sameDay(w, p.week.value);
      final isThis = sameDay(w, mondayOf(today()));
      children.add(Padding(
        key: sel ? selKey : null,
        padding: const EdgeInsets.only(bottom: 8),
        child: Pressable(
          onTap: () {
            p.selectWeek(w);
            Navigator.of(ctx).pop();
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: sel ? AppColors.sun.withValues(alpha: 0.12) : AppColors.card,
              border: Border.all(color: sel ? AppColors.sun : AppColors.line),
            ),
            child: Row(
              children: [
                SizedBox(width: 64, child: Text('Week ${i + 1}', style: T.small.copyWith(fontWeight: FontWeight.w600))),
                Expanded(child: Text(fmtWeekRange(w), style: T.strong.copyWith(fontSize: 14.5))),
                if (isThis)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('This week', style: T.small.copyWith(color: AppColors.sun2, fontWeight: FontWeight.w600)),
                  ),
                if (sel) const StrokeIcon(Ic.check, color: AppColors.sun, size: 18),
              ],
            ),
          ),
        ),
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Pick a week', style: T.h2),
        const SizedBox(height: 4),
        Text('Weeks covered by ${rep.name}\'s planner.', style: T.small),
        Flexible(
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ),
      ],
    );
  });
}

// ───────────────────────── monthly ─────────────────────────

class _MonthlyView extends StatelessWidget {
  const _MonthlyView();

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    return Obx(() {
      final rep = p.report;
      if (rep == null) return const SizedBox.shrink();
      final m = p.month.value;
      final months = rep.monthStarts;
      final i = months.indexWhere((x) => sameMonth(x, m));
      final isThisMonth = sameMonth(m, today());
      final res = p.monthlyOf(m);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: staggered(gap: _gap, stepMs: 60, [
          _PeriodNav(
            title: fmtMonthYear(m),
            subtitle: isThisMonth ? 'This month' : 'Month ${i + 1} of ${months.length}',
            canPrev: p.canShiftMonth(-1),
            canNext: p.canShiftMonth(1),
            onPrev: () => p.shiftMonth(-1),
            onNext: () => p.shiftMonth(1),
            onPick: () => _showMonthPicker(context),
          ),
          _FiveDCard(
            title: 'Monthly 5D',
            note: 'for rare events',
            actions: isThisMonth ? 'What to do this month' : 'What to do that month',
            periodKey: m,
            result: res,
            onRetry: () => p.ensureMonthly(m, force: true),
          ),
          _MonthDetail(month: m),
        ]),
      );
    });
  }
}

void _showMonthPicker(BuildContext context) {
  final p = Get.find<PlannerController>();
  final rep = p.report;
  if (rep == null) return;
  final months = rep.monthStarts;
  showGlassSheet(context, builder: (ctx) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Pick a month', style: T.h2),
        const SizedBox(height: 4),
        Text('Months covered by ${rep.name}\'s planner.', style: T.small),
        const SizedBox(height: 16),
        Flexible(
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              for (var i = 0; i < months.length; i++)
                Builder(builder: (_) {
                  final m = months[i];
                  final sel = sameMonth(m, p.month.value);
                  final isThis = sameMonth(m, today());
                  return PopIn(
                    delay: Duration(milliseconds: 30 * i),
                    child: Pressable(
                      onTap: () {
                        p.selectMonth(m);
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: sel ? AppColors.sun.withValues(alpha: 0.15) : AppColors.card,
                          border: Border.all(
                            color: sel ? AppColors.sun : (isThis ? AppColors.sun.withValues(alpha: 0.45) : AppColors.line),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(fmtMonShortYear(m).substring(0, 3), style: T.strong),
                            const SizedBox(height: 2),
                            Text(isThis ? 'This month' : '${m.year}',
                                style: T.small.copyWith(color: isThis ? AppColors.sun2 : AppColors.tx3)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  });
}


// ───────────────────────── daily detail (week / month) ─────────────────────────

const double _labelW = 64;

/// Small caption above a detail card.
class _DetailTitle extends StatelessWidget {
  final String left;
  final String right;
  const _DetailTitle(this.left, this.right);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Expanded(child: Text(left, style: T.cap.copyWith(fontSize: 10.5, letterSpacing: 1.2))),
          Text(right, style: T.small.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

/// A red box over one column, from Career down to Love: marks today.
class _TodayBox extends StatelessWidget {
  final double radius;
  const _TodayBox({this.radius = 10});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: AppColors.red.withValues(alpha: 0.05),
          border: Border.all(color: AppColors.red, width: 1.5),
        ),
      ),
    );
  }
}

/// The week's seven days × five dimensions as zone-coloured dots.
/// Tap a day to open it.
class _WeekDetail extends StatelessWidget {
  final List<DateTime> days;
  const _WeekDetail({required this.days});

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DetailTitle('INSIDE THIS WEEK · DAILY DETAIL', 'tap a day'),
        Glass(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
          radius: 20,
          child: Obx(() {
            p.results.length; // rebuild as days arrive
            final rep = p.report;
            final ti = days.indexWhere((d) => sameDay(d, today()));
            return LayoutBuilder(builder: (context, c) {
              final colW = (c.maxWidth - _labelW) / 7;
              return Stack(
                children: [
                  if (ti >= 0)
                    Positioned(left: _labelW + colW * ti, width: colW, top: 0, bottom: 0, child: const _TodayBox()),
                  Column(
                    children: [
                      Row(children: [
                        const SizedBox(width: _labelW),
                        for (var i = 0; i < 7; i++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Center(
                                child: Text(kWeekdayShort[days[i].weekday - 1],
                                    style: T.small.copyWith(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: i == ti ? AppColors.red : AppColors.tx3)),
                              ),
                            ),
                          ),
                      ]),
                      for (final dim in kDims)
                        Container(
                          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF3F3F6)))),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(children: [
                            SizedBox(width: _labelW, child: Text(dim.label, style: T.strong.copyWith(fontSize: 12.5))),
                            for (final day in days)
                              Expanded(
                                child: Pressable(
                                  onTap: rep != null && rep.contains(day) ? () => p.openDay(day) : null,
                                  child: Center(child: _Dot(p.dailyOf(day), dim.key, inRange: rep?.contains(day) ?? false)),
                                ),
                              ),
                          ]),
                        ),
                    ],
                  ),
                ],
              );
            });
          }),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final FiveDResult? res;
  final String dimKey;
  final bool inRange;
  const _Dot(this.res, this.dimKey, {required this.inRange});

  @override
  Widget build(BuildContext context) {
    final v = (res != null && res!.isOk) ? res!.data!.of(dimKey) : null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: !inRange
            ? Colors.transparent
            : v == null
                ? const Color(0xFFEDEDF0)
                : Zone.of(v).color,
        border: inRange ? Border.all(color: Colors.black.withValues(alpha: 0.06)) : null,
      ),
    );
  }
}

/// Every day of the month as a thin zone-coloured cell per dimension, so a
/// whole month reads at a glance. Tap a cell to open that day.
class _MonthDetail extends StatelessWidget {
  final DateTime month;
  const _MonthDetail({required this.month});

  @override
  Widget build(BuildContext context) {
    final p = Get.find<PlannerController>();
    final days = p.daysOfMonth(month);
    final n = days.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DetailTitle('INSIDE THIS MONTH · DAILY DETAIL', 'tap a date'),
        Glass(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          radius: 20,
          child: Obx(() {
            p.results.length;
            final rep = p.report;
            final ti = days.indexWhere((d) => sameDay(d, today()));
            return Column(
              children: [
                LayoutBuilder(builder: (context, c) {
                  final cellW = (c.maxWidth - _labelW) / n;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (ti >= 0)
                        Positioned(
                          left: _labelW + cellW * ti - 3,
                          width: cellW + 6,
                          top: -4,
                          bottom: -4,
                          child: const _TodayBox(radius: 6),
                        ),
                      Column(
                        children: [
                          for (var r = 0; r < kDims.length; r++)
                            Padding(
                              padding: EdgeInsets.only(top: r == 0 ? 0 : 7),
                              child: Row(children: [
                                SizedBox(width: _labelW, child: Text(kDims[r].label, style: T.strong.copyWith(fontSize: 12))),
                                for (final day in days)
                                  Expanded(
                                    child: Pressable(
                                      onTap: rep != null && rep.contains(day) ? () => p.openDay(day) : null,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 0.75),
                                        child: _Cell(p.dailyOf(day), kDims[r].key, inRange: rep?.contains(day) ?? false),
                                      ),
                                    ),
                                  ),
                              ]),
                            ),
                        ],
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: _labelW),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final t in ['1', '10', '20', '$n']) Text(t, style: T.small.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  final FiveDResult? res;
  final String dimKey;
  final bool inRange;
  const _Cell(this.res, this.dimKey, {required this.inRange});

  @override
  Widget build(BuildContext context) {
    final v = (res != null && res!.isOk) ? res!.data!.of(dimKey) : null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: !inRange
            ? const Color(0xFFF7F7F9)
            : v == null
                ? const Color(0xFFEDEDF0)
                : Zone.of(v).color,
      ),
    );
  }
}
