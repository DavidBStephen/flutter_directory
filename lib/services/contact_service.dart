import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:directory/config/dependencies.dart';
import 'package:directory/config/logging.dart';
import 'package:directory/models/contact.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';

import '../models/contacts.dart';

class ContactService {
  // ignore: constant_identifier_names
  static const ContactsCollection = 'contacts';

  bool _isSignedIn() => FirebaseAuth.instance.currentUser != null;

  Future<Contacts> getContacts() async {
    logger.i('ContactService.getContacts');
    final trace = locator.get<FirebasePerformance>().newTrace('getContacts');
    await trace.start();
    List<Contact> contacts = [];
    try {
      if (_isSignedIn()) {
        trace.putAttribute('isSignedIn', 'true');
        final db = locator.get<FirebaseFirestore>();
        final contactsCollection = db.collection(ContactsCollection);
        final docRef = await contactsCollection.get();
        for (var e in docRef.docs) {
          contacts.add(Contact.fromJson(e.id, e.data()));
        }
        logger.i('ContactService.getContacts -> ${contacts.length} items');
      }
      trace.putAttribute('contacts', contacts.length.toString());
    } on FirebaseException catch (e) {
      if (_isSignedIn()) {
        logger.e('ContactService.getContacts', e);
      }
      return Contacts(records: contacts, fromServer: false);
    } finally {
      await trace.stop();
    }
    return Contacts(records: contacts, fromServer: true);
  }

  Future<Contact> saveContact(Contact contact) async {
    logger.i(
        'ContactService.saveContact email:${contact.email} phone:${contact.phone}');
    final trace = locator.get<FirebasePerformance>().newTrace('getContacts');
    await trace.start();
    try {
      trace.putAttribute('contact.id', contact.id);
      trace.putAttribute('contact.email', contact.email);
      final db = locator.get<FirebaseFirestore>();
      final contactsCollection = db.collection(ContactsCollection);
      if (contact.id.isEmpty) {
        final result = await contactsCollection.add(contact.toJson());
        return contact.copyWith(id: result.id);
      }
      await contactsCollection.doc(contact.id).update(contact.toJson());
      return contact;
    } finally {
      await trace.stop();
    }
  }

  Future<void> deleteContact(String id) async {
    logger.i('ContactService.deleteContact id:$id');
    final trace = locator.get<FirebasePerformance>().newTrace('deleteContact');
    await trace.start();
    try {
      trace.putAttribute('contact.id', id);
      final db = locator.get<FirebaseFirestore>();
      final contactsCollection = db.collection(ContactsCollection);
      final contact = contactsCollection.doc(id);
      await contact.delete();
    } finally {
      await trace.stop();
    }
  }
}
