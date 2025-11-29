import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool get isMobile {
  return defaultTargetPlatform == TargetPlatform.android || 
         defaultTargetPlatform == TargetPlatform.iOS;
}

bool get isWeb {
  return kIsWeb;
}

bool get isDesktop {
  return defaultTargetPlatform == TargetPlatform.windows ||
         defaultTargetPlatform == TargetPlatform.macOS ||
         defaultTargetPlatform == TargetPlatform.linux;
}

// Screen size categories
enum ScreenSize { small, medium, large }

ScreenSize getScreenSize(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return ScreenSize.small; // Mobile
  if (width < 1200) return ScreenSize.medium; // Tablet
  return ScreenSize.large; // Desktop/Web
}

// Responsive value helper
T getResponsiveValue<T>(BuildContext context, {
  required T mobile,
  required T tablet,
  required T desktop,
}) {
  final screenSize = getScreenSize(context);
  switch (screenSize) {
    case ScreenSize.small:
      return mobile;
    case ScreenSize.medium:
      return tablet;
    case ScreenSize.large:
      return desktop;
  }
}