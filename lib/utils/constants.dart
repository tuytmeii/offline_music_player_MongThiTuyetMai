import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1DB954);
  static const Color secondary = Color(0xFF191414);
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF282828);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFB3B3B3);
  static const Color darkGrey = Color(0xFF535353);
}

class AppSizes {
  static const double playerHeightMini = 80.0;
  static const double buttonSizeMain = 48.0;
  static const double buttonSizeSecondary = 40.0;
  static const double albumArtRadius = 8.0;
  static const double screenPadding = 16.0;
  static const double cardPadding = 12.0;
  static const double iconSize = 24.0;
  static const double iconSizeLarge = 32.0;
}

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.white,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    color: AppColors.grey,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.grey,
  );
}

class AppStrings {
  static const String appName = 'Music Player';
  static const String allSongs = 'All Songs';
  static const String playlists = 'Playlists';
  static const String favorites = 'Favorites';
  static const String settings = 'Settings';
  static const String nowPlaying = 'Now Playing';
  static const String createPlaylist = 'Create Playlist';
  static const String playlistName = 'Playlist Name';
  static const String cancel = 'Cancel';
  static const String create = 'Create';
  static const String delete = 'Delete';
  static const String rename = 'Rename';
  static const String addToPlaylist = 'Add to Playlist';
  static const String removeFromPlaylist = 'Remove from Playlist';
  static const String noSongsFound = 'No songs found';
  static const String permissionRequired = 'Storage permission is required';
  static const String unknownArtist = 'Unknown Artist';
  static const String unknownAlbum = 'Unknown Album';
}