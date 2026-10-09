/// Form validators. Each returns an error message, or null when valid.
library;

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String? validateName(String value) {
  if (value.trim().length < 2) return 'Enter your full name.';
  return null;
}

String? validateEmail(String value) {
  if (value.trim().isEmpty) return 'Enter your email address.';
  if (!_emailPattern.hasMatch(value.trim())) return 'Enter a valid email address.';
  return null;
}

String? validatePassword(String value) {
  if (value.isEmpty) return 'Enter your password.';
  if (value.length < 6) return 'Password must be at least 6 characters.';
  return null;
}

/// Philippine mobile numbers such as 0917 123 4567 or +63 917 123 4567.
String? validateMobile(String value) {
  final digits = value.replaceAll(RegExp(r'[\s-]'), '');
  if (digits.isEmpty) return null; // optional
  if (!RegExp(r'^(09\d{9}|\+639\d{9})$').hasMatch(digits)) {
    return 'Use a format like 0917 123 4567.';
  }
  return null;
}

/// Parses "1,250.50" → 1250.5. Returns 0 for empty or invalid input.
double parseAmount(String value) =>
    double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
