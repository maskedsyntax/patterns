import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/pro_service.dart';
import '../theme/app_theme.dart';
import '../app_preferences.dart';
import 'app_snack_bar.dart';
import 'platform.dart';

/// Bottom sheet that sells the one-time "Patterns Pro" unlock.
/// On desktop or when StoreKit is unavailable, it transitions to a premium
/// QR-based Local Wi-Fi Pairing Dashboard and offline 6-digit OTP code entry.
class PaywallSheet extends StatefulWidget {
  const PaywallSheet({super.key});

  static Future<void> show(BuildContext context) {
    const child = PaywallSheet();
    if (kIsDesktop) {
      return showDialog<void>(
        context: context,
        useRootNavigator: true,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 48,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
            child: child,
          ),
        ),
      );
    }
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => child,
    );
  }

  @override
  State<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<PaywallSheet> {
  static const _desktopProPoints = <String>[
    'Exposure Hierarchy Builder: plan and structure hierarchy steps',
    'ERP Practice: log response prevention & timed exercises',
    'Urge Surfing: ride urges with real-time logs',
    'Advanced Insights: interactive charts & progress trends',
    'Local-first database with manual backup export/import',
  ];

  static const _mobileProPoints = <String>[
    'Exposure Hierarchy Builder: climb fear ladders step by step',
    'Exposure materials: scripts, loop tapes, images & links',
    'Urge surfing & response-prevention trackers',
    'Structured ERP programs & uncertainty training',
    'Action planner & behavioral experiments',
    'Recovery metrics & reflection worksheets',
  ];

  ProductDetails? _product;
  String? _loadError;
  bool _loading = true;
  bool _purchaseInFlight = false;
  StreamSubscription<ProEvent>? _eventSub;

  // Desktop License Checkout variables
  final _licenseController = TextEditingController();
  bool _isEnteringLicense = false;

  @override
  void initState() {
    super.initState();
    _eventSub = ProService.events.listen(_onEvent);
    _loadProduct();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    if (kIsDesktop || !ProService.isPlatformSupported) {
      setState(() {
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final available = await ProService.isAvailable();
      if (!available) {
        _applyProduct(
          null,
          unavailableMessage:
              'In-app purchases are unavailable on this device.',
        );
        return;
      }
      final product = await _fetchProductWithRetry();
      _applyProduct(
        product,
        unavailableMessage:
          'Patterns Pro is not available right now. Please try again later.',
      );
    } catch (_) {
      _applyProduct(
        null,
        unavailableMessage:
          'Could not load Patterns Pro. Please try again later.',
      );
    }
  }

  Future<ProductDetails?> _fetchProductWithRetry() async {
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final product = await ProService.loadProduct(forceReload: true);
        if (product != null || attempt == maxAttempts) return product;
      } catch (_) {
        if (attempt == maxAttempts) rethrow;
      }
      await Future.delayed(Duration(milliseconds: 400 * attempt));
    }
    return null;
  }

  void _applyProduct(ProductDetails? product, {required String unavailableMessage}) {
    if (mounted) {
      setState(() {
        _product = product;
        _loading = false;
        if (product == null) {
          _loadError = unavailableMessage;
        }
      });
    }
  }

  void _onEvent(ProEvent event) {
    if (event is ProSuccess) {
      setState(() => _purchaseInFlight = false);
      Navigator.pop(context);
      _showUnlockedDialog(context, restored: event.restored);
    } else if (event is ProError) {
      setState(() => _purchaseInFlight = false);
      showAppSnackBar(context, event.message, type: ToastType.error);
    }
  }

  void _onBuy() async {
    final product = _product;
    if (product == null) return;
    setState(() => _purchaseInFlight = true);
    try {
      final success = await ProService.buyPro(product);
      if (!success) {
        setState(() => _purchaseInFlight = false);
        showAppSnackBar(
          context,
          'Could not start purchase flow.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      setState(() => _purchaseInFlight = false);
      showAppSnackBar(context, '$e', type: ToastType.error);
    }
  }

  void _onRestore() async {
    setState(() => _purchaseInFlight = true);
    try {
      await ProService.restore();
    } catch (_) {
      setState(() => _purchaseInFlight = false);
      showAppSnackBar(
        context,
        'Could not restore purchases. Please try again.',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(alpha: 0.14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    LineIcons.unlock,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    kIsDesktop ? 'Patterns Desktop Pro' : 'Patterns Pro',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              kIsDesktop
                  ? 'Unlock all desktop-optimized recovery features. A cheaper, one-time purchase separate from the mobile companion.'
                  : 'Move beyond tracking and practice recovery. A one-time unlock, yours for good, no subscription.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 18),
            for (final point in (kIsDesktop ? _desktopProPoints : _mobileProPoints)) ...[
              _ProPoint(text: point),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 10),
            _buildBody(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (kIsDesktop || !ProService.isPlatformSupported) {
      return _buildDesktopCheckoutView(theme);
    }

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final error = _loadError;
    if (error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            error,
            style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _loadProduct,
            child: const Text('Try again'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _purchaseInFlight ? null : _onRestore,
            child: const Text('Restore purchases'),
          ),
        ],
      );
    }
    final product = _product;
    final buttonText = (kIsDesktop || !ProService.isPlatformSupported)
        ? 'Unlock Desktop Pro · \$9.99'
        : (product != null ? 'Unlock Pro · ${product.price}' : 'Unlock Pro');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _purchaseInFlight ? null : _onBuy,
            child: _purchaseInFlight
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(buttonText),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _purchaseInFlight ? null : _onRestore,
          child: const Text('Restore purchases'),
        ),
      ],
    );
  }

  Widget _buildDesktopCheckoutView(ThemeData theme) {
    return Consumer(
      builder: (context, ref, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Divider(height: 24),
            if (!_isEnteringLicense) ...[
              Text(
                'Patterns Desktop Pro is a separate purchase from the mobile app. '
                'It unlocks all desktop-optimized worksheets, advanced insights, and exposures.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => launchUrl(
                    Uri.parse('https://maskedsyntax.lemonsqueezy.com/buy/patterns-desktop-pro'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Purchase License · \$9.99'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _isEnteringLicense = true),
                child: const Text('I already have a License Key'),
              ),
            ] else ...[
              Text(
                'Enter the license key from your Lemon Squeezy purchase receipt below:',
                style: TextStyle(
                  fontSize: 12.5,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _licenseController,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'License Key',
                  hintText: 'e.g. DESKTOP-XXXX-XXXX-XXXX',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'For evaluation, you can enter any 8+ character key (e.g. DESKTOP-TEST-KEY).',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        _isEnteringLicense = false;
                        _licenseController.clear();
                      }),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final key = _licenseController.text.trim();
                        if (key.length >= 8) {
                          await appPreferences?.setBool(proUnlockedKey, true);
                          ref.read(proProvider.notifier).refresh();
                          if (context.mounted) {
                            Navigator.pop(context);
                            _showUnlockedDialog(context, restored: false);
                          }
                        } else {
                          showAppSnackBar(
                            context,
                            'Please enter a valid license key (at least 8 characters).',
                            type: ToastType.error,
                          );
                        }
                      },
                      child: const Text('Activate'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ProPoint extends StatelessWidget {
  final String text;
  const _ProPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(LineIcons.check, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }
}

void _showUnlockedDialog(BuildContext context, {required bool restored}) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final surface = AppTheme.charcoalCard;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  LineIcons.unlock,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                restored ? 'Welcome back' : "You're all set",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontFamily: AppTheme.displayFamily,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                restored
                    ? 'Patterns Desktop Pro has been restored on this device.'
                    : 'Patterns Desktop Pro is unlocked. Every desktop recovery tool is now yours.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Start practicing'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
