import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LyricReportDialog extends StatefulWidget {
  final String hymnNumber;
  final String hymnTitle;

  const LyricReportDialog({
    super.key,
    required this.hymnNumber,
    required this.hymnTitle,
  });

  @override
  State<LyricReportDialog> createState() => _LyricReportDialogState();
}

class _LyricReportDialogState extends State<LyricReportDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardNavy,
      title: Text(
        'Report Error - Hymn ${widget.hymnNumber}',
        style: const TextStyle(color: AppColors.celestialGold),
      ),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        style: const TextStyle(color: AppColors.textWhite),
        decoration: const InputDecoration(
          hintText: 'Describe the typo or missing stanza...',
          hintStyle: TextStyle(color: AppColors.textGrey),
          filled: true,
          fillColor: AppColors.primaryNavy,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textGrey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.celestialGold),
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thank you! Correction report submitted.')),
            );
          },
          child: const Text('Submit', style: TextStyle(color: AppColors.primaryNavy)),
        ),
      ],
    );
  }
}