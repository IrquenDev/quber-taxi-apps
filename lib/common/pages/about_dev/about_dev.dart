import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDevPage extends StatelessWidget {
  const AboutDevPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            Container(
              height: 340,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(dimensions.borderRadius),
                  bottomRight: Radius.circular(dimensions.borderRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.surfaceDim,
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: dimensions.contentPadding,
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          localizations.aboutDeveloperTitle,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCLogo(
                      context,
                      imagePath: 'assets/icons/isotipo_irquen.png',
                    ),
                    Text(
                      localizations.nameAboutDev,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.softwareCompany,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content cards
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -30,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        // Contact Info Card
                        SizedBox(
                          width: cardWidth,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(dimensions.borderRadius),
                            ),
                            child: Padding(
                              padding: dimensions.contentPadding,
                              child: Column(
                                children: [
                                  _buildContactRow(
                                    context,
                                    imagePath: 'assets/icons/mail.svg',
                                    text: localizations.email,
                                  ),
                                  const SizedBox(height: 6),
                                  _buildContactRow(
                                    context,
                                    imagePath: 'assets/icons/phone.svg',
                                    text: localizations.phoneAboutDev,
                                  ),
                                  const SizedBox(height: 6),
                                  _buildContactRow(
                                    context,
                                    imagePath: 'assets/icons/web.svg',
                                    text: localizations.websiteAboutDev,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // About Us Card
                        SizedBox(
                          width: cardWidth,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(dimensions.borderRadius),
                            ),
                            child: Padding(
                              padding: dimensions.contentPadding,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(
                                    AppLocalizations.of(context)!.aboutText,
                                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(
    BuildContext context, {
    required String imagePath,
    required String text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () => _handleTap(text),
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: text));
        if (context.mounted) {
          showToast(context: context, message: localizations.copiedToClipboard);
        }
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              imagePath,
              width: 20,
              height: 20,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCLogo(BuildContext context, {required String imagePath}) {
    return Center(
      child: Image.asset(
        imagePath,
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      ),
    );
  }

  void _handleTap(String text) async {
    Uri? uri;

    if (text.startsWith('http')) {
      uri = Uri.parse(text);
    } else if (text.contains('@')) {
      uri = Uri(
        scheme: 'mailto',
        path: text,
      );
    } else if (text.startsWith('+') || RegExp(r'^\d+$').hasMatch(text)) {
      uri = Uri(scheme: 'tel', path: text);
    }

    if (uri != null) {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        final launched = await launchUrl(
          uri,
        );
        if (!launched) {
          debugPrint('No se pudo abrir $uri');
        }
      } else {
        debugPrint('No se pudo lanzar la URL: $uri');
      }
    }
  }
}
