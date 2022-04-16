import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:directory/config/dependencies.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(ThemeMode theme) : super(theme) {
    _analytics = locator.get<FirebaseAnalytics>();
  }

  late final FirebaseAnalytics _analytics;

  Future<void> toggleTheme() async {
    final theme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    unawaited(_analytics
        .logEvent(name: 'theme', parameters: {'mode': theme.toString()}));
    emit(theme);
  }
}
