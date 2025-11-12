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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.t('appTitle')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: strings.t('login')),
            Tab(text: strings.t('signup')),
            Tab(text: strings.t('forgotPassword')),
            Tab(text: strings.t('verifyCode')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LoginForm(onContinue: _goHome),
          _SignupForm(onContinue: _goHome),
          _ForgotForm(),
          const _VerifyPlaceholder(),
        ],
      ),
    );
  }

  void _goHome() {
    Navigator.of(context).pushReplacementNamed('/');
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _email,
              decoration: InputDecoration(labelText: strings.t('email')),
              validator: (value) => validateEmail(value)?.let(strings.t),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _loading = true);
                      await state.authController.login(_email.text, _password.text);
                      await state.persistAuth(loggedIn: true);
                      setState(() => _loading = false);
                      widget.onContinue();
                    },
              child: _loading ? const CircularProgressIndicator() : Text(strings.t('login')),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: strings.t('name')),
              validator: (value) => value == null || value.isEmpty ? strings.t('requiredField') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
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
                    PasswordStrengthMeter(label: strings.t('passwordStrength'), strength: passwordStrengthLabel(value.text),),
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
    );
  }
}

class _ForgotForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.t('forgotPassword'), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(strings.t('passwordRule')),
          const SizedBox(height: 24),
          TextField(decoration: InputDecoration(labelText: strings.t('email'))),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, child: Text(strings.t('confirm'))),
        ],
      ),
    );
  }
}

class _VerifyPlaceholder extends StatelessWidget {
  const _VerifyPlaceholder();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(child: Text('${strings.t('verifyCode')} — Coming soon'));
  }
}

extension _MapError on String? {
  String? let(String Function(String key) translate) {
    if (this == null) return null;
    return translate(this!);
  }
}
