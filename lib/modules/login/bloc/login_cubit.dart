import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:directory/config/dependencies.dart';
import 'package:directory/core/Validation/email_validator.dart';
import 'package:directory/core/Validation/password_validator.dart';
import 'package:directory/modules/login/bloc/bloc.dart';
import 'package:directory/modules/field.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_oauth/firebase_auth_oauth.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../config/logging.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState.empty()) {
    _storage = locator.get<FlutterSecureStorage>();
    _auth = locator.get<FirebaseAuth>();
    _analytics = locator.get<FirebaseAnalytics>();
  }

  late final FlutterSecureStorage _storage;
  late final FirebaseAuth _auth;
  late final FirebaseAnalytics _analytics;

  void emailChanged(String value) {
    final field = state.emailField.copyWith(value);
    emit(state.copyWith(email: field, status: Status.none));
  }

  void passwordChanged(String value) {
    final field = state.passwordField.copyWith(value);
    emit(state.copyWith(password: field, status: Status.none));
  }

  Future<void> performLogin(String provider, List<String> scopes,
      Map<String, String> parameters) async {
    try {
      logger.i('performLogin "$provider"');
      await FirebaseAuthOAuth().openSignInFlow(provider, scopes, parameters);
    } on PlatformException catch (e) {
      logger.e('performLogin "$provider"', e);
      emit(state.copyWith(exceptionError: e.toString()));
    }
  }

  Future<void> logInWithCredentials() async {
    emit(state.copyWith(status: Status.progress));
    logger.i('logInWithCredentials "${state.emailField.value}"');
    final trace =
        locator.get<FirebasePerformance>().newTrace('logInWithCredentials');
    await trace.start();
    try {
      trace.putAttribute('email', state.emailField.value);
      // Can not emit events after logging in as page is refreshed causing cubit to be closed
      await _auth.signInWithEmailAndPassword(
          email: state.emailField.value, password: state.passwordField.value);
      await storeCredentials();
      unawaited(_analytics.logLogin(loginMethod: 'logInWithCredentials'));
      unawaited(_analytics.setUserId(id: state.emailField.value));
    } on FirebaseAuthException catch (e) {
      logger.e('signUpWithCredentials "${state.emailField.value}"', e);
      emit(state.copyWith(status: Status.failure, exceptionError: e.message));
    } finally {
      await trace.stop();
    }
  }

  Future<void> loadCredentials() async {
    var email = await _storage.read(key: 'email') ?? '';
    var password = await _storage.read(key: 'password') ?? '';
    if (email.isNotEmpty && password.isNotEmpty) {
      emit(state.copyWith(
        email: state.emailField.copyWith(email),
        password: state.passwordField.copyWith(password),
        status: Status.none,
      ));
    }
  }

  Future<void> storeCredentials() async {
    await _storage.write(key: 'email', value: state.emailField.value);
    await _storage.write(key: 'password', value: state.passwordField.value);
  }

  Future signInWithGoogle() async {
    emit(state.copyWith(status: Status.progress));
    final trace =
        locator.get<FirebasePerformance>().newTrace('signInWithGoogle');
    await trace.start();
    try {
      if (kIsWeb) {
        final authProvider = GoogleAuthProvider();

        await _auth.signInWithPopup(authProvider).then((value) async {
          emit(state.copyWith(status: Status.success));
          unawaited(_analytics.logLogin(loginMethod: 'signInWithGoogle'));
          unawaited(_analytics.setUserId(id: value.user?.email ?? 'unknown'));
          trace.putAttribute('email', value.user?.email ?? 'unknown');
        });
        return;
      }
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth == null) {
        emit(state.copyWith(status: Status.none));
        return;
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      if (!isClosed) {
        emit(state.copyWith(status: Status.success));
      }
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(status: Status.failure, exceptionError: e.message));
    } finally {
      await trace.stop();
    }
  }

  Future signInWithGithub() async {
    emit(state.copyWith(status: Status.progress));

    try {
      await performLogin("github.com", ["user:email"], {"lang": "en"});
      emit(state.copyWith(status: Status.success));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(status: Status.failure, exceptionError: e.message));
    }
  }

  Future signInWithTwitter() async {
    emit(state.copyWith(status: Status.progress));
    try {
      await performLogin("twitter.com", ["user:email"], {"lang": "en"});
      emit(state.copyWith(status: Status.success));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(status: Status.failure, exceptionError: e.message));
    }
  }

  Future signInWithApple() async {
    emit(state.copyWith(status: Status.progress));
    try {
      await performLogin("apple.com", ["user:email"], {"lang": "en"});
      emit(state.copyWith(status: Status.success));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(status: Status.failure, exceptionError: e.message));
    }
  }

  Future signInWithMicrosoft() async {
    emit(state.copyWith(status: Status.progress));
    try {
      await performLogin("microsoft.com", ["user:email"], {"lang": "en"});
      emit(state.copyWith(status: Status.success));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(status: Status.failure, exceptionError: e.message));
    }
  }
}
