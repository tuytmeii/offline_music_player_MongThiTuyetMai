import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _playlistsKey = 'playlists';
  static const String _favoritesKey = 'favorites';
  static const String _lastPlayedKey = 'last_played';
  static const String _lastPositionKey = 'last_position';
  static const String _shuffleKey = 'shuffle_enabled';
  static const String _repeatKey = 'repeat_mode';
  static const String _playerStateKey = 'player_state';
  static const String _recentlyPlayedKey = 'recently_played';


  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<bool> requestStoragePermission() async {
    Future<bool> requestStoragePermission() async {
  if (await Permission.audio.isGranted) {
    return true;
  }

  final status = await Permission.audio.request();

  return status.isGranted;
}

    final statuses = await [
      Permission.storage,
      Permission.audio,
    ].request();

    return statuses[Permission.storage]?.isGranted == true ||
        statuses[Permission.audio]?.isGranted == true;
  }

  Future<List<Song>> fetchAllSongs() async {
    try {
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) return [];

      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.DISPLAY_NAME,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      return songs.map((song) {
        return Song(
          id: song.id.toString(),
          title: song.title,
          artist: song.artist ?? 'Unknown Artist',
          album: song.album,
          albumArt: song.data,
          filePath: song.data,
          duration: Duration(milliseconds: song.duration ?? 0),
          dateAdded: song.dateAdded,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePlaylists(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData =
        playlists.map((p) => p.toJson()).toList();
    await prefs.setString(_playlistsKey, jsonEncode(jsonData));
  }

  Future<List<Playlist>> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_playlistsKey);
    if (str == null) return [];
    final List data = jsonDecode(str);
    return data
        .map((e) => Playlist.fromJson(e))
        .toList();
  }


  Future<void> addRecentlyPlayed(String songId) async {
  final recent = await loadRecentlyPlayed();

  recent.remove(songId);
  recent.insert(0, songId);

  if (recent.length > 20) {
    recent.removeLast();
  }

  await saveRecentlyPlayed(recent);
}



  Future<void> saveFavorites(List<String> songIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, songIds);
  }

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> saveLastPlayed(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPlayedKey, songId);
  }

  Future<String?> loadLastPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastPlayedKey);
  }

  Future<void> saveLastPosition(Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastPositionKey,
      position.inMilliseconds,
    );
  }

  Future<Duration> loadLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_lastPositionKey) ?? 0;
    return Duration(milliseconds: ms);
  }

  Future<void> saveShuffleEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shuffleKey, enabled);
  }

  Future<bool> loadShuffleEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shuffleKey) ?? false;
  }

  Future<void> saveRepeatMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_repeatKey, mode);
  }

  Future<int> loadRepeatMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_repeatKey) ?? 0;
  }

  Future<void> saveRecentlyPlayed(List<String> songIds) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(_recentlyPlayedKey, songIds);
}

Future<List<String>> loadRecentlyPlayed() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(_recentlyPlayedKey) ?? [];
}


  Future<void> savePlayerState({
    required String songId,
    required int positionMs,
    required List<String> playlistIds,
    required int currentIndex,
    required bool shuffleEnabled,
    required int repeatMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'songId': songId,
      'positionMs': positionMs,
      'playlistIds': playlistIds,
      'currentIndex': currentIndex,
      'shuffleEnabled': shuffleEnabled,
      'repeatMode': repeatMode,
    };
    await prefs.setString(_playerStateKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> loadPlayerState() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_playerStateKey);
    if (str == null) return null;
    return jsonDecode(str);
  }

  Future<void> clearPlayerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playerStateKey);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
