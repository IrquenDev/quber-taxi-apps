import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        'image': 'assets/images/friends_phone_curve1.png',
        'title': localizations.onboardingPage2Title,
        'subtitle': localizations.onboardingPage2Subtitle,
        'referral_source_options': ReferralSource.values
      }
    ];

    // Only show referral code page if friend is selected
    if (_selectedRefSrc == ReferralSource.friend) {
      pages.add({
        'image': 'assets/images/friends_phone_curve2.png',
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
      _pageController.previousPage(
          duration: _animationDuration, curve: _animationCurve);
    }
  }

  void _nextPage(int length) async {
    FocusScope.of(context).unfocus();
    if (_currentPage < length - 1) {
      _pageController.nextPage(duration: _animationDuration, curve: _animationCurve);
    } else {
      final success = await OnboardingPrefsManager.instance.saveData(_onboardingData);
      if(!mounted) return;
      if(success) {
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
            child: Column(
                children: [
                  // Page View
                  Expanded(
                      child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) => setState(() => _currentPage = index),
                          itemCount: pages.length,
                          itemBuilder: (context, index) => _buildPageView(pages[index], colorScheme, localizations)
                      )
                  ),
                  // Controls
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Page Back
                        if (_currentPage > 0)
                          GestureDetector(
                            onTap: _prevPage,
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: colorScheme.primaryContainer,
                              child: Icon(Icons.arrow_back, color: colorScheme.secondary),
                            ),
                          )
                        else const SizedBox(width: 44),
                        // Dots Indicators
                        Row(
                          children: List.generate(
                            pages.length,
                                (dotIndex) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 10,
                                  height: 10,
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
                            radius: 22,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(Icons.arrow_forward, color: colorScheme.secondary),
                          )
                        )
                      ]
                    )
                  )
                ]
            )
        )
    );
  }

  Widget _buildPageView (dynamic page, ColorScheme colorScheme, AppLocalizations localizations) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
        children: [
          // Image
          Expanded(
              child: SizedBox(
                  width: double.infinity,
                  child: ColoredBox(
                      color: colorScheme.surface,
                      child: Image.asset(page['image'], fit: BoxFit.fill)
                  )
              )
          ),
          // Data
          Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  spacing: 8.0,
                  children: [
                    if (page['title'] != null)
                      Text(
                          page['title'],
                          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                      ),
                    if (page['subtitle'] != null)
                      Text(
                          page['subtitle'],
                          style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.primaryContainer, fontWeight: FontWeight.bold
                          )
                      ),
                    if (page['description'] != null)
                      Text(page['description']),
                    if (page['referral_source_options'] != null)
                      Column(
                        spacing: 8.0,
                        children: (page['referral_source_options'] as List<ReferralSource>).map((referralOption) {
                          final isSelected = referralOption == _selectedRefSrc;
                          return OutlinedButton(
                            style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                                backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
                                side: WidgetStatePropertyAll(
                                    BorderSide(
                                        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                                        width: isSelected ? 2.0 : 1.0
                                    )
                                )
                            ),
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
                                  _pageController.animateToPage(1, duration: _animationDuration, curve: _animationCurve);
                                  _currentPage = 1;
                                }
                              });
                            },
                              child: Text(
                                  ReferralSource.nameOf(referralOption, localizations),
                                  style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? colorScheme.primary : null
                                  )
                              )
                          );
                        }).toList(),
                      ),
                    if (page['inputHint'] != null)
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextField(
                              decoration: InputDecoration(
                                  hintText: page['inputHint'],
                                  fillColor: colorScheme.surface
                              ),
                              onChanged: (value) => _onboardingData["referralCode"] = value
                          )
                      )
                  ]
              )
          )
        ]
    );
  }
}