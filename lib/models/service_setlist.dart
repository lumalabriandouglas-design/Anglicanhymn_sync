class SetlistItem {
  final String role; // Entrance, Gradual, Offertory, Communion, Recessional
  final String hymnNumber;
  final String hymnTitle;

  SetlistItem({
    required this.role,
    required this.hymnNumber,
    required this.hymnTitle,
  });

  factory SetlistItem.fromJson(Map<String, dynamic> json) {
    return SetlistItem(
      role: json['role'] ?? 'General',
      hymnNumber: json['hymnNumber'] ?? '',
      hymnTitle: json['hymnTitle'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role,
        'hymnNumber': hymnNumber,
        'hymnTitle': hymnTitle,
      };
}

class ServiceSetlist {
  final String id;
  final String title;
  final DateTime date;
  final List<SetlistItem> items;

  ServiceSetlist({
    required this.id,
    required this.title,
    required this.date,
    required this.items,
  });

  factory ServiceSetlist.fromJson(Map<String, dynamic> json) {
    return ServiceSetlist(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Sunday Service',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => SetlistItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'items': items.map((item) => item.toJson()).toList(),
      };
}