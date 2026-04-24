import '../../core/network/api_client.dart';

String formatAuthError(Object error) {
  if (error is ApiException) {
    if (error.statusCode == 401 || error.statusCode == 403) {
      return 'Incorrect password';
    }
    if (error.statusCode == 500 || error.statusCode == 502 || error.statusCode == 503) {
      return 'Can\'t reach the server right now. Try again in a moment.';
    }
  }

  final message = error.toString().replaceFirst('Exception: ', '');
  if (message.contains('invalid-credential') ||
      message.contains('wrong-password') ||
      message.contains('invalid-password') ||
      message.contains('INVALID_LOGIN_CREDENTIALS')) {
    return 'Incorrect password';
  }
  if (message.contains('XMLHttpRequest') ||
      message.contains('SocketException') ||
      message.contains('Connection refused')) {
    return 'Can\'t reach the server right now. Try again in a moment.';
  }

  return 'Something went wrong. Please try again.';
}
