import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/setlist_provider.dart';
import '../widgets/create_setlist_dialog.dart';

class SetlistScreen extends StatelessWidget {
  const SetlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final setlistProvider = context.watch<SetlistProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Setlists'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.celestialGold,
        child: const Icon(Icons.add, color: AppColors.primaryNavy),
        onPressed: () async {
          final newSetlist = await showDialog(
            context: context,
            builder: (_) => const CreateSetlistDialog(),
          );
          if (newSetlist != null) {
            setlistProvider.addSetlist(newSetlist);
          }
        },
      ),
      body: setlistProvider.setlists.isEmpty
          ? const Center(
              child: Text(
                'No service setlists created.\nTap + to start planning.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey),
              ),
            )
          : ListView.builder(
              itemCount: setlistProvider.setlists.length,
              itemBuilder: (context, index) {
                final setlist = setlistProvider.setlists[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.cardNavy,
                  child: ListTile(
                    title: Text(setlist.title, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${setlist.date.day}/${setlist.date.month}/${setlist.date.year} • ${setlist.items.length} Hymns',
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => setlistProvider.deleteSetlist(setlist.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}