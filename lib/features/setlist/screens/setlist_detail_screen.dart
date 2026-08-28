import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/hymn_audio.dart';
import '../../../models/hymn.dart';
import '../../../models/service_setlist.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/hymn_provider.dart';
import '../../../providers/setlist_provider.dart';
import '../../reader/screens/hymn_detail_screen.dart';
import '../widgets/pick_hymn_sheet.dart';

const _roles = [
  'Entrance',
  'Gradual',
  'Offertory',
  'Communion',
  'Recessional',
  'General',
];

class SetlistDetailScreen extends StatelessWidget {
  final String setlistId;

  const SetlistDetailScreen({super.key, required this.setlistId});

  Hymn? _findHymn(HymnProvider hymns, String number) {
    try {
      return hymns.allHymns.firstWhere((h) => h.number == number);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SetlistProvider>();
    final hymns = context.watch<HymnProvider>();
    final audio = context.watch<AudioProvider>();
    final setlist = provider.byId(setlistId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (setlist == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Setlist')),
        body: const Center(child: Text('This setlist was deleted.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(setlist.title),
        actions: [
          if (setlist.items.isNotEmpty)
            IconButton(
              tooltip: 'Play available audio in order',
              icon: const Icon(Icons.playlist_play_rounded),
              onPressed: () {
                final playable = setlist.items
                    .map((i) => _findHymn(hymns, i.hymnNumber))
                    .whereType<Hymn>()
                    .where(HymnAudio.hasAudio)
                    .toList();
                if (playable.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No audio in this setlist yet')),
                  );
                  return;
                }
                audio.setHymns(playable);
                audio.playHymn(playable.first);
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.celestialGold,
        foregroundColor: AppColors.primaryNavy,
        icon: const Icon(Icons.add),
        label: const Text('Add hymn'),
        onPressed: () async {
          final picked = await showModalBottomSheet<Hymn>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const PickHymnSheet(),
          );
          if (picked == null) return;
          await provider.addItemToSetlist(
            setlistId,
            SetlistItem(
              role: 'General',
              hymnNumber: picked.number,
              hymnTitle: picked.title,
            ),
          );
        },
      ),
      body: setlist.items.isEmpty
          ? Center(
              child: Text(
                'No hymns in this service yet.\nTap Add hymn to plan the order.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppColors.textGrey : AppColors.lightTextSecondary,
                ),
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: setlist.items.length,
              onReorder: (oldIndex, newIndex) {
                provider.reorderItems(setlistId, oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = setlist.items[index];
                final hymn = _findHymn(hymns, item.hymnNumber);
                final hasAudio = hymn != null && HymnAudio.hasAudio(hymn);

                return Card(
                  key: ValueKey('${item.hymnNumber}-$index-${item.role}'),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.celestialGold.withOpacity(0.18),
                      child: Text(
                        item.hymnNumber,
                        style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    title: Text(
                      item.hymnTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(item.role),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          tooltip: 'Liturgical role',
                          onSelected: (role) =>
                              provider.updateItemRole(setlistId, index, role),
                          itemBuilder: (_) => _roles
                              .map((r) => PopupMenuItem(value: r, child: Text(r)))
                              .toList(),
                          child: const Icon(Icons.label_outline_rounded),
                        ),
                        if (hasAudio)
                          IconButton(
                            icon: const Icon(Icons.play_arrow_rounded),
                            onPressed: () {
                              audio.setHymns(hymns.allHymns);
                              audio.playHymn(hymn);
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => provider.removeItem(setlistId, index),
                        ),
                      ],
                    ),
                    onTap: hymn == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HymnDetailScreen(hymn: hymn),
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
