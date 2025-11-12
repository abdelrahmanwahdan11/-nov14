final _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
final _passwordUpperOrNumber = RegExp(r'(?=.*[A-Z0-9])');

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'requiredField';
  if (!_emailRegExp.hasMatch(value.trim())) return 'invalidEmail';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'requiredField';
  if (value.contains(' ')) return 'passwordRule';
  if (value.length < 8) return 'passwordRule';
  if (!_passwordUpperOrNumber.hasMatch(value)) return 'passwordRule';
  return null;
}

String passwordStrengthLabel(String value) {
  if (value.length >= 12 && RegExp(r'(?=.*[A-Z])(?=.*[0-9])').hasMatch(value)) {
    return 'strong';
  }
  if (value.length >= 8) {
    return 'medium';
  }
  return 'weak';
}
