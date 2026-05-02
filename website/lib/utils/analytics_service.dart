import 'dart:js_interop';

import 'package:flutter/foundation.dart';

@JS('gtag')
external void _gtag(String command, String eventName, [JSObject? parameters]);

class AnalyticsService {
  static void logEvent(String name, {Map<String, dynamic>? parameters}) {
    try {
      _gtag('event', name, parameters?.jsify() as JSObject?);
    } catch (e) {
      // Analytics might be blocked by adblockers or not initialized
      if (kDebugMode) {
        debugPrint('Analytics error: $e');
      }
    }
  }

  static void logDownload(String platform, String version) {
    logEvent(
      'download',
      parameters: {'platform': platform, 'version': version},
    );
  }

  static void logGitHubClick() {
    logEvent('github_click');
  }
}
