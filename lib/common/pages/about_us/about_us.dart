import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';


class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            Container(
              height: MediaQuery.of(context).size.height * 0.39,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.surfaceDim,
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: colorScheme.shadow),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 15),
                        Text(
                          AppLocalizations.of(context)!.aboutUsTitle,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.shadow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCLogo(
                      context,
                      imagePath: 'assets/icons/isotipo_quber.png',
                    ),

                    Text(
                      'Quber',
                      style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.shadow,
                          fontSize: 34
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.companyDescription,
                      style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.shadow,
                          fontWeight: FontWeight.normal,
                          fontSize: 18
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
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _buildContactRow(
                                    context,
                                    imagePath: 'assets/icons/mail.svg',
                                    text: AppLocalizations.of(context)!.companyAdress,
                                  ),
                                  const SizedBox(height: 6),
                                  _buildContactRow(
                                    context,
                                    imagePath: 'assets/icons/phone.svg',
                                    text: '+5355555555',
                                  ),
                                  const SizedBox(height: 6),
                                  _buildContactRow(
                                    context,
                                    imagePath: 'assets/icons/location_on.svg',
                                    text: AppLocalizations.of(context)!.contactAddress,
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
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(
                                    AppLocalizations.of(context)!.companyAboutText,
                                    style: textTheme.bodyMedium?.copyWith(
                                        fontSize: 18,
                                        color: colorScheme.secondary
                                    ),
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

  Widget _buildContactRow(BuildContext context, {required String imagePath, required String text}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),

          child: SvgPicture.asset(
            imagePath,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            color: colorScheme.secondary,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.secondary,
                fontSize: 18
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCLogo(BuildContext context, {required String imagePath}) {

    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 110),

          child: Image.asset(
            imagePath,
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
        ),

      ],
    );
  }
}