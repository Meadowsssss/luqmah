final _namePattern = RegExp(r'^[A-Za-z\u0621-\u064A\s]+$');

const _blockedNameTerms = <String>[
  'fuck',
  'shit',
  'bitch',
  'asshole',
  'bastard',
  'slut',
  'whore',
  'كس',
  'كسم',
  'شرموط',
  'شرموطة',
  'زق',
  'قحبة',
  'متناك',
  'خول',
];

String _normalizeName(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

bool containsBlockedDisplayNameTerm(String value) {
  final normalized = _normalizeName(value);
  return _blockedNameTerms.any(normalized.contains);
}

String? validateCustomerDisplayName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) {
    return 'Enter your full name.';
  }
  if (name.length < 2 || name.length > 80) {
    return 'Use between 2 and 80 characters.';
  }
  if (!_namePattern.hasMatch(name)) {
    return 'Use letters and spaces only.';
  }
  if (containsBlockedDisplayNameTerm(name)) {
    return 'Choose a different display name.';
  }
  return null;
}

String? validateCustomerPhoneNumber(String? value) {
  final phoneNumber = value?.trim() ?? '';
  if (phoneNumber.isEmpty) {
    return 'Enter your phone number.';
  }
  if (phoneNumber.length > 30) {
    return 'Phone number is too long.';
  }
  if (!RegExp(r'^[0-9+\- ]+$').hasMatch(phoneNumber)) {
    return 'Use digits, spaces, +, or - only.';
  }
  return null;
}
