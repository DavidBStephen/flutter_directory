import 'package:directory/core/Validation/password_validator.dart';
import 'package:directory/core/Validation/validation.dart';

class ConfirmPasswordValidator extends PasswordValidator {
  ConfirmPasswordValidator(this.password);

  final String password;

  @override
  bool validate(String value) => super.validate(value) && value == password;
}