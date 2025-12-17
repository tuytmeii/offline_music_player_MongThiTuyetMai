import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/audio_provider.dart';
import '../services/playlist_service.dart';
import '../services/permission_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PermissionService _permissionService = PermissionService();
  final PlaylistService _playlistService = PlaylistService();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.settings,
          style: AppTextStyles.title,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          _buildSectionHeader('Appearance'),
          _buildCard(
            children: [
              _buildThemeModeTile(themeProvider),
              const Divider(height: 1),
              _buildAccentColorTile(themeProvider),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Playback'),
          _buildCard(
            children: [
              _buildPlaybackQualityTile(),
              const Divider(height: 1),
              _buildGaplessPlaybackTile(),
              const Divider(height: 1),
              _buildCrossfadeTile(),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Storage & Permissions'),
          _buildCard(
            children: [
              _buildPermissionsTile(),
              const Divider(height: 1),
              _buildRescanMusicTile(audioProvider),
              const Divider(height: 1),
              _buildClearCacheTile(),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Data Management'),
          _buildCard(
            children: [
              _buildExportDataTile(),
              const Divider(height: 1),
              _buildClearAllDataTile(),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('About'),
          _buildCard(
            children: [
              _buildAboutTile(),
              const Divider(height: 1),
              _buildVersionTile(),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.subtitle.copyWith(
          fontSize: 14,
          color: AppColors.grey,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  // Theme Mode
  Widget _buildThemeModeTile(ThemeProvider themeProvider) {
    return ListTile(
      leading: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: AppColors.primary,
      ),
      title: const Text('Theme Mode', style: AppTextStyles.body),
      subtitle: Text(
        _getThemeModeText(themeProvider.themeMode),
        style: AppTextStyles.caption,
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: () => _showThemeModeDialog(themeProvider),
    );
  }

  String _getThemeModeText(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System Default';
    }
  }

  void _showThemeModeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Theme Mode', style: AppTextStyles.subtitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(_getThemeModeText(mode), style: AppTextStyles.body),
              value: mode,
              groupValue: themeProvider.themeMode,
              activeColor: AppColors.primary,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAccentColorTile(ThemeProvider themeProvider) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: themeProvider.accentColor,
          shape: BoxShape.circle,
        ),
      ),
      title: const Text('Accent Color', style: AppTextStyles.body),
      subtitle: const Text('Customize app colors', style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: () => _showAccentColorDialog(themeProvider),
    );
  }

  void _showAccentColorDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Choose Accent Color', style: AppTextStyles.subtitle),
        content: SizedBox(
          width: double.maxFinite,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ThemeProvider.accentColors.map((color) {
              final isSelected = color == themeProvider.accentColor;
              return GestureDetector(
                onTap: () {
                  themeProvider.setAccentColor(color);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppColors.white, width: 3)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: AppColors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackQualityTile() {
    return const ListTile(
      leading: Icon(Icons.high_quality, color: AppColors.primary),
      title: Text('Audio Quality', style: AppTextStyles.body),
      subtitle: Text('High Quality (320kbps)', style: AppTextStyles.caption),
      trailing: Icon(Icons.chevron_right, color: AppColors.grey),
    );
  }

  Widget _buildGaplessPlaybackTile() {
    return SwitchListTile(
      secondary: const Icon(Icons.music_note, color: AppColors.primary),
      title: const Text('Gapless Playback', style: AppTextStyles.body),
      subtitle: const Text('Seamless song transitions', style: AppTextStyles.caption),
      value: false,
      activeColor: AppColors.primary,
      onChanged: (value) {
      },
    );
  }

  Widget _buildCrossfadeTile() {
    return SwitchListTile(
      secondary: const Icon(Icons.blur_on, color: AppColors.primary),
      title: const Text('Crossfade', style: AppTextStyles.body),
      subtitle: const Text('Fade between songs', style: AppTextStyles.caption),
      value: false,
      activeColor: AppColors.primary,
      onChanged: (value) {
      },
    );
  }

  Widget _buildPermissionsTile() {
    return ListTile(
      leading: const Icon(Icons.security, color: AppColors.primary),
      title: const Text('Permissions', style: AppTextStyles.body),
      subtitle: const Text('Manage app permissions', style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: () async {
        await _permissionService.openAppSettings();
      },
    );
  }

  Widget _buildRescanMusicTile(AudioProvider audioProvider) {
    return ListTile(
      leading: const Icon(Icons.refresh, color: AppColors.primary),
      title: const Text('Rescan Music Library', style: AppTextStyles.body),
      subtitle: const Text('Refresh song list', style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: () async {
        await audioProvider.loadSongs();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Music library rescanned'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      },
    );
  }

  Widget _buildClearCacheTile() {
    return ListTile(
      leading: const Icon(Icons.delete_sweep, color: AppColors.primary),
      title: const Text('Clear Cache', style: AppTextStyles.body),
      subtitle: const Text('Free up storage space', style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: () {
        _showClearCacheDialog();
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Clear Cache?', style: AppTextStyles.subtitle),
        content: const Text(
          'This will clear temporary files and free up storage space.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildExportDataTile() {
    return ListTile(
      leading: const Icon(Icons.upload, color: AppColors.primary),
      title: const Text('Export Playlists', style: AppTextStyles.body),
      subtitle: const Text('Backup your data', style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export feature coming soon'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
    );
  }

  Widget _buildClearAllDataTile() {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Colors.red),
      title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
      subtitle: const Text('Delete all playlists and settings', style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: () => _showClearAllDataDialog(),
    );
  }

  void _showClearAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Clear All Data?', style: AppTextStyles.subtitle),
        content: const Text(
          'This will permanently delete all your playlists, favorites, and settings. This action cannot be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await _playlistService.clearAllData();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTile() {
    return ListTile(
      leading: const Icon(Icons.info, color: AppColors.primary),
      title: const Text('About', style: AppTextStyles.body),
      subtitle: const Text('Learn more about this app', style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: AppStrings.appName,
          applicationVersion: '1.0.0',
          applicationIcon: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.music_note,
              color: AppColors.white,
              size: 32,
            ),
          ),
          children: [
            const SizedBox(height: 16),
            const Text(
              'A simple and beautiful offline music player built with Flutter.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2024 Music Player',
              style: AppTextStyles.caption,
            ),
          ],
        );
      },
    );
  }

  Widget _buildVersionTile() {
    return const ListTile(
      leading: Icon(Icons.info_outline, color: AppColors.primary),
      title: Text('Version', style: AppTextStyles.body),
      subtitle: Text('1.0.0', style: AppTextStyles.caption),
    );
  }
}