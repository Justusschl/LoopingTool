import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/audio_service.dart';
import 'features/looping_tool/viewmodels/looping_tool_viewmodel.dart';
import 'theme/app_colors.dart';
import 'features/looping_tool/screens/main_screen.dart';
//import 'features/looping_tool/screens/main_screen.dart';

/// The main entry point for the Looping Tool application.
/// 
/// This file serves as the root of the application, setting up:
/// - State management using Provider
/// - Theme configuration
/// - Navigation structure
/// - Core service initialization
/// 
/// The application uses a dark theme optimized for audio work,
/// with carefully selected colors for different UI elements.
/// 
/// State Management:
/// - AudioService: Handles audio playback and processing
/// - LoopingToolViewModel: Manages the main application state
/// 
/// Theme Configuration:
/// - Dark background with high contrast
/// - Custom accent colors for interactive elements
/// - Consistent text styling
/// - Custom button appearance
void main() {
  runApp(
    MultiProvider(
      providers: [
        // Audio service provider for handling audio playback
        ChangeNotifierProvider<AudioService>(
          create: (_) => AudioService(),
        ),
        // Main view model provider with dependency on audio service
        ChangeNotifierProxyProvider<AudioService, LoopingToolViewModel>(
          create: (_) => LoopingToolViewModel(),
          update: (_, audioService, vm) {
            vm!.audioService = audioService;
            return vm;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Dark theme configuration
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.card,
          ),
          // Text theme configuration
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: AppColors.textPrimary),
            bodyMedium: TextStyle(color: AppColors.textSecondary),
          ),
          // App bar styling
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
          ),
          // Button styling
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBackground,
              foregroundColor: AppColors.textPrimary,
              shape: const StadiumBorder(),
            ),
          ),
        ),
        // Main screen configuration
        // Note: Commented options show alternative screens for development
        // home: LoopingToolScreen(), // Production screen
        home: const MainScreen(),         // Current main screen
        // home: ZoomTest(),        // Test screen
      ),
    ),
  );
}
