import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final String? initialValue;
  final bool isPasswordField;
  final bool isRequiredField;
  final bool enabled;
  final bool hasError;
  final String? error;
  final EdgeInsets padding;

  const TextInput({
    Key? key,
    this.hint = '',
    required this.onChanged,
    required this.keyboardType,
    this.initialValue,
    this.isPasswordField = false,
    this.isRequiredField = false,
    this.enabled = true,
    this.hasError = true,
    this.error,
    this.padding = const EdgeInsets.all(0),
  }) : super(key: key);

  String? get value => initialValue;

  @override
  Widget build(BuildContext context) {
    var border = const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent, width: 2));
    var errorBorder = const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2));
    final fillColor = Theme.of(context).canvasColor;
    return Padding(
      padding: padding,
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: const TextStyle(fontSize: 12),
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          filled: true,
          hintText: isRequiredField ? '$hint*' : hint,
          border: border,
          disabledBorder: border,
          enabledBorder: border,
          errorBorder: errorBorder,
          focusedErrorBorder: errorBorder,
          errorText: hasError ? error : null,
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        autocorrect: false,
        textInputAction: TextInputAction.done,
        obscureText: isPasswordField,
        maxLines: 1,
        onChanged: onChanged,
      ),
    );
  }
}
