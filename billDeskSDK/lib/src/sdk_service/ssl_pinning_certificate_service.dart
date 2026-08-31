import 'dart:io';

import 'package:billdesk_sdk/src/utilities/sdk_logger.dart';
import 'package:crypto/crypto.dart';

class CertificateService {
  static Future<List<String>> getFingerprintsForEnv(String url) async {
    try {
      final uri = Uri.parse(url);
      final serverUrl = uri.host;
      final port = uri.port;

      final fingerprints = await getServerFingerprints(serverUrl, port);

      if (fingerprints.isEmpty || fingerprints['hex'] == null) {
        throw Exception('Failed to fetch server fingerprints');
      }

      return [fingerprints['hex']!];
    } catch (e) {
      SdkLogger.e("Error during fingerprint fetch: $e");
      throw Exception("SSL Certificate verification failed");
    }
  }
}

Future<Map<String, String>> getServerFingerprints(
    String serverUrl, int port) async {
  final Map<String, String> fingerprints = {};

  try {
    // Connect to the server securely
    final socket = await SecureSocket.connect(
      serverUrl,
      port,
      onBadCertificate: (X509Certificate cert) {
        // Accept the certificate for fetching purposes
        return true;
      },
    );

    // Extract the server's certificate in DER format
    final certificateBytes = socket.peerCertificate?.der;
    socket.destroy();

    if (certificateBytes != null) {
      // Compute the SHA-256 hash of the certificate
      final digest = sha256.convert(certificateBytes);

      // Convert the SHA-256 bytes to hexadecimal format
      final hexFingerprint = digest.bytes
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join(':')
          .toUpperCase();

      fingerprints['hex'] = hexFingerprint;
    }
  } catch (e) {
    SdkLogger.e("Error fetching fingerprints: $e");
    throw Exception("SSL Connection Error or Certificate Missing");
  }

  return fingerprints;
}
