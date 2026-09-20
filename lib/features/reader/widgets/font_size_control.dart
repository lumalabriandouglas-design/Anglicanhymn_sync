import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/settings_provider.dart';

class FontSizeControl extends StatelessWidget {
  final bool compact;

  const FontSizeControl({super.key, this.compact = false});

  static const double minSize = 14;
  static const double maxSize = 28;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.textWhite : AppColors.primaryNavy;
    final canSmaller = settings.fontSize > minSize;
    final canLarger = settings.fontSize < maxSize;

    return Container(
      height: compact ? 36 : 40,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AaButton(
            label: 'A',
            fontSize: 13,
            enabled: canSmaller,
            color: color,
            tooltip: 'Smaller text',
            onTap: () => settings.setFontSize(
              (settings.fontSize - 1).clamp(minSize, maxSize),
            ),
          ),
          Container(
            width: 1,
            height: 18,
            color: Colors.grey.withOpacity(0.25),
          ),
          _AaButton(
            label: 'A',
            fontSize: 19,
            enabled: canLarger,
            color: color,
            tooltip: 'Larger text',
            onTap: () => settings.setFontSize(
              (settings.fontSize + 1).clamp(minSize, maxSize),
            ),
          ),
        ],
      ),
    );
  }
}

class _AaButton extends StatelessWidget {
  final String label;
  final double fontSize;
  final bool enabled;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _AaButton({
    required this.label,
    required this.fontSize,
    required this.enabled,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: GoogleFonts.lora(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              height: 1,
              color: enabled ? color : color.withOpacity(0.28),
            ),
          ),
        ),
      ),
    );
  }
}
