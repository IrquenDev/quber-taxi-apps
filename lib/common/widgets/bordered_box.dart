import 'package:flutter/material.dart';

/// (Development only) A quick way to delimit your widget in the UI and see how much space it is taking up.
class BorderedBox extends StatelessWidget {

  final Widget child;

  const BorderedBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(border: Border.all()), child: child);
  }
}