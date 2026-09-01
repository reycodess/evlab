import 'package:flutter/material.dart';

/// Lightweight app-wide preferences. Kept dependency-free so EV-LAB works
/// on Android and Web without an additional settings package.
class EVLabSettings {
  EVLabSettings._();

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.system);
  static final ValueNotifier<bool> animationsEnabled = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> soundEnabled = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> scientificGuidance = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> compactMode = ValueNotifier<bool>(false);

  static void dispose() {
    themeMode.dispose();
    animationsEnabled.dispose();
    soundEnabled.dispose();
    scientificGuidance.dispose();
    compactMode.dispose();
  }
}

class EVLabColors {
  EVLabColors._();
  static const Color emerald = Color(0xFF12B8A6);
  static const Color emeraldDark = Color(0xFF078A7C);
  static const Color emeraldLight = Color(0xFF75E6D7);
  static const Color cyan = Color(0xFF22B8CF);
  static const Color blue = Color(0xFF4C8DFF);
  static const Color purple = Color(0xFF7566E8);
  static const Color purpleLight = Color(0xFFB39DFF);
  static const Color orange = Color(0xFFFFA62B);
  static const Color yellow = Color(0xFFFFD166);
  static const Color pink = Color(0xFFEC5A93);
  static const Color coral = Color(0xFFFF7657);
  static const Color background = Color(0xFFF4F8FA);
  static const Color darkBackground = Color(0xFF0C1420);
  static const Color card = Colors.white;
  static const Color darkCard = Color(0xFF172232);
  static const Color textDark = Color(0xFF172033);
  static const Color textMedium = Color(0xFF596579);
  static const Color textLight = Color(0xFF8A94A6);
  static const Color success = Color(0xFF20A879);
  static const Color warning = Color(0xFFFFA000);
  static const Color danger = Color(0xFFE84A5F);
}

class EVLabGradients {
  EVLabGradients._();
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [EVLabColors.emerald, EVLabColors.cyan],
  );
  static const LinearGradient purple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [EVLabColors.purple, EVLabColors.pink],
  );
  static const LinearGradient orange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [EVLabColors.orange, EVLabColors.coral],
  );
  static const LinearGradient blue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [EVLabColors.blue, EVLabColors.cyan],
  );
  static const LinearGradient dark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF111827), Color(0xFF172554)],
  );
}

class EVLabTheme {
  EVLabTheme._();

  static ThemeData light() => _theme(Brightness.light);
  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final background = dark ? EVLabColors.darkBackground : EVLabColors.background;
    final card = dark ? EVLabColors.darkCard : EVLabColors.card;
    final text = dark ? Colors.white : EVLabColors.textDark;
    final secondary = dark ? const Color(0xFFB7C3D4) : EVLabColors.textMedium;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Arial',
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: EVLabColors.emerald,
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: dark ? 1 : 2,
        shadowColor: Colors.black.withValues(alpha: dark ? .25 : .08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textTheme: ThemeData(brightness: brightness, fontFamily: 'Arial').textTheme.apply(
            bodyColor: text,
            displayColor: text,
          ).copyWith(
            bodyMedium: TextStyle(color: secondary, height: 1.45),
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EVLabColors.emeraldDark,
          foregroundColor: Colors.white,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: EVLabColors.emeraldDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: EVLabColors.emerald,
        inactiveTrackColor: EVLabColors.emeraldLight.withValues(alpha: .45),
        thumbColor: EVLabColors.emeraldDark,
      ),
    );
  }
}
