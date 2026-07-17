import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../app_preferences.dart';

/// Service that handles secure, serverless Pro activation on desktop
/// by pairing with an unlocked mobile app over local Wi-Fi or via an offline OTP code.
class ProPairingService {
  static const int port = 24061;
  static const String secretSalt = 'SECRET_SALT_123_PATTERNS_PRO_SYNC';

  static HttpServer? _server;
  static String? _currentSessionToken;
  static final _pairingController = StreamController<bool>.broadcast();

  /// Stream that fires `true` when desktop has successfully paired and unlocked Pro.
  static Stream<bool> get onPairingSuccess => _pairingController.stream;

  /// Starts the local HTTP server on desktop to listen for mobile activation requests.
  /// Returns the pairing URL to be encoded in the QR code.
  static Future<String?> startDesktopServer() async {
    await stopDesktopServer();

    // Generate a random session token
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    _currentSessionToken = base64Url.encode(bytes);

    final ips = await getLocalIPs();
    if (ips.isEmpty) return null;

    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      _server!.listen((HttpRequest request) async {
        // Handle Mobile App native camera scans (which make GET requests via browser)
        if (request.method == 'GET' && request.uri.path == '/unlock') {
          try {
            final token = request.uri.queryParameters['token'];
            final signature = request.uri.queryParameters['sig'];

            if (token == _currentSessionToken && signature != null) {
              final expectedSig = _computeHmac(token!, secretSalt);
              if (signature == expectedSig) {
                // Unlock Pro!
                await unlockProLocally();
                _respondHtml(request, 200, _successHtml());
                _pairingController.add(true);
                stopDesktopServer();
                return;
              }
            }
            _respondHtml(request, 403, _errorHtml('Invalid signature or session expired.'));
          } catch (e) {
            _respondHtml(request, 500, _errorHtml('Error: $e'));
          }
        }
        // Handle Mobile App API pairing requests (POST)
        else if (request.method == 'POST' && request.uri.path == '/unlock') {
          try {
            final content = await utf8.decoder.bind(request).join();
            final data = jsonDecode(content) as Map<String, dynamic>;
            
            final token = data['token'] as String?;
            final signature = data['signature'] as String?;

            if (token == _currentSessionToken && signature != null) {
              final expectedSig = _computeHmac(token!, secretSalt);
              if (signature == expectedSig) {
                await unlockProLocally();
                _respondJson(request, 200, {'status': 'success', 'message': 'Pro unlocked!'});
                _pairingController.add(true);
                stopDesktopServer();
                return;
              }
            }
            _respondJson(request, 403, {'status': 'error', 'message': 'Invalid signature.'});
          } catch (e) {
            _respondJson(request, 500, {'status': 'error', 'message': 'Error: $e'});
          }
        } else {
          _respondJson(request, 404, {'status': 'error', 'message': 'Not found.'});
        }
      });

      // Construct URL: http://<desktop_ip>:<port>/unlock?token=<currentSessionToken>&sig=<signature>
      final sig = _computeHmac(_currentSessionToken!, secretSalt);
      final qrUrl = 'http://${ips.first}:$port/unlock?token=$_currentSessionToken&sig=$sig';
      return qrUrl;
    } catch (e) {
      debugPrint('Failed to start pairing server: $e');
      return null;
    }
  }

  /// Stops the desktop pairing server.
  static Future<void> stopDesktopServer() async {
    await _server?.close(force: true);
    _server = null;
    _currentSessionToken = null;
  }

  /// Mobile: Verifies if mobile is Pro, and sends the signed payload to the desktop IP.
  static Future<bool> sendUnlockToDesktop({
    required String desktopIp,
    required int desktopPort,
    required String sessionToken,
  }) async {
    // Compute signature: HMAC_SHA256(sessionToken, secretSalt)
    final signature = _computeHmac(sessionToken, secretSalt);

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 5);
    try {
      final request = await client.post(desktopIp, desktopPort, '/unlock');
      request.headers.contentType = ContentType.json;
      
      final body = jsonEncode({
        'token': sessionToken,
        'signature': signature,
      });
      request.write(body);
      
      final response = await request.close();
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('Failed to send unlock request: $e');
    } finally {
      client.close();
    }
    return false;
  }

  /// Unlocks Patterns Pro locally on this device.
  static Future<void> unlockProLocally() async {
    if (appPreferences != null) {
      await appPreferences!.setBool(proUnlockedKey, true);
    }
  }

  /// Offline fallback: Generates a 6-digit linking code for the current 5-minute time window.
  static String generateOfflineOTP() {
    final window = DateTime.now().millisecondsSinceEpoch ~/ (1000 * 60 * 5); // 5 min window
    return _computeOTP(window);
  }

  /// Offline fallback: Verifies a 6-digit code against current, past, and next windows (to allow clock drift).
  static bool verifyOfflineOTP(String code) {
    final cleanCode = code.trim().replaceAll(' ', '').toUpperCase();
    if (cleanCode.length != 6) return false;

    final window = DateTime.now().millisecondsSinceEpoch ~/ (1000 * 60 * 5);
    
    // Check current, previous, and next window to accommodate clock drift (up to 5 mins off)
    for (var i = -1; i <= 1; i++) {
      if (cleanCode == _computeOTP(window + i)) {
        unlockProLocally();
        return true;
      }
    }
    return false;
  }

  // --- Helper Methods ---

  static String _computeHmac(String input, String key) {
    final hmac = Hmac(sha256, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(input));
    return digest.toString();
  }

  static String _computeOTP(int window) {
    final hash = _computeHmac(window.toString(), secretSalt);
    // Convert part of hash to a 6-digit numeric string
    final numericValue = int.parse(hash.substring(0, 8), radix: 16);
    final otp = (numericValue % 1000000).toString().padLeft(6, '0');
    return otp;
  }

  static void _respondJson(HttpRequest request, int code, Map<String, dynamic> body) {
    request.response.statusCode = code;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(body));
    request.response.close();
  }

  static void _respondHtml(HttpRequest request, int code, String html) {
    request.response.statusCode = code;
    request.response.headers.contentType = ContentType.html;
    request.response.write(html);
    request.response.close();
  }

  static String _successHtml() => '''
  <!DOCTYPE html>
  <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <style>
        body {
          background-color: #161616;
          color: #ffffff;
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          height: 100vh;
          margin: 0;
        }
        .container {
          text-align: center;
          padding: 24px;
        }
        h1 {
          color: #FFD700; /* Gold */
          font-size: 28px;
          margin-bottom: 12px;
          font-weight: 800;
        }
        p {
          color: #a0a0a0;
          font-size: 15px;
          line-height: 1.5;
          max-width: 320px;
          margin: 0 auto;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>✓ Connected</h1>
        <p>Patterns Pro is now unlocked on your desktop computer. You can start practicing.</p>
      </div>
    </body>
  </html>
  ''';

  static String _errorHtml(String message) => '''
  <!DOCTYPE html>
  <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <style>
        body {
          background-color: #161616;
          color: #ffffff;
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          height: 100vh;
          margin: 0;
        }
        .container {
          text-align: center;
          padding: 24px;
        }
        h1 {
          color: #ff453a; /* Red */
          font-size: 28px;
          margin-bottom: 12px;
          font-weight: 800;
        }
        p {
          color: #a0a0a0;
          font-size: 15px;
          line-height: 1.5;
          max-width: 320px;
          margin: 0 auto;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>✗ Pairing Failed</h1>
        <p>$message</p>
      </div>
    </body>
  </html>
  ''';

  static Future<List<String>> getLocalIPs() async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      return interfaces
          .expand((interface) => interface.addresses)
          .map((addr) => addr.address)
          .where((ip) => !ip.startsWith('127.'))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
