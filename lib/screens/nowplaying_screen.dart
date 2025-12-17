import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../models/song_model.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();

    final List<Song> playlist = audioProvider.currentPlaylist;
    final int currentIndex = audioProvider.currentIndex;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đang phát'),
      ),
      body: playlist.isEmpty
          ? const Center(child: Text('Chưa có bài nào đang phát'))
          : ListView.builder(
              itemCount: playlist.length,
              itemBuilder: (context, index) {
                final song = playlist[index];
                final isCurrent = index == currentIndex;

                return ListTile(
                  leading: Icon(
                    isCurrent ? Icons.play_arrow : Icons.music_note,
                    color: isCurrent ? Colors.green : null,
                  ),
                  title: Text(
                    song.title,
                    style: TextStyle(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(song.artist),
                  onTap: () {
                    audioProvider.playPlaylist(
                      playlist,
                      initialIndex: index,
                    );
                  },
                );
              },
            ),
    );
  }
}
  