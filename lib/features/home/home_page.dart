import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../app/localization.dart';
import '../../core/widgets/hero_card.dart';
import '../../core/widgets/metric_chip.dart';
import '../../core/widgets/skeleton_box.dart';
import '../catalog/catalog_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const route = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  late StreamController<int> _stepsStream;

  @override
  void initState() {
    super.initState();
    _stepsStream = StreamController<int>()..addStream(Stream.periodic(const Duration(seconds: 1), (count) => 4500 + count * 12));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _stepsStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.t('home')),
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, CatalogPage.route), icon: const Icon(Icons.search)),
          IconButton(onPressed: () => Navigator.pushNamed(context, '/settings'), icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => Future.delayed(const Duration(milliseconds: 500)),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('${strings.t('guestGreeting')} 👋', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: _loading
                  ? const SkeletonBox()
                  : Parallax3DCard(
                      image: _images.first,
                      title: 'Total Body Blast',
                      subtitle: strings.t('trainNow'),
                      badge: 'PRO',
                      onTap: () => Navigator.pushNamed(context, CatalogPage.route),
                    ),
            ),
            const SizedBox(height: 24),
            _loading
                ? const SkeletonBox(height: 120)
                : StreamBuilder<int>(
                    stream: _stepsStream.stream,
                    builder: (context, snapshot) {
                      final steps = snapshot.data ?? 0;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Daily Steps', style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 8),
                                    Text('$steps steps'),
                                  ],
                                ),
                              ),
                              const Icon(IconlyLight.activity, size: 40),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 24),
            Text('Focus Areas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final chip in ['Back', 'Core', 'Arms', 'Legs'])
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: MetricChip(icon: IconlyLight.time_circle, label: chip, value: '75%'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/train');
          if (index == 2) Navigator.pushNamed(context, '/plans');
          if (index == 3) Navigator.pushNamed(context, '/community');
          if (index == 4) Navigator.pushNamed(context, '/profile');
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: strings.t('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.timer), label: strings.t('train')),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_today), label: strings.t('plans')),
          BottomNavigationBarItem(icon: const Icon(Icons.groups_2), label: strings.t('community')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: strings.t('profile')),
        ],
      ),
    );
  }
}

const _images = [
  'https://images.unsplash.com/photo-1558611848-73f7eb4001a1',
];
