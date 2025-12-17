import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import '../widgets/playlist_card.dart';
import '../widgets/song_tile.dart';
import '../models/playlist_model.dart';
import 'recently_played_screen.dart';




class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: const Text(
          AppStrings.playlists,
          style: AppTextStyles.title,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.white),
            onPressed: () => _showCreatePlaylistDialog(context),
          ),
        ],
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, playlistProvider, child) {
          final playlists = playlistProvider.playlists;

          if (playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.playlist_play,
                    size: 64,
                    color: AppColors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No playlists yet',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreatePlaylistDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.createPlaylist),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Consumer<AudioProvider>(
            builder: (context, audioProvider, child) {
              return GridView.builder(
                padding: EdgeInsets.only(
                  top: AppSizes.screenPadding,
                  left: AppSizes.screenPadding,
                  right: AppSizes.screenPadding,
                  bottom: audioProvider.currentSong != null
                      ? AppSizes.playerHeightMini + 16
                      : 16,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: playlists.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final recentPlaylist = SystemPlaylists.recentlyPlayed;

                    final recentSongs = playlistProvider.recentSongIds
                        .map(
                          (id) => audioProvider.allSongs.firstWhere(
                            (s) => s.id == id,
                            orElse: () => audioProvider.allSongs.first,
                          ),
                        )
                        .toList();

                    return PlaylistCard(
                      playlist: recentPlaylist,
                      songCount: recentSongs.length,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecentlyPlayedScreen(),
                          ),
                        );

                      },
                    );

                  }

                  final playlist = playlists[index - 1];
                  final songs = playlistProvider.getPlaylistSongs(
                    playlist.id,
                    audioProvider.allSongs,
                  );

                  return GestureDetector(
                    onLongPress: () {
                      _showPlaylistOptions(
                        context,
                        playlist.id,
                        playlist.name,
                      );
                    },
                    child: PlaylistCard(
                      playlist: playlist,
                      songCount: songs.length,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PlaylistDetailScreen(playlist: playlist),
                          ),
                        );
                      },
                    ),
                  );
                },

              );
            },
          );
        },
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          AppStrings.createPlaylist,
          style: AppTextStyles.subtitle,
        ),
        content: TextField(
          controller: controller,
          style: AppTextStyles.body,
          decoration: const InputDecoration(
            hintText: AppStrings.playlistName,
            hintStyle: AppTextStyles.bodySmall,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<PlaylistProvider>(context, listen: false)
                    .createPlaylist(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text(
              AppStrings.create,
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(
    BuildContext context,
    String playlistId,
    String name,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename playlist'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, playlistId, name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete playlist',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, playlistId, name);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    String playlistId,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Rename Playlist',
          style: AppTextStyles.subtitle,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                Provider.of<PlaylistProvider>(context, listen: false)
                    .renamePlaylist(playlistId, newName);
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String playlistId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Delete Playlist',
          style: AppTextStyles.subtitle,
        ),
        content: Text(
          'Are you sure you want to delete "$name"?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<PlaylistProvider>(context, listen: false)
                  .deletePlaylist(playlistId);
              Navigator.pop(context);
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaylistDetailScreen extends StatelessWidget {
  final dynamic playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlaylistProvider, AudioProvider>(
      builder: (context, playlistProvider, audioProvider, child) {
        final songs = playlistProvider.getPlaylistSongs(
          playlist.id,
          audioProvider.allSongs,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.secondary,
            title: Text(
              playlist.name,
              style: AppTextStyles.title,
            ),
          ),
          body: songs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 64,
                        color: AppColors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No songs in this playlist',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(
                    bottom: audioProvider.currentSong != null
                        ? AppSizes.playerHeightMini + 16
                        : 16,
                  ),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    return SongTile(
                      song: songs[index],
                      onTap: () {
                        audioProvider.playPlaylist(
                          songs,
                          initialIndex: index,
                          
                        );
                        Provider.of<PlaylistProvider>(context, listen: false)
                          .addRecentlyPlayed(songs[index].id);
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Colors.red,
                        onPressed: () {
                          playlistProvider.removeSongFromPlaylist(
                            playlist.id,
                            songs[index].id,
                          );
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
