import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final String bodyMessage;
  final String footerMessage;
  final String buttonText;

  const InfoDialog({
    super.key,
    required this.title,
    required this.bodyMessage,
    required this.footerMessage,
    this.buttonText = 'Aceptar',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      content: Column(
        spacing: 8.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bodyMessage),
          Text(footerMessage)
        ]
      ),
      actions: [
        OutlinedButton(
          onPressed: () => context.pop(),
          child: Text(buttonText)
        )
      ]
    );
  }
}