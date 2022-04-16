import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:directory/config/dependencies.dart';
import 'package:directory/constants/status.dart';
import 'package:directory/core/Validation/confirm_password_validator.dart';
import 'package:directory/core/Validation/email_validator.dart';
import 'package:directory/core/Validation/password_validator.dart';
import 'package:directory/modules/field.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';

import '../../../config/logging.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit({required String email})
      : super(SignUpState(
          emailField: Field(email),
          status: Status.none,
          passwordField: Field.empty(validation: PasswordValidator()),
          confirmField: Field.empty(validation: ConfirmPasswordValidator('')),
        )) {
    _analytics = locator.get<FirebaseAnalytics>();
  }

  late final FirebaseAnalytics _analytics;

  void emailChanged(String value) {
    final field = state.emailField.copyWith(value);
    emit(state.copyWith(email: field, status: Status.none));
  }

  void passwordChanged(String value) {
    final field = state.passwordField.copyWith(value);
    emit(state.copyWith(password: field, status: Status.none));
  }

  void confirmChanged(String value) {
    final password = state.passwordField.value;
    final field = state.confirmField
        .copyWith(value, validator: ConfirmPasswordValidator(password));
    emit(state.copyWith(confirm: field, status: Status.none));
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signUpWithCredentials() async {
    if (!state.isValid) return;
    logger.i('signUpWithCredentials "${state.emailField.value}"');
    emit(state.copyWith(status: Status.progress));
    final trace =
        locator.get<FirebasePerformance>().newTrace('signUpWithCredentials');
    await trace.start();
    try {
      trace.putAttribute('email', state.emailField.value);
      final firebaseAuth = await _auth.createUserWithEmailAndPassword(
          email: state.emailField.value,
          password: state.passwordField.value.toString());
      await firebaseAuth.user?.sendEmailVerification();
      emit(state.copyWith(status: Status.success));
      unawaited(_analytics.logSignUp(signUpMethod: 'signUpWithCredentials'));
    } on FirebaseAuthException catch (e) {
      logger.e('signUpWithCredentials "${state.emailField.value}"', e);
      emit(state.copyWith(status: Status.failure, exceptionError: e.message));
    } finally {
      await trace.stop();
    }
  }

  /// deleteUser for testing only - no need for performance tracing
  Future<bool> deleteUser(String email, String password) async {
    try {
      logger.i('deleteUser "$email"');
      // Can not emit events after logging in as page is refreshed causing cubit to be closed
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _auth.currentUser?.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'user-mismatch') {
        logger.i('deleteUser "$email" ${e.message}');
      } else {
        logger.e('deleteUser "$email"', e);
      }
      return false;
    }
  }
}
