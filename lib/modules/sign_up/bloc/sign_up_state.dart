part of 'sign_up_cubit.dart';

class SignUpState extends Equatable {
  const SignUpState({
    required this.emailField,
    required this.passwordField,
    required this.confirmField,
    this.status = Status.none,
    this.exceptionError = '',
  });

  final Field emailField;
  final Field passwordField;
  final Field confirmField;
  final Status status;
  final String exceptionError;

  SignUpState.empty()
      : this(
            emailField: Field.empty(validation: EmailValidator()),
            passwordField: Field.empty(validation: PasswordValidator()),
            confirmField: Field.empty(validation: ConfirmPasswordValidator('')));

  @override
  List<Object> get props => [emailField, passwordField, confirmField, status, exceptionError];

  bool get isValid => emailField.isValid && passwordField.isValid && confirmField.isValid;

  SignUpState copyWith({
    Field? email,
    Field? password,
    Field? confirm,
    Status? status,
    String? exceptionError,
  }) {
    return SignUpState(
      emailField: email ?? emailField,
      passwordField: password ?? passwordField,
      confirmField: confirm ?? confirmField,
      status: status ?? this.status,
      exceptionError: exceptionError ?? this.exceptionError,
    );
  }
}
