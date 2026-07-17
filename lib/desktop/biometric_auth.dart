import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Thin wrapper around [LocalAuthentication] so the UI can call into native
/// biometric auth without taking a direct dependency on the plugin. Widget
/// tests override [biometricAuthenticatorProvider] with a fake to simulate
/// the biometric prompt's lifecycle side effects.
class BiometricAuthenticator {
  const BiometricAuthenticator();

  Future<bool> isDeviceSupported() => LocalAuthentication().isDeviceSupported();

  Future<bool> authenticate({required String reason}) {
    return LocalAuthentication().authenticate(
      localizedReason: reason,
      persistAcrossBackgrounding: true,
    );
  }
}

final biometricAuthenticatorProvider = Provider<BiometricAuthenticator>(
  (ref) => const BiometricAuthenticator(),
);
