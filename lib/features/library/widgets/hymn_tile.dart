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
    final lyricPreview = hymn.lyricsLuganda.split('\n').firstWhere(
          (line) => line.trim().isNotEmpty,
          orElse: () => 'Tap to view hymn lyrics',
        );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.celestialGold.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            hymn.number,
            style: const TextStyle(
              color: AppColors.celestialGold,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          hymn.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textWhite,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          lyricPreview,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_circle_outline_rounded, color: AppColors.celestialGold),
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