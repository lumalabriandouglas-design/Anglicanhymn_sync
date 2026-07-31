import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/hymn.dart';
import '../../reader/screens/hymn_detail_screen.dart';

class HymnTile extends StatelessWidget {
  final Hymn hymn;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;

  const HymnTile({
    super.key,
    required this.hymn,
    this.onTap,
    this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textWhite : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.textGrey : AppColors.lightTextSecondary;
    final numberBg = isDark
        ? AppColors.celestialGold.withOpacity(0.15)
        : AppColors.celestialGold.withOpacity(0.18);

    final lyricPreview = hymn.lyricsLuganda.split('\n').firstWhere(
          (line) => line.trim().isNotEmpty,
          orElse: () => 'Tap to view hymn lyrics',
        );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isDark ? 2 : 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: numberBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            hymn.number,
            style: const TextStyle(
              color: AppColors.primaryNavy,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        title: Text(
          hymn.title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
            color: titleColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          lyricPreview,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: subtitleColor,
            fontSize: 12.5,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.play_circle_outline_rounded,
            color: isDark ? AppColors.celestialGold : AppColors.primaryNavy,
            size: 28,
          ),
          onPressed: onPlayTap,
        ),
        onTap: onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HymnDetailScreen(hymn: hymn),
                ),
              );
            },
      ),
    );
  }
}