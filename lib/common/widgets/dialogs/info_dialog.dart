import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';

/// A reusable informational dialog with a title, main message, and optional footer.
///
/// Displays a single "Accept" button and optionally executes a callback when accepted.
/// If no [onAccept] callback is provided, the dialog will simply close itself
/// using `context.pop()`.
///
/// This dialog is useful for showing non-blocking alerts, notices,
/// instructions, or confirmations without requiring complex interaction.
///
/// Example:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => InfoDialog(
///     title: 'Notice',
///     bodyMessage: 'Your session is about to expire.',
///     footerMessage: 'Please save your progress.',
///   ),
/// );
/// ```
class InfoDialog extends StatelessWidget {

  /// The dialog title displayed at the top.
  final String title;

  /// The main message shown to the user.
  final String bodyMessage;

  /// An optional footer message shown below the body (smaller or secondary info).
  final String? footerMessage;

  /// Optional callback executed when the accept button is pressed.
  /// If not provided, the dialog will dismiss by default.
  final VoidCallback? onAccept;

  /// Creates an informational dialog with optional action.
  const InfoDialog({
    super.key,
    required this.title,
    required this.bodyMessage,
    required this.footerMessage,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        spacing: 8.0, // Flutter 3.22+ uses spacing instead of mainAxisSize here
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bodyMessage),
          if (footerMessage != null) Text(footerMessage!),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            if (onAccept != null) {
              onAccept!();
            } else {
              context.pop();
            }
          },
          child: Text(AppLocalizations.of(context)!.acceptButton),
        ),
      ],
    );
  }
}