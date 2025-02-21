import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isPasswordField;
  final bool isEnabled;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final bool isNumberOnly; // Add this flag for number-only fields

  const TextFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.isPasswordField = false,
    this.isEnabled = true,
    this.validator,
    this.prefixIcon,
    this.focusNode,
    this.isNumberOnly = false, // Default is false
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.isPasswordField ? _isObscured : false,
        keyboardType:
            widget.isNumberOnly ? TextInputType.number : TextInputType.text,
        inputFormatters: widget.isNumberOnly
            ? [
                FilteringTextInputFormatter.digitsOnly
              ] // Restrict input to digits
            : [],
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: Colors.grey[400],
          ),
          floatingLabelStyle: const TextStyle(
            color: Colors.green,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 13.0, horizontal: 12.0),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 209, 209, 209)),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(
              color: Colors.green,
              width: 2.0,
            ),
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: Colors.grey)
              : null,
          suffixIcon: widget.isPasswordField
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
        ),
        validator: widget.validator,
      ),
    );
  }
}
