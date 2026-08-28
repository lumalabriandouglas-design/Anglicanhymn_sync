import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/setlist_provider.dart';
import '../widgets/create_setlist_dialog.dart';
import 'setlist_detail_screen.dart';

class SetlistScreen extends StatelessWidget {
  const SetlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final setlistProvider = context.watch<SetlistProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            await setlistProvider.addSetlist(newSetlist);
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SetlistDetailScreen(setlistId: newSetlist.id),
              ),
            );
          }
        },
      ),
      body: setlistProvider.setlists.isEmpty
          ? Center(
              child: Text(
                'No service setlists created.\nTap + to start planning Sunday.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppColors.textGrey : AppColors.lightTextSecondary,
                ),
              ),
            )
          : ListView.builder(
              itemCount: setlistProvider.setlists.length,
              itemBuilder: (context, index) {
                final setlist = setlistProvider.setlists[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      setlist.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${setlist.date.day}/${setlist.date.month}/${setlist.date.year} • ${setlist.items.length} hymns',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => setlistProvider.deleteSetlist(setlist.id),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SetlistDetailScreen(setlistId: setlist.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
