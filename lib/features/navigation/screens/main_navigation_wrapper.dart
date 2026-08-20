import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final hasPlayer = audio.currentHymn != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anglican Hymn Sync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Settings & Tools',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const MoreBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: ResponsiveCenter(
        maxContentWidth: 900.0,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player appears here when a hymn is playing
          if (hasPlayer) const SlimMiniPlayer(),
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
          ),
        ],
      ),
    );
  }
}