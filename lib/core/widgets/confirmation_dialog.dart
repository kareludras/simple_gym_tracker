import 'package:flutter/material.dart';

/// Reusable confirmation dialog for destructive or important actions
class ConfirmationDialog {
  ConfirmationDialog._();

  /// Shows a confirmation dialog and returns true if confirmed
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDangerous
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Shows a delete confirmation dialog (pre-configured for delete actions)
  static Future<bool> showDeleteConfirmation({
    required BuildContext context,
    required String itemName,
    String? additionalMessage,
  }) async {
    final message = additionalMessage != null
        ? 'Delete "$itemName"?\n\n$additionalMessage'
        : 'Delete "$itemName"?';

    return await show(
      context: context,
      title: 'Delete Confirmation',
      message: message,
      confirmText: 'Delete',
      isDangerous: true,
    );
  }
}
