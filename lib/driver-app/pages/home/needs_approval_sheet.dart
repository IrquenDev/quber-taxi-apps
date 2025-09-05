import 'package:flutter/material.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';

/// Bottom sheet widget that displays when a driver account needs approval.
/// This sheet cannot be dismissed by the user and will only disappear when
/// the driver's account state changes to approved.
class NeedsApprovalSheet extends StatelessWidget {
  const NeedsApprovalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(dimensions.cardBorderRadiusMedium),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Icon
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pending_actions,
              size: 48,
              color: colorScheme.error,
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              localizations.needsApproval,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16.0),
          
          // Body message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              localizations.needsApprovalMessage,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }
}
