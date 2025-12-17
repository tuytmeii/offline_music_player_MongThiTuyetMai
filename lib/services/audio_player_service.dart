import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/song_model.dart';
import 'storage_service.dart';

enum RepeatMode { off, one, all }

class AudioPlayerService {
  void Function()? onSongChanged;


  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  Future<void> setPlaybackSpeed(double speed) async {
  await setSpeed(speed);
}


  final AudioPlayer _audioPlayer = AudioPlayer();
  final StorageService _storageService = StorageService();

  List<Song> _playlist = [];
  int _currentIndex = 0;
  bool _isShuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  List<int> _shuffleIndices = [];

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  Song? get currentSong =>
      _playlist.isNotEmpty ? _playlist[_currentIndex] : null;
  bool get isShuffleEnabled => _isShuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // 🔗 Restore settings từ StorageService
    _isShuffleEnabled = await _storageService.loadShuffleEnabled();
    _repeatMode =
        RepeatMode.values[await _storageService.loadRepeatMode()];

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleSongCompletion();
      }
    });
  }

  Future<void> _loadSong(int index) async {
    _currentIndex = index;
    final song = _playlist[_currentIndex];

    await _storageService.saveLastPlayed(song.id);

    onSongChanged?.call();

    try {
      if (song.filePath.startsWith('audio/')) {
        await _audioPlayer.setAsset('assets/${song.filePath}');
      } else {
        await _audioPlayer.setFilePath(song.filePath);
      }

      await _audioPlayer.seek(Duration.zero);
    } catch (e) {
      print('Error loading song: $e');
    }
  }

  Future<void> setPlaylist(
  List<Song> songs, {
  int initialIndex = 0,
}) async {
  _playlist = songs;
  _currentIndex = initialIndex;

  if (_isShuffleEnabled) {
    _generateShuffleIndices();
  }

  await _loadSong(initialIndex);
}


  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing: $e');
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    await _storageService.saveLastPosition(position);
  }

  Future<void> skipToNext() async {
    int nextIndex = _getNextIndex();
    if (nextIndex != -1) {
      await _loadSong(nextIndex);
      await play();
    }
  }

  Future<void> skipToPrevious() async {
    if (_audioPlayer.position.inSeconds > 3) {
      await seek(Duration.zero);
    } else {
      int prevIndex = _getPreviousIndex();
      if (prevIndex != -1) {
        await _loadSong(prevIndex);
        await play();
      }
    }
  }

  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    _storageService.saveShuffleEnabled(_isShuffleEnabled);

    if (_isShuffleEnabled) {
      _generateShuffleIndices();
    }
  }

  void toggleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }

    _storageService.saveRepeatMode(_repeatMode.index);
  }

  void _generateShuffleIndices() {
    _shuffleIndices = List.generate(_playlist.length, (index) => index);
    _shuffleIndices.shuffle();

    int currentSongIndex = _shuffleIndices.indexOf(_currentIndex);
    if (currentSongIndex != -1) {
      _shuffleIndices.removeAt(currentSongIndex);
      _shuffleIndices.insert(0, _currentIndex);
    }
  }

  int _getNextIndex() {
    if (_playlist.isEmpty) return -1;

    if (_repeatMode == RepeatMode.one) {
      return _currentIndex;
    }

    if (_isShuffleEnabled) {
      int currentPos = _shuffleIndices.indexOf(_currentIndex);
      if (currentPos < _shuffleIndices.length - 1) {
        return _shuffleIndices[currentPos + 1];
      } else if (_repeatMode == RepeatMode.all) {
        return _shuffleIndices[0];
      }
      return -1;
    }

    if (_currentIndex < _playlist.length - 1) {
      return _currentIndex + 1;
    } else if (_repeatMode == RepeatMode.all) {
      return 0;
    }
    return -1;
  }

  int _getPreviousIndex() {
    if (_playlist.isEmpty) return -1;

    if (_isShuffleEnabled) {
      int currentPos = _shuffleIndices.indexOf(_currentIndex);
      if (currentPos > 0) {
        return _shuffleIndices[currentPos - 1];
      } else if (_repeatMode == RepeatMode.all) {
        return _shuffleIndices[_shuffleIndices.length - 1];
      }
      return -1;
    }

    if (_currentIndex > 0) {
      return _currentIndex - 1;
    } else if (_repeatMode == RepeatMode.all) {
      return _playlist.length - 1;
    }
    return -1;
  }

  void _handleSongCompletion() {
    if (_repeatMode == RepeatMode.one) {
      seek(Duration.zero);
      play();
    } else {
      int nextIndex = _getNextIndex();
      if (nextIndex != -1) {
        _loadSong(nextIndex);
        play();
      }
    }
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed.clamp(0.5, 2.0));
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

extension AudioPlayerPersistence on AudioPlayerService {
  static const String _lastSongIdKey = 'player_last_song_id';
  static const String _lastPositionKey = 'player_last_position';
  static const String _shuffleKey = 'player_shuffle';
  static const String _repeatKey = 'player_repeat';
  static const String _volumeKey = 'player_volume';
  static const String _speedKey = 'player_speed';

  Future<void> savePlayerState() async {
    final prefs = await SharedPreferences.getInstance();

    if (currentSong != null) {
      await prefs.setString(_lastSongIdKey, currentSong!.id);
    }

    await prefs.setInt(
      _lastPositionKey,
      audioPlayer.position.inMilliseconds,
    );
    await prefs.setBool(_shuffleKey, _isShuffleEnabled);
    await prefs.setInt(_repeatKey, _repeatMode.index);
    await prefs.setDouble(_volumeKey, audioPlayer.volume);
    await prefs.setDouble(_speedKey, audioPlayer.speed);
  }

  Future<void> restorePlayerSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isShuffleEnabled = prefs.getBool(_shuffleKey) ?? false;
    _repeatMode =
        RepeatMode.values[prefs.getInt(_repeatKey) ?? 0];

    final volume = prefs.getDouble(_volumeKey);
    if (volume != null) {
      await setVolume(volume);
    }

    final speed = prefs.getDouble(_speedKey);
    if (speed != null) {
      await setSpeed(speed);
    }
  }

  Future<void> restorePlaybackPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_lastPositionKey) ?? 0;

    if (ms > 0) {
      await seek(Duration(milliseconds: ms));
    }
  }

  Future<String?> getLastPlayedSongId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSongIdKey);
  }
}
