part of 'login_cubit.dart';

const String empty = '';

class LoginState extends Equatable {
  LoginState({
    required this.emailField,
    required this.passwordField,
    this.status = Status.none,
    this.exceptionError = '',
  }) {
    isValid = emailField.isValid && passwordField.isValid;
    hasError = emailField.hasError || passwordField.hasError;
  }

  final Field emailField;
  final Field passwordField;
  final Status status;
  final String exceptionError;

  LoginState.empty()
      : this(
            emailField: Field.empty(validation: EmailValidator()),
            passwordField: Field.empty(validation: PasswordValidator()));

  late final bool isValid;

  late final bool hasError;

  @override
  List<Object> get props => [status, exceptionError, emailField, passwordField];

  LoginState copyWith({
    Field? email,
    Field? password,
    Status? status,
    String? exceptionError,
  }) {
    return LoginState(
      emailField: email ?? emailField,
      passwordField: password ?? passwordField,
      status: status ?? this.status,
      exceptionError: exceptionError ?? this.exceptionError,
    );
  }
}
