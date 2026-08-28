import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/hymn_audio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/search_engine.dart';
import '../../../models/hymn.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/hymn_provider.dart';
import '../../../providers/settings_provider.dart';
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
    final playable = hymns.where(HymnAudio.hasAudio).toList();
    return SearchEngine.searchHymns(playable, _query);
  }

  void _openFullPlayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PlayerDeck(),
        fullscreenDialog: true,
      ),
    );
  }

  void _playHymn(BuildContext context, Hymn hymn) {
    final audio = context.read<AudioProvider>();
    final hymnProvider = context.read<HymnProvider>();
    final settings = context.read<SettingsProvider>();
    audio.setHymns(hymnProvider.allHymns);
    audio.playHymn(hymn, language: settings.lyricsLanguage);
    _openFullPlayer(context);
  }

  @override
  Widget build(BuildContext context) {
    final hymnProvider = context.watch<HymnProvider>();
    final audio = context.watch<AudioProvider>();
    final hymns = _filterHymns(hymnProvider.allHymns);
    final extras = HymnAudio.extraTracks;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.primaryNavy : AppColors.lightBackground;
    final card = isDark ? AppColors.cardNavy : Colors.white;
    final text = isDark ? Colors.white : AppColors.lightTextPrimary;
    final muted = isDark ? Colors.white.withOpacity(0.45) : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text('Audio Library'),
        elevation: 0,
        actions: [
          if (audio.currentHymn != null)
            IconButton(
              icon: Icon(Icons.queue_music_rounded,
                  color: isDark ? AppColors.celestialGold : AppColors.primaryNavy),
              onPressed: () => _openFullPlayer(context),
              tooltip: 'Open now playing',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              style: TextStyle(color: text),
              decoration: InputDecoration(
                hintText: 'Search number, Luganda or English title...',
                hintStyle: TextStyle(color: muted),
                prefixIcon: const Icon(Icons.search, color: AppColors.celestialGold),
                filled: true,
                fillColor: card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: hymns.isEmpty && extras.isEmpty
                ? Center(
                    child: Text(
                      _query.trim().isEmpty ? 'No audio uploaded yet' : 'No matching audio',
                      style: TextStyle(color: muted),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 90),
                    children: [
                      ...hymns.map((hymn) {
                        final isCurrent = audio.currentHymn?.number == hymn.number;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isCurrent
                                ? AppColors.celestialGold
                                : AppColors.celestialGold.withOpacity(0.15),
                            child: isCurrent
                                ? const Icon(Icons.equalizer_rounded, color: AppColors.primaryNavy, size: 20)
                                : Text(
                                    hymn.number,
                                    style: TextStyle(
                                      color: isDark ? AppColors.celestialGold : AppColors.primaryNavy,
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
                              color: isCurrent
                                  ? (isDark ? AppColors.celestialGold : AppColors.primaryNavy)
                                  : text,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: hymn.hasEnglishTitle
                              ? Text(hymn.titleEnglish, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: muted, fontSize: 12))
                              : null,
                          trailing: IconButton(
                            icon: Icon(
                              isCurrent && audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: isDark ? AppColors.celestialGold : AppColors.primaryNavy,
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
                      }),
                      if (extras.isNotEmpty && _query.trim().isEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text('Other recordings', style: TextStyle(color: muted, fontWeight: FontWeight.w700)),
                        ),
                        ...extras.map((track) {
                          return ListTile(
                            leading: const Icon(Icons.library_music_outlined),
                            title: Text(track.title),
                            subtitle: Text(track.language),
                            trailing: const Icon(Icons.play_arrow_rounded),
                            onTap: () {
                              audio.playHymn(
                                Hymn(number: track.hymnNumber ?? track.id, title: track.title, lyricsLuganda: ''),
                                audioUrl: track.url,
                              );
                              _openFullPlayer(context);
                            },
                          );
                        }),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
