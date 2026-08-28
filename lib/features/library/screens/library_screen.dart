import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/breakpoints.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/hymn_provider.dart';
import '../../../providers/settings_provider.dart';
import '../widgets/collapsing_search_bar.dart';
import '../widgets/hymn_tile.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hymnProvider = context.watch<HymnProvider>();
    final audioProvider = context.watch<AudioProvider>();
    final settings = context.watch<SettingsProvider>();
    final hymns = hymnProvider.filteredHymns;
    final columns = Breakpoints.libraryColumns(context);

    if (hymnProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFC107)),
      );
    }

    return Column(
      children: [
        CollapsingSearchBar(
          scrollController: _scrollController,
          onChanged: (query) => hymnProvider.setSearchQuery(query),
        ),
        Expanded(
          child: hymns.isEmpty
              ? const Center(
                  child: Text(
                    'No hymns found matching your search',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : columns == 1
                  ? ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: hymns.length,
                      itemBuilder: (context, index) {
                        final hymn = hymns[index];
                        return HymnTile(
                          hymn: hymn,
                          onPlayTap: () {
                            audioProvider.setHymns(hymnProvider.allHymns);
                            audioProvider.playHymn(
                              hymn,
                              language: settings.lyricsLanguage,
                            );
                          },
                        );
                      },
                    )
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisExtent: 88,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: hymns.length,
                      itemBuilder: (context, index) {
                        final hymn = hymns[index];
                        return HymnTile(
                          hymn: hymn,
                          onPlayTap: () {
                            audioProvider.setHymns(hymnProvider.allHymns);
                            audioProvider.playHymn(
                              hymn,
                              language: settings.lyricsLanguage,
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
