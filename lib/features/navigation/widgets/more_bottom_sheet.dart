import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/settings_provider.dart';
import '../../setlist/screens/setlist_screen.dart';

class MoreBottomSheet extends StatelessWidget {
  const MoreBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Settings & Tools',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 1. Service Setlists
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.playlist_add_check_rounded,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Service Setlists'),
            subtitle: const Text(
              'Plan order of hymns for Sunday service',
              style: TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetlistScreen()),
              );
            },
          ),
          const Divider(),

          // 2. Theme Mode
          const Text('Theme', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          SegmentedButton<AppThemeMode>(
            segments: const [
              ButtonSegment(
                value: AppThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_rounded, size: 18),
              ),
              ButtonSegment(
                value: AppThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_rounded, size: 18),
              ),
              ButtonSegment(
                value: AppThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto_rounded, size: 18),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (Set<AppThemeMode> selected) {
              settings.setThemeMode(selected.first);
            },
          ),
          const SizedBox(height: 20),

          // 3. Lyrics Language
          const Text('Default Lyrics Language',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          SegmentedButton<LyricsLanguage>(
            segments: const [
              ButtonSegment(
                value: LyricsLanguage.luganda,
                label: Text('Luganda'),
              ),
              ButtonSegment(
                value: LyricsLanguage.english,
                label: Text('English'),
              ),
              ButtonSegment(
                value: LyricsLanguage.both,
                label: Text('Both'),
              ),
            ],
            selected: {settings.lyricsLanguage},
            onSelectionChanged: (Set<LyricsLanguage> selected) {
              settings.setLyricsLanguage(selected.first);
            },
          ),
          const SizedBox(height: 20),

          // 4. PRO Mode
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(Icons.workspace_premium_rounded,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('PRO Mode Access'),
            subtitle: const Text(
              'Unlocks auto-scroll & speed modifiers',
              style: TextStyle(fontSize: 12),
            ),
            value: settings.isProUser,
            onChanged: (_) => settings.toggleProUser(),
          ),
          const Divider(),

          // 5. Font Size
          const Text('Reader Font Size',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          Slider(
            value: settings.fontSize,
            min: 14.0,
            max: 28.0,
            divisions: 14,
            label: settings.fontSize.round().toString(),
            onChanged: (val) => settings.setFontSize(val),
          ),
        ],
      ),
    );
  }
}