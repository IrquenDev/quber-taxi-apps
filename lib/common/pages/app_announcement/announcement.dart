import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/common/models/app_announcement.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';

class AppAnnouncementPage extends StatelessWidget {
  final AppAnnouncement? announcement;
  
  const AppAnnouncementPage({super.key, this.announcement});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    // Use announcement data or fallback to placeholders
    final title = announcement?.title ?? strings.titlePlaceholder;
    final description = announcement?.description ?? strings.descriptionPlaceholder;
    final imageUrl = announcement?.imageUrl;
    final backgroundColor = announcement?.backgroundColor;
    final isDismissible = announcement?.isDismissible ?? false;

    // Parse background color from hex string
    Color? parsedBackgroundColor;
    if (backgroundColor != null && backgroundColor.isNotEmpty) {
      try {
        // Remove # if present and ensure it's a valid hex color
        String colorString = backgroundColor.replaceAll('#', '');
        if (colorString.length == 6) {
          colorString = 'FF$colorString'; // Add alpha if not present
        }
        parsedBackgroundColor = Color(int.parse(colorString, radix: 16));
      } catch (e) {
        // If parsing fails, use default background
        parsedBackgroundColor = null;
      }
    }

    return PopScope(
      canPop: isDismissible,
      child: Scaffold(
        backgroundColor: parsedBackgroundColor ?? colorScheme.surface,
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                child: Column(
                  children: [
                    // Top spacing
                    SizedBox(height: screenHeight * 0.15),
                    
                    // Image - use network image if available, fallback to asset
                    _buildImage(imageUrl),
                    
                    // Spacing between image and title
                    SizedBox(height: 60),
                    
                    // Title
                    Text(
                      title,
                      style: textTheme.headlineMedium?.copyWith(
                        color: _getTextColor(parsedBackgroundColor, colorScheme),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    // Spacing between title and description
                    SizedBox(height: 24),
                    
                    // Description
                    if (description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          description,
                          style: textTheme.bodyLarge?.copyWith(
                            color: _getSecondaryTextColor(parsedBackgroundColor, colorScheme),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    // Bottom spacing
                    Spacer(),
                  ],
                ),
              ),
            ),
            // Close button in top right corner - only show if dismissible
            if (isDismissible)
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.close,
                      color: _getTextColor(parsedBackgroundColor, colorScheme),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    const double imageSize = 200;
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        height: imageSize,
        width: imageSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to asset image if network image fails
          return Image.asset(
            'assets/images/looking_for_drivers.png',
            height: imageSize,
            width: imageSize,
            fit: BoxFit.contain,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            height: imageSize,
            width: imageSize,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else {
      // Use default asset image
      return Image.asset(
        'assets/images/looking_for_drivers.png',
        height: imageSize,
        width: imageSize,
        fit: BoxFit.contain,
      );
    }
  }

  Color _getTextColor(Color? backgroundColor, ColorScheme colorScheme) {
    if (backgroundColor != null) {
      // Calculate if we need light or dark text based on background brightness
      double luminance = backgroundColor.computeLuminance();
      return luminance > 0.5 ? Colors.black87 : Colors.white;
    }
    return colorScheme.onSurface;
  }

  Color _getSecondaryTextColor(Color? backgroundColor, ColorScheme colorScheme) {
    if (backgroundColor != null) {
      double luminance = backgroundColor.computeLuminance();
      return luminance > 0.5 ? Colors.black54 : Colors.white70;
    }
    return colorScheme.onSurfaceVariant;
  }
}