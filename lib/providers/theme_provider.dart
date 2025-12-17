import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeProvider with ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';

  AppThemeMode _themeMode = AppThemeMode.dark;
  Color _accentColor = AppColors.primary;
  bool _isInitialized = false;

  AppThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  bool get isInitialized => _isInitialized;
  bool get isDarkMode => _themeMode == AppThemeMode.dark;

  ThemeProvider() {
    _loadThemePreferences();
  }

  Future<void> _loadThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final themeModeIndex = prefs.getInt(_themeModeKey);
      if (themeModeIndex != null && themeModeIndex < AppThemeMode.values.length) {
        _themeMode = AppThemeMode.values[themeModeIndex];
      }

      final accentColorValue = prefs.getInt(_accentColorKey);
      if (accentColorValue != null) {
        _accentColor = Color(accentColorValue);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error loading theme preferences: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (e) {
      print('Error saving theme mode: $e');
    }
  }

  Future<void> setAccentColor(Color color) async {
    if (_accentColor == color) return;

    _accentColor = color;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_accentColorKey, color.value);
    } catch (e) {
      print('Error saving accent color: $e');
    }
  }

  Future<void> toggleTheme() async {
    final newMode = _themeMode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    await setThemeMode(newMode);
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: _accentColor,
      scaffoldBackgroundColor: Colors.grey[50],
      colorScheme: ColorScheme.light(
        primary: _accentColor,
        secondary: Colors.grey[800]!,
        background: Colors.grey[50]!,
        surface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[900],
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.grey[900]),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.albumArtRadius),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _accentColor,
        unselectedItemColor: Colors.grey[600],
        elevation: 8,
      ),
      iconTheme: IconThemeData(
        color: Colors.grey[800],
        size: AppSizes.iconSize,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.title.copyWith(color: Colors.grey[900]),
        displayMedium: AppTextStyles.subtitle.copyWith(color: Colors.grey[900]),
        bodyLarge: AppTextStyles.body.copyWith(color: Colors.grey[800]),
        bodyMedium: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
        bodySmall: AppTextStyles.caption.copyWith(color: Colors.grey[500]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _accentColor,
        inactiveTrackColor: Colors.grey[300],
        thumbColor: _accentColor,
        overlayColor: _accentColor.withOpacity(0.2),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _accentColor,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.dark(
        primary: _accentColor,
        secondary: AppColors.secondary,
        background: AppColors.background,
        surface: AppColors.cardBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.albumArtRadius),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: _accentColor,
        unselectedItemColor: AppColors.grey,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.white,
        size: AppSizes.iconSize,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.title,
        displayMedium: AppTextStyles.subtitle,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySmall,
        bodySmall: AppTextStyles.caption,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _accentColor,
        inactiveTrackColor: AppColors.darkGrey,
        thumbColor: AppColors.white,
        overlayColor: _accentColor.withOpacity(0.2),
      ),
    );
  }

  ThemeData getCurrentTheme(BuildContext context) {
    if (_themeMode == AppThemeMode.system) {
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark ? darkTheme : lightTheme;
    }
    return _themeMode == AppThemeMode.dark ? darkTheme : lightTheme;
  }

  static final List<Color> accentColors = [
    AppColors.primary,
    const Color(0xFFE91E63),
    const Color(0xFF9C27B0),
    const Color(0xFF673AB7),
    const Color(0xFF3F51B5),
    const Color(0xFF2196F3),
    const Color(0xFF00BCD4),
    const Color(0xFF009688),
    const Color(0xFFFF5722),
    const Color(0xFFFF9800), 
  ];

  Future<void> resetToDefault() async {
    await setThemeMode(AppThemeMode.dark);
    await setAccentColor(AppColors.primary);
  }
}