import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../core/utils/validators.dart';
import '../shared/app_state.dart';
import 'widgets/password_strength_meter.dart';

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  static const route = '/auth';

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ValueNotifier<int> _indexNotifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _stages.length, vsync: this);
    _indexNotifier = ValueNotifier<int>(0);
    _tabController.addListener(_onStageChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onStageChanged);
    _tabController.dispose();
    _indexNotifier.dispose();
    super.dispose();
  }

  void _onStageChanged() {
    if (_tabController.indexIsChanging) return;
    FocusScope.of(context).unfocus();
    _indexNotifier.value = _tabController.index;
  }

  void _goHome() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final hero = _AuthHeroPane(indexListenable: _indexNotifier);
            final formColumn = _buildFormColumn(context, isWide, strings);

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: hero,
                    ),
                  ),
                  Expanded(flex: 2, child: formColumn),
                ],
              );
            }

            return Column(
              children: [
                SizedBox(
                  height: constraints.maxHeight * 0.38,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: hero,
                  ),
                ),
                Expanded(child: formColumn),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormColumn(BuildContext context, bool isWide, AppLocalizations strings) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(isWide ? 48 : 24, isWide ? 48 : 24, isWide ? 48 : 24, 12),
          child: Text(strings.t('authWelcomeTitle'), style: theme.textTheme.headlineSmall),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 24),
          child: ValueListenableBuilder<int>(
            valueListenable: _indexNotifier,
            builder: (context, index, _) {
              final stage = _stages[index];
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: Text(
                  strings.t(stage.subtitleKey),
                  key: ValueKey(stage.subtitleKey),
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 16),
          child: Material(
            color: theme.colorScheme.surface,
            elevation: isWide ? 2 : 0,
            shadowColor: theme.shadowColor.withOpacity(.12),
            borderRadius: BorderRadius.circular(28),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: theme.colorScheme.primary.withOpacity(.12),
              ),
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              tabs: [
                for (final stage in _stages)
                  Tab(
                    text: strings.t(stage.tabKey),
                    icon: Icon(stage.icon, size: 18),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 24),
          child: ValueListenableBuilder<int>(
            valueListenable: _indexNotifier,
            builder: (context, index, _) {
              final stage = _stages[index];
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: _StageDetailWrap(
                  key: ValueKey(stage.tabKey),
                  stage: stage,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 48 : 16, 0, isWide ? 48 : 16, isWide ? 48 : 24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: theme.colorScheme.surface,
                boxShadow: [
                  if (isWide)
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(.08),
                      blurRadius: 24,
                      offset: const Offset(0, 18),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: ValueListenableBuilder<int>(
                  valueListenable: _indexNotifier,
                  builder: (context, index, _) {
                    return PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation, secondaryAnimation) {
                        return SharedAxisTransition(
                          transitionType: SharedAxisTransitionType.horizontal,
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          child: child,
                        );
                      },
                      child: KeyedSubtree(key: ValueKey(index), child: _buildForm(index)),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(int index) {
    switch (index) {
      case 0:
        return _LoginForm(onContinue: _goHome);
      case 1:
        return _SignupForm(onContinue: _goHome);
      case 2:
        return const _ForgotForm();
      default:
        return const _VerifyPlaceholder();
    }
  }
}

class _AuthHeroPane extends StatelessWidget {
  const _AuthHeroPane({required this.indexListenable});

  final ValueListenable<int> indexListenable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: indexListenable,
      builder: (context, index, _) {
        final stage = _stages[index];
        final accent = stage.accent;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: LinearGradient(
              colors: [
                Color.alphaBlend(accent.withOpacity(.25), theme.colorScheme.surface),
                accent.withOpacity(.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: AnimatedScale(
                    scale: 1,
                    duration: const Duration(milliseconds: 400),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(.2),
                      child: Icon(stage.icon, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(stage.image, fit: BoxFit.cover),
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
                            child: PageTransitionSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, animation, secondaryAnimation) {
                                return SharedAxisTransition(
                                  transitionType: SharedAxisTransitionType.vertical,
                                  animation: animation,
                                  secondaryAnimation: secondaryAnimation,
                                  child: child,
                                );
                              },
                              child: _AuthHeroCopy(stage: stage, strings: strings),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final key in stage.highlights)
                      Chip(
                        label: Text(strings.t(key), style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.white.withOpacity(.15),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AuthHeroCopy extends StatelessWidget {
  const _AuthHeroCopy({required this.stage, required this.strings});

  final _AuthStageConfig stage;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(stage.titleKey),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.t(stage.titleKey),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            strings.t(stage.subtitleKey),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final state = AppStateScope.of(context);
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(strings.t('authStageLoginSubtitle'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username],
                decoration: InputDecoration(labelText: strings.t('email')),
                validator: (value) => validateEmail(value)?.let(strings.t),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: !_showPassword,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: strings.t('password'),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                validator: (value) => validatePassword(value)?.let(strings.t),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _loading = true);
                        await state.authController.login(_email.text, _password.text);
                        await state.persistAuth(loggedIn: true);
                        if (!mounted) return;
                        setState(() => _loading = false);
                        widget.onContinue();
                      },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(strings.t('login')),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await state.authController.guestLogin();
                  await state.persistAuth(loggedIn: true, guest: true);
                  widget.onContinue();
                },
                child: Text(strings.t('guest')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignupForm extends StatefulWidget {
  const _SignupForm({required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _confirm = TextEditingController();
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final state = AppStateScope.of(context);
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(strings.t('authStageSignupSubtitle'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              TextFormField(
                controller: _name,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(labelText: strings.t('name')),
                validator: (value) => value == null || value.isEmpty ? strings.t('requiredField') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(labelText: strings.t('email')),
                validator: (value) => validateEmail(value)?.let(strings.t),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _password,
                builder: (context, value, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _password,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: strings.t('password'),
                          suffixIcon: IconButton(
                            icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                        validator: (value) => validatePassword(value)?.let(strings.t),
                      ),
                      const SizedBox(height: 8),
                      PasswordStrengthMeter(
                        label: strings.t('passwordStrength'),
                        strength: passwordStrengthLabel(value.text),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                decoration: InputDecoration(labelText: strings.t('confirmPassword')),
                validator: (value) => value == _password.text ? null : strings.t('passwordRule'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  await state.authController.register(
                    name: _name.text,
                    email: _email.text,
                    password: _password.text,
                  );
                  await state.persistAuth(loggedIn: true);
                  widget.onContinue();
                },
                child: Text(strings.t('signup')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForgotForm extends StatelessWidget {
  const _ForgotForm();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.t('forgotPassword'), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(strings.t('authStageForgotSubtitle')),
            const SizedBox(height: 24),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: strings.t('email')),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: Text(strings.t('confirm'))),
          ],
        ),
      ),
    );
  }
}

class _VerifyPlaceholder extends StatelessWidget {
  const _VerifyPlaceholder();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('${strings.t('authStageVerifySubtitle')} — ${strings.t('comingSoon')}'),
        ),
      ),
    );
  }
}

class _AuthStageConfig {
  const _AuthStageConfig({
    required this.tabKey,
    required this.titleKey,
    required this.subtitleKey,
    required this.image,
    required this.accent,
    required this.icon,
    required this.highlights,
    required this.details,
  });

  final String tabKey;
  final String titleKey;
  final String subtitleKey;
  final String image;
  final Color accent;
  final IconData icon;
  final List<String> highlights;
  final List<_AuthStageDetail> details;
}

class _AuthStageDetail {
  const _AuthStageDetail({
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
  });

  final IconData icon;
  final String titleKey;
  final String bodyKey;
}

class _StageDetailWrap extends StatelessWidget {
  const _StageDetailWrap({super.key, required this.stage});

  final _AuthStageConfig stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final double spacing = 18;
        final bool twoColumn = maxWidth > 720;
        final double itemWidth = twoColumn ? (maxWidth - spacing) / 2 : maxWidth;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final detail in stage.details)
              SizedBox(
                width: itemWidth,
                child: _StageDetailCard(detail: detail, theme: theme, strings: strings),
              ),
          ],
        );
      },
    );
  }
}

class _StageDetailCard extends StatelessWidget {
  const _StageDetailCard({required this.detail, required this.theme, required this.strings});

  final _AuthStageDetail detail;
  final ThemeData theme;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final surfaceVariant =
        theme.colorScheme.surfaceVariant.withOpacity(theme.brightness == Brightness.dark ? .32 : .65);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: surfaceVariant,
        border: Border.all(color: theme.colorScheme.primary.withOpacity(.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(detail.icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.t(detail.titleKey),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  strings.t(detail.bodyKey),
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _stages = [
  _AuthStageConfig(
    tabKey: 'login',
    titleKey: 'authHeroLoginTitle',
    subtitleKey: 'authStageLoginSubtitle',
    image: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
    accent: Color(0xFF4C6EF5),
    icon: Icons.lock_open_rounded,
    highlights: ['authHighlightTraining', 'authHighlightWellness', 'authHighlightCommunity'],
    details: [
      _AuthStageDetail(
        icon: Icons.security_rounded,
        titleKey: 'authDetailLoginSecurityTitle',
        bodyKey: 'authDetailLoginSecuritySubtitle',
      ),
      _AuthStageDetail(
        icon: Icons.timeline_rounded,
        titleKey: 'authDetailLoginHistoryTitle',
        bodyKey: 'authDetailLoginHistorySubtitle',
      ),
    ],
  ),
  _AuthStageConfig(
    tabKey: 'signup',
    titleKey: 'authHeroSignupTitle',
    subtitleKey: 'authStageSignupSubtitle',
    image: 'https://images.unsplash.com/photo-1558611848-73f7eb4001a1',
    accent: Color(0xFF22C55E),
    icon: Icons.person_add_alt_1_rounded,
    highlights: ['authHighlightWellness', 'authHighlightCommunity', 'authHighlightTraining'],
    details: [
      _AuthStageDetail(
        icon: Icons.badge_rounded,
        titleKey: 'authDetailSignupProfileTitle',
        bodyKey: 'authDetailSignupProfileSubtitle',
      ),
      _AuthStageDetail(
        icon: Icons.palette_rounded,
        titleKey: 'authDetailSignupPreferencesTitle',
        bodyKey: 'authDetailSignupPreferencesSubtitle',
      ),
    ],
  ),
  _AuthStageConfig(
    tabKey: 'forgotPassword',
    titleKey: 'authHeroForgotTitle',
    subtitleKey: 'authStageForgotSubtitle',
    image: 'https://images.unsplash.com/photo-1526403226-1d7b0aeaa2a1',
    accent: Color(0xFFF97316),
    icon: Icons.refresh_rounded,
    highlights: ['authHighlightTraining', 'authHighlightCommunity', 'authHighlightWellness'],
    details: [
      _AuthStageDetail(
        icon: Icons.lightbulb_rounded,
        titleKey: 'authDetailForgotGuidanceTitle',
        bodyKey: 'authDetailForgotGuidanceSubtitle',
      ),
      _AuthStageDetail(
        icon: Icons.support_agent_rounded,
        titleKey: 'authDetailForgotSupportTitle',
        bodyKey: 'authDetailForgotSupportSubtitle',
      ),
    ],
  ),
  _AuthStageConfig(
    tabKey: 'verifyCode',
    titleKey: 'authHeroVerifyTitle',
    subtitleKey: 'authStageVerifySubtitle',
    image: 'https://images.unsplash.com/photo-1518611012118-696072aa579a',
    accent: Color(0xFF8B5CF6),
    icon: Icons.verified_rounded,
    highlights: ['authHighlightWellness', 'authHighlightTraining', 'authHighlightCommunity'],
    details: [
      _AuthStageDetail(
        icon: Icons.shield_rounded,
        titleKey: 'authDetailVerifyProtectionTitle',
        bodyKey: 'authDetailVerifyProtectionSubtitle',
      ),
      _AuthStageDetail(
        icon: Icons.devices_rounded,
        titleKey: 'authDetailVerifyDevicesTitle',
        bodyKey: 'authDetailVerifyDevicesSubtitle',
      ),
    ],
  ),
];

extension _MapError on String? {
  String? let(String Function(String key) translate) {
    if (this == null) return null;
    return translate(this!);
  }
}
