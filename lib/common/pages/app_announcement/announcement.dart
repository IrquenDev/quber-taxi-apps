import 'package:flutter/material.dart';
import 'package:quber_taxi/common/models/app_announcement.dart';
import 'package:quber_taxi/enums/linkable_type.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AppAnnouncementPage extends StatefulWidget {
  final List<AppAnnouncement> announcements;
  final VoidCallback? onDone;
  final Function(List<int>)? onCacheAnnouncements;

  const AppAnnouncementPage({
    super.key,
    required this.announcements,
    this.onDone,
    this.onCacheAnnouncements,
  });

  @override
  State<AppAnnouncementPage> createState() => _AppAnnouncementPageState();
}

class _AppAnnouncementPageState extends State<AppAnnouncementPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.announcements.isEmpty) {
      return const SizedBox.shrink();
    }

    final announcement = widget.announcements[_currentIndex];
    final isLastAnnouncement = _currentIndex == widget.announcements.length - 1;
    final strings = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    // Use announcement data or fallback to placeholders
    final title = announcement.title;
    final description = announcement.description ?? strings.descriptionPlaceholder;
    final imageUrl = announcement.imageUrl;
    final backgroundColor = announcement.backgroundColor;
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
    return Scaffold(
      backgroundColor: parsedBackgroundColor ?? colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Only allow action if current announcement is dismissible
          if (announcement.isDismissible) {
            if (isLastAnnouncement) {
              // Cache all announcement IDs and call done callback
              final announcementIds = widget.announcements.map((a) => a.id).toList();
              widget.onCacheAnnouncements?.call(announcementIds);
              widget.onDone?.call();
            } else {
              // Move to next announcement
              setState(() {
                _currentIndex++;
              });
            }
          }
          // If not dismissible, do nothing (locked)
        },
        child: Icon(announcement.isDismissible ? (isLastAnnouncement ? Icons.done : Icons.arrow_forward) : Icons.lock),
      ),
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
                  const SizedBox(height: 60),

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
                  const SizedBox(height: 24),

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

                  // Linkable text - show as clickable link if available
                  if (_shouldShowLinkable(announcement))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: _buildLinkableWidget(context, textTheme, colorScheme, parsedBackgroundColor, announcement),
                    ),

                  // Bottom spacing
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
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
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
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

  bool _shouldShowLinkable(AppAnnouncement announcement) {
    if (announcement.linkableType == LinkableType.none) return false;

    // Show if we have linkableText OR linkableUrl
    return (announcement.linkableText != null && announcement.linkableText!.isNotEmpty) ||
        (announcement.linkableUrl != null && announcement.linkableUrl!.isNotEmpty);
  }

  String _getLinkableDisplayText(AppAnnouncement announcement) {
    // If linkableText exists, use it. Otherwise use linkableUrl
    if (announcement.linkableText != null && announcement.linkableText!.isNotEmpty) {
      return announcement.linkableText!;
    } else if (announcement.linkableUrl != null && announcement.linkableUrl!.isNotEmpty) {
      return announcement.linkableUrl!;
    }
    return '';
  }

  Widget _buildLinkableWidget(BuildContext context, TextTheme textTheme, ColorScheme colorScheme,
      Color? parsedBackgroundColor, AppAnnouncement announcement) {
    final displayText = _getLinkableDisplayText(announcement);
    final textColor = _getSecondaryTextColor(parsedBackgroundColor, colorScheme);

    if (announcement.linkableType == LinkableType.button) {
      // Show as outlined button for BUTTON type
      return OutlinedButton(
        onPressed: () => _handleLinkableTap(context, announcement),
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: textColor),
          backgroundColor: Colors.transparent,
        ),
        child: Text(displayText),
      );
    } else {
      // Show as underlined text for TEXT type (default)
      return GestureDetector(
        onTap: () => _handleLinkableTap(context, announcement),
        child: Text(
          displayText,
          style: textTheme.bodyLarge?.copyWith(
            color: textColor,
            decoration: TextDecoration.underline,
            decorationColor: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  void _handleLinkableTap(BuildContext context, AppAnnouncement announcement) async {
    if (announcement.linkableUrl == null || announcement.linkableUrl!.isEmpty) {
      return;
    }
    final url = announcement.linkableUrl!;
    switch (announcement.linkableType) {
      case LinkableType.text:
      case LinkableType.button:
        try {
          final uri = Uri.parse(url);
          final canLaunch = await canLaunchUrl(uri);
          if (!context.mounted) return;
          if (canLaunch) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No se pudo abrir el enlace: $url')),
            );
          }
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al abrir el enlace: $e')),
          );
        }
        break;
      case LinkableType.none:
        // No action for NONE type
        break;
    }
  }
}
