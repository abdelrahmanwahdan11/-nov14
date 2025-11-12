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

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller;
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAuto();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAuto() {
    _timer?.cancel();
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
  });

  final String titleKey;
  final String subtitleKey;
  final String image;
  final List<Color> gradientLight;
  final List<Color> gradientDark;

  List<Color> gradient(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark ? gradientDark : gradientLight;
  }
}

const _onboardingData = [
  _OnboardingData(
    titleKey: 'onboardingTitle1',
    subtitleKey: 'onboardingSubtitle1',
    image: 'https://images.unsplash.com/photo-1558611848-73f7eb4001a1',
    gradientLight: [Color(0xFFBBD2F3), Color(0xFF4C6EF5)],
    gradientDark: [Color(0xFF0F172A), Color(0xFF334155)],
  ),
  _OnboardingData(
    titleKey: 'onboardingTitle2',
    subtitleKey: 'onboardingSubtitle2',
    image: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
    gradientLight: [Color(0xFFDFF4D8), Color(0xFF22C55E)],
    gradientDark: [Color(0xFF1E3A2F), Color(0xFF14532D)],
  ),
  _OnboardingData(
    titleKey: 'onboardingTitle3',
    subtitleKey: 'onboardingSubtitle3',
    image: 'https://images.unsplash.com/photo-1526403226-1d7b0aeaa2a1',
    gradientLight: [Color(0xFFFFE1EA), Color(0xFFEC4899)],
    gradientDark: [Color(0xFF3B1F2B), Color(0xFF9D174D)],
  ),
  _OnboardingData(
    titleKey: 'onboardingTitle4',
    subtitleKey: 'onboardingSubtitle4',
    image: 'https://images.unsplash.com/photo-1518611012118-696072aa579a',
    gradientLight: [Color(0xFFFFDCCB), Color(0xFFF97316)],
    gradientDark: [Color(0xFF3B241F), Color(0xFFC2410C)],
  ),
];

const _onboardingChips = ['authChipCoaching', 'authChipWellness', 'authChipPerformance'];
