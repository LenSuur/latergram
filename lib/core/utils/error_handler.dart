import 'package:flutter/material.dart';

/// Global error and success message handler
/// Provides consistent user feedback across the app
class ErrorHandler {
  /// Shows an error message to the user
  ///
  /// [context] - BuildContext from the widget
  /// [message] - Error message to display
  /// [onRetry] - Optional callback for retry action
  static void showError(
      BuildContext context,
      String message, {
        VoidCallback? onRetry,
      }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
          label: 'Retry',
          onPressed: onRetry,
        )
            : null,
      ),
    );
  }

  /// Shows a success message to the user
  ///
  /// [context] - BuildContext from the widget
  /// [message] - Success message to display
  static void showSuccess(
      BuildContext context,
      String message,
      ) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Shows an info message to the user
  ///
  /// [context] - BuildContext from the widget
  /// [message] - Info message to display
  static void showInfo(
      BuildContext context,
      String message,
      ) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }
}