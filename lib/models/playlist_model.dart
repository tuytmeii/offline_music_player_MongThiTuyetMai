class PlaylistModel {
  final String id;
  final String name;
  final String? description;
  final List<String> songIds;
  final String? coverArt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int songCount;

  PlaylistModel({
    required this.id,
    required this.name,
    this.description,
    required this.songIds,
    this.coverArt,
    required this.createdAt,
    required this.updatedAt,
    int? songCount,
  }) : songCount = songCount ?? songIds.length;

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      songIds: List<String>.from(json['songIds'] as List? ?? []),
      coverArt: json['coverArt'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      songCount: json['songCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'songIds': songIds,
      'coverArt': coverArt,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'songCount': songCount,
    };
  }

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? songIds,
    String? coverArt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? songCount,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      songIds: songIds ?? this.songIds,
      coverArt: coverArt ?? this.coverArt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      songCount: songCount ?? this.songCount,
    );
  }

  bool containsSong(String songId) {
    return songIds.contains(songId);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaylistModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PlaylistModel(id: $id, name: $name, songCount: $songCount)';
  }
}

class SystemPlaylists {
  static const String favoritesId = 'system_favorites';
  static const String recentlyPlayedId = 'system_recently_played';
  static const String mostPlayedId = 'system_most_played';

  static PlaylistModel get favorites => PlaylistModel(
        id: favoritesId,
        name: 'Favorites',
        description: 'Your favorite songs',
        songIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlaylistModel get recentlyPlayed => PlaylistModel(
        id: recentlyPlayedId,
        name: 'Danh sách bài hát đã phát gần đây',
        description: 'Các bài hát bạn đã nghe gần đây',
        songIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  static PlaylistModel get mostPlayed => PlaylistModel(
        id: mostPlayedId,
        name: 'Most Played',
        description: 'Your most played songs',
        songIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

}