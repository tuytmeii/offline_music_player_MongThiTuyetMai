import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../utils/constants.dart';
import '../widgets/mini_player.dart';
import 'all_songs_screen.dart';
import 'playlist_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AllSongsScreen(),
    const PlaylistScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.music_note),
      selectedIcon: Icon(Icons.music_note),
      label: 'Songs',
    ),
    NavigationDestination(
      icon: Icon(Icons.playlist_play),
      selectedIcon: Icon(Icons.playlist_play),
      label: 'Playlists',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final hasCurrentSong = audioProvider.currentSong != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _screens[_selectedIndex],
          if (hasCurrentSong)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: const MiniPlayer(),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          bottom: hasCurrentSong ? AppSizes.playerHeightMini : 0,
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: _destinations,
          backgroundColor: Theme.of(context).cardColor,
          indicatorColor: Theme.of(context).primaryColor.withOpacity(0.2),
          elevation: 0,
          height: 65,
        ),
      ),
    );
  }
}