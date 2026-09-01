import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const EVLabApp());
}

class EVLabApp extends StatelessWidget {
  const EVLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: EVLabSettings.themeMode,
      builder: (context, mode, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EV-LAB',
        theme: EVLabTheme.light(),
        darkTheme: EVLabTheme.dark(),
        themeMode: mode,
        home: const HomeScreen(),
      ),
    );
  }
}
