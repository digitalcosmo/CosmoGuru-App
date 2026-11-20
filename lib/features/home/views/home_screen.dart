import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../ui/cosmic_background.dart';
import '../../../ui/motion.dart';
import '../../../ui/stroke_icon.dart';
import '../../contact/views/contact_tab.dart';
import '../../predictions/views/planner_tab.dart';
import '../../rashi/views/rashi_tab.dart';
import '../../reports/views/reports_tab.dart';
import 'home_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final topInset = MediaQuery.of(context).padding.top;

    // Android back: go Home first, only then leave the app.
    return Obx(() => PopScope(
          canPop: home.currentNavIndex.value == HomeController.tabHome,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) home.changeNav(HomeController.tabHome);
          },
          child: Scaffold(
            backgroundColor: AppColors.bg,
            extendBody: true,
            body: Stack(
              children: [
                const Positioned.fill(child: CosmicBackground(orbits: false)),
                Positioned.fill(child: _TabSwitcher(index: home.currentNavIndex.value)),
                // Scrim behind the status bar so content scrolls under cleanly.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: topInset + 22,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.bg, AppColors.bg.withValues(alpha: 0.9), AppColors.bg.withValues(alpha: 0)],
                          stops: const [0, 0.6, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: MediaQuery.of(context).padding.bottom + 10,
                  child: _TabBar(active: home.currentNavIndex.value, onTap: home.changeNav),
                ),
              ],
            ),
          ),
        ));
  }
}

/// Keeps every tab alive (scroll position, loaded data) and cross-fades the
/// incoming tab with a small lift.
class _TabSwitcher extends StatelessWidget {
  final int index;
  const _TabSwitcher({required this.index});

  static const _tabs = [HomeTab(), RashiTab(), PlannerTab(), ReportsTab(), ContactTab()];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var i = 0; i < _tabs.length; i++)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: i != index,
              child: TickerMode(
                enabled: i == index,
                child: AnimatedOpacity(
                  opacity: i == index ? 1 : 0,
                  duration: const Duration(milliseconds: 380),
                  curve: kEase,
                  child: AnimatedSlide(
                    offset: i == index ? Offset.zero : const Offset(0, 0.02),
                    duration: const Duration(milliseconds: 420),
                    curve: kEase,
                    child: _tabs[i],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TabDef {
  final String label;
  final String path;
  final String extra;
  const _TabDef(this.label, this.path, [this.extra = '']);
}

/// Floating frosted-white tab bar with a sliding red pill.
class _TabBar extends StatelessWidget {
  final int active;
  final ValueChanged<int> onTap;
  const _TabBar({required this.active, required this.onTap});

  static const _tabs = [
    _TabDef('Home', 'M4 11l8-7 8 7v9h-5v-6H9v6H4z'),
    _TabDef('Rashi', Ic.sunRays, Ic.sunCircle),
    _TabDef('Planner', Ic.calendar),
    _TabDef('Reports', Ic.doc),
    _TabDef('Contact', 'M4 5h16v11H9l-5 4z'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 30, offset: const Offset(0, 12)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.line),
            ),
            padding: const EdgeInsets.all(6),
            child: LayoutBuilder(builder: (context, c) {
              final w = c.maxWidth / _tabs.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 480),
                    curve: kEase,
                    left: w * active + 3,
                    width: w - 6,
                    top: 1,
                    bottom: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: AppColors.redSoft,
                        border: Border.all(color: AppColors.red.withValues(alpha: 0.18)),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < _tabs.length; i++)
                        Expanded(
                          child: Semantics(
                            button: true,
                            selected: i == active,
                            label: _tabs[i].label,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onTap(i),
                              child: _TabItem(def: _tabs[i], active: i == active),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final _TabDef def;
  final bool active;
  const _TabItem({required this.def, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.red : AppColors.tx2;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedScale(
          scale: active ? 1.08 : 1,
          duration: const Duration(milliseconds: 350),
          curve: kEase,
          child: StrokeIcon(def.path, extra: def.extra, color: color, size: 22, strokeWidth: 1.9),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: GoogleFonts.inter(fontSize: 10.5, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: color),
          child: Text(def.label),
        ),
      ],
    );
  }
}
