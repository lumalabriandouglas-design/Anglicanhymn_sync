import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/pro_features.dart';
import '../../../core/widgets/app_nav.dart';
import '../../../core/widgets/breakpoints.dart';
import '../../../providers/settings_provider.dart';
import '../../setlist/screens/setlist_screen.dart';

class MoreBottomSheet extends StatelessWidget {
  const MoreBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asDialog = Breakpoints.useRail(context);
    final primaryColor = isDark ? AppColors.celestialGold : AppColors.primaryNavy;
    final textColor = isDark ? AppColors.textWhite : AppColors.lightTextPrimary;
    final secondaryText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final bg = isDark ? AppColors.cardNavy : Colors.white;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(asDialog ? 20 : 24).copyWith(
        bottomLeft: asDialog ? const Radius.circular(20) : Radius.zero,
        bottomRight: asDialog ? const Radius.circular(20) : Radius.zero,
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!asDialog)
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
              )
            else
              const SizedBox(height: 8),

            Text(
              'Settings & Tools',
              style: TextStyle(
                color: textColor,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

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
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.push(
                  AppPageRoute(builder: (_) => const SetlistScreen()),
                );
              },
            ),

            const SizedBox(height: 8),
            Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
            const SizedBox(height: 12),

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
            const SizedBox(height: 12),

            Text(
              'LYRICS LANGUAGE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: secondaryText,
              ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<LyricsLanguage>(
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

            const SizedBox(height: 22),
            Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              decoration: BoxDecoration(
                color: AppColors.celestialGold.withOpacity(isDark ? 0.12 : 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.celestialGold.withOpacity(0.45),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'PRO',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.celestialGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          ProFeatures.previewLabel,
                          style: TextStyle(
                            color: AppColors.primaryNavy,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ProFeatures.blurb,
                    style: TextStyle(fontSize: 12.5, height: 1.35, color: secondaryText),
                  ),
                  const SizedBox(height: 10),
                  for (final item in ProFeatures.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_rounded, size: 16, color: AppColors.celestialGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(color: textColor, fontSize: 13, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
            const SizedBox(height: 12),

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
      ),
    );
  }
}
