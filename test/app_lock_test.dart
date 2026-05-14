import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart'
    show LocalAuthException, LocalAuthExceptionCode;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:patterns/mobile/biometric_auth.dart';
import 'package:patterns/mobile/main_shell.dart';
import 'package:patterns/mobile/preferences.dart';

void main() {
  testWidgets(
    'enabling app lock does not loop biometric prompts',
    (tester) async {
      SharedPreferences.setMockInitialValues({appLockPreferenceKey: true});
      await initMobilePreferences();

      final fake = _PromptingFakeAuthenticator();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            biometricAuthenticatorProvider.overrideWithValue(fake),
          ],
          child: const MaterialApp(
            home: MobileAppFrame(child: SizedBox.shrink()),
          ),
        ),
      );

      // initState's post-frame callback kicks off the first auth, and the
      // fake then drives the natural lifecycle of a biometric prompt:
      // `paused` while the system UI is up, then `resumed` once it closes.
      // Pump enough times to let any loop unwind itself before we assert.
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(
        fake.authCount,
        1,
        reason: 'the post-prompt resumed event must not re-trigger auth',
      );
    },
  );

  testWidgets(
    'cancelling the biometric prompt does not loop',
    (tester) async {
      SharedPreferences.setMockInitialValues({appLockPreferenceKey: true});
      await initMobilePreferences();

      final fake = _PromptingFakeAuthenticator(
        throws: const LocalAuthException(
          code: LocalAuthExceptionCode.userCanceled,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            biometricAuthenticatorProvider.overrideWithValue(fake),
          ],
          child: const MaterialApp(
            home: MobileAppFrame(child: SizedBox.shrink()),
          ),
        ),
      );

      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(
        fake.authCount,
        1,
        reason:
            'a cancelled prompt must surface the Unlock button, not auto-re-prompt',
      );
      // Cancellation is a no-fault outcome — no error message should be shown.
      expect(find.textContaining('Try again'), findsNothing);
    },
  );

  testWidgets(
    'lockout surfaces an explanation on the cover',
    (tester) async {
      SharedPreferences.setMockInitialValues({appLockPreferenceKey: true});
      await initMobilePreferences();

      final fake = _PromptingFakeAuthenticator(
        throws: const LocalAuthException(
          code: LocalAuthExceptionCode.temporaryLockout,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            biometricAuthenticatorProvider.overrideWithValue(fake),
          ],
          child: const MaterialApp(
            home: MobileAppFrame(child: SizedBox.shrink()),
          ),
        ),
      );

      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(fake.authCount, 1);
      expect(find.textContaining('Try again in a moment'), findsOneWidget);
    },
  );

  testWidgets(
    'missing biometric enrollment disables app lock',
    (tester) async {
      SharedPreferences.setMockInitialValues({appLockPreferenceKey: true});
      await initMobilePreferences();

      final fake = _PromptingFakeAuthenticator(
        throws: const LocalAuthException(
          code: LocalAuthExceptionCode.noBiometricsEnrolled,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          biometricAuthenticatorProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: MobileAppFrame(child: SizedBox.shrink()),
          ),
        ),
      );

      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(
        container.read(appLockEnabledProvider),
        isFalse,
        reason:
            'when biometrics are not enrolled, app lock must turn itself off so the user is not trapped',
      );
    },
  );

  testWidgets(
    'app-switcher peek (inactive) does not trigger auth',
    (tester) async {
      SharedPreferences.setMockInitialValues({appLockPreferenceKey: true});
      await initMobilePreferences();

      final fake = _CountingFakeAuthenticator();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            biometricAuthenticatorProvider.overrideWithValue(fake),
          ],
          child: const MaterialApp(
            home: MobileAppFrame(child: SizedBox.shrink()),
          ),
        ),
      );

      // Let the initial auth complete (and short-circuit since the fake
      // returns true immediately without dispatching lifecycle events).
      await tester.pumpAndSettle();
      expect(fake.authCount, 1);

      // Simulate the iOS app-switcher peek: inactive → resumed, with no
      // paused in between. This should not trigger another auth.
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.inactive,
      );
      await tester.pump();
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pumpAndSettle();

      expect(
        fake.authCount,
        1,
        reason: 'a transient inactive → resumed peek must not re-auth',
      );
    },
  );

  testWidgets(
    'real backgrounding (paused → resumed) triggers re-auth',
    (tester) async {
      SharedPreferences.setMockInitialValues({appLockPreferenceKey: true});
      await initMobilePreferences();

      final fake = _CountingFakeAuthenticator();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            biometricAuthenticatorProvider.overrideWithValue(fake),
          ],
          child: const MaterialApp(
            home: MobileAppFrame(child: SizedBox.shrink()),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(fake.authCount, 1);

      // Real backgrounding: the OS sends paused (not just inactive).
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.paused,
      );
      await tester.pump();
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pumpAndSettle();

      expect(
        fake.authCount,
        2,
        reason: 'returning from a true backgrounding must re-auth exactly once',
      );
    },
  );
}

/// Fake authenticator that mimics the OS dispatching `paused` while the
/// biometric sheet is visible and `resumed` after it closes. The resumed
/// event is scheduled via [Timer] so it lands on the event loop *after*
/// the authenticate Future resolves — that's the timing that produced the
/// production loop, because the resumed handler ran with `_authInProgress`
/// already cleared.
/// Simple counter — doesn't simulate prompt lifecycle. Used for tests that
/// drive lifecycle events directly from the test body.
class _CountingFakeAuthenticator implements BiometricAuthenticator {
  int authCount = 0;

  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> authenticate({required String reason}) async {
    authCount++;
    return true;
  }
}

class _PromptingFakeAuthenticator implements BiometricAuthenticator {
  /// If [throws] is non-null, [authenticate] will throw it instead of
  /// returning success. Mirrors the real plugin: success returns true,
  /// everything else surfaces as [LocalAuthException].
  _PromptingFakeAuthenticator({this.throws});

  final LocalAuthException? throws;
  int authCount = 0;
  static const _safetyCap = 8;

  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> authenticate({required String reason}) async {
    authCount++;
    if (authCount > _safetyCap) {
      throw StateError(
        'authenticate() called $authCount times — infinite loop suspected',
      );
    }
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.paused,
    );
    Timer(Duration.zero, () {
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
    });
    if (throws != null) throw throws!;
    return true;
  }
}
