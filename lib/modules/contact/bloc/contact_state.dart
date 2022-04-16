part of 'contact_cubit.dart';

class ContactState extends Equatable {
  ContactState({
    required Contact contact,
    Contact? initialContact,
    this.status = Status.none,
    this.activity = Activity.none,
    this.exceptionError = '',
    this.isNew = false,
    Field? firstName,
    Field? lastName,
    Field? email,
    Field? phone,
    Field? role,
  }) {
    firstNameField =
        firstName ?? Field(contact.firstName, validator: RequiredValidator());
    lastNameField =
        lastName ?? Field(contact.lastName, validator: RequiredValidator());
    emailField = email ?? Field(contact.email, validator: EmailValidator());
    phoneField = phone ?? Field(contact.phone, validator: RequiredValidator());
    roleField = role ?? Field(contact.role);
    _contact = contact.copyWith(
      firstName: firstName?.value ?? contact.firstName,
      lastName: lastName?.value ?? contact.lastName,
      email: email?.value ?? contact.email,
      phone: phone?.value ?? contact.phone,
      role: role?.value ?? contact.role,
    );
    isValid = firstNameField.isValid &&
        lastNameField.isValid &&
        emailField.isValid &&
        phoneField.isValid &&
        roleField.isValid;
    hasError = firstNameField.hasError ||
        lastNameField.hasError ||
        emailField.hasError ||
        phoneField.hasError ||
        roleField.hasError;
    logger.i(
        'ContactState -> hasError: $hasError firstName:${firstNameField.hasError} lastName:${lastNameField.hasError} email:${emailField.hasError} phone:${phoneField.hasError} role:${roleField.hasError}');
    _initialContact = initialContact ?? _contact;
  }

  late final Contact _contact;
  late final Contact _initialContact;
  final String exceptionError;

  late final Field firstNameField;
  late final Field lastNameField;
  late final Field emailField;
  late final Field phoneField;
  late final Field roleField;
  final Status status;
  final Activity activity;
  late final bool isNew;
  late final bool isValid;
  late final bool hasError;

  Contact get contact => _contact;

  bool get hasChanged => _contact != _initialContact;

  @override
  List<Object> get props => [_contact, status, exceptionError];

  ContactState copyWith({
    Contact? contact,
    Contact? initialContact,
    Field? firstName,
    Field? lastName,
    Field? email,
    Field? phone,
    Field? role,
    Status? status,
    Activity? activity,
    String? exceptionError,
    bool? isNew,
  }) {
    return ContactState(
        contact: contact ?? _contact,
        initialContact: initialContact ?? _initialContact,
        status: status ?? this.status,
        activity: activity ?? this.activity,
        exceptionError: exceptionError ?? this.exceptionError,
        isNew: isNew ?? this.isNew,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        role: role);
  }
}
