import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme.dart';
import '../../app/localization.dart';
import '../../data/models/catalog_item.dart';
import '../../data/repositories/catalog_repository.dart';
import '../profile/profile_controller.dart';

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final prefs = snapshot.data!;
        final themeController = ThemeController(
          darkMode: prefs.getBool('theme_isDark') ?? false,
          seed: Color(prefs.getInt('theme_primaryColor') ?? const Color(0xFF4C6EF5).value),
        );
        final localeCode = prefs.getString('locale_code') ?? 'ar';
        final loggedIn = prefs.getBool('auth_isLoggedIn') ?? false;
        final guest = prefs.getBool('auth_isGuest') ?? false;
        final appState = AppState(
          prefs: prefs,
          themeController: themeController,
          locale: Locale(localeCode),
          initialLoggedIn: loggedIn,
          initialGuest: guest,
        );
        return AppStateScope(state: appState, child: child);
      },
    );
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppState not found');
    return scope!.notifier!;
  }
}

class AppState extends ChangeNotifier {
  AppState({
    required SharedPreferences prefs,
    required this.themeController,
    required Locale locale,
    bool initialLoggedIn = false,
    bool initialGuest = false,
  })  : _prefs = prefs,
        _locale = locale,
        catalogController = CatalogController(CatalogRepository()) {
    profileController = ProfileController(prefs: prefs);
    authController = AuthController(
      profileController: profileController,
      loggedIn: initialLoggedIn,
      guest: initialGuest,
    );
  }

  final SharedPreferences _prefs;
  final ThemeController themeController;
  Locale _locale;
  Locale get locale => _locale;

  final CatalogController catalogController;
  late final AuthController authController;
  late final ProfileController profileController;

  void updateLocale(Locale locale) {
    _locale = locale;
    _prefs.setString('locale_code', locale.languageCode);
    notifyListeners();
  }

  Future<void> persistTheme() async {
    await _prefs.setBool('theme_isDark', themeController.isDark);
    await _prefs.setInt('theme_primaryColor', themeController.primarySeed.value);
  }

  Future<void> persistAuth({required bool loggedIn, bool guest = false}) async {
    await _prefs.setBool('auth_isLoggedIn', loggedIn);
    await _prefs.setBool('auth_isGuest', guest);
  }

  bool get onboardingSeen => _prefs.getBool('onboarding_seen') ?? false;

  Future<void> setOnboardingSeen() async {
    await _prefs.setBool('onboarding_seen', true);
  }

  @override
  void dispose() {
    catalogController.dispose();
    authController.dispose();
    profileController.dispose();
    super.dispose();
  }
}

class AuthController extends ChangeNotifier {
  AuthController({
    required ProfileController profileController,
    bool loggedIn = false,
    bool guest = false,
  })  : _profileController = profileController,
        _loggedIn = loggedIn,
        _guest = guest;

  final ProfileController _profileController;
  bool _loggedIn;
  bool _guest;

  bool get isLoggedIn => _loggedIn;
  bool get isGuest => _guest;

  Future<void> login(String email, String password) async {
    _loggedIn = true;
    _guest = false;
    _profileController.recordLogin(method: 'password', device: 'Mobile');
    notifyListeners();
  }

  Future<void> guestLogin() async {
    _loggedIn = true;
    _guest = true;
    _profileController.recordLogin(method: 'guest', device: 'Mobile', successful: true);
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _loggedIn = true;
    _guest = false;
    _profileController.completeRegistration(name: name, email: email);
    _profileController.recordLogin(method: 'register', device: 'Mobile', successful: true);
    notifyListeners();
  }

  Future<void> logout() async {
    _loggedIn = false;
    _guest = false;
    notifyListeners();
  }
}

class CatalogController extends ChangeNotifier {
  CatalogController(this.repository);

  final CatalogRepository repository;
  final List<CatalogItem> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  String _query = '';
  Map<String, dynamic> _filters = {};

  List<CatalogItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get query => _query;
  Map<String, dynamic> get filters => _filters;

  Future<void> refresh() async {
    _items.clear();
    _page = 0;
    _hasMore = true;
    await loadMore();
  }

  Future<void> search(String query) async {
    _query = query;
    await refresh();
  }

  Future<void> applyFilters(Map<String, dynamic> filters) async {
    _filters = filters;
    await refresh();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 320));
    final pageItems = repository.fetchPage(_page, 20, query: _query, filters: _filters);
    if (pageItems.isEmpty) {
      _hasMore = false;
    } else {
      _page++;
      _items.addAll(pageItems);
    }
    _isLoading = false;
    notifyListeners();
  }
}
