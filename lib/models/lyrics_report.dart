class LyricReport {
  final String hymnNumber;
  final String hymnTitle;
  final String issueDescription;
  final DateTime reportedAt;

  LyricReport({
    required this.hymnNumber,
    required this.hymnTitle,
    required this.issueDescription,
    required this.reportedAt,
  });

  Map<String, dynamic> toJson() => {
        'hymnNumber': hymnNumber,
        'hymnTitle': hymnTitle,
        'issueDescription': issueDescription,
        'reportedAt': reportedAt.toIso8601String(),
      };
}