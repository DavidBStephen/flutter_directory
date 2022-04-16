import 'dart:async';

import 'package:directory/config/dependencies.dart';
import 'package:directory/services/preference_service.dart';
import 'package:directory/ui/pages/introduction_page.dart';
import 'package:directory/ui/pages/landing_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/themes/app_theme.dart';
import 'config/themes/bloc/theme_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//TODO: Structure - https://itnext.io/5-flutter-tips-for-better-code-structure-fa514845a903
//TODO: Accessibility - https://tonyowen.medium.com/accessibility-in-flutter-592f2e760149
//TODO: Upgrader - https://pub.dev/packages/upgrader

bool _kTestingCrashlytics = true;

Future<void> main() async {
  await init();
  runZonedGuarded(
      () => runApp(const MainApp()), FirebaseCrashlytics.instance.recordError);
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await registerLocator();
  await Future.wait([
    setupCrashlytics(),
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true),
    FirebasePerformance.instance.setPerformanceCollectionEnabled(true)
  ]);
}

Future<void> setupCrashlytics() async {
  if (_kTestingCrashlytics) {
    // Force enable crashlytics collection enabled if we're testing it.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  } else {
    // Else only enable it in non-debug builds.
    // You could additionally extend this to allow users to opt-in.
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  // Pass all uncaught errors to Crashlytics.
  Function originalOnError = FlutterError.onError!;
  FlutterError.onError = (FlutterErrorDetails errorDetails) async {
    await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    // Forward to original handler.
    originalOnError(errorDetails);
  };
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final preferenceService = locator.get<PreferenceService>();
    const pageTransitionsTheme = PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
      },
    );
    return BlocProvider<ThemeCubit>(
      lazy: false,
      create: (context) => ThemeCubit(ThemeMode.light),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, state) => MaterialApp(
          restorationScopeId: 'root',
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (BuildContext context) {
            return AppLocalizations.of(context)!.appTitle;
          },
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // themeMode: state,
          theme: AppTheme.lightTheme.copyWith(
            pageTransitionsTheme: pageTransitionsTheme,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: AppTheme.darkTheme.copyWith(
            pageTransitionsTheme: pageTransitionsTheme,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          themeMode: state,
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
          ],
          home: preferenceService.skipIntroduction
              ? const LandingPage()
              : const IntroductionPage(),
        ),
      ),
    );
  }
}
