import 'dart:convert';
import '../../models/service_setlist.dart';

class QrScannerService {
  /// Parses raw QR payload data into a structured ServiceSetlist
  static ServiceSetlist? parseBulletinQrCode(String qrData) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(qrData);
      return ServiceSetlist.fromJson(decoded);
    } catch (_) {
      // Return null if payload is not a valid setlist JSON
      return null;
    }
  }
}