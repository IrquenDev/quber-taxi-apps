import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/client_routes.dart';
import 'package:quber_taxi/navigation/routes/driver_routes.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/runtime.dart';

class FaceIdConfirmed extends StatelessWidget {
  final Uint8List imageBytes;

  const FaceIdConfirmed({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Column(children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(dimensions.cardBorderRadiusMedium),
                  bottomRight: Radius.circular(dimensions.cardBorderRadiusMedium),
                ),
                boxShadow: [
                  BoxShadow(color: colorScheme.primary.withAlpha(50), blurRadius: 9, offset: const Offset(0, 4)),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                  child: Text(
                    AppLocalizations.of(context)!.thankYouForVerification,
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 150),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                AppLocalizations.of(context)!.thanks,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                AppLocalizations.of(context)!.successConfirm,
                textAlign: TextAlign.left,
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.shadow),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                AppLocalizations.of(context)!.passSecurity,
                textAlign: TextAlign.left,
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.shadow),
              ),
            ),
            const SizedBox(height: 40),
            const Spacer(),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  shape: const RoundedRectangleBorder(),
                  elevation: 0,
                ),
                onPressed: () {
                  // We don't care about admin here, 'cause they don't have a create account page. Otherwise this
                  // should be taken into account.
                  final route = isClientMode ? ClientRoutes.createAccount : DriverRoutes.createAccount;
                  context.go(route, extra: imageBytes);
                },
                child: Text(
                  AppLocalizations.of(context)!.createAccountButton,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            )
          ]),
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onSecondaryContainer,
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
