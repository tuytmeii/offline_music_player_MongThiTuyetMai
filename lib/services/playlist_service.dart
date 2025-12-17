import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';

class PlaylistService {
  static final PlaylistService _instance = PlaylistService._internal();
  factory PlaylistService() => _instance;
  PlaylistService._internal();

  static const String _playlistsKey = 'user_playlists';
  static const String _favoritesKey = 'favorites_playlist';
  static const String _recentlyPlayedKey = 'recently_played';
  static const String _mostPlayedKey = 'most_played';

  // Load all playlists
  Future<List<PlaylistModel>> loadPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = prefs.getString(_playlistsKey);
      
      if (playlistsJson == null || playlistsJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(playlistsJson);
      return decoded
          .map((json) => PlaylistModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading playlists: $e');
      return [];
    }
  }

  // Save all playlists
  Future<bool> savePlaylists(List<PlaylistModel> playlists) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = jsonEncode(
        playlists.map((p) => p.toJson()).toList(),
      );
      return await prefs.setString(_playlistsKey, playlistsJson);
    } catch (e) {
      print('Error saving playlists: $e');
      return false;
    }
  }

  // Create new playlist
  Future<PlaylistModel?> createPlaylist({
    required String name,
    String? description,
  }) async {
    try {
      final playlists = await loadPlaylists();
      
      final newPlaylist = PlaylistModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        songIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      playlists.add(newPlaylist);
      final success = await savePlaylists(playlists);
      
      return success ? newPlaylist : null;
    } catch (e) {
      print('Error creating playlist: $e');
      return null;
    }
  }

  // Update playlist
  Future<bool> updatePlaylist(PlaylistModel playlist) async {
    try {
      final playlists = await loadPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlist.id);
      
      if (index == -1) return false;

      playlists[index] = playlist.copyWith(updatedAt: DateTime.now());
      return await savePlaylists(playlists);
    } catch (e) {
      print('Error updating playlist: $e');
      return false;
    }
  }

  // Delete playlist
  Future<bool> deletePlaylist(String playlistId) async {
    try {
      final playlists = await loadPlaylists();
      playlists.removeWhere((p) => p.id == playlistId);
      return await savePlaylists(playlists);
    } catch (e) {
      print('Error deleting playlist: $e');
      return false;
    }
  }

  // Add song to playlist
  Future<bool> addSongToPlaylist(String playlistId, String songId) async {
    try {
      final playlists = await loadPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlistId);
      
      if (index == -1) return false;

      final playlist = playlists[index];
      if (playlist.songIds.contains(songId)) {
        return true; // Already exists
      }

      final updatedSongIds = List<String>.from(playlist.songIds)..add(songId);
      playlists[index] = playlist.copyWith(
        songIds: updatedSongIds,
        updatedAt: DateTime.now(),
      );

      return await savePlaylists(playlists);
    } catch (e) {
      print('Error adding song to playlist: $e');
      return false;
    }
  }

  // Remove song from playlist
  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final playlists = await loadPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlistId);
      
      if (index == -1) return false;

      final playlist = playlists[index];
      final updatedSongIds = List<String>.from(playlist.songIds)
        ..remove(songId);
      
      playlists[index] = playlist.copyWith(
        songIds: updatedSongIds,
        updatedAt: DateTime.now(),
      );

      return await savePlaylists(playlists);
    } catch (e) {
      print('Error removing song from playlist: $e');
      return false;
    }
  }

  // Reorder songs in playlist
  Future<bool> reorderSongs(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    try {
      final playlists = await loadPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlistId);
      
      if (index == -1) return false;

      final playlist = playlists[index];
      final updatedSongIds = List<String>.from(playlist.songIds);
      
      if (oldIndex < 0 || oldIndex >= updatedSongIds.length ||
          newIndex < 0 || newIndex >= updatedSongIds.length) {
        return false;
      }

      final songId = updatedSongIds.removeAt(oldIndex);
      updatedSongIds.insert(newIndex, songId);

      playlists[index] = playlist.copyWith(
        songIds: updatedSongIds,
        updatedAt: DateTime.now(),
      );

      return await savePlaylists(playlists);
    } catch (e) {
      print('Error reordering songs: $e');
      return false;
    }
  }

  // Get playlist by ID
  Future<PlaylistModel?> getPlaylistById(String playlistId) async {
    try {
      final playlists = await loadPlaylists();
      return playlists.firstWhere(
        (p) => p.id == playlistId,
        orElse: () => playlists.first,
      );
    } catch (e) {
      print('Error getting playlist: $e');
      return null;
    }
  }

  // Favorites management
  Future<List<String>> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_favoritesKey) ?? [];
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  Future<bool> saveFavorites(List<String> songIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList(_favoritesKey, songIds);
    } catch (e) {
      print('Error saving favorites: $e');
      return false;
    }
  }

  Future<bool> toggleFavorite(String songId) async {
    try {
      final favorites = await loadFavorites();
      
      if (favorites.contains(songId)) {
        favorites.remove(songId);
      } else {
        favorites.add(songId);
      }

      return await saveFavorites(favorites);
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  Future<bool> isFavorite(String songId) async {
    final favorites = await loadFavorites();
    return favorites.contains(songId);
  }

  // Recently played management
  Future<List<String>> loadRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_recentlyPlayedKey) ?? [];
    } catch (e) {
      print('Error loading recently played: $e');
      return [];
    }
  }

  Future<bool> addToRecentlyPlayed(String songId) async {
    try {
      final recentlyPlayed = await loadRecentlyPlayed();
      
      // Remove if already exists to avoid duplicates
      recentlyPlayed.remove(songId);
      
      // Add to the beginning
      recentlyPlayed.insert(0, songId);
      
      // Keep only last 50 songs
      if (recentlyPlayed.length > 50) {
        recentlyPlayed.removeRange(50, recentlyPlayed.length);
      }

      final prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList(_recentlyPlayedKey, recentlyPlayed);
    } catch (e) {
      print('Error adding to recently played: $e');
      return false;
    }
  }

  // Most played management
  Future<Map<String, int>> loadMostPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_mostPlayedKey);
      
      if (jsonStr == null) return {};
      
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      print('Error loading most played: $e');
      return {};
    }
  }

  Future<bool> incrementPlayCount(String songId) async {
    try {
      final mostPlayed = await loadMostPlayed();
      mostPlayed[songId] = (mostPlayed[songId] ?? 0) + 1;

      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_mostPlayedKey, jsonEncode(mostPlayed));
    } catch (e) {
      print('Error incrementing play count: $e');
      return false;
    }
  }

  Future<List<String>> getMostPlayedSongIds({int limit = 50}) async {
    try {
      final mostPlayed = await loadMostPlayed();
      
      // Sort by play count
      final sortedEntries = mostPlayed.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedEntries
          .take(limit)
          .map((entry) => entry.key)
          .toList();
    } catch (e) {
      print('Error getting most played songs: $e');
      return [];
    }
  }

  // Clear all data
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_playlistsKey);
      await prefs.remove(_favoritesKey);
      await prefs.remove(_recentlyPlayedKey);
      await prefs.remove(_mostPlayedKey);
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }

  // Get songs for playlist
  List<Song> getPlaylistSongs(
    PlaylistModel playlist,
    List<Song> allSongs,
  ) {
    return allSongs
        .where((song) => playlist.songIds.contains(song.id))
        .toList();
  }

  // Search playlists
  Future<List<PlaylistModel>> searchPlaylists(String query) async {
    try {
      final playlists = await loadPlaylists();
      final lowerQuery = query.toLowerCase();
      
      return playlists.where((playlist) {
        return playlist.name.toLowerCase().contains(lowerQuery) ||
               (playlist.description?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      print('Error searching playlists: $e');
      return [];
    }
  }
}
// ===============================
// PLAYER STATE PERSISTENCE
// (KHÔNG PHÁ CODE CŨ)
// ===============================

extension PlaylistServicePlayerState on PlaylistService {
  static const String _lastPlayedSongKey = 'last_played_song';
  static const String _lastPositionKey = 'last_playback_position';
  static const String _shuffleEnabledKey = 'shuffle_enabled';
  static const String _repeatModeKey = 'repeat_mode';
  static const String _volumeKey = 'player_volume';

  // -------- Last played song --------
  Future<void> saveLastPlayedSong(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPlayedSongKey, songId);
  }

  Future<String?> loadLastPlayedSong() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastPlayedSongKey);
  }

  // -------- Playback position --------
  Future<void> saveLastPlaybackPosition(Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPositionKey, position.inMilliseconds);
  }

  Future<Duration> loadLastPlaybackPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_lastPositionKey) ?? 0;
    return Duration(milliseconds: ms);
  }

  // -------- Shuffle --------
  Future<void> saveShuffleEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shuffleEnabledKey, enabled);
  }

  Future<bool> loadShuffleEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shuffleEnabledKey) ?? false;
  }

  // -------- Repeat mode --------
  Future<void> saveRepeatMode(int modeIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_repeatModeKey, modeIndex);
  }

  Future<int> loadRepeatMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_repeatModeKey) ?? 0; // off
  }

  // -------- Volume --------
  Future<void> saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, volume);
  }

  Future<double> loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_volumeKey) ?? 1.0;
  }
}
