class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Palun sisesta email';
    }

    // Regex pattern for email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Palun sisesta kehtiv email';
    }

    return null;  // null = validation passed
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Palun sisesta parool';
    }

    if (value.length < 6) {
      return 'Parool peab olema vähemalt 6 tähemärki';
    }

    return null;
  }

  // Name validation
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Palun sisesta nimi';
    }

    if (value.length < 2) {
      return 'Nimi peab olema vähemalt 2 tähemärki';
    }

    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Palun kinnita parool';
    }

    if (value != password) {
      return 'Paroolid ei ühti';
    }

    return null;
  }
}