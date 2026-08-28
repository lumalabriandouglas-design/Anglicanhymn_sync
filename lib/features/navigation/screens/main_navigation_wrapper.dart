import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/breakpoints.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../../providers/audio_provider.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../library/screens/library_screen.dart';
import '../../player/screens/player_screen.dart';
import '../../player/widgets/slim_mini_player.dart';
import '../widgets/more_bottom_sheet.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LibraryScreen(),
    PlayerScreen(),
    FavoritesScreen(),
  ];

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MoreBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final hasPlayer = audio.currentHymn != null;
    final wide = Breakpoints.useRail(context);
    final padding = MediaQuery.paddingOf(context);

    final body = ResponsiveCenter(
      child: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anglican Hymn Sync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Settings & Tools',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _currentIndex = index),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book_rounded),
                      label: Text('Library'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.headphones_outlined),
                      selectedIcon: Icon(Icons.headphones_rounded),
                      label: Text('Player'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite_outline_rounded),
                      selectedIcon: Icon(Icons.favorite_rounded),
                      label: Text('Favorites'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasPlayer) const SlimMiniPlayer(),
          if (!wide)
            BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_rounded),
                  label: 'Library',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.headphones_rounded),
                  label: 'Player',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_rounded),
                  label: 'Favorites',
                ),
              ],
            )
          else
            SizedBox(height: padding.bottom),
        ],
      ),
    );
  }
}
