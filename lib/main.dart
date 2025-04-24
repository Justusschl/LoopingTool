import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/audio_service.dart';
import 'features/looping_tool/viewmodels/looping_tool_viewmodel.dart';
import 'features/looping_tool/screens/looping_tool_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LoopingToolViewModel>(
          create: (_) => LoopingToolViewModel(),
        ),
        ChangeNotifierProvider<AudioService>(
          create: (_) => AudioService(), // ✅ Matches type expectations
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Looping Tool MVP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoopingToolScreen(),
    );
  }
}
