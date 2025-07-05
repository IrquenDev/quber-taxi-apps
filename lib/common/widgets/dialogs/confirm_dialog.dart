import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';

/// A reusable confirmation dialog widget with localized text and customizable content.
///
/// Presents a title, message, and two actions: "Cancel" and "Accept".
/// The result is returned via `context.pop(bool)`:
/// - `true` if the user confirmed
/// - `false` if the user cancelled
///
/// Usage:
/// ```dart
/// final confirmed = await showDialog<bool>(
///   context: context,
///   builder: (_) => ConfirmDialog(
///     title: 'Confirm Action',
///     message: 'Are you sure you want to proceed?',
///   ),
/// ) ?? false;
/// ```
///
/// Localization is handled via [AppLocalizations].
class ConfirmDialog extends StatelessWidget {

  /// The dialog title text.
  final String title;

  /// The message displayed in the dialog body.
  final String message;

  /// Creates a confirmation dialog with [title] and [message].
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(localizations.cancelButton)
        ),
        OutlinedButton(
          onPressed: () => context.pop(true),
          child: Text(localizations.acceptButton)
        )
      ]
    );
  }
}