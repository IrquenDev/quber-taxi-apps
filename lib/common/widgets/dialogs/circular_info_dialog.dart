import 'package:flutter/material.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'dart:math' as math;

/// A circular informational dialog with a large number, medium text, and small text.
///
/// This dialog displays information in a circular format with three text elements:
/// - A large number at the top
/// - Medium-sized text in the middle
/// - Small text at the bottom
///
/// The dialog is completely circular and can be used in both driver and client apps.
/// Optionally supports number animation from a start value to an end value.
///
/// Example:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => CircularInfoDialog(
///     largeNumber: '5',
///     mediumText: 'Remaining minutes',
///     smallText: 'To complete the trip',
///     animateFrom: 0,
///     animateTo: 5,
///   ),
/// );
/// ```
class CircularInfoDialog extends StatefulWidget {
  /// The large number displayed at the top of the dialog.
  final String largeNumber;

  /// The medium-sized text displayed in the middle.
  final String mediumText;

  /// The small text displayed at the bottom.
  final String smallText;

  /// Optional callback executed when the dialog is tapped to dismiss.
  final VoidCallback? onTapToDismiss;

  /// Optional starting value for number animation.
  final int? animateFrom;

  /// Optional ending value for number animation.
  final int? animateTo;

  /// Creates a circular informational dialog.
  const CircularInfoDialog({
    super.key,
    required this.largeNumber,
    required this.mediumText,
    required this.smallText,
    this.onTapToDismiss,
    this.animateFrom,
    this.animateTo,
  });

  @override
  State<CircularInfoDialog> createState() => _CircularInfoDialogState();
}

class _CircularInfoDialogState extends State<CircularInfoDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _numberAnimation;
  String _displayNumber = '';

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Check if animation is needed
    if (widget.animateFrom != null && widget.animateTo != null) {
      _numberAnimation = Tween<double>(
        begin: widget.animateFrom!.toDouble(),
        end: widget.animateTo!.toDouble(),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic, // Starts fast, ends medium speed
      ));

      _animationController.addListener(() {
        setState(() {
          _displayNumber = _numberAnimation.value.toInt().toString();
        });
      });

      // Start animation
      _animationController.forward();
    } else {
      _displayNumber = widget.largeNumber;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final size = MediaQuery.of(context).size;
    final dialogSize = size.width * 0.75; // 75% of screen width for circular dialog

    return GestureDetector(
      onTap: widget.onTapToDismiss ?? () => Navigator.of(context).pop(),
      child: Container(
        color: Theme.of(context).colorScheme.scrim,
        child: Center(
          child: Container(
            width: dialogSize,
            height: dialogSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: dimensions.elevation * 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Large number
                  Text(
                    _displayNumber,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Medium text
                  Text(
                    widget.mediumText,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Small text
                  Flexible(
                    child: Text(
                      widget.smallText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 