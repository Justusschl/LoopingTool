import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/audio_service.dart';
import 'features/looping_tool/viewmodels/looping_tool_viewmodel.dart';
import 'features/looping_tool/screens/looping_tool_screen.dart';
import 'features/looping_tool/screens/looping_tool_experiment_screen.dart';
import 'theme/app_colors.dart';
import 'features/looping_tool/widgets/song_timeline_slider.dart';
import 'features/looping_tool/widgets/loop_settings_panel.dart';
import 'features/looping_tool/widgets/segment_selector.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LoopingToolViewModel>(
          create: (_) => LoopingToolViewModel(),
        ),
        ChangeNotifierProvider<AudioService>(
          create: (_) => AudioService(),
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
        home: LoopingToolExperimentScreen(), // <-- Experiment
      ),
    ),
  );
}
