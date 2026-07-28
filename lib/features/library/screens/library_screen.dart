import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/audio_provider.dart';
import '../../../providers/hymn_provider.dart';
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
    final hymns = hymnProvider.filteredHymns;

    if (hymnProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFC107)),
      );
    }

    return Column(
      children: [
        // Search bar directly at top (no duplicate header text)
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
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: hymns.length,
                  itemBuilder: (context, index) {
                    final hymn = hymns[index];
                    return HymnTile(
                      hymn: hymn,
                      onPlayTap: () => audioProvider.playHymn(hymn),
                    );
                  },
                ),
        ),
      ],
    );
  }
}