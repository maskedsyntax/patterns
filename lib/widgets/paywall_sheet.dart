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
/// On desktop, it automatically shows the high-fidelity [DesktopPaywallView].
class PaywallSheet extends StatefulWidget {
  const PaywallSheet({super.key});

  static Future<void> show(BuildContext context) {
    if (kIsDesktop) {
      return showDialog<void>(
        context: context,
        useRootNavigator: true,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 48,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: DesktopPaywallView(
              onUnlocked: () => Navigator.pop(context),
            ),
          ),
        ),
      );
    }
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const PaywallSheet(),
    );
  }

  @override
  State<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<PaywallSheet> {
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

  @override
  void initState() {
    super.initState();
    _eventSub = ProService.events.listen(_onEvent);
    _loadProduct();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    if (!ProService.isPlatformSupported) {
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
                    'Patterns Pro',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Move beyond tracking and practice recovery. A one-time unlock, yours for good, no subscription.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 18),
            for (final point in _mobileProPoints) ...[
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
    final buttonText = product != null ? 'Unlock Pro · ${product.price}' : 'Unlock Pro';

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

/// A high-fidelity, premium paywall view for Desktop (reused dialog / inline).
class DesktopPaywallView extends StatefulWidget {
  final VoidCallback? onUnlocked;
  const DesktopPaywallView({super.key, this.onUnlocked});

  @override
  State<DesktopPaywallView> createState() => _DesktopPaywallViewState();
}

class _DesktopPaywallViewState extends State<DesktopPaywallView> {
  final _licenseController = TextEditingController();
  bool _isEnteringLicense = false;

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // List of premium features optimized for desktop
    final features = [
      (
        icon: Icons.linear_scale_rounded,
        title: 'Hierarchy Builder',
        desc: 'Construct and track exposure steps and ladders.',
      ),
      (
        icon: Icons.assignment_turned_in_rounded,
        title: 'ERP Exercise Logs',
        desc: 'Log response prevention and timed exercises.',
      ),
      (
        icon: Icons.hourglass_empty_rounded,
        title: 'Urge Surfing Waves',
        desc: 'Ride urge spikes with live timed logging.',
      ),
      (
        icon: Icons.analytics_rounded,
        title: 'Advanced Insights',
        desc: 'View interactive trend charts and weekly metrics.',
      ),
    ];

    Widget buildFeatureCard(IconData icon, String title, String desc) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.verified_user_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock Patterns Desktop Pro',
                      style: TextStyle(
                        fontFamily: AppTheme.displayFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'A cheaper, one-time payment for offline desktop-optimized recovery tools.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Features Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildFeatureCard(
                      features[0].icon,
                      features[0].title,
                      features[0].desc,
                    ),
                    const SizedBox(height: 12),
                    buildFeatureCard(
                      features[2].icon,
                      features[2].title,
                      features[2].desc,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildFeatureCard(
                      features[1].icon,
                      features[1].title,
                      features[1].desc,
                    ),
                    const SizedBox(height: 12),
                    buildFeatureCard(
                      features[3].icon,
                      features[3].title,
                      features[3].desc,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Pricing & Checkout Box
          Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isEnteringLicense) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'One-Time License',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$9.99 (one-time purchase)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => launchUrl(
                              Uri.parse('https://maskedsyntax.lemonsqueezy.com/buy/patterns-desktop-pro'),
                              mode: LaunchMode.externalApplication,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                            child: const Text('Purchase License Key'),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Colors.white10),
                      GestureDetector(
                        onTap: () => setState(() => _isEnteringLicense = true),
                        child: Center(
                          child: Text(
                            'Already purchased? Enter your License Key',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Enter your Lemon Squeezy license key:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _licenseController,
                        style: TextStyle(
                          fontSize: 13.5,
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
                      const SizedBox(height: 8),
                      Text(
                        'For testing, enter any 8+ character key (e.g. DESKTOP-TEST-KEY).',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
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
                            child: Consumer(
                              builder: (context, ref, _) {
                                return ElevatedButton(
                                  onPressed: () async {
                                    final key = _licenseController.text.trim();
                                    if (key.length >= 8) {
                                      await appPreferences?.setBool(proUnlockedKey, true);
                                      ref.read(proProvider.notifier).refresh();
                                      if (widget.onUnlocked != null) {
                                        widget.onUnlocked!();
                                      } else {
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
                                  child: const Text('Activate License'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
