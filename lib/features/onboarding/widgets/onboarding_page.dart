import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage extends StatelessWidget {
  final String? lottieAsset;
  final IconData? icon;
  final String title;
  final String subtitle;
  final Color accentColor;

  const OnboardingPage({
    super.key,
    this.lottieAsset,
    this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  }) : assert(lottieAsset != null || icon != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 1),
          Expanded(
            flex: 4,
            child: lottieAsset != null
                ? Lottie.asset(
                    lottieAsset!,
                    fit: BoxFit.contain,
                    repeat: true,
                  )
                : Center(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
