import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final song = audioProvider.currentSong;

        if (song == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: const Center(
              child: Text(
                'No song playing',
                style: AppTextStyles.body,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, size: 32),
              color: AppColors.white,
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              children: [
                const Text(
                  AppStrings.nowPlaying,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
                Text(
                  '${audioProvider.currentIndex + 1}/${audioProvider.currentPlaylist.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  audioProvider.isFavorite(song.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: audioProvider.isFavorite(song.id)
                      ? AppColors.primary
                      : AppColors.white,
                ),
                onPressed: () {
                  audioProvider.toggleFavorite(song.id);
                },
              ),
            ],
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                /// Album Art
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppSizes.albumArtRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSizes.albumArtRadius),
                    child: Image.asset(
                      'assets/images/default_album_art.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cardBackground,
                        child: const Icon(
                          Icons.music_note,
                          size: 100,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  song.title,
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  song.artist,
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                /// Progress Bar
                StreamBuilder<Duration>(
                  stream: audioProvider.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration?>(
                      stream: audioProvider.durationStream,
                      builder: (context, snapshot) {
                        final duration = snapshot.data ?? Duration.zero;
                        return ProgressBar(
                          position: position,
                          duration: duration,
                          onSeek: audioProvider.seek,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                /// Player Controls
                StreamBuilder<PlayerState>(
                  stream: audioProvider.playerStateStream,
                  builder: (context, snapshot) {
                    final isPlaying =
                        snapshot.data?.playing ?? false;
                    return PlayerControls(
                      isPlaying: isPlaying,
                      isShuffleEnabled:
                          audioProvider.isShuffleEnabled,
                      repeatMode: audioProvider.repeatMode,
                      onPlayPause:
                          audioProvider.togglePlayPause,
                      onSkipNext:
                          audioProvider.skipToNext,
                      onSkipPrevious:
                          audioProvider.skipToPrevious,
                      onShuffle:
                          audioProvider.toggleShuffle,
                      onRepeat:
                          audioProvider.toggleRepeatMode,
                    );
                  },
                ),

                const SizedBox(height: 32),

                /// NOW PLAYING LIST
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Danh sách đang phát',
                    style: AppTextStyles.body,
                  ),
                ),

                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: audioProvider.currentPlaylist.length,
                  itemBuilder: (context, index) {
                    final s =
                        audioProvider.currentPlaylist[index];
                    final isCurrent =
                        index == audioProvider.currentIndex;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isCurrent
                            ? Icons.play_arrow
                            : Icons.music_note,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.grey,
                      ),
                      title: Text(
                        s.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: AppColors.white,
                        ),
                      ),
                      subtitle: Text(
                        s.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall,
                      ),
                      onTap: () {
                        audioProvider.playPlaylist(
                          audioProvider.currentPlaylist,
                          initialIndex: index,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
