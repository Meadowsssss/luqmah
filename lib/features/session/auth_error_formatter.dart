import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';

String formatAuthError(Object error) {
  if (error is ApiException) {
    switch (error.code) {
      case 'INVALID_CREDENTIALS':
        return 'Incorrect email or password.';
      case 'CUSTOMER_FIREBASE_AUTH_REQUIRED':
        return 'Customers sign in with Firebase. Use the customer login flow.';
      case 'FIREBASE_EMAIL_NOT_VERIFIED':
        return 'Verify your email before continuing.';
      case 'INVALID_FIREBASE_ID_TOKEN':
      case 'CUSTOMER_SYNC_FAILED':
        return 'We could not sync your Luqmah account right now. Please sign in again.';
      case 'AUTH_ROLE_MISMATCH':
        return 'This account is trying to sign in to the wrong workspace.';
      case 'NETWORK_UNREACHABLE':
        return 'Can\'t reach the Luqmah backend right now. Check the server and try again.';
      case 'REQUEST_TIMEOUT':
        return 'The Luqmah backend took too long to respond. Please try again.';
      case 'FIREBASE_AUTH_NOT_CONFIGURED':
        return _withDebug(
          'Customer sign-in is not configured on the backend yet.',
          error,
        );
      case 'CURRENT_PASSWORD_INCORRECT':
        return 'Your current password is incorrect.';
      case 'PASSWORD_UNCHANGED':
        return 'Choose a different new password.';
    }

    if (error.statusCode == 500 || error.statusCode == 502 || error.statusCode == 503) {
      return _withDebug(
        'The Luqmah backend hit an internal error. Please try again.',
        error,
      );
    }

    return _withDebug(error.message, error);
  }

  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'INVALID_LOGIN_CREDENTIALS':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'That email is already in use.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Use a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a bit and try again.';
      case 'network-request-failed':
        return 'Can\'t reach Firebase right now. Check your connection and try again.';
      case 'requires-recent-login':
        return 'Sign in again before changing your password.';
      case 'no-current-user':
      case 'missing-id-token':
        return 'Please sign in again to continue.';
    }

    return _withDebug(
      error.message ?? 'Something went wrong. Please try again.',
      error,
    );
  }

  return _withDebug(
    error.toString().replaceFirst('Exception: ', ''),
    error,
  );
}

String _withDebug(String message, Object error) {
  if (!kDebugMode) {
    return message;
  }

  return '$message\n[$error]';
}
