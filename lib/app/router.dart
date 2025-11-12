import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../features/auth/auth_flow.dart';
import '../features/catalog/catalog_page.dart';
import '../features/compare/compare_page.dart';
import '../features/activity/activity_page.dart';
import '../features/community/community_page.dart';
import '../features/home/home_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/plans/plans_page.dart';
import '../features/profile/profile_page.dart';
import '../features/settings/settings_page.dart';
import '../features/train/train_page.dart';

class AppRouter {
  static Route<dynamic> onGenerate(RouteSettings settings) {
    Widget builder;
    switch (settings.name) {
      case OnboardingPage.route:
        builder = const OnboardingPage();
        break;
      case AuthFlow.route:
        builder = const AuthFlow();
        break;
      case CatalogPage.route:
        builder = const CatalogPage();
        break;
      case ComparePage.route:
        builder = ComparePage(items: settings.arguments as List? ?? const []);
        break;
      case TrainPage.route:
        builder = const TrainPage();
        break;
      case SettingsPage.route:
        builder = const SettingsPage();
        break;
      case ProfilePage.route:
        builder = const ProfilePage();
        break;
      case PlansPage.route:
        builder = const PlansPage();
        break;
      case CommunityPage.route:
        builder = const CommunityPage();
        break;
      case ActivityPage.route:
        builder = const ActivityPage();
        break;
      case HomePage.route:
      default:
        builder = const HomePage();
    }
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SharedAxisTransition(
          fillColor: Colors.transparent,
          transitionType: SharedAxisTransitionType.horizontal,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: builder,
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
