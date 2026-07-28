import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/service_setlist.dart';

class CreateSetlistDialog extends StatefulWidget {
  const CreateSetlistDialog({super.key});

  @override
  State<CreateSetlistDialog> createState() => _CreateSetlistDialogState();
}

class _CreateSetlistDialogState extends State<CreateSetlistDialog> {
  final _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardNavy,
      title: const Text('New Service Setlist', style: TextStyle(color: AppColors.celestialGold)),
      content: TextField(
        controller: _titleController,
        style: const TextStyle(color: AppColors.textWhite),
        decoration: const InputDecoration(
          hintText: 'e.g., 1st Sunday of Advent',
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
            if (_titleController.text.trim().isEmpty) return;
            final newSetlist = ServiceSetlist(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text.trim(),
              date: DateTime.now(),
              items: [],
            );
            Navigator.pop(context, newSetlist);
          },
          child: const Text('Create', style: TextStyle(color: AppColors.primaryNavy)),
        ),
      ],
    );
  }
}