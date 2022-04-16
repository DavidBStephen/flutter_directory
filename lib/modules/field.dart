import 'package:directory/core/Validation/validation.dart';

class Field {
  final String value;
  final Validator? validator;

  // String errorMsg = '';
  bool _isValid = true;
  bool _isTouched = false;

  Field(this.value, {this.validator}) {
    if (validator != null) {
      _isValid = validator!.validate(value);
    } else {
      _isValid = true;
    }
  }

  Field.empty({Validator? validation}) : this('', validator: validation);

  void setTouched() => _isTouched = true;

  bool get hasError =>
      (_isTouched || value.isNotEmpty ? !_isValid : _isTouched);

  bool get isValid => _isValid;

  Field copyWith(String value, {Validator? validator}) {
    final field = Field(value, validator: validator ?? this.validator);
    field._isTouched = true;
    return field;
  }
}
