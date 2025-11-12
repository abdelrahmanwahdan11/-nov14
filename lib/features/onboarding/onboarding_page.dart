import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/localization.dart';
import '../../core/widgets/pinned_controller_bar.dart';
import '../auth/auth_flow.dart';
import '../shared/app_state.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static const route = '/onboarding';

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final PageController _controller;
  int _index = 0;
  Timer? _timer;
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _progressController.forward();
    _startAuto();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _startAuto() {
    _timer?.cancel();
    _progressController.forward(from: 0);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % _onboardingData.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 620),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final data = _onboardingData;
    final current = data[_index];
    final chips = _onboardingChips.map(strings.t).toList();
    final media = MediaQuery.of(context);
    final reservedSpace = media.viewPadding.bottom + 12;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: current.gradient(context),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: reservedSpace),
              child: PageView.builder(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _index = index);
                  _startAuto();
                },
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return _OnboardingSlide(
                    data: data[index],
                    chips: chips,
                  );
                },
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: 0,
              child: SafeArea(
                bottom: false,
                minimum: const EdgeInsets.only(top: 28),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) {
                      final theme = Theme.of(context);
                      return LinearProgressIndicator(
                        value: _progressController.value,
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.onSurface.withOpacity(.15),
                        valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                      child: SizedBox(
                        key: ValueKey(_index == data.length - 1 ? 'cta-finish' : 'cta-next'),
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () => _finish(context),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: Text(strings.t(_index == data.length - 1 ? 'startNow' : 'getStarted')),
                          style: ElevatedButton.styleFrom(
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    PinnedControllerBar(
                      index: _index,
                      length: data.length,
                      onNext: () {
                        if (_index == data.length - 1) {
                          _finish(context);
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 360),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      onPrev: () => _controller.previousPage(
                        duration: const Duration(milliseconds: 360),
                        curve: Curves.easeInOut,
                      ),
                      onSkip: () => _finish(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finish(BuildContext context) async {
    final state = AppStateScope.of(context);
    _timer?.cancel();
    _progressController.stop();
    await state.setOnboardingSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AuthFlow.route);
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.data, required this.chips});

  final _OnboardingData data;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTall = constraints.maxHeight > 720;
        final spacing = isTall ? 24.0 : 16.0;
        final bottomInset = isTall ? 200.0 : 160.0;

        return Padding(
          padding: EdgeInsets.fromLTRB(24, media.viewPadding.top + 24, 24, bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          data.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(.05), Colors.black.withOpacity(.65)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                strings.t(data.titleKey),
                                style: GoogleFonts.manrope(
                                  fontSize: media.size.width > 600 ? 40 : 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                strings.t(data.subtitleKey),
                                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacing),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  for (final label in chips)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        label,
                        style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                ],
              ),
              SizedBox(height: spacing),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _OnboardingHighlights(
                  key: ValueKey(data.titleKey),
                  highlights: data.highlights,
                ),
              ),
            ],
          );
        },
      },
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.titleKey,
    required this.subtitleKey,
    required this.image,
    required this.gradientLight,
    required this.gradientDark,
    required this.highlights,
  });

  final String titleKey;
  final String subtitleKey;
  final String image;
  final List<Color> gradientLight;
  final List<Color> gradientDark;
  final List<_OnboardingHighlight> highlights;

  List<Color> gradient(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark ? gradientDark : gradientLight;
  }
}

class _OnboardingHighlight {
  const _OnboardingHighlight({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
  });

  final IconData icon;
  final String titleKey;
  final String subtitleKey;
}

class _OnboardingHighlights extends StatelessWidget {
  const _OnboardingHighlights({super.key, required this.highlights});

  final List<_OnboardingHighlight> highlights;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final twoColumn = maxWidth > 640;
        final itemWidth = twoColumn ? (maxWidth - 16) / 2 : maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final highlight in highlights)
              SizedBox(
                width: itemWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.16),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(.22)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.22),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(highlight.icon, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.t(highlight.titleKey),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                strings.t(highlight.subtitleKey),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

const _onboardingData = [
  _OnboardingData(
    titleKey: 'onboardingTitle1',
    subtitleKey: 'onboardingSubtitle1',
    image: 'https://images.unsplash.com/photo-1558611848-73f7eb4001a1',
    gradientLight: [Color(0xFFBBD2F3), Color(0xFF4C6EF5)],
    gradientDark: [Color(0xFF0F172A), Color(0xFF334155)],
    highlights: [
      _OnboardingHighlight(
        icon: Icons.auto_graph_rounded,
        titleKey: 'onboardingHighlightAdaptiveTitle',
        subtitleKey: 'onboardingHighlightAdaptiveSubtitle',
      ),
      _OnboardingHighlight(
        icon: Icons.timer_rounded,
        titleKey: 'onboardingHighlightRhythmTitle',
        subtitleKey: 'onboardingHighlightRhythmSubtitle',
      ),
    ],
  ),
  _OnboardingData(
    titleKey: 'onboardingTitle2',
    subtitleKey: 'onboardingSubtitle2',
    image: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
    gradientLight: [Color(0xFFDFF4D8), Color(0xFF22C55E)],
    gradientDark: [Color(0xFF1E3A2F), Color(0xFF14532D)],
    highlights: [
      _OnboardingHighlight(
        icon: Icons.water_drop_rounded,
        titleKey: 'onboardingHighlightWellnessTitle',
        subtitleKey: 'onboardingHighlightWellnessSubtitle',
      ),
      _OnboardingHighlight(
        icon: Icons.self_improvement_rounded,
        titleKey: 'onboardingHighlightMindfulTitle',
        subtitleKey: 'onboardingHighlightMindfulSubtitle',
      ),
    ],
  ),
  _OnboardingData(
    titleKey: 'onboardingTitle3',
    subtitleKey: 'onboardingSubtitle3',
    image: 'https://images.unsplash.com/photo-1526403226-1d7b0aeaa2a1',
    gradientLight: [Color(0xFFFFE1EA), Color(0xFFEC4899)],
    gradientDark: [Color(0xFF3B1F2B), Color(0xFF9D174D)],
    highlights: [
      _OnboardingHighlight(
        icon: Icons.people_alt_rounded,
        titleKey: 'onboardingHighlightCommunityTitle',
        subtitleKey: 'onboardingHighlightCommunitySubtitle',
      ),
      _OnboardingHighlight(
        icon: Icons.emoji_events_rounded,
        titleKey: 'onboardingHighlightCelebrateTitle',
        subtitleKey: 'onboardingHighlightCelebrateSubtitle',
      ),
    ],
  ),
  _OnboardingData(
    titleKey: 'onboardingTitle4',
    subtitleKey: 'onboardingSubtitle4',
    image: 'https://images.unsplash.com/photo-1518611012118-696072aa579a',
    gradientLight: [Color(0xFFFFDCCB), Color(0xFFF97316)],
    gradientDark: [Color(0xFF3B241F), Color(0xFFC2410C)],
    highlights: [
      _OnboardingHighlight(
        icon: Icons.insights_rounded,
        titleKey: 'onboardingHighlightInsightsTitle',
        subtitleKey: 'onboardingHighlightInsightsSubtitle',
      ),
      _OnboardingHighlight(
        icon: Icons.devices_other_rounded,
        titleKey: 'onboardingHighlightDevicesTitle',
        subtitleKey: 'onboardingHighlightDevicesSubtitle',
      ),
    ],
  ),
];

const _onboardingChips = ['authChipCoaching', 'authChipWellness', 'authChipPerformance'];
