import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              _FilterChip(
                label: 'All ${hymnProvider.allHymns.length}',
                selected: !hymnProvider.englishOnly,
                isDark: isDark,
                onTap: () => hymnProvider.setEnglishOnly(false),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'English ${hymnProvider.englishCount}',
                selected: hymnProvider.englishOnly,
                isDark: isDark,
                onTap: () => hymnProvider.setEnglishOnly(true),
              ),
            ],
          ),
        ),
        Expanded(
          child: hymns.isEmpty
              ? Center(
                  child: Text(
                    hymnProvider.englishOnly
                        ? 'No English hymns match that search'
                        : 'No hymns found matching your search',
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : columns == 1
                  ? ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.celestialGold
              : (isDark ? AppColors.cardNavy : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.celestialGold
                : (isDark ? Colors.white12 : Colors.black12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected
                ? AppColors.primaryNavy
                : (isDark ? Colors.white70 : AppColors.lightTextPrimary),
          ),
        ),
      ),
    );
  }
}
