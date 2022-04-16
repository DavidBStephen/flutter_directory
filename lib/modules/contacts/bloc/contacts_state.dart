part of 'contacts_cubit.dart';

class ContactsState extends Equatable {
  const ContactsState({
    required this.contacts  ,
    this.exceptionError = '',
    this.status = Status.none,
  });

  final Contacts contacts;
  final String exceptionError;
  final Status status;
  bool get isEmpty => contacts.records.isEmpty;
  bool get fromServer => contacts.fromServer;

  @override
  List<Object> get props => [contacts, exceptionError];

  ContactsState copyWith({
    Contacts? contacts,
    String? exceptionError,
    Status? status,
  }) {
    return ContactsState(
        contacts: contacts ?? this.contacts,
        exceptionError: exceptionError ?? this.exceptionError,
        status: status ?? this.status);
  }
}
