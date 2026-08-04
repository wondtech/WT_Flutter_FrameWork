// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.4
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/widgets.dart';

import 'wt_security.dart';

/// Ready-made form-field validators that plug straight into a
/// `TextFormField.validator`.
///
/// Each factory returns a `String? Function(String?)` — null means valid, a
/// string is the error message. Combine several with [compose]:
///
/// ```dart
/// TextFormField(
///   validator: WtValidator.compose([
///     WtValidator.required(),
///     WtValidator.email(),
///   ]),
/// );
/// ```
class WtValidator {
  const WtValidator._();

  /// Fails when the value is null/blank (after trimming).
  static FormFieldValidator<String> required([String message = 'Required']) =>
      (value) => (value == null || value.trim().isEmpty) ? message : null;

  /// Fails when a non-empty value isn't a valid email. Empty passes — combine
  /// with [required] to also require a value.
  static FormFieldValidator<String> email([String message = 'Invalid email']) =>
      (value) =>
          (value == null || value.isEmpty || WtSecurity.isValidEmail(value))
              ? null
              : message;

  /// Fails when the value is shorter than [length] characters.
  static FormFieldValidator<String> minLength(int length, [String? message]) =>
      (value) => (value ?? '').length < length
          ? (message ?? 'Must be at least $length characters')
          : null;

  /// Fails when the value is longer than [length] characters.
  static FormFieldValidator<String> maxLength(int length, [String? message]) =>
      (value) => (value ?? '').length > length
          ? (message ?? 'Must be at most $length characters')
          : null;

  /// Fails when a non-empty value doesn't match [regex].
  static FormFieldValidator<String> pattern(
    RegExp regex, [
    String message = 'Invalid format',
  ]) =>
      (value) => (value == null || value.isEmpty || regex.hasMatch(value))
          ? null
          : message;

  /// Fails when a non-empty value isn't a plausible phone number
  /// (digits, spaces and `+ - ( )`, 7–15 digits).
  static FormFieldValidator<String> phone(
          [String message = 'Invalid phone number']) =>
      (value) {
        if (value == null || value.isEmpty) return null;
        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
        final shape = RegExp(r'^\+?[0-9\s\-()]+$');
        return (shape.hasMatch(value) &&
                digits.length >= 7 &&
                digits.length <= 15)
            ? null
            : message;
      };

  /// Fails when the value doesn't equal the value returned by [other] (e.g. a
  /// password-confirmation field).
  static FormFieldValidator<String> match(
    String? Function() other, [
    String message = 'Values do not match',
  ]) =>
      (value) => value == other() ? null : message;

  /// Runs [validators] in order and returns the first error (or null).
  static FormFieldValidator<String> compose(
    List<FormFieldValidator<String>> validators,
  ) =>
      (value) {
        for (final v in validators) {
          final result = v(value);
          if (result != null) return result;
        }
        return null;
      };
}
