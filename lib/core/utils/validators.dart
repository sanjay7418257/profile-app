class Validators {
  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final reg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!reg.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  }

  static String? required(String? v, [String field = 'This field']) {
    if (v == null || v.isEmpty) return '$field is required';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.isEmpty) return 'Phone is required';
    if (v.length < 7) return 'Enter a valid phone number';
    return null;
  }

  static String? age(String? v) {
    if (v == null || v.isEmpty) return 'Age is required';
    final n = int.tryParse(v);
    if (n == null || n < 1 || n > 120) return 'Enter a valid age';
    return null;
  }
}
