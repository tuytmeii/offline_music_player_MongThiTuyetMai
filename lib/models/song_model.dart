class Song {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? albumArt;
  final String filePath;
  final Duration? duration;
  final int? dateAdded;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.albumArt,
    required this.filePath,
    this.duration,
    this.dateAdded,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      albumArt: json['albumArt'] as String?,
      filePath: json['filePath'] as String,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      dateAdded: json['dateAdded'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'albumArt': albumArt,
      'filePath': filePath,
      'duration': duration?.inMilliseconds,
      'dateAdded': dateAdded,
    };
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumArt,
    String? filePath,
    Duration? duration,
    int? dateAdded,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArt: albumArt ?? this.albumArt,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}

class Playlist {
  final String id;
  final String name;
  final List<String> songIds;
  final String? coverArt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    this.coverArt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      songIds: List<String>.from(json['songIds'] as List),
      coverArt: json['coverArt'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songIds': songIds,
      'coverArt': coverArt,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Playlist copyWith({
    String? id,
    String? name,
    List<String>? songIds,
    String? coverArt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      coverArt: coverArt ?? this.coverArt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}