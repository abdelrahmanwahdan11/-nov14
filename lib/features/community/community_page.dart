import 'package:flutter/material.dart';

import '../../app/localization.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  static const route = '/community';

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.t('community')),
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary,
            tabs: [
              Tab(text: strings.t('challenges')),
              Tab(text: strings.t('leaderboardTitle')),
              Tab(text: strings.t('social')),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ChallengesTab(),
            _LeaderboardTab(),
            _SocialTab(),
          ],
        ),
      ),
    );
  }
}

class _ChallengesTab extends StatelessWidget {
  const _ChallengesTab();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final challenges = const [
      _CommunityChallenge(title: 'Sunrise Steps', description: '6k steps · daily streak', progress: 0.7, participants: 1280),
      _CommunityChallenge(title: 'Core Crusher', description: '12 min plank flow', progress: 0.52, participants: 980),
      _CommunityChallenge(title: 'Ride the City', description: '15 km group ride', progress: 0.38, participants: 420),
    ];
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 30, end: 0),
          duration: const Duration(milliseconds: 340),
          curve: Curves.easeOut,
          builder: (context, value, child) => Transform.translate(offset: Offset(0, value), child: child),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(.08),
                    blurRadius: 24,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(challenge.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        FilledButton.tonal(
                          onPressed: () {},
                          child: Text(strings.t('joinChallenge')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(challenge.description),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(value: challenge.progress, minHeight: 12),
                    ),
                    const SizedBox(height: 12),
                    Text('${challenge.participants} members'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final leaders = const [
      _CommunityMember(name: 'Lina', points: 4820),
      _CommunityMember(name: 'Salem', points: 4510),
      _CommunityMember(name: 'Mira', points: 4280),
      _CommunityMember(name: 'Amir', points: 4100),
      _CommunityMember(name: 'Noor', points: 3960),
    ];
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
      itemCount: leaders.length,
      itemBuilder: (context, index) {
        final member = leaders[index];
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 320),
          opacity: 1,
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(member.name, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text('${member.points} pts'),
              trailing: Text(strings.t('share')),
            ),
          ),
        );
      },
    );
  }
}

class _SocialTab extends StatelessWidget {
  const _SocialTab();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(colors: [theme.colorScheme.primary.withOpacity(.18), theme.colorScheme.surface]),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.t('inviteFriends'), style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                Text('Share your plan and grow together.'),
                const SizedBox(height: 16),
                FilledButton(onPressed: () {}, child: Text(strings.t('share'))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(.08),
                blurRadius: 24,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Community tips', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Text('• Schedule a live workout
• Celebrate streaks with reactions
• Drop a voice note for teammates'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CommunityChallenge {
  const _CommunityChallenge({required this.title, required this.description, required this.progress, required this.participants});

  final String title;
  final String description;
  final double progress;
  final int participants;
}

class _CommunityMember {
  const _CommunityMember({required this.name, required this.points});

  final String name;
  final int points;
}
