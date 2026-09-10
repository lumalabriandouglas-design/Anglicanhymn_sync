  Hymn _correctEnglish(Hymn hymn) {
    if (hymn.number == '193') {
      return hymn.copyWith(titleEnglish: '', lyricsEnglish: '');
    }
    if (hymn.number == '109') {
      return hymn.copyWith(
        titleEnglish: 'The Son of God goes forth to war',
      );
    }
    if (hymn.number == '220') {
      return hymn.copyWith(
        titleEnglish: 'Soldiers of Christ, arise',
      );
    }
    if (hymn.number == '221') {
      return hymn.copyWith(
        titleEnglish: 'Onward, Christian soldiers',
      );
    }
    return hymn;
  }