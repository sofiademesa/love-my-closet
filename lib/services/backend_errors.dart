import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A problem talking to the backend. [message] is safe to show to Sofia.
class BackendException implements Exception {
  const BackendException(this.message);
  final String message;

  @override
  String toString() => 'BackendException: $message';
}

/// Turns any error from Supabase (auth, database, storage, network) into a
/// short friendly sentence. Technical details only go to the debug console.
String friendlyError(Object error) {
  debugPrint('[Love My Closet] backend error: $error');

  if (error is BackendException) return error.message;

  if (error is AuthException) {
    switch (error.code) {
      case 'invalid_credentials':
        return 'That email and password don’t match. Please try again.';
      case 'email_not_confirmed':
        return 'Please confirm your email first. Check your inbox for the link.';
      case 'otp_expired':
      case 'otp_disabled':
        return 'That code is wrong or has expired. Check it or tap Resend.';
      case 'user_already_exists':
      case 'email_exists':
        return 'An account with this email already exists. Try logging in.';
      case 'weak_password':
        return 'Please choose a stronger password.';
      case 'same_password':
        return 'Your new password must be different from the old one.';
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return 'Too many attempts. Please wait a minute and try again.';
      case 'signup_disabled':
        return 'New sign-ups are currently turned off.';
    }
    if (error is AuthRetryableFetchException) {
      return 'Couldn’t reach the server. Check your connection and try again.';
    }
    return error.message.isNotEmpty ? error.message : 'Something went wrong. Please try again.';
  }

  if (error is StorageException) {
    if (error.statusCode == '413') return 'That photo is too large to upload.';
    return 'Couldn’t upload the photo. Please try again.';
  }

  if (error is PostgrestException) {
    if (error.code == '42501') {
      return 'You don’t have access to that. Please log in again.';
    }
    return 'Couldn’t save your changes. Please try again.';
  }

  final text = error.toString().toLowerCase();
  if (text.contains('socket') ||
      text.contains('failed host lookup') ||
      text.contains('xmlhttprequest') ||
      text.contains('clientexception')) {
    return 'Couldn’t reach the server. Check your connection and try again.';
  }
  return 'Something went wrong. Please try again.';
}