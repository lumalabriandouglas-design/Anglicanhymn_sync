String cleanTitle(String rawTitle) {
  if (rawTitle.isEmpty) return '';

  String t = rawTitle;
  t = t.replaceAll(RegExp(r'Enjatula.*', caseSensitive: false), '');
  t = t.replaceAll(RegExp(r'Song Lyrics', caseSensitive: false), '');
  t = t.replaceAll(RegExp(r'O?LUYIMBA\s*\d+:\s*', caseSensitive: false), '');
  
  return t.trim();
}

String cleanHymnLyrics(String rawLyrics) {
  if (rawLyrics.isEmpty) return '';

  String cleaned = rawLyrics.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  // Cut off everything starting from WordPress/comment form footers
  final bottomMarkers = [
    'your email address will not be published',
    'required fields are marked',
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

  // Remove top scrap lines (AZNIMI, Enjatula headers, author lines)
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
    bool isJunk = lineLower.isEmpty || 
        topJunk.any((junk) => lineLower == junk || lineLower.startsWith(junk));
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