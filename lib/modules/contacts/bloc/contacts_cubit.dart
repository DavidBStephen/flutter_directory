import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:directory/services/contact_service.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../../../constants/status.dart';
import '../../../models/contacts.dart';
import '../../../services/file_service.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  static const fileName = 'contacts.json';

  ContactsCubit()
      : super(ContactsState(
            contacts: Contacts(
          records: [],
          fromServer: false,
        ))) {
    final locator = GetIt.instance;
    _contactsService = locator.get<ContactService>();
    _fileService = locator.get<FileService>();
    _analytics = locator.get<FirebaseAnalytics>();
  }

  late final ContactService _contactsService;
  late final FileService _fileService;
  late final FirebaseAnalytics _analytics;

  Future<Contacts> getContacts(
      {required bool isConnected, bool refresh = false}) async {
    if (refresh ||
        (state.isEmpty && !state.fromServer) ||
        (isConnected && !state.fromServer)) {
      try {
        emit(state.copyWith(status: Status.progress));
        // await Future.delayed(const Duration(seconds: 3)); // Temp delay
        late Contacts contacts;
        if (isConnected) {
          contacts = await _contactsService.getContacts();
          if (contacts.fromServer) {
            await _writeFile(contacts);
          }
        } else {
          contacts = await _loadFile();
        }
        if (!isClosed) {
          emit(state.copyWith(contacts: contacts, status: Status.success));
        }
        unawaited(_analytics.logEvent(name: 'getContacts', parameters: {
          'records': contacts.length,
          'server': contacts.fromServer
        }));
        return contacts;
      } on PlatformException catch (error) {
        emit(state.copyWith(
            exceptionError: error.toString(), status: Status.failure));
      }
    }
    return Contacts(fromServer: false, records: []);
  }

  Future<void> _writeFile(Contacts contacts) async {
    final list = contacts.toMap();
    final contents = jsonEncode(list);
    await _fileService.write(fileName, contents);
  }

  Future<Contacts> _loadFile() async {
    final source = await _fileService.read(fileName);
    final list = jsonDecode(source) as List;
    return Contacts.fromMap(list, false);
  }
}
