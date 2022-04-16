import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:directory/config/dependencies.dart';
import 'package:directory/constants/status.dart';
import 'package:directory/modules/field.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit({required String email})
      : super(ResetPasswordState(
          emailField: Field(email),
          status: email.isEmpty ? Status.none : Status.none,
        )) {
    _analytics = locator.get<FirebaseAnalytics>();
  }

  late final FirebaseAnalytics _analytics;

  void emailChanged(String value) {
    final field = state.emailField.copyWith(value);
    emit(state.copyWith(email: field, status: Status.none));
  }

  Future<void> resetPassword() async {
    if (!state.isValid) return;
    emit(state.copyWith(status: Status.progress));
    final trace = locator.get<FirebasePerformance>().newTrace('resetPassword');
    await trace.start();
    try {
      trace.putAttribute('email', state.emailField.value);
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: state.emailField.value);
      emit(state.copyWith(status: Status.success));
      unawaited(_analytics.logLogin(loginMethod: 'resetPassword'));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(status: Status.failure, exceptionError: e.message));
    } finally {
      await trace.stop();
    }
  }
}
