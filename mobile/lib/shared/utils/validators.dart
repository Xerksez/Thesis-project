class Validator {
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    } else if (!RegExp(r'^[0-9]{9,15}$').hasMatch(value)) {
      return 'Wrong telehpone number';
    }
    return null;
  }
}
