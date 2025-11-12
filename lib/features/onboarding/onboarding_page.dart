import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/localization.dart';
import '../../core/widgets/pinned_controller_bar.dart';
import '../shared/app_state.dart';
import '../auth/auth_flow.dart';

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

  final _slides = List.generate(4, (i) => i);

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAuto();
  }

  void _startAuto() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final next = (_index + 1) % _slides.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.ease);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => _index = index);
              _startAuto();
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return _OnboardingSlide(index: index);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: PinnedControllerBar(
              index: _index,
              length: _slides.length,
              onNext: () {
                if (_index == _slides.length - 1) {
                  _finish(context);
                } else {
                  _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeInOut);
                }
              },
              onPrev: () => _controller.previousPage(duration: const Duration(milliseconds: 320), curve: Curves.easeInOut),
              onSkip: () => _finish(context),
            ),
          ),
          Positioned(
            bottom: 110,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: () => _finish(context),
              child: Text(strings.t('getStarted')),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _finish(BuildContext context) async {
    final state = AppStateScope.of(context);
    await state.setOnboardingSeen();
    Navigator.of(context).pushReplacementNamed(AuthFlow.route);
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    final image = _images[index % _images.length];
    final title = [
      'Live coached workouts',
      'Adaptive training plans',
      'Track every metric',
      'Compete with friends',
    ][index];
    final subtitle = [
      'Stay on pace with live HUD and haptic cues.',
      'Personalize each week with intensity dials.',
      'Monitor calories, heart rate and pace in real time.',
      'Join community challenges and climb the board.',
    ][index];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(image, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(.1), Colors.black.withOpacity(.65)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(subtitle, style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            children: [
              Chip(label: Text('HIIT'), backgroundColor: palette.primaryContainer.withOpacity(.4)),
              Chip(label: Text('Strength'), backgroundColor: palette.secondaryContainer.withOpacity(.4)),
              Chip(label: Text('Mindful'), backgroundColor: palette.tertiaryContainer.withOpacity(.4)),
            ],
          )
        ],
      ),
    );
  }
}

const _images = [
  'https://images.unsplash.com/photo-1558611848-73f7eb4001a1',
  'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
  'https://images.unsplash.com/photo-1526403226-1d7b0aeaa2a1',
];
