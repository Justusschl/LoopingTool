import 'package:flutter/material.dart';

/// Central color system for the Looping Tool application.
/// 
/// This class defines the color palette used throughout the application,
/// providing a consistent and cohesive visual experience. The colors are
/// carefully chosen to support a dark theme optimized for audio work,
/// with high contrast and clear visual hierarchy.
/// 
/// Color Usage:
/// - Background colors: Create visual depth and hierarchy
/// - Text colors: Ensure readability and information hierarchy
/// - Accent colors: Highlight interactive elements and important actions
/// - Button colors: Provide clear visual feedback for interactive elements
/// 
/// The colors are defined as static constants to ensure:
/// - Consistent usage across the application
/// - Easy theme modifications
/// - Clear color relationships
class AppColors {
  /// Main background color for the application
  /// A dark gray that provides good contrast while being easy on the eyes
  static const background = Color(0xFF232323);

  /// Background color for card and elevated elements
  /// Slightly darker than the main background to create visual hierarchy
  static const card = Color(0xFF181818);

  /// Primary accent color for interactive elements and highlights
  /// A vibrant red that draws attention to important actions
  static const accent = Color(0xFFFF3B30); // Red accent

  /// Primary text color
  /// Pure white for maximum readability on dark backgrounds
  static const textPrimary = Colors.white;

  /// Secondary text color
  /// A light gray for less prominent text and supporting information
  static const textSecondary = Color(0xFFB0B0B0);

  /// Background color for buttons and interactive elements
  /// A medium gray that provides good contrast for text while being
  /// visually distinct from the main background
  static const buttonBackground = Color(0xFF353535);
} 