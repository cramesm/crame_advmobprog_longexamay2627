// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/services.dart';
import '../constants.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.validator,
    required this.onSaved,
    this.controller,
    this.isObscure = false,
    required this.fontSize,
    this.fontColor,
    this.hintTextSize = 12,
    this.hintText = '',
    this.fillColor,
    required this.height,
    required this.width,
    this.keyboardType = TextInputType.text,
    this.maxLength = 200,
    this.suffixIcon,
  });

  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final TextEditingController? controller;
  final bool isObscure;
  final double fontSize;
  final Color? fontColor;
  final double height;
  final double width;
  final double hintTextSize;
  final String hintText;
  final Color? fillColor;
  final TextInputType keyboardType;
  final int maxLength;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveFontColor = fontColor ?? (isDark ? Colors.white : FB_DARK_PRIMARY);
    final effectiveFillColor = fillColor ?? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04));
    final effectiveHintColor = isDark ? Colors.white38 : Colors.black38;
    final effectiveBorderColor = isDark ? FB_LIGHT_PRIMARY : FB_DARK_PRIMARY;

    return TextFormField(
      validator: validator,
      onSaved: onSaved,
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxLength),
      ],
      style: TextStyle(
        fontSize: fontSize,
        color: effectiveFontColor,
      ),
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.fromLTRB(width, height, width, height),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: effectiveBorderColor,
            width: 1.5,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        errorStyle: const TextStyle(fontFamily: 'Frutiger'),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: FB_LIGHT_PRIMARY,
            width: 2,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        filled: true,
        hintStyle: TextStyle(
          color: effectiveHintColor,
          fontSize: hintTextSize,
          fontFamily: 'Frutiger',
        ),
        hintText: hintText,
        fillColor: effectiveFillColor,
      ),
    );
  }
}