import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import '../widgets/song_tile.dart';

enum SongSortType {
  title,
  artist,
  album,
  duration,
}

class AllSongsScreen extends StatefulWidget {
  const AllSongsScreen({super.key});

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  String _searchQuery = '';
  bool _showFavoritesOnly = false;
  SongSortType _sortType = SongSortType.title;

  List<dynamic> _applySort(List<dynamic> songs) {
    final result = List.from(songs);

    switch (_sortType) {
      case SongSortType.title:
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SongSortType.artist:
        result.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case SongSortType.album:
        result.sort(
          (a, b) => (a.album ?? '').compareTo(b.album ?? ''),
        );
        break;
      case SongSortType.duration:
        result.sort((a, b) => a.duration.compareTo(b.duration));
        break;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final songs = _showFavoritesOnly
            ? audioProvider.favoriteSongs
            : audioProvider.allSongs;

        final filteredSongs = _applySort(
          songs.where((song) {
            final query = _searchQuery.toLowerCase();
            return song.title.toLowerCase().contains(query) ||
                song.artist.toLowerCase().contains(query) ||
                (song.album?.toLowerCase().contains(query) ?? false);
          }).toList(),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.secondary,
            title: const Text(
              AppStrings.allSongs,
              style: AppTextStyles.title,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _showFavoritesOnly
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: _showFavoritesOnly
                      ? AppColors.primary
                      : AppColors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _showFavoritesOnly = !_showFavoritesOnly;
                  });
                },
              ),
              PopupMenuButton<SongSortType>(
                icon: const Icon(Icons.sort, color: AppColors.white),
                onSelected: (value) {
                  setState(() => _sortType = value);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: SongSortType.title,
                    child: Text('Sort by Title'),
                  ),
                  PopupMenuItem(
                    value: SongSortType.artist,
                    child: Text('Sort by Artist'),
                  ),
                  PopupMenuItem(
                    value: SongSortType.album,
                    child: Text('Sort by Album'),
                  ),
                  PopupMenuItem(
                    value: SongSortType.duration,
                    child: Text('Sort by Duration'),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.white),
                onPressed: () {
                  audioProvider.loadSongs();
                },
              ),
            ],
          ),
          floatingActionButton: filteredSongs.isNotEmpty
              ? FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.shuffle),
                  onPressed: () {
                    audioProvider.playSong(filteredSongs.first);
                  },
                )
              : null,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                child: TextField(
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: 'Search songs...',
                    hintStyle: AppTextStyles.bodySmall,
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              if (audioProvider.isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                )
              else if (audioProvider.errorMessage != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          audioProvider.errorMessage!,
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            audioProvider.loadSongs();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filteredSongs.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showFavoritesOnly
                              ? Icons.favorite_border
                              : Icons.music_note,
                          size: 64,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showFavoritesOnly
                              ? 'No favorite songs yet'
                              : AppStrings.noSongsFound,
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: audioProvider.currentSong != null
                          ? AppSizes.playerHeightMini + 16
                          : 16,
                    ),
                    itemCount: filteredSongs.length,
                    itemBuilder: (context, index) {
                      return SongTile(
                        song: filteredSongs[index],
                        onTap: () {
                          audioProvider.playSong(filteredSongs[index]);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
