import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../helper/colors.dart';

class CustomTextField extends StatelessWidget {
  final FocusNode? focusNode;
  final TextEditingController controller;
  final String? label;
  final TextInputAction? textInputAction;
  final String? hintText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final TextInputType? textInputType;
  final Function()? onTap;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  CustomTextField({
    this.autofocus = false,
    this.focusNode,
    required this.controller,
    this.label,
    this.textInputAction,
    this.hintText,
    this.validator,
    this.prefixIcon,
    this.textInputType,
    this.onTap,
    this.maxLines,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                label!,
              ),
            ),
          TextFormField(
            focusNode: focusNode,
            textAlignVertical: TextAlignVertical.center,
            inputFormatters: inputFormatters,
            onTap: onTap,
            controller: controller,
            validator: validator,
            keyboardType: textInputType,
            textInputAction: textInputAction,
            textCapitalization: TextCapitalization.sentences,
            autofocus: autofocus,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: secondaryColor, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC62F3A), width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC62F3A), width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              contentPadding: EdgeInsets.all(16.0),
              prefixIcon: prefixIcon,
            ),
          ),
        ],
      ),
    );
  }
}
