import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/onboarding_page.dart';
import '../../home/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'lottie': 'assets/animations/onboarding_convert.json',
      'title': AppStrings.onboardingTitle1,
      'subtitle': AppStrings.onboardingSubtitle1,
      'color': AppColors.onboarding1,
      'colorDark': AppColors.onboarding1Dark,
    },
    {
      'lottie': 'assets/animations/onboarding_temperature.json',
      'title': AppStrings.onboardingTitle2,
      'subtitle': AppStrings.onboardingSubtitle2,
      'color': AppColors.onboarding2,
      'colorDark': AppColors.onboarding2Dark,
    },
    {
      'lottie': 'assets/animations/onboarding_toolkit.json',
      'title': AppStrings.onboardingTitle3,
      'subtitle': AppStrings.onboardingSubtitle3,
      'color': AppColors.onboarding3,
      'colorDark': AppColors.onboarding3Dark,
    },
    {
      'icon': Icons.task_alt_rounded,
      'title': AppStrings.onboardingTitle4,
      'subtitle': AppStrings.onboardingSubtitle4,
      'color': AppColors.onboarding4,
      'colorDark': AppColors.onboarding4Dark,
    },
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _navigateToHome,
                  child: Text(
                    AppStrings.skip,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  final accentColor = isDark
                      ? page['colorDark'] as Color
                      : page['color'] as Color;

                  if (page.containsKey('lottie')) {
                    return OnboardingPage(
                      lottieAsset: page['lottie'] as String,
                      title: page['title'] as String,
                      subtitle: page['subtitle'] as String,
                      accentColor: accentColor,
                    );
                  } else {
                    return OnboardingPage(
                      icon: page['icon'] as IconData,
                      title: page['title'] as String,
                      subtitle: page['subtitle'] as String,
                      accentColor: accentColor,
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: Theme.of(context).colorScheme.primary,
                      dotColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  FilledButton(
                    onPressed: _onNext,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isLastPage ? AppStrings.getStarted : AppStrings.next,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
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
}
