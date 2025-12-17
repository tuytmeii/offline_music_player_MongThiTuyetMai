import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorExtractor {
  static Future<Color?> extractDominantColor(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    try {
      ImageProvider? imageProvider;

      if (imagePath.startsWith('assets/')) {
        imageProvider = AssetImage(imagePath);
      } else if (imagePath.startsWith('http://') || 
                 imagePath.startsWith('https://')) {
        imageProvider = NetworkImage(imagePath);
      } else {
        final file = File(imagePath);
        if (file.existsSync()) {
          imageProvider = FileImage(file);
        }
      }

      if (imageProvider == null) {
        return null;
      }

      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(100, 100),
        maximumColorCount: 10,
      );

      return paletteGenerator.dominantColor?.color ??
          paletteGenerator.vibrantColor?.color ??
          paletteGenerator.mutedColor?.color;
    } catch (e) {
      print('Error extracting color: $e');
      return null;
    }
  }

  static Future<ColorPalette?> extractPalette(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    try {
      ImageProvider? imageProvider;

      if (imagePath.startsWith('assets/')) {
        imageProvider = AssetImage(imagePath);
      } else if (imagePath.startsWith('http://') || 
                 imagePath.startsWith('https://')) {
        imageProvider = NetworkImage(imagePath);
      } else {
        final file = File(imagePath);
        if (file.existsSync()) {
          imageProvider = FileImage(file);
        }
      }

      if (imageProvider == null) {
        return null;
      }

      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(100, 100),
        maximumColorCount: 16,
      );

      return ColorPalette(
        dominant: paletteGenerator.dominantColor?.color,
        vibrant: paletteGenerator.vibrantColor?.color,
        vibrantLight: paletteGenerator.lightVibrantColor?.color,
        vibrantDark: paletteGenerator.darkVibrantColor?.color,
        muted: paletteGenerator.mutedColor?.color,
        mutedLight: paletteGenerator.lightMutedColor?.color,
        mutedDark: paletteGenerator.darkMutedColor?.color,
      );
    } catch (e) {
      print('Error extracting palette: $e');
      return null;
    }
  }

  static Future<LinearGradient?> extractGradient(String? imagePath) async {
    final palette = await extractPalette(imagePath);
    if (palette == null) return null;

    final colors = <Color>[];
    
    if (palette.vibrant != null) colors.add(palette.vibrant!);
    if (palette.vibrantDark != null) colors.add(palette.vibrantDark!);
    if (palette.dominant != null && colors.length < 2) {
      colors.add(palette.dominant!);
    }

    if (colors.isEmpty) return null;
    if (colors.length == 1) colors.add(colors[0].withOpacity(0.7));

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  static bool isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  static Color getContrastingTextColor(Color backgroundColor) {
    return isLightColor(backgroundColor) ? Colors.black : Colors.white;
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  static Color getComplementary(Color color) {
    final hsl = HSLColor.fromColor(color);
    final complementaryHue = (hsl.hue + 180) % 360;
    return hsl.withHue(complementaryHue).toColor();
  }

  static ColorScheme createColorScheme(Color primaryColor) {
    final hsl = HSLColor.fromColor(primaryColor);
    
    return ColorScheme(
      brightness: isLightColor(primaryColor) ? Brightness.light : Brightness.dark,
      primary: primaryColor,
      onPrimary: getContrastingTextColor(primaryColor),
      secondary: hsl.withHue((hsl.hue + 30) % 360).toColor(),
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      background: isLightColor(primaryColor) ? Colors.white : Colors.black,
      onBackground: isLightColor(primaryColor) ? Colors.black : Colors.white,
      surface: isLightColor(primaryColor) ? Colors.grey[100]! : Colors.grey[900]!,
      onSurface: isLightColor(primaryColor) ? Colors.black : Colors.white,
    );
  }

  static Color blend(Color color1, Color color2, double ratio) {
    assert(ratio >= 0 && ratio <= 1);
    
    return Color.lerp(color1, color2, ratio)!;
  }

  static List<Color> getAnalogousColors(Color color, {int count = 3}) {
    final hsl = HSLColor.fromColor(color);
    final colors = <Color>[];
    final step = 30.0;

    for (int i = -(count ~/ 2); i <= (count ~/ 2); i++) {
      final hue = (hsl.hue + (i * step)) % 360;
      colors.add(hsl.withHue(hue).toColor());
    }

    return colors;
  }

  static List<Color> getTriadicColors(Color color) {
    final hsl = HSLColor.fromColor(color);
    
    return [
      color,
      hsl.withHue((hsl.hue + 120) % 360).toColor(),
      hsl.withHue((hsl.hue + 240) % 360).toColor(),
    ];
  }
}

class ColorPalette {
  final Color? dominant;
  final Color? vibrant;
  final Color? vibrantLight;
  final Color? vibrantDark;
  final Color? muted;
  final Color? mutedLight;
  final Color? mutedDark;

  const ColorPalette({
    this.dominant,
    this.vibrant,
    this.vibrantLight,
    this.vibrantDark,
    this.muted,
    this.mutedLight,
    this.mutedDark,
  });

  Color? get primaryColor => vibrant ?? dominant;

  Color? get secondaryColor => vibrantDark ?? mutedDark;

  Color? get backgroundColor => muted ?? mutedLight;

  bool get hasColors =>
      dominant != null ||
      vibrant != null ||
      muted != null;

  List<Color> get allColors {
    final colors = <Color>[];
    if (dominant != null) colors.add(dominant!);
    if (vibrant != null) colors.add(vibrant!);
    if (vibrantLight != null) colors.add(vibrantLight!);
    if (vibrantDark != null) colors.add(vibrantDark!);
    if (muted != null) colors.add(muted!);
    if (mutedLight != null) colors.add(mutedLight!);
    if (mutedDark != null) colors.add(mutedDark!);
    return colors;
  }

  @override
  String toString() {
    return 'ColorPalette('
        'dominant: $dominant, '
        'vibrant: $vibrant, '
        'muted: $muted'
        ')';
  }
}