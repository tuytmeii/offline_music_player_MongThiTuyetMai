import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import '../screens/now_playing_screen.dart';
import '../services/audio_player_service.dart'; // ✅ THÊM

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerService = AudioPlayerService(); // ✅ THÊM

    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final song = audioProvider.currentSong;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NowPlayingScreen(),
              ),
            );
          },
          child: Container(
            height: AppSizes.playerHeightMini,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                StreamBuilder<Duration>(
                  stream: audioProvider.positionStream,
                  builder: (context, positionSnapshot) {
                    return StreamBuilder<Duration?>(
                      stream: audioProvider.durationStream,
                      builder: (context, durationSnapshot) {
                        final position =
                            positionSnapshot.data ?? Duration.zero;
                        final duration =
                            durationSnapshot.data ?? Duration.zero;
                        final progress = duration.inMilliseconds > 0
                            ? position.inMilliseconds /
                                duration.inMilliseconds
                            : 0.0;

                        return LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.darkGrey,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          minHeight: 2,
                        );
                      },
                    );
                  },
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.screenPadding,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppSizes.albumArtRadius,
                            ),
                            color: AppColors.background,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSizes.albumArtRadius,
                            ),
                            child: song.albumArt != null
                                ? Image.asset(
                                    'assets/images/default_album_art.png',
                                    fit: BoxFit.cover,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: AppTextStyles.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.artist,
                                style: AppTextStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        StreamBuilder<PlayerState>(
                          stream: audioProvider.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final isPlaying =
                                playerState?.playing ?? false;
                            final isBuffering =
                                playerState?.processingState ==
                                    ProcessingState.buffering;

                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.skip_previous),
                                  color: AppColors.white,
                                  iconSize: 28,
                                  onPressed: () async {
                                    await audioProvider
                                        .skipToPrevious();
                                    await playerService
                                        .savePlayerState(); // ✅
                                  },
                                ),
                                if (isBuffering)
                                  const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(8.0),
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                else
                                  IconButton(
                                    icon: Icon(
                                      isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                    color: AppColors.white,
                                    iconSize: 32,
                                    onPressed: () async {
                                      if (isPlaying) {
                                        await audioProvider.pause();
                                      } else {
                                        await audioProvider.play();
                                      }
                                      await playerService
                                          .savePlayerState(); // ✅
                                    },
                                  ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.skip_next),
                                  color: AppColors.white,
                                  iconSize: 28,
                                  onPressed: () async {
                                    await audioProvider.skipToNext();
                                    await playerService
                                        .savePlayerState(); // ✅
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
