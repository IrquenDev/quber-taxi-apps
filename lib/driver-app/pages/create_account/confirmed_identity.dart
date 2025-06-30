import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/driver-app/pages/create_account/create_account.dart';

class ConfirmedIdentityPage extends StatelessWidget {
  const ConfirmedIdentityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Column(
            children: [
              Container(height: 180, color: Colors.transparent),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    children: [
                      SizedBox(height: 150),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          AppLocalizations.of(context)!.thankYouForVerification,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0,),
                        child: Text(
                          AppLocalizations.of(context)!.identityConfirmedSuccessfully,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.secondary
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          AppLocalizations.of(context)!.verificationBenefits,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 20,
                              color: Theme.of(context).colorScheme.secondary
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 200,
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular
                (dimensions.borderRadius)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 52, left: 24, right: 16),
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.secondary),
                SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.identityVerificationTitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 75,
                backgroundColor: Colors.white,
                child: SvgPicture.asset(
                  "assets/icons/camera.svg",
                  width: 80,
                  height: 80,
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateAccount()),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.createAccountButton,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary
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
