import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:local_auth/local_auth.dart'
    show LocalAuthException, LocalAuthExceptionCode;

import '../app_preferences.dart';
import '../theme/app_theme.dart';
import 'biometric_auth.dart';

/// Desktop app-lock cover. Reimplements the mobile privacy gate without
/// importing mobile UI.
class DesktopPrivacyGate extends ConsumerStatefulWidget {
  final Widget child;

  const DesktopPrivacyGate({super.key, required this.child});

  @override
  ConsumerState<DesktopPrivacyGate> createState() => _DesktopPrivacyGateState();
}

class _DesktopPrivacyGateState extends ConsumerState<DesktopPrivacyGate>
    with WidgetsBindingObserver {
  bool _lifecycleCovered = false;
  bool _didBackground = false;
  bool _locked = appPreferences?.getBool(appLockPreferenceKey) ?? false;
  bool _authInProgress = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_locked) _authenticate();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_authInProgress) return;

    if (state == AppLifecycleState.resumed) {
      final shouldReauth = _didBackground;
      setState(() {
        _lifecycleCovered = false;
        _didBackground = false;
      });
      if (shouldReauth && _locked && ref.read(appLockEnabledProvider)) {
        _authenticate();
      }
      return;
    }

    setState(() {
      _lifecycleCovered = true;
      if (state == AppLifecycleState.paused) {
        _didBackground = true;
        if (ref.read(appLockEnabledProvider)) _locked = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(appLockEnabledProvider, (_, enabled) {
      if (!enabled) setState(() => _locked = false);
    });
    final covered = _lifecycleCovered || _locked;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !covered,
            child: AnimatedOpacity(
              opacity: covered ? 1 : 0,
              duration: const Duration(milliseconds: 120),
              child: _Cover(
                showUnlock: _locked && !_lifecycleCovered,
                unlockBusy: _authInProgress,
                onUnlock: _authenticate,
                message: _lifecycleCovered ? null : _errorMessage,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _authenticate() async {
    if (_authInProgress || !mounted || !ref.read(appLockEnabledProvider)) {
      return;
    }
    setState(() {
      _authInProgress = true;
      _errorMessage = null;
    });
    try {
      final auth = ref.read(biometricAuthenticatorProvider);
      final supported = await auth.isDeviceSupported();
      if (!supported) {
        await ref.read(appLockEnabledProvider.notifier).setEnabled(false);
        if (mounted) setState(() => _locked = false);
        return;
      }
      final ok = await auth.authenticate(
        reason: 'Unlock Patterns',
      );
      if (!mounted) return;
      setState(() {
        _locked = !ok;
        if (!ok) {
          _errorMessage = 'Could not unlock. Try again.';
        }
      });
    } on LocalAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.code == LocalAuthExceptionCode.userCanceled
            ? null
            : 'Unlock failed. Try again.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unlock failed. Try again.');
    } finally {
      if (mounted) setState(() => _authInProgress = false);
    }
  }
}

class _Cover extends StatelessWidget {
  final bool showUnlock;
  final bool unlockBusy;
  final VoidCallback onUnlock;
  final String? message;

  const _Cover({
    required this.showUnlock,
    required this.unlockBusy,
    required this.onUnlock,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.dividerColor),
              ),
              child: Icon(
                LineIcons.lock,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
            if (showUnlock) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: unlockBusy ? null : onUnlock,
                child: Text(unlockBusy ? 'Unlocking...' : 'Unlock'),
              ),
            ],
            if (message != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
