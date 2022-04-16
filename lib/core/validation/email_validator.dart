import 'package:directory/core/Validation/validation.dart';

const String emailPattern =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

class EmailValidator extends Validator {
  @override
  bool validate(String value) {
    final regex = RegExp(emailPattern);
    return value.isNotEmpty && regex.hasMatch(value);
  }
}
