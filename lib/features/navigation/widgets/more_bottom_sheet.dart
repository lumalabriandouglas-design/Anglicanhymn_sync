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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.celestialGold : AppColors.primaryNavy;
    final textColor = isDark ? AppColors.textWhite : AppColors.lightTextPrimary;
    final secondaryText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardNavy : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            'Settings & Tools',
            style: TextStyle(
              color: textColor,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          // Service Setlists
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.playlist_add_check_rounded, color: primaryColor),
            title: Text('Service Setlists', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
            subtitle: Text(
              'Plan order of hymns for Sunday service',
              style: TextStyle(fontSize: 12.5, color: secondaryText),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: secondaryText),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetlistScreen()),
              );
            },
          ),

          const SizedBox(height: 8),
          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
          const SizedBox(height: 12),

          // Theme Section
          Text(
            'THEME',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<AppThemeMode>(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primaryColor;
                }
                return isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return isDark ? AppColors.primaryNavy : Colors.white;
                }
                return textColor;
              }),
            ),
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

          const SizedBox(height: 22),
          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
          const SizedBox(height: 8),

          // PRO Mode
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(Icons.workspace_premium_rounded, color: primaryColor),
            title: Text('PRO Mode Access', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
            subtitle: Text(
              'Unlocks auto-scroll & speed modifiers',
              style: TextStyle(fontSize: 12.5, color: secondaryText),
            ),
            activeColor: primaryColor,
            value: settings.isProUser,
            onChanged: (_) => settings.toggleProUser(),
          ),

          const SizedBox(height: 8),
          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
          const SizedBox(height: 12),

          // Font Size
          Text(
            'READER FONT SIZE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('${settings.fontSize.round()}', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
              Expanded(
                child: Slider(
                  value: settings.fontSize,
                  min: 14.0,
                  max: 28.0,
                  divisions: 14,
                  activeColor: primaryColor,
                  onChanged: (val) => settings.setFontSize(val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}