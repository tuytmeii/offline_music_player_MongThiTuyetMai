import 'package:flutter/foundation.dart';
import '../models/song_model.dart';
import '../services/storage_service.dart';

enum PlaylistSortType {
  nameAsc,
  nameDesc,
  createdAtNewest,
  createdAtOldest,
}

class PlaylistProvider with ChangeNotifier {
  static const String _recentlyPlayedKey = 'recently_played';

  final StorageService _storageService = StorageService();
  List<Playlist> _playlists = [];

  // NEW: Recently Played
  static const int _maxRecentSongs = 20;
  List<String> _recentSongIds = [];

  List<Playlist> get playlists => _playlists;
  List<String> get recentSongIds => _recentSongIds;

  PlaylistProvider() {
    loadPlaylists();
    loadRecentlyPlayed(); // NEW
  }

  Future<void> loadPlaylists() async {
    _playlists = await _storageService.loadPlaylists();
    notifyListeners();
  }

  //NEW: Load recently played
  Future<void> loadRecentlyPlayed() async {
    _recentSongIds = await _storageService.loadRecentlyPlayed();
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _playlists.add(playlist);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((playlist) => playlist.id == playlistId);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      await _storageService.savePlaylists(_playlists);
      notifyListeners();
    }
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      if (!playlist.songIds.contains(songId)) {
        final updatedSongIds = List<String>.from(playlist.songIds)
          ..add(songId);
        _playlists[index] = playlist.copyWith(
          songIds: updatedSongIds,
          updatedAt: DateTime.now(),
        );
        await _storageService.savePlaylists(_playlists);
        notifyListeners();
      }
    }
  }

  Future<void> removeSongFromPlaylist(
      String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      final updatedSongIds = List<String>.from(playlist.songIds)
        ..remove(songId);
      _playlists[index] = playlist.copyWith(
        songIds: updatedSongIds,
        updatedAt: DateTime.now(),
      );
      await _storageService.savePlaylists(_playlists);
      notifyListeners();
    }
  }

  List<Song> getPlaylistSongs(String playlistId, List<Song> allSongs) {
    final playlist = _playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => Playlist(
        id: '',
        name: '',
        songIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return allSongs
        .where((song) => playlist.songIds.contains(song.id))
        .toList();
  }

  bool isSongInPlaylist(String playlistId, String songId) {
    final playlist = _playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => Playlist(
        id: '',
        name: '',
        songIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return playlist.songIds.contains(songId);
  }

  // NEW FEATURES

  bool isPlaylistNameExists(String name) {
    return _playlists.any(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
    );
  }

  Playlist? getPlaylistById(String playlistId) {
    try {
      return _playlists.firstWhere((p) => p.id == playlistId);
    } catch (_) {
      return null;
    }
  }

  int getSongCount(String playlistId) {
    final playlist = getPlaylistById(playlistId);
    return playlist?.songIds.length ?? 0;
  }

  List<Playlist> getSortedPlaylists(PlaylistSortType sortType) {
    final sorted = List<Playlist>.from(_playlists);

    switch (sortType) {
      case PlaylistSortType.nameAsc:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case PlaylistSortType.nameDesc:
        sorted.sort((a, b) => b.name.compareTo(a.name));
        break;
      case PlaylistSortType.createdAtNewest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case PlaylistSortType.createdAtOldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    return sorted;
  }

  Future<void> addRecentlyPlayed(String songId) async {
    _recentSongIds.remove(songId);
    _recentSongIds.insert(0, songId);

    if (_recentSongIds.length > _maxRecentSongs) {
      _recentSongIds = _recentSongIds.sublist(0, _maxRecentSongs);
    }

    await _storageService.saveRecentlyPlayed(_recentSongIds);
    notifyListeners();
  }
}
