import 'contact.dart';

class Contacts {
  final bool fromServer;
  final List<Contact> records;

  Contacts({required this.records, required this.fromServer});

  int get length => records.length;

  static Contacts empty() => Contacts(records: [], fromServer: false);

  List<Map<String, Object?>> toMap() => List<Map<String, Object?>>.generate(
      records.length, (index) => records[index].toMap(isNew: false));

  static Contacts fromMap(List list, bool fromServer) {
    final contacts = List<Contact>.generate(
        list.length, (index) => Contact.fromMap(list[index]));
    return Contacts(records: contacts, fromServer: fromServer);
  }
}
