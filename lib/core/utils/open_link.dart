import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> openLink(String url) async {
  final uri = Uri.parse(url);
  try {
    return await launchUrl(
      uri,
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );
  } catch (e) {
    debugPrint('openLink failed: $e');
    return false;
  }
}
