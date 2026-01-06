/// UI-related constants for consistent spacing, sizing, and constraints
class UIConstants {
  // Prevent instantiation
  UIConstants._();

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Widget sizes
  static const double setNumberWidth = 40.0;
  static const double checkboxWidth = 40.0;
  static const double iconButtonSize = 48.0;

  // Input constraints
  static const int noteMaxLines = 3;
  static const int maxExerciseNameLength = 100;
  static const int maxCategoryNameLength = 50;

  // Minimum requirements
  static const int minimumSetsBeforeDelete = 1;

  // Icon sizes
  static const double smallIconSize = 60.0;
  static const double largeIconSize = 80.0;

  // Card spacing
  static const double cardHorizontalMargin = 16.0;
  static const double cardVerticalMargin = 8.0;
  static const double cardPadding = 16.0;

  // List padding
  static const double listBottomPadding = 80.0;

  // Dialog sizes
  static const double dialogMaxWidth = 400.0;

  // Font sizes
  static const double categoryHeaderFontSize = 18.0;
  static const double exerciseNameFontSize = 18.0;
  static const double prFontSize = 12.0;
}
