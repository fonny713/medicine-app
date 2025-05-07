import 'package:firebase_auth/firebase_auth.dart';
import '../errors/app_error.dart';

class ErrorUtils {
  static AppError handleFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'user-not-found':
        return AppError(
          'No user found with this email.',
          code: error.code,
          originalError: error,
        );
      case 'wrong-password':
        return AppError(
          'Incorrect password.',
          code: error.code,
          originalError: error,
        );
      case 'email-already-in-use':
        return AppError(
          'An account already exists with this email.',
          code: error.code,
          originalError: error,
        );
      case 'invalid-email':
        return AppError(
          'Please enter a valid email address.',
          code: error.code,
          originalError: error,
        );
      case 'weak-password':
        return AppError(
          'The password is too weak. Please choose a stronger password.',
          code: error.code,
          originalError: error,
        );
      case 'operation-not-allowed':
        return AppError(
          'Email/password accounts are not enabled. Please contact support.',
          code: error.code,
          originalError: error,
        );
      default:
        return AppError(
          'An error occurred. Please try again later.',
          code: error.code,
          originalError: error,
        );
    }
  }
}
