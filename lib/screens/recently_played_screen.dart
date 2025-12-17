import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../utils/constants.dart';
import '../widgets/song_tile.dart';

class RecentlyPlayedScreen extends StatelessWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AudioProvider, PlaylistProvider>(
      builder: (context, audioProvider, playlistProvider, _) {
        final songs = playlistProvider.recentSongIds
            .map(
              (id) => audioProvider.allSongs.firstWhere(
                (s) => s.id == id,
                orElse: () => audioProvider.allSongs.first,
              ),
            )
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.secondary,
            title: const Text(
              'Recently Played',
              style: AppTextStyles.title,
            ),
          ),
          body: songs.isEmpty
              ? const Center(
                  child: Text(
                    'No recently played songs',
                    style: AppTextStyles.body,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    return SongTile(
                      song: songs[index],
                      onTap: () {
                        audioProvider.playPlaylist(
                          songs,
                          initialIndex: index,
                          
                        );
                      },
                    );  
                  },
                ),
        );
      },
    );
  }
}
