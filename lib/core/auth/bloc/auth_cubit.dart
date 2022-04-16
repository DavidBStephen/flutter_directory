import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:directory/config/dependencies.dart';
import 'package:directory/config/logging.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState(isSignedIn: false)) {
    _analytics = locator.get<FirebaseAnalytics>();
    final auth = locator.get<FirebaseAuth>();
    auth.authStateChanges().listen((User? user) {
      if (!isClosed) {
        emit(copyWith(isSignedIn: user != null));
      }
    });
  }

  late final FirebaseAnalytics _analytics;

  get isSignedIn => state.isSignedIn;

  Future<void> signOut() async {
    logger.i('signOut');
    final trace = locator.get<FirebasePerformance>().newTrace('signOut');
    await trace.start();
    try {
      if (!kIsWeb) {
        await GoogleSignIn()
            .signOut(); // Logs out user from Google on device - not just application
      }
      trace.putAttribute(
          'email', FirebaseAuth.instance.currentUser?.email ?? 'unknown');
      return await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      logger.e('signOut', e);
    } finally {
      unawaited(_analytics.logLogin(loginMethod: 'signOut'));
      await trace.stop();
    }
  }
}
