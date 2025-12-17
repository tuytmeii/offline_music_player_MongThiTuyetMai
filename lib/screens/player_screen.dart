import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import 'now_playing_screen.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_note, size: 140),

                const SizedBox(height: 20),

                Text(
                  audioProvider.currentSong?.title ?? 'Chưa phát bài nào',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: audioProvider.skipToPrevious,
                    ),
                    IconButton(
                      iconSize: 64,
                      icon: Icon(
                        audioProvider.isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                      ),
                      onPressed: audioProvider.togglePlayPause,
                    ),
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.skip_next),
                      onPressed: audioProvider.skipToNext,
                    ),
                  ],
                ),
              ],
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.08,
            minChildSize: 0.08,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black26,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Danh sách đang phát',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Divider(),

                    Expanded(
                      child: NowPlayingScreen(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
