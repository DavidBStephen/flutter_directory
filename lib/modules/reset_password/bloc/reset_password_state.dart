part of 'reset_password_cubit.dart';

class ResetPasswordState extends Equatable {
  const ResetPasswordState({
    required this.emailField,
    this.status = Status.none,
    this.exceptionError = '',
  });

  final Field emailField;
  final Status status;
  final String exceptionError;

  ResetPasswordState.empty() : this(emailField: Field.empty());

  bool get isValid => emailField.isValid;

  @override
  List<Object> get props => [emailField, status, exceptionError];

  ResetPasswordState copyWith({
    Field? email,
    Status? status,
    String? exceptionError,
  }) {
    return ResetPasswordState(
      emailField: email ?? emailField,
      status: status ?? this.status,
      exceptionError: exceptionError ?? this.exceptionError,
    );
  }
}
