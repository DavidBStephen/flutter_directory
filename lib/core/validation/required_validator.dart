import 'package:directory/core/Validation/validation.dart';

class RequiredValidator extends Validator {
  @override
  bool validate(String value) => value.isNotEmpty;
}