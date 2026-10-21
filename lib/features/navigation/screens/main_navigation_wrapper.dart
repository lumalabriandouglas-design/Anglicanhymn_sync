import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_nav.dart';
import '../../../core/widgets/breakpoints.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../../providers/hymn_provider.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../library/screens/library_screen.dart';
import '../../reader/screens/hymn_detail_screen.dart';
import '../../steward/steward_screen.dart';
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
    FavoritesScreen(),
  ];

  void _openSettings() {
    AppNav.showSheet(
      context: context,
      builder: (_) => const MoreBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<HymnProvider>().selectedHymn;
    final wide = Breakpoints.useRail(context);
    final padding = MediaQuery.paddingOf(context);
    final showReader = wide && _currentIndex == 0 && selected != null;

    final tabBody = ResponsiveCenter(
      child: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );

    Widget navigationBody;
    if (wide) {
      navigationBody = Row(
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
                icon: Icon(Icons.favorite_outline_rounded),
                selectedIcon: Icon(Icons.favorite_rounded),
                label: Text('Favorites'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(flex: showReader ? 5 : 1, child: tabBody),
          if (showReader) ...[
            const VerticalDivider(width: 1),
            Expanded(
              flex: 6,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: HymnDetailScreen(
                  key: ValueKey(selected.number),
                  hymn: selected,
                  embedded: true,
                ),
              ),
            ),
          ],
        ],
      );
    } else {
      navigationBody = tabBody;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anglican Hymn Sync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Settings & Tools',
            onPressed: _openSettings,
            onLongPress: () => openStewardWall(context),
          ),
        ],
      ),
      body: navigationBody,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
