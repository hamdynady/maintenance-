import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:maintenance2/core/widgets/error_screen.dart';

/// A centralized error handler for the application
class ErrorHandler {
  /// Handles initialization errors and returns an error widget
  static Widget handleInitializationError(dynamic error) {
    developer.log('Error during initialization: $error', error: error);

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
      ),
      home: ErrorScreen(
        title: 'خطأ في تهيئة التطبيق',
        message: _getUserFriendlyErrorMessage(error),
        onRetry: () {
          // You can implement retry logic here
        },
      ),
    );
  }

  /// Shows a database error dialog
  static void showDatabaseError(BuildContext context, dynamic error) {
    developer.log('Database error: $error', error: error);
    _showErrorDialog(
      context,
      'خطأ في قاعدة البيانات',
      _getUserFriendlyErrorMessage(error),
    );
  }

  /// Shows a file system error dialog
  static void showFileSystemError(BuildContext context, dynamic error) {
    developer.log('File system error: $error', error: error);
    _showErrorDialog(
      context,
      'خطأ في نظام الملفات',
      _getUserFriendlyErrorMessage(error),
    );
  }

  /// Shows a network error dialog
  static void showNetworkError(BuildContext context, dynamic error) {
    developer.log('Network error: $error', error: error);
    _showErrorDialog(
      context,
      'خطأ في الاتصال',
      _getUserFriendlyErrorMessage(error),
    );
  }

  /// Shows a general error dialog
  static void showError(BuildContext context, String title, String message) {
    _showErrorDialog(context, title, message);
  }

  /// Shows an error dialog with the given title and message
  static void _showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('حسناً'),
              ),
            ],
          ),
    );
  }

  /// Converts technical error messages to user-friendly messages
  static String _getUserFriendlyErrorMessage(dynamic error) {
    if (error is String) return error;

    final errorMessage = error.toString();

    // Map common error messages to user-friendly Arabic messages
    if (errorMessage.contains('database')) {
      return 'حدث خطأ في قاعدة البيانات. يرجى المحاولة مرة أخرى لاحقاً.';
    } else if (errorMessage.contains('file')) {
      return 'حدث خطأ في الوصول إلى الملفات. يرجى التأكد من الصلاحيات والمحاولة مرة أخرى.';
    } else if (errorMessage.contains('network')) {
      return 'حدث خطأ في الاتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.';
    } else if (errorMessage.contains('permission')) {
      return 'لا يوجد لديك الصلاحيات الكافية. يرجى التحقق من الإعدادات.';
    }

    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقاً.';
  }

  /// Global navigator key for accessing context in error handling
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
