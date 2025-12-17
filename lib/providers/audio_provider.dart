  import 'package:flutter/foundation.dart';
  import 'package:just_audio/just_audio.dart';
  import '../models/song_model.dart';
  import '../services/audio_player_service.dart';
  import '../services/storage_service.dart';
  import 'package:provider/provider.dart';
  import '../providers/playlist_provider.dart';
  import 'package:flutter/material.dart';


  class AudioProvider with ChangeNotifier {
    final AudioPlayerService _audioService = AudioPlayerService();
    final StorageService _storageService = StorageService();


  

    List<Song> _allSongs = [];
    List<String> _favorites = [];
    bool _isLoading = false;
    String? _errorMessage;

    double _playbackSpeed = 1.0;
    double _volume = 1.0;


    Duration _lastPosition = Duration.zero;

    // Getters
    List<Song> get allSongs => _allSongs;
    List<Song> get favoriteSongs =>
        _allSongs.where((song) => _favorites.contains(song.id)).toList();
    Song? get currentSong => _audioService.currentSong;
    List<Song> get currentPlaylist => _audioService.playlist;
    int get currentIndex => _audioService.currentIndex;
    bool get isShuffleEnabled => _audioService.isShuffleEnabled;
    RepeatMode get repeatMode => _audioService.repeatMode;
    bool get isLoading => _isLoading;
    String? get errorMessage => _errorMessage;
    double get playbackSpeed => _playbackSpeed;
    double get volume => _volume;


    Stream<Duration> get positionStream => _audioService.positionStream;
    Stream<Duration?> get durationStream => _audioService.durationStream;
    Stream<PlayerState> get playerStateStream =>
        _audioService.playerStateStream;

    AudioProvider() {
      _init();
    }

    Future<void> _init() async {
      await _audioService.init();
      await _audioService.restorePlayerSettings();
      await loadSongs();
      await _loadFavorites();
      await _restoreLastPlayback();
      

      _audioService.playerStateStream.listen((state) {
        final song = _audioService.currentSong;
        if (song != null) {
          _storageService.saveLastPlayed(song.id);
        }
        notifyListeners();
      });


      _audioService.positionStream.listen((position) {
        _lastPosition = position;
      });

      _audioService.onSongChanged = () async {
        final song = _audioService.currentSong;
        if (song != null) {
          await _storageService.addRecentlyPlayed(song.id);
          await _storageService.saveLastPosition(Duration.zero);
          notifyListeners();
        }
      };

      _volume = _audioService.audioPlayer.volume;
      notifyListeners();


    }



    Future<void> loadSongs() async {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      try {
        final hasPermission =
            await _storageService.requestStoragePermission();
        if (!hasPermission) {
          _errorMessage =
              'Storage permission is required to access music files';
          _isLoading = false;
          notifyListeners();
          return;
        }

        _allSongs = await _storageService.fetchAllSongs();
        _isLoading = false;
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Error loading songs: $e';
        _isLoading = false;
        notifyListeners();
      }
    }

    Future<void> _loadFavorites() async {
      _favorites = await _storageService.loadFavorites();
      notifyListeners();
    }

    Future<void> toggleFavorite(String songId) async {
      if (_favorites.contains(songId)) {
        _favorites.remove(songId);
      } else {
        _favorites.add(songId);
      }
      await _storageService.saveFavorites(_favorites);
      notifyListeners();
    }

    bool isFavorite(String songId) {
      return _favorites.contains(songId);
    }

    //  PLAYBACK CONTROL 

    Future<void> playSong(Song song) async {
    final index = _allSongs.indexOf(song);
    if (index != -1) {
      await _audioService.setPlaylist(
        _allSongs,
        initialIndex: index,
      );

      await _audioService.play();
      notifyListeners();
    }
  }
  

    Future<void> playPlaylist(
    List<Song> songs, {
    int initialIndex = 0,
    bool shuffle = false,
  }) async {
    await _audioService.setPlaylist(
      songs,
      initialIndex: initialIndex,
    );

    if (shuffle && !_audioService.isShuffleEnabled) {
      _audioService.toggleShuffle();
    }

    await _audioService.play();
    notifyListeners();
  }


    Future<void> play() async {
      await _audioService.play();
      notifyListeners();
    }

    Future<void> togglePlayPause() async {
      if (isPlaying) {
        await pause();
      } else {
        await play();
      }
    }


    Future<void> pause() async {
      await _audioService.pause();
      notifyListeners();
    }

    Future<void> stop() async {
      await _audioService.stop();
      notifyListeners();
    }

    Future<void> seek(Duration position) async {
      await _audioService.seek(position);
      await _storageService.saveLastPosition(position);
    }

    Future<void> skipToNext() async {
      await _audioService.skipToNext();

      final song = _audioService.currentSong;
      if (song != null) {
        await _storageService.addRecentlyPlayed(song.id);
        await _storageService.saveLastPlayed(song.id);
        await _storageService.saveLastPosition(Duration.zero);
      }

      notifyListeners();
    }


    Future<void> skipToPrevious() async {
      await _audioService.skipToPrevious();

      final song = _audioService.currentSong;
      if (song != null) {
        await _storageService.addRecentlyPlayed(song.id);
        await _storageService.saveLastPlayed(song.id);
        await _storageService.saveLastPosition(Duration.zero);
      }

      notifyListeners();
    }


    void toggleShuffle() {
      _audioService.toggleShuffle();
      _storageService
          .saveShuffleEnabled(_audioService.isShuffleEnabled);
      notifyListeners();
    }

    void toggleRepeatMode() {
      _audioService.toggleRepeatMode();
      _storageService
          .saveRepeatMode(_audioService.repeatMode.index);
      notifyListeners();
    }

    // VOLUME / SPEED 

    Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioService.setVolume(volume);
    await _audioService.savePlayerState();
    notifyListeners();
    }


    Future<void> setPlaybackSpeed(double speed) async {
      _playbackSpeed = speed;
      await _audioService.setPlaybackSpeed(speed);
      notifyListeners();
    }

    bool get isPlaying {
      return _audioService.audioPlayer.playing;
    }

    // RESTORE LAST STATE 

    Future<void> _restoreLastPlayback() async {
      final lastSongId = await _storageService.loadLastPlayed();
      final lastPosition =
          await _storageService.loadLastPosition();

      if (lastSongId != null) {
        final song =
            _allSongs.firstWhere((s) => s.id == lastSongId,
                orElse: () => _allSongs.isNotEmpty
                    ? _allSongs.first
                    : throw Exception());

        await playSong(song);
        await seek(lastPosition);
      }
    }

    @override
    void dispose() {
      _storageService.saveLastPosition(_lastPosition);
      _audioService.dispose();
      super.dispose();
    }
  }
