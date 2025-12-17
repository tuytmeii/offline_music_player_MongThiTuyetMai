import 'package:just_audio/just_audio.dart';

enum PlaybackStatus {
  idle,
  loading,
  playing,
  paused,
  buffering,
  completed,
  error,
}

enum RepeatModeEnum { off, one, all }

enum ShuffleMode { off, on }

class PlaybackStateModel {
  final PlaybackStatus status;
  final Duration position;
  final Duration duration;
  final double speed;
  final double volume;
  final RepeatModeEnum repeatMode;
  final ShuffleMode shuffleMode;
  final String? currentSongId;
  final int? currentIndex;
  final List<String> queue;
  final String? errorMessage;

  const PlaybackStateModel({
    this.status = PlaybackStatus.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.volume = 1.0,
    this.repeatMode = RepeatModeEnum.off,
    this.shuffleMode = ShuffleMode.off,
    this.currentSongId,
    this.currentIndex,
    this.queue = const [],
    this.errorMessage,
  });

  factory PlaybackStateModel.fromJson(Map<String, dynamic> json) {
    return PlaybackStateModel(
      status: PlaybackStatus.values[json['status'] as int? ?? 0],
      position: Duration(milliseconds: json['position'] as int? ?? 0),
      duration: Duration(milliseconds: json['duration'] as int? ?? 0),
      speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      repeatMode: RepeatModeEnum.values[json['repeatMode'] as int? ?? 0],
      shuffleMode: ShuffleMode.values[json['shuffleMode'] as int? ?? 0],
      currentSongId: json['currentSongId'] as String?,
      currentIndex: json['currentIndex'] as int?,
      queue: List<String>.from(json['queue'] as List? ?? []),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.index,
      'position': position.inMilliseconds,
      'duration': duration.inMilliseconds,
      'speed': speed,
      'volume': volume,
      'repeatMode': repeatMode.index,
      'shuffleMode': shuffleMode.index,
      'currentSongId': currentSongId,
      'currentIndex': currentIndex,
      'queue': queue,
      'errorMessage': errorMessage,
    };
  }

  PlaybackStateModel copyWith({
    PlaybackStatus? status,
    Duration? position,
    Duration? duration,
    double? speed,
    double? volume,
    RepeatModeEnum? repeatMode,
    ShuffleMode? shuffleMode,
    String? currentSongId,
    int? currentIndex,
    List<String>? queue,
    String? errorMessage,
  }) {
    return PlaybackStateModel(
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleMode: shuffleMode ?? this.shuffleMode,
      currentSongId: currentSongId ?? this.currentSongId,
      currentIndex: currentIndex ?? this.currentIndex,
      queue: queue ?? this.queue,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isPlaying => status == PlaybackStatus.playing;
  bool get isPaused => status == PlaybackStatus.paused;
  bool get isBuffering => status == PlaybackStatus.buffering;
  bool get isLoading => status == PlaybackStatus.loading;
  bool get hasError => status == PlaybackStatus.error;
  bool get isIdle => status == PlaybackStatus.idle;
  bool get isShuffleEnabled => shuffleMode == ShuffleMode.on;
  
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  Duration get remaining {
    return duration - position;
  }

  bool get canSkipNext => currentIndex != null && currentIndex! < queue.length - 1;
  bool get canSkipPrevious => currentIndex != null && currentIndex! > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaybackStateModel &&
        other.status == status &&
        other.position == position &&
        other.duration == duration &&
        other.speed == speed &&
        other.volume == volume &&
        other.repeatMode == repeatMode &&
        other.shuffleMode == shuffleMode &&
        other.currentSongId == currentSongId &&
        other.currentIndex == currentIndex;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      position,
      duration,
      speed,
      volume,
      repeatMode,
      shuffleMode,
      currentSongId,
      currentIndex,
    );
  }

  @override
  String toString() {
    return 'PlaybackStateModel('
        'status: $status, '
        'position: $position, '
        'duration: $duration, '
        'currentSongId: $currentSongId, '
        'repeatMode: $repeatMode, '
        'shuffleMode: $shuffleMode'
        ')';
  }

  static PlaybackStatus fromPlayerState(PlayerState playerState) {
    if (playerState.playing) {
      return PlaybackStatus.playing;
    }

    switch (playerState.processingState) {
      case ProcessingState.idle:
        return PlaybackStatus.idle;
      case ProcessingState.loading:
        return PlaybackStatus.loading;
      case ProcessingState.buffering:
        return PlaybackStatus.buffering;
      case ProcessingState.ready:
        return PlaybackStatus.paused;
      case ProcessingState.completed:
        return PlaybackStatus.completed;
    }
  }
}