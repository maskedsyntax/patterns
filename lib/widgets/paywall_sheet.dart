import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:line_icons/line_icons.dart';

import '../services/pro_service.dart';
import '../theme/app_theme.dart';
import 'app_snack_bar.dart';

/// Bottom sheet that sells the one-time "Patterns Pro" unlock. Mirrors the tip
/// jar sheet's layout and purchase-lifecycle handling, but for a single
/// non-consumable product plus a Restore action.
class PaywallSheet extends StatefulWidget {
  const PaywallSheet({super.key});

  static Future<void> show(BuildContext context) {
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
  static const _proPoints = <String>[
    'Exposure Hierarchy Builder — climb fear ladders step by step',
    'Exposure materials — scripts, loop tapes, images & links',
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
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final available = await ProService.isAvailable();
      if (!available) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _loadError = 'In-app purchases are unavailable on this device.';
        });
        return;
      }
      final product = await ProService.loadProduct(forceReload: true);
      if (!mounted) return;
      setState(() {
        _product = product;
        _loading = false;
        if (product == null) {
          _loadError =
              'Patterns Pro is not available right now. Please try again later.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Could not load Patterns Pro. Please try again later.';
      });
    }
  }

  void _onEvent(ProEvent event) {
    if (!mounted) return;
    switch (event) {
      case ProSuccess(:final restored):
        setState(() => _purchaseInFlight = false);
        final rootNavigator = Navigator.of(context, rootNavigator: true);
        Navigator.of(context).pop();
        _showUnlockedDialog(rootNavigator.context, restored: restored);
      case ProError(:final message):
        setState(() => _purchaseInFlight = false);
        showAppSnackBar(context, message, type: ToastType.error);
      case ProCanceled():
        setState(() => _purchaseInFlight = false);
    }
  }

  Future<void> _onBuy() async {
    final product = _product;
    if (product == null || _purchaseInFlight) return;
    setState(() => _purchaseInFlight = true);
    try {
      final launched = await ProService.buyPro(product);
      if (!launched && mounted) setState(() => _purchaseInFlight = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _purchaseInFlight = false);
      showAppSnackBar(
        context,
        'Could not start the purchase. Please try again.',
        type: ToastType.error,
      );
    }
  }

  Future<void> _onRestore() async {
    if (_purchaseInFlight) return;
    setState(() => _purchaseInFlight = true);
    try {
      await ProService.restore();
      if (!mounted) return;
      // A restored entitlement arrives via the event stream; if nothing came
      // back the user simply has no prior purchase to restore.
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _purchaseInFlight) {
          setState(() => _purchaseInFlight = false);
          if (!ProService.isUnlocked) {
            showAppSnackBar(
              context,
              'No previous Patterns Pro purchase found.',
              type: ToastType.info,
            );
          }
        }
      });
    } catch (_) {
      if (!mounted) return;
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
              'Move beyond tracking and practice recovery. A one-time unlock — '
              'yours for good, no subscription.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 18),
            for (final point in _proPoints) ...[
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
                : Text(
                    product != null
                        ? 'Unlock Pro · ${product.price}'
                        : 'Unlock Pro',
                  ),
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

void _showUnlockedDialog(BuildContext context, {required bool restored}) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final isDark = theme.brightness == Brightness.dark;
      final surface = isDark
          ? AppTheme.charcoalCard
          : theme.colorScheme.surface;
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
                    ? 'Patterns Pro has been restored on this device.'
                    : 'Patterns Pro is unlocked. Every recovery tool is now yours.',
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
