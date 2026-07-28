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
      decoration: const BoxDecoration(
        color: AppColors.cardNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                color: AppColors.textGrey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Settings & Tools',
            style: TextStyle(
              color: AppColors.celestialGold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 1. Service Setlists Manager
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.playlist_add_check_rounded, color: AppColors.celestialGold),
            title: const Text('Service Setlists', style: TextStyle(color: AppColors.textWhite)),
            subtitle: const Text('Plan order of hymns for Sunday service', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetlistScreen()),
              );
            },
          ),
          const Divider(color: AppColors.surfaceLight),

          // 2. Dark/Light Theme Toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(
              settings.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: AppColors.celestialGold,
            ),
            title: const Text('Dark Mode', style: TextStyle(color: AppColors.textWhite)),
            value: settings.isDarkMode,
            activeColor: AppColors.celestialGold,
            onChanged: (_) => settings.toggleTheme(),
          ),

          // 3. PRO Mode Toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.workspace_premium_rounded, color: AppColors.celestialGold),
            title: const Text('PRO Mode Access', style: TextStyle(color: AppColors.textWhite)),
            subtitle: const Text('Unlocks auto-scroll & speed modifiers', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
            value: settings.isProUser,
            activeColor: AppColors.celestialGold,
            onChanged: (_) => settings.toggleProUser(),
          ),

          const Divider(color: AppColors.surfaceLight),

          // 4. Text Scaling
          const Text('Reader Font Size', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          Slider(
            value: settings.fontSize,
            min: 14.0,
            max: 28.0,
            activeColor: AppColors.celestialGold,
            inactiveColor: AppColors.surfaceLight,
            onChanged: (val) => settings.setFontSize(val),
          ),
        ],
      ),
    );
  }
}