import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/hymn.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/hymn_provider.dart';
import '../widgets/player_deck.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Hymn> _filterHymns(List<Hymn> hymns) {
    if (_query.trim().isEmpty) return hymns;

    final q = _query.toLowerCase();
    return hymns.where((h) {
      return h.number.toLowerCase().contains(q) ||
          h.title.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final hymnProvider = context.watch<HymnProvider>();
    final hymns = _filterHymns(hymnProvider.allHymns);

    // If something is currently playing → show the full player
    if (audio.currentHymn != null) {
      return const PlayerDeck();
    }

    // Otherwise show searchable list
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B132B),
        title: const Text('Audio Library'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search hymns by number or title...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: const Icon(Icons.search, color: AppColors.celestialGold),
                filled: true,
                fillColor: AppColors.cardNavy,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Results
          Expanded(
            child: hymns.isEmpty
                ? const Center(
                    child: Text(
                      'No hymns found',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  )
                : ListView.builder(
                    itemCount: hymns.length,
                    itemBuilder: (context, index) {
                      final hymn = hymns[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.celestialGold.withOpacity(0.15),
                          child: Text(
                            hymn.number,
                            style: const TextStyle(
                              color: AppColors.celestialGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        title: Text(
                          hymn.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_arrow_rounded, color: AppColors.celestialGold),
                          onPressed: () {
                            // Make sure the full list is available for next/prev
                            context.read<AudioProvider>().setHymns(hymnProvider.allHymns);
                            context.read<AudioProvider>().playHymn(hymn);
                          },
                        ),
                        onTap: () {
                          context.read<AudioProvider>().setHymns(hymnProvider.allHymns);
                          context.read<AudioProvider>().playHymn(hymn);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}