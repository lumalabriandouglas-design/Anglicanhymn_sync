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

  void _openFullPlayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PlayerDeck(),
        fullscreenDialog: true, // nice slide-up feel
      ),
    );
  }

  void _playHymn(BuildContext context, Hymn hymn) {
    final audio = context.read<AudioProvider>();
    final hymnProvider = context.read<HymnProvider>();

    audio.setHymns(hymnProvider.allHymns);
    audio.playHymn(hymn);

    // Open full player after starting
    _openFullPlayer(context);
  }

  @override
  Widget build(BuildContext context) {
    final hymnProvider = context.watch<HymnProvider>();
    final audio = context.watch<AudioProvider>();
    final hymns = _filterHymns(hymnProvider.allHymns);

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B132B),
        title: const Text('Audio Library'),
        elevation: 0,
        actions: [
          // Quick button to open full player if something is already playing
          if (audio.currentHymn != null)
            IconButton(
              icon: const Icon(Icons.queue_music_rounded, color: AppColors.celestialGold),
              onPressed: () => _openFullPlayer(context),
              tooltip: 'Open now playing',
            ),
        ],
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
                    padding: const EdgeInsets.only(bottom: 90), // space for mini player
                    itemBuilder: (context, index) {
                      final hymn = hymns[index];
                      final isCurrent = audio.currentHymn?.number == hymn.number;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCurrent
                              ? AppColors.celestialGold
                              : AppColors.celestialGold.withOpacity(0.15),
                          child: isCurrent
                              ? const Icon(Icons.equalizer_rounded, color: Color(0xFF0B132B), size: 20)
                              : Text(
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
                          style: TextStyle(
                            color: isCurrent ? AppColors.celestialGold : Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isCurrent && audio.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: AppColors.celestialGold,
                          ),
                          onPressed: () {
                            if (isCurrent) {
                              audio.togglePlayPause();
                            } else {
                              _playHymn(context, hymn);
                            }
                          },
                        ),
                        onTap: () {
                          if (isCurrent) {
                            _openFullPlayer(context);
                          } else {
                            _playHymn(context, hymn);
                          }
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