import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../services/audio_player_service.dart';
import '../providers/audio_provider.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isShuffleEnabled;
  final RepeatMode repeatMode;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipNext;
  final VoidCallback onSkipPrevious;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.isShuffleEnabled,
    required this.repeatMode,
    required this.onPlayPause,
    required this.onSkipNext,
    required this.onSkipPrevious,
    required this.onShuffle,
    required this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    final playerService = AudioPlayerService();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color:
                    isShuffleEnabled ? AppColors.primary : AppColors.grey,
              ),
              iconSize: AppSizes.buttonSizeSecondary,
              onPressed: () {
                onShuffle();
                playerService.savePlayerState();
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous),
              color: AppColors.white,
              iconSize: AppSizes.buttonSizeMain,
              onPressed: () {
                onSkipPrevious();
                playerService.savePlayerState();
              },
            ),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                color: AppColors.white,
                iconSize: 36,
                onPressed: () {
                  onPlayPause();
                  playerService.savePlayerState();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              color: AppColors.white,
              iconSize: AppSizes.buttonSizeMain,
              onPressed: () {
                onSkipNext();
                playerService.savePlayerState();
              },
            ),
            IconButton(
              icon: Icon(
                repeatMode == RepeatMode.one
                    ? Icons.repeat_one
                    : Icons.repeat,
                color: repeatMode != RepeatMode.off
                    ? AppColors.primary
                    : AppColors.grey,
              ),
              iconSize: AppSizes.buttonSizeSecondary,
              onPressed: () {
                onRepeat();
                playerService.savePlayerState();
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        Consumer<AudioProvider>(
          builder: (context, audioProvider, _) {
            return Row(
              children: [
                const Icon(Icons.volume_down, color: AppColors.grey),
                Expanded(
                  child: Slider(
                    value: audioProvider.volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      audioProvider.setVolume(value);
                    },
                  ),
                ),
                const Icon(Icons.volume_up, color: AppColors.grey),
              ],
            );
          },
        ),

        const SizedBox(height: 8),

        Consumer<AudioProvider>(
          builder: (context, audioProvider, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Playback speed',
                  style: AppTextStyles.body,
                ),
                DropdownButton<double>(
                  value: audioProvider.playbackSpeed,
                  dropdownColor: AppColors.cardBackground,
                  items: const [
                    DropdownMenuItem(
                      value: 0.75,
                      child: Text('0.75x'),
                    ),
                    DropdownMenuItem(
                      value: 1.0,
                      child: Text('1.0x'),
                    ),
                    DropdownMenuItem(
                      value: 1.25,
                      child: Text('1.25x'),
                    ),
                    DropdownMenuItem(
                      value: 1.5,
                      child: Text('1.5x'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      audioProvider.setPlaybackSpeed(value);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
