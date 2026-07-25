import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() async {
  // Ensure Flutter engine bindings are initialized BEFORE loading assets
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
  await appState.loadHymns();

  runApp(AnglicanHymnSyncApp(appState: appState));
}

// ==========================================
// 1. BRANDED LOGO WIDGET (PNG WITH VECTOR FALLBACK)
// ==========================================

class HymnSyncLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const HymnSyncLogo({
    super.key,
    this.size = 28,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.2),
          child: Image.asset(
            'assets/images/app_icon.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback vector icon if asset file is missing
              return Container(
                padding: EdgeInsets.all(size * 0.2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: const Color(0xFFFFC107),
                  size: size * 0.8,
                ),
              );
            },
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Text(
            'Anglican Hymn Sync',
            style: TextStyle(
              fontSize: size * 0.65,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
}

// ==========================================
// 2. DATA CLEANER & PARSER
// ==========================================

String cleanHymnLyrics(String rawLyrics) {
  if (rawLyrics.isEmpty) return '';

  String cleaned = rawLyrics.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  final bottomMarkers = [
    'your email address will not be published',
    'comment *',
    'save my name, email, and website',
    'designed with wordpress',
    'luganda content everyday',
  ];
  for (final marker in bottomMarkers) {
    final index = cleaned.toLowerCase().indexOf(marker);
    if (index != -1) {
      cleaned = cleaned.substring(0, index);
    }
  }

  final topJunk = [
    'aznimi-luganda',
    '—',
    'by',
    'enjatula luganda anglican hymns',
    'song lyrics',
  ];

  List<String> lines = cleaned.split('\n');
  while (lines.isNotEmpty) {
    final lineLower = lines.first.trim().toLowerCase();
    bool isJunk = lineLower.isEmpty || topJunk.any((j) => lineLower.contains(j));
    if (isJunk) {
      lines.removeAt(0);
    } else {
      break;
    }
  }

  cleaned = lines.join('\n');
  cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return cleaned.trim();
}

String cleanTitle(String rawTitle) {
  String t = rawTitle;
  t = t.replaceAll(RegExp(r'Enjatula.*', caseSensitive: false), '');
  t = t.replaceAll(RegExp(r'Song Lyrics', caseSensitive: false), '');
  t = t.replaceAll(RegExp(r'OLUYIMBA \d+:', caseSensitive: false), '');
  return t.trim();
}

class Hymn {
  final String number;
  final String title;
  final String lyricsLuganda;
  final String lyricsEnglish;
  bool isFavorite;

  Hymn({
    required this.number,
    required this.title,
    required this.lyricsLuganda,
    required this.lyricsEnglish,
    this.isFavorite = false,
  });

  factory Hymn.fromJson(Map<String, dynamic> json, int index) {
    String num = json['number']?.toString() ?? (index + 1).toString().padLeft(3, '0');
    String rawTitle = json['title'] ?? 'Hymn $num';
    return Hymn(
      number: num,
      title: cleanTitle(rawTitle),
      lyricsLuganda: cleanHymnLyrics(json['lyrics'] ?? ''),
      lyricsEnglish: cleanHymnLyrics(json['english_lyrics'] ?? ''),
    );
  }
}

// ==========================================
// 3. APP STATE MANAGEMENT
// ==========================================

class AppState extends ChangeNotifier {
  List<Hymn> allHymns = [];
  bool isLoading = true;
  String? errorMessage;
  bool isProUser = false;

  // Player State
  Hymn? currentHymn;
  bool isPlaying = false;
  bool showMiniPlayer = false;
  double playbackSpeed = 1.0;

  Future<void> loadHymns() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final String jsonString = await rootBundle.loadString('assets/hymns-full.json');
      final List<dynamic> data = json.decode(jsonString);

      allHymns = data.asMap().entries.map((entry) {
        return Hymn.fromJson(entry.value as Map<String, dynamic>, entry.key);
      }).toList();
    } catch (e) {
      errorMessage =
          "Could not load assets/hymns-full.json.\nEnsure it is registered in pubspec.yaml.\n\nError details: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void togglePro(bool val) {
    isProUser = val;
    notifyListeners();
  }

  void toggleFavorite(Hymn hymn) {
    hymn.isFavorite = !hymn.isFavorite;
    notifyListeners();
  }

  void playHymn(Hymn hymn) {
    currentHymn = hymn;
    isPlaying = true;
    showMiniPlayer = true;
    notifyListeners();
  }

  void togglePlayPause() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void dismissMiniPlayer() {
    showMiniPlayer = false;
    isPlaying = false;
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    playbackSpeed = speed;
    notifyListeners();
  }
}

// ==========================================
// 4. MAIN APP THEME
// ==========================================

class AnglicanHymnSyncApp extends StatelessWidget {
  final AppState appState;

  const AnglicanHymnSyncApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    const primaryNavy = Color(0xFF0B132B);
    const cardNavy = Color(0xFF1C2541);
    const celestialGold = Color(0xFFFFC107);

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'Anglican Hymn Sync',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: primaryNavy,
            colorScheme: const ColorScheme.dark(
              primary: celestialGold,
              surface: cardNavy,
              background: primaryNavy,
              onBackground: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: primaryNavy,
              elevation: 0,
              centerTitle: false,
            ),
            cardTheme: const CardThemeData(
              color: cardNavy,
              elevation: 0,
            ),
          ),
          home: MainNavigationWrapper(appState: appState),
        );
      },
    );
  }
}

// ==========================================
// 5. MAIN NAVIGATION & OVERFLOW MENU
// ==========================================

class MainNavigationWrapper extends StatefulWidget {
  final AppState appState;
  const MainNavigationWrapper({super.key, required this.appState});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  void _openMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2541),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListenableBuilder(
          listenable: widget.appState,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner, color: Color(0xFFFFC107)),
                    title: const Text('Scan Church Bulletin', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Jump straight to Sunday service hymns'),
                    onTap: () {
                      Navigator.pop(context);
                      _showScanDialog();
                    },
                  ),
                  const Divider(color: Colors.white10),
                  SwitchListTile(
                    secondary: Icon(
                      Icons.star,
                      color: widget.appState.isProUser ? const Color(0xFFFFC107) : Colors.grey,
                    ),
                    title: const Text('PRO Mode Active', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Unlocks Auto-scroll & Speed control'),
                    activeColor: const Color(0xFFFFC107),
                    value: widget.appState.isProUser,
                    onChanged: (val) => widget.appState.togglePro(val),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showScanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Color(0xFFFFC107)),
            SizedBox(width: 10),
            Text('Bulletin Scanner'),
          ],
        ),
        content: const Text('Point your camera at the church bulletin QR code to load today\'s liturgy hymns.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFFFFC107))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appState.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HymnSyncLogo(size: 48, showText: false),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Color(0xFFFFC107)),
              SizedBox(height: 12),
              Text('Loading Hymnal Database...', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    if (widget.appState.errorMessage != null) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 48),
                const SizedBox(height: 16),
                const Text('Database Initialization Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  widget.appState.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => widget.appState.loadHymns(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Loading'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final screens = [
      LibraryTab(hymns: widget.appState.allHymns, appState: widget.appState),
      PlayerTab(appState: widget.appState),
      FavoritesTab(
        hymns: widget.appState.allHymns.where((h) => h.isFavorite).toList(),
        appState: widget.appState,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const HymnSyncLogo(size: 28),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _openMoreMenu,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Expanded(child: screens[_currentIndex]),
              if (widget.appState.showMiniPlayer && widget.appState.currentHymn != null)
                SlimYouTubeMiniPlayer(
                  appState: widget.appState,
                  onTapExpand: () => setState(() => _currentIndex = 1),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF0B132B),
          selectedItemColor: const Color(0xFFFFC107),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Library'),
            BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill), label: 'Player'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Favorites'),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. LIBRARY TAB (Collapsing Search Bar)
// ==========================================

class LibraryTab extends StatefulWidget {
  final List<Hymn> hymns;
  final AppState appState;

  const LibraryTab({super.key, required this.hymns, required this.appState});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  final ScrollController _scrollController = ScrollController();
  bool _isSearchVisible = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse && _isSearchVisible) {
      setState(() => _isSearchVisible = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward && !_isSearchVisible) {
      setState(() => _isSearchVisible = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.hymns.where((hymn) {
      final q = _searchQuery.toLowerCase().trim();
      if (q.isEmpty) return true;
      return hymn.number.contains(q) ||
          hymn.title.toLowerCase().contains(q) ||
          hymn.lyricsLuganda.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
          height: _isSearchVisible ? 68.0 : 0.0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search hymn number, title, or verse...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFFFC107), size: 20),
                  filled: true,
                  fillColor: const Color(0xFF1C2541),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No hymns found matching your search', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final hymn = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            hymn.number,
                            style: const TextStyle(
                              color: Color(0xFFFFC107),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        title: Text(hymn.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: Text(
                          hymn.lyricsLuganda.split('\n').take(2).join(' '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_circle_outline, color: Color(0xFFFFC107)),
                          onPressed: () => widget.appState.playHymn(hymn),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HymnDetailScreen(hymn: hymn, appState: widget.appState),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ==========================================
// 7. HYMN DETAIL SCREEN
// ==========================================

class HymnDetailScreen extends StatefulWidget {
  final Hymn hymn;
  final AppState appState;

  const HymnDetailScreen({super.key, required this.hymn, required this.appState});

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  String _selectedLang = 'Luganda';
  double _fontSize = 16.0;
  bool _isAutoScrolling = false;
  Timer? _autoScrollTimer;
  final ScrollController _scrollController = ScrollController();

  void _toggleAutoScroll() {
    if (!widget.appState.isProUser) {
      _showProUpgradeDialog(context, "Hands-Free Auto-Scroll is a PRO feature.");
      return;
    }

    setState(() => _isAutoScrolling = !_isAutoScrolling);

    if (_isAutoScrolling) {
      _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_scrollController.hasClients) {
          double maxScroll = _scrollController.position.maxScrollExtent;
          double currentScroll = _scrollController.offset;
          if (currentScroll < maxScroll) {
            _scrollController.jumpTo(currentScroll + 1.5);
          } else {
            timer.cancel();
            setState(() => _isAutoScrolling = false);
          }
        }
      });
    } else {
      _autoScrollTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.hymn.number} - ${widget.hymn.title}', style: const TextStyle(fontSize: 15)),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(12.0, 32.0)),
          ),
          Center(child: Text('${_fontSize.toInt()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(12.0, 32.0)),
          ),
          IconButton(
            icon: Icon(
              widget.hymn.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.hymn.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () {
              widget.appState.toggleFavorite(widget.hymn);
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1C2541),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLangButton('Luganda'),
                const SizedBox(width: 8),
                _buildLangButton('Dual'),
                const SizedBox(width: 8),
                _buildLangButton('English'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                if (_selectedLang == 'Luganda')
                  Text(widget.hymn.lyricsLuganda, style: TextStyle(fontSize: _fontSize, height: 1.6)),
                if (_selectedLang == 'English')
                  Text(
                    widget.hymn.lyricsEnglish.isNotEmpty
                        ? widget.hymn.lyricsEnglish
                        : "English translation not available yet.",
                    style: TextStyle(fontSize: _fontSize, height: 1.6),
                  ),
                if (_selectedLang == 'Dual') _buildDualLyricsView(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF1C2541),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: _toggleAutoScroll,
                  icon: Icon(
                    _isAutoScrolling ? Icons.pause : Icons.arrow_downward,
                    color: widget.appState.isProUser ? const Color(0xFFFFC107) : Colors.grey,
                  ),
                  label: Text(
                    _isAutoScrolling ? 'Pause Scroll' : 'Auto-Scroll',
                    style: TextStyle(color: widget.appState.isProUser ? const Color(0xFFFFC107) : Colors.grey),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => widget.appState.playHymn(widget.hymn),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Audio', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(String label) {
    final isSelected = _selectedLang == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFFFC107),
      labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
      onSelected: (_) => setState(() => _selectedLang = label),
    );
  }

  Widget _buildDualLyricsView() {
    final lugandaVerses = widget.hymn.lyricsLuganda.split('\n\n');
    final englishVerses = widget.hymn.lyricsEnglish.split('\n\n');
    final count = lugandaVerses.length > englishVerses.length ? lugandaVerses.length : englishVerses.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(count, (index) {
        final luganda = index < lugandaVerses.length ? lugandaVerses[index] : '';
        final english = index < englishVerses.length ? englishVerses[index] : '';

        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (luganda.isNotEmpty) Text(luganda, style: TextStyle(fontSize: _fontSize, height: 1.5, color: Colors.white)),
              if (english.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(english, style: TextStyle(fontSize: _fontSize * 0.95, height: 1.5, color: const Color(0xFFFFC107))),
              ],
              const Divider(color: Colors.white10, height: 24),
            ],
          ),
        );
      }),
    );
  }
}

// ==========================================
// 8. AUDIO HUB PLAYER TAB
// ==========================================

class PlayerTab extends StatelessWidget {
  final AppState appState;
  const PlayerTab({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final currentHymn = appState.currentHymn;
    final allHymns = appState.allHymns;

    return CustomScrollView(
      slivers: [
        // 1. TOP SECTION: NOW PLAYING DECK OR PROMPT BANNER
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: currentHymn != null
                ? _buildActivePlayerDeck(context, currentHymn)
                : _buildDefaultHeaderDeck(context),
          ),
        ),

        // 2. SECTION HEADER
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(Icons.playlist_play_rounded, color: Color(0xFFFFC107)),
                SizedBox(width: 8),
                Text(
                  'All Audio Hymns',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. BOTTOM SECTION: SCROLLABLE AUDIO TRACKLIST
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final hymn = allHymns[index];
                final isCurrent = currentHymn?.number == hymn.number;

                return Card(
                  color: isCurrent
                      ? const Color(0xFFFFC107).withOpacity(0.15)
                      : const Color(0xFF1C2541),
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isCurrent
                        ? const BorderSide(color: Color(0xFFFFC107), width: 1.5)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFFFFC107)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isCurrent && appState.isPlaying
                            ? Icons.graphic_eq_rounded
                            : Icons.music_note_rounded,
                        color: isCurrent ? Colors.black : const Color(0xFFFFC107),
                        size: 22,
                      ),
                    ),
                    title: Text(
                      '${hymn.number} - ${hymn.title}',
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                        color: isCurrent ? const Color(0xFFFFC107) : Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      hymn.lyricsLuganda.split('\n').firstWhere(
                            (line) => line.trim().isNotEmpty,
                            orElse: () => '',
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCurrent ? Colors.white70 : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isCurrent && appState.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: const Color(0xFFFFC107),
                        size: 32,
                      ),
                      onPressed: () {
                        if (isCurrent) {
                          appState.togglePlayPause();
                        } else {
                          appState.playHymn(hymn);
                        }
                      },
                    ),
                    onTap: () => appState.playHymn(hymn),
                  ),
                );
              },
              childCount: allHymns.length,
            ),
          ),
        ),
      ],
    );
  }

  // Active Player Deck (When a song is loaded)
  Widget _buildActivePlayerDeck(BuildContext context, Hymn hymn) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2541),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const HymnSyncLogo(size: 48, showText: false),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HYMN #${hymn.number}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        color: Color(0xFFFFC107),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hymn.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Playback Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, size: 32),
                onPressed: () {
                  int idx = appState.allHymns.indexOf(hymn);
                  if (idx > 0) appState.playHymn(appState.allHymns[idx - 1]);
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                iconSize: 56,
                icon: Icon(
                  appState.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  color: const Color(0xFFFFC107),
                ),
                onPressed: () => appState.togglePlayPause(),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 32),
                onPressed: () {
                  int idx = appState.allHymns.indexOf(hymn);
                  if (idx < appState.allHymns.length - 1) {
                    appState.playHymn(appState.allHymns[idx + 1]);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Speed Control Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Speed: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 8),
              ...[0.75, 1.0, 1.25, 1.5].map((speed) {
                final isSelected = appState.playbackSpeed == speed;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: ChoiceChip(
                    label: Text('${speed}x', style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFC107),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) {
                      if (appState.isProUser) {
                        appState.setPlaybackSpeed(speed);
                      } else {
                        _showProUpgradeDialog(context, "Audio Speed Control is a PRO feature.");
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // Default Header (When opening Audio tab for the first time)
  Widget _buildDefaultHeaderDeck(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2541),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const HymnSyncLogo(size: 56, showText: false),
          const SizedBox(height: 12),
          const Text(
            'Audio Hymnal Deck',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Select any hymn from the list below to begin audio playback.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (appState.allHymns.isNotEmpty) {
                appState.playHymn(appState.allHymns.first);
              }
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Play First Hymn', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 9. MINI PLAYER & FAVORITES
// ==========================================

class SlimYouTubeMiniPlayer extends StatelessWidget {
  final AppState appState;
  final VoidCallback onTapExpand;

  const SlimYouTubeMiniPlayer({super.key, required this.appState, required this.onTapExpand});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2541),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            child: LinearProgressIndicator(
              value: null,
              minHeight: 2,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
            ),
          ),
          InkWell(
            onTap: onTapExpand,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.music_note, color: Color(0xFFFFC107), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      appState.currentHymn!.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: Icon(appState.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => appState.togglePlayPause(),
                  ),
                  const SizedBox(width: 14),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => appState.dismissMiniPlayer(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesTab extends StatelessWidget {
  final List<Hymn> hymns;
  final AppState appState;

  const FavoritesTab({super.key, required this.hymns, required this.appState});

  @override
  Widget build(BuildContext context) {
    if (hymns.isEmpty) return const Center(child: Text('No favorite hymns saved yet', style: TextStyle(color: Colors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: hymns.length,
      itemBuilder: (context, index) {
        final hymn = hymns[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text(hymn.title),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HymnDetailScreen(hymn: hymn, appState: appState)),
            ),
          ),
        );
      },
    );
  }
}

void _showProUpgradeDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1C2541),
      title: const Row(
        children: [
          Icon(Icons.star, color: Color(0xFFFFC107)),
          SizedBox(width: 8),
          Text('PRO Feature'),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK', style: TextStyle(color: Color(0xFFFFC107))),
        ),
      ],
    ),
  );
}