import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/localization.dart';
import '../app/router.dart';
import '../app/theme.dart';
import '../features/shared/app_state.dart';
import '../features/auth/auth_flow.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/home/home_page.dart';

class FitProApp extends StatefulWidget {
  const FitProApp({super.key});

  @override
  State<FitProApp> createState() => _FitProAppState();
}

class _FitProAppState extends State<FitProApp> {
  @override
  Widget build(BuildContext context) {
    return AppBootstrap(
      child: Builder(builder: (context) {
        final state = AppStateScope.of(context);
        final themeController = state.themeController;
        final authController = state.authController;
        final initialRoute = state.onboardingSeen
            ? (authController.isLoggedIn ? HomePage.route : AuthFlow.route)
            : OnboardingPage.route;
        return AnimatedBuilder(
          animation: themeController,
          builder: (context, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'FitPro Coach',
              theme: themeController.theme(Brightness.light).copyWith(
                textTheme: GoogleFonts.manropeTextTheme(ThemeData.light().textTheme),
              ),
              darkTheme: themeController.theme(Brightness.dark).copyWith(
                textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
              ),
              themeMode: themeController.mode,
              locale: state.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.delegates,
              initialRoute: initialRoute,
              onGenerateRoute: AppRouter.onGenerate,
              builder: (context, child) {
                final strings = AppLocalizations.of(context);
                final direction = strings.isRtl ? TextDirection.rtl : TextDirection.ltr;
                return Directionality(textDirection: direction, child: child ?? const SizedBox());
              },
            );
          },
        );
      }),
    );
  }
}
