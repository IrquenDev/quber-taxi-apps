import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/enums/referral_source.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/common_routes.dart';
import 'package:quber_taxi/storage/onboarding_prefs_manager.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final _animationDuration = const Duration(milliseconds: 300);
  final _animationCurve = Curves.easeInOut;
  int _currentPage = 0;
  final Map<String, String> _onboardingData = {};
  ReferralSource? _selectedRefSrc;

  List<Map<String, dynamic>> _getLocalizedPages(AppLocalizations localizations) {
    final pages = [
      {
        'image': 'assets/images/client_map_curve.png',
        'title': localizations.onboardingPage1Title,
        'subtitle': localizations.onboardingPage1Subtitle,
        'description': localizations.onboardingPage1Description
      },
      {
        'image': 'assets/images/friends_phone_curve.png',
        'title': localizations.onboardingPage2Title,
        'subtitle': localizations.onboardingPage2Subtitle,
        'referral_source_options': ReferralSource.values
      }
    ];

    // Only show referral code page if friend is selected
    if (_selectedRefSrc == ReferralSource.friend) {
      pages.add({
        'image': 'assets/images/friends_phone_curve.png',
        'title': localizations.onboardingPage3Title,
        'subtitle': localizations.onboardingPage3Subtitle,
        'description': localizations.onboardingPage3Description,
        'inputHint': localizations.onboardingPage3InputHint
      });
    }

    // Add remaining pages
    pages.addAll([
      {
        'image': 'assets/images/trip_price_curve.png',
        'title': localizations.onboardingPage4Title,
        'subtitle': localizations.onboardingPage4Subtitle,
        'description': localizations.onboardingPage4Description
      },
      {
        'image': 'assets/images/quber_points_curve.png',
        'title': localizations.onboardingPage5Title,
        'subtitle': localizations.onboardingPage5Subtitle,
        'description': localizations.onboardingPage5Description
      }
    ]);

    return pages;
  }

  void _prevPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage > 0) {
      _pageController.previousPage(duration: _animationDuration, curve: _animationCurve);
    }
  }

  void _nextPage(int length) async {
    FocusScope.of(context).unfocus();
    if (_currentPage < length - 1) {
      _pageController.nextPage(duration: _animationDuration, curve: _animationCurve);
    } else {
      final success = await OnboardingPrefsManager.instance.saveData(_onboardingData);
      if (!mounted) return;
      if (success) {
        if (kDebugMode) {
          print('ONBOARDING SAVED DATA: ${OnboardingPrefsManager.instance.getOnboardingData()}');
        }
        context.go(CommonRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    AppLocalizations localizations = AppLocalizations.of(context)!;
    final pages = _getLocalizedPages(localizations);

    return Scaffold(
      body: ColoredBox(
        color: Colors.white,
        child: Stack(
          children: [
            // Page View
            PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: pages.length,
                itemBuilder: (context, index) => _buildPageView(pages[index], colorScheme, localizations)),
            // Controls
            Positioned(
              bottom: 20.0,
              left: 20.0,
              right: 20.0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(225),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  // Page Back
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: _prevPage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(Icons.arrow_back, color: colorScheme.secondary, size: 20),
                      ),
                    )
                  else
                    const SizedBox(width: 36),
                  // Dots Indicators
                  Row(
                    children: List.generate(
                      pages.length,
                      (dotIndex) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dotIndex == _currentPage
                              ? colorScheme.primaryContainer
                              : colorScheme.primaryContainer.withAlpha(75),
                        ),
                      ),
                    ),
                  ),
                  // Next Page
                  GestureDetector(
                    onTap: () => _nextPage(pages.length),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(Icons.arrow_forward, color: colorScheme.secondary, size: 20),
                    ),
                  )
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPageView(dynamic page, ColorScheme colorScheme, AppLocalizations localizations) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        // Image - now takes full width and maintains aspect ratio
        SizedBox(
            width: double.infinity,
            child: Image.asset(
              page['image'],
              fit: BoxFit.fitWidth,
              width: double.infinity,
            )),
        // Data - now has scroll if content doesn't fit
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
            child: Column(
              children: [
                if (page['title'] != null)
                  Text(page['title'], style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                if (page['subtitle'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(page['subtitle'],
                        style: textTheme.bodyLarge
                            ?.copyWith(color: colorScheme.primaryContainer, fontWeight: FontWeight.bold)),
                  ),
                if (page['description'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(page['description']),
                  ),
                if (page['referral_source_options'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: (page['referral_source_options'] as List<ReferralSource>).map((referralOption) {
                        final isSelected = referralOption == _selectedRefSrc;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: OutlinedButton(
                              style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                                  backgroundColor: WidgetStatePropertyAll(
                                      isSelected ? colorScheme.primary.withAlpha(25) : Colors.grey.withAlpha(25)),
                                  side: WidgetStatePropertyAll(
                                    BorderSide(
                                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                                      width: isSelected ? 2.0 : 1.0,
                                    ),
                                  ),
                                  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 8.0)),
                                  minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
                                  maximumSize: const WidgetStatePropertyAll(Size(double.infinity, 36))),
                              onPressed: () {
                                setState(() {
                                  _onboardingData["referralSource"] = referralOption.apiValue;
                                  _selectedRefSrc = referralOption;
                                  // Clear referral code if not selecting friend
                                  if (referralOption != ReferralSource.friend) {
                                    _onboardingData.remove("referralCode");
                                  }
                                  // Reset to first page when changing referral source to avoid navigation issues
                                  if (_currentPage > 1) {
                                    _pageController.animateToPage(1,
                                        duration: _animationDuration, curve: _animationCurve);
                                    _currentPage = 1;
                                  }
                                });
                              },
                              child: Text(
                                ReferralSource.nameOf(referralOption, localizations),
                                style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? colorScheme.primary : null),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                if (page['inputHint'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextField(
                        decoration: InputDecoration(hintText: page['inputHint'], fillColor: colorScheme.surface),
                        onChanged: (value) => _onboardingData["referralCode"] = value),
                  ),
                const SizedBox(height: 100)
              ],
            ),
          ),
        )
      ],
    );
  }
}
