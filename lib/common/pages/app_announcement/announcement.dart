import 'package:flutter/material.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';

class AppAnnouncementPage extends StatelessWidget {
  const AppAnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
              child: Column(
                children: [
                  // Top spacing
                  SizedBox(height: screenHeight * 0.15),
                  
                  // Image
                  Image.asset(
                    'assets/images/looking_for_drivers.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                  
                  // Spacing between image and title
                  SizedBox(height: 60),
                  
                  // Title
                  Text(
                    strings.titlePlaceholder,
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Spacing between title and description
                  SizedBox(height: 24),
                  
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      strings.descriptionPlaceholder,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
          // Close button in top right corner
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}