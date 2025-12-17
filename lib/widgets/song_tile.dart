import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../utils/constants.dart';
import '../utils/duration_formatter.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final Widget? trailing;
  final String? playlistId; 

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.trailing,
    this.playlistId, 
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final isCurrentSong = audioProvider.currentSong?.id == song.id;
        final isPlaying = isCurrentSong && audioProvider.isPlaying;
        return InkWell(
          onTap: () {
            onTap();

            context
                .read<PlaylistProvider>()
                .addRecentlyPlayed(song.id);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.screenPadding,
              vertical: 8,
            ),
            color: isCurrentSong
                ? AppColors.cardBackground.withOpacity(0.5)
                : Colors.transparent,
            child: Row(
              children: [
                
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppSizes.albumArtRadius),
                    color: AppColors.cardBackground,
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSizes.albumArtRadius),
                    child: song.albumArt != null
                        ? Image.asset(
                            'assets/images/default_album_art.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.music_note,
                                color: AppColors.grey,
                              );
                            },
                          )
                        : const Icon(
                            Icons.music_note,
                            color: AppColors.grey,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: AppTextStyles.body.copyWith(
                          color: isCurrentSong
                              ? AppColors.primary
                              : AppColors.white,
                          fontWeight: isCurrentSong
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                if (isPlaying)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      Icons.graphic_eq,
                      color: AppColors.primary,
                    ),
                  )
                else if (song.duration != null)
                  Text(
                    DurationFormatter.formatShort(song.duration!),
                    style: AppTextStyles.caption,
                  ),
              
                if (trailing != null)
                  trailing!
                else
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: AppColors.grey),
                    color: AppColors.cardBackground,
                    onSelected: (value) {
                      if (value == 'favorite') {
                        audioProvider.toggleFavorite(song.id);
                      } else if (value == 'add_to_playlist') {
                        _showAddToPlaylistDialog(context, song.id);
                      } else if (value == 'remove_from_playlist' &&
                          playlistId != null) {
                        context
                            .read<PlaylistProvider>()
                            .removeSongFromPlaylist(
                              playlistId!,
                              song.id,
                            );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'favorite',
                        child: Row(
                          children: [
                            Icon(
                              audioProvider.isFavorite(song.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: AppColors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              audioProvider.isFavorite(song.id)
                                  ? 'Remove from Favorites'
                                  : 'Add to Favorites',
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'add_to_playlist',
                        child: Row(
                          children: [
                            Icon(
                              Icons.playlist_add,
                              color: AppColors.white,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Text(
                              AppStrings.addToPlaylist,
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                      ),
                      if (playlistId != null)
                        const PopupMenuItem(
                          value: 'remove_from_playlist',
                          child: Row(
                            children: [
                              Icon(
                                Icons.remove_circle_outline,
                                color: AppColors.white,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Remove from playlist',
                                style: AppTextStyles.body,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, String songId) {
    showDialog(
      context: context,
      builder: (context) => Consumer<PlaylistProvider>(
        builder: (context, playlistProvider, child) {
          final playlists = playlistProvider.playlists;

          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              AppStrings.addToPlaylist,
              style: AppTextStyles.subtitle,
            ),
            content: playlists.isEmpty
                ? const Text(
                    'No playlists available. Create one first!',
                    style: AppTextStyles.body,
                  )
                : SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        final isInPlaylist =
                            playlistProvider.isSongInPlaylist(
                          playlist.id,
                          songId,
                        );

                        return ListTile(
                          enabled: !isInPlaylist,
                          leading: Icon(
                            isInPlaylist
                                ? Icons.check_circle
                                : Icons.playlist_play,
                            color: isInPlaylist
                                ? AppColors.primary
                                : AppColors.grey,
                          ),
                          title: Text(
                            playlist.name,
                            style: AppTextStyles.body,
                          ),
                          onTap: isInPlaylist
                              ? null
                              : () {
                                  playlistProvider.addSongToPlaylist(
                                    playlist.id,
                                    songId,
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Added to ${playlist.name}'),
                                      backgroundColor:
                                          AppColors.primary,
                                      duration:
                                          const Duration(seconds: 2),
                                    ),
                                  );
                                },
                        );
                      },
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: AppColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
