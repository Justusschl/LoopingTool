import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/audio_service.dart';
import 'features/looping_tool/viewmodels/looping_tool_viewmodel.dart';
import 'theme/app_colors.dart';
import 'features/looping_tool/screens/main_screen.dart';
import 'features/looping_tool/widgets/zooom_test.dart';
//import 'features/looping_tool/screens/main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioService>(
          create: (_) => AudioService(),
        ),
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
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.card,
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: AppColors.textPrimary),
            bodyMedium: TextStyle(color: AppColors.textSecondary),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBackground,
              foregroundColor: AppColors.textPrimary,
              shape: StadiumBorder(),
            ),
          ),
        ),
        // Switch between your production and experiment screens here:
        // home: LoopingToolScreen(), // <-- Production
        home: MainScreen(),
        // home: ZoomTest(),
      ),
    ),
  );
}
