class AudioTrack {
  final String id;
  final String? hymnNumber;
  final String language;
  final String title;
  final String url;
  final AudioTrackType type;

  const AudioTrack({
    required this.id,
    required this.language,
    required this.title,
    required this.url,
    this.hymnNumber,
    this.type = AudioTrackType.hymn,
  });

  bool get isHymn => type == AudioTrackType.hymn && hymnNumber != null;
  bool get isExtra => type == AudioTrackType.extra;

  factory AudioTrack.fromJson(Map<String, dynamic> json) {
    final typeRaw = (json['type'] ?? 'hymn').toString().toLowerCase();
    return AudioTrack(
      id: json['id']?.toString() ?? json['url']?.toString() ?? '',
      hymnNumber: json['hymnNumber']?.toString(),
      language: (json['language'] ?? 'english').toString().toLowerCase(),
      title: json['title']?.toString() ?? 'Untitled',
      url: json['url']?.toString() ?? '',
      type: typeRaw == 'extra' ? AudioTrackType.extra : AudioTrackType.hymn,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hymnNumber': hymnNumber,
        'language': language,
        'title': title,
        'url': url,
        'type': type == AudioTrackType.extra ? 'extra' : 'hymn',
      };
}

enum AudioTrackType { hymn, extra }
