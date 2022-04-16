import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:directory/config/dependencies.dart';
import 'package:directory/config/logging.dart';
import 'package:directory/constants/activity.dart';
import 'package:directory/constants/status.dart';
import 'package:directory/core/Validation/validation.dart';
import 'package:directory/models/contact.dart';
import 'package:directory/modules/field.dart';
import 'package:directory/services/contact_service.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  ContactCubit({
    required Contact contact,
    required bool isNew,
  }) : super(ContactState(contact: contact, isNew: isNew)) {
    _contactsService = locator.get<ContactService>();
    _analytics = locator.get<FirebaseAnalytics>();
  }

  late final ContactService _contactsService;
  late final FirebaseAnalytics _analytics;

  firstNameChanged(String value) {
    final field = state.firstNameField.copyWith(value);
    emit(state.copyWith(firstName: field, status: Status.none));
  }

  lastNameChanged(String value) {
    final field = state.lastNameField.copyWith(value);
    emit(state.copyWith(lastName: field, status: Status.none));
  }

  emailChanged(String value) {
    final field = state.emailField.copyWith(value);
    emit(state.copyWith(email: field, status: Status.none));
  }

  phoneChanged(String value) {
    final field = state.phoneField.copyWith(value);
    emit(state.copyWith(phone: field, status: Status.none));
  }

  roleChanged(String value) {
    final field = state.roleField.copyWith(value);
    emit(state.copyWith(role: field, status: Status.none));
  }

  Future<bool> saveContact() async {
    try {
      emit(state.copyWith(status: Status.progress, activity: Activity.update));
      // TEST CRASHLYTICS if Role = "**CRASH**"
      if (kDebugMode && state.roleField.value == '**CRASH**') {
        FirebaseCrashlytics.instance.crash();
      }
      final contact = await _contactsService.saveContact(state._contact.trim());
      emit(state.copyWith(
          contact: contact, status: Status.success, activity: Activity.update));
      unawaited(_analytics.logEvent(
          name: 'saveContact', parameters: {'email': state.emailField.value}));
      return true;
    } on PlatformException catch (error) {
      emit(state.copyWith(
          exceptionError: error.toString(),
          status: Status.failure,
          activity: Activity.update));
      return false;
    } catch (error) {
      emit(state.copyWith(
          exceptionError: error.toString(),
          status: Status.failure,
          activity: Activity.update));
      return false;
    }
  }

  Future<bool> deleteContact() async {
    try {
      emit(state.copyWith(status: Status.progress, activity: Activity.delete));
      // await Future.delayed(const Duration(seconds: 3)); // Temp delay;
      await _contactsService.deleteContact(state._contact.id);
      emit(state.copyWith(status: Status.success, activity: Activity.delete));
      unawaited(_analytics.logEvent(
          name: 'deleteContact',
          parameters: {'email': state.emailField.value}));
      return true;
    } on PlatformException catch (error) {
      emit(state.copyWith(
          exceptionError: error.toString(),
          status: Status.failure,
          activity: Activity.delete));
      logger.e('deleteContact', error);
      return false;
    }
  }

  Future<void> _crash() => Future.delayed(
      // Delay crash for 5 seconds
      const Duration(seconds: 5),
      () => FirebaseCrashlytics.instance.crash());
}
