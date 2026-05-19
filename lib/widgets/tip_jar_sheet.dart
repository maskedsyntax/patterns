import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:line_icons/line_icons.dart';

import '../services/tip_jar.dart';
import '../theme/app_theme.dart';
import 'tip_thanks_dialog.dart';

class TipJarSheet extends StatefulWidget {
  const TipJarSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const TipJarSheet(),
    );
  }

  @override
  State<TipJarSheet> createState() => _TipJarSheetState();
}

class _TipJarSheetState extends State<TipJarSheet> {
  List<ProductDetails>? _products;
  String? _loadError;
  bool _loading = true;
  bool _purchaseInFlight = false;
  StreamSubscription<TipJarEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _eventSub = TipJarService.events.listen(_onEvent);
    _loadProducts();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final available = await TipJarService.isAvailable();
      if (!available) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _loadError = 'In-app purchases are unavailable on this device.';
        });
        return;
      }
      final products = await TipJarService.loadProducts(forceReload: true);
      if (!mounted) return;
      setState(() {
        _products = products;
        _loading = false;
        if (products.isEmpty) {
          _loadError = 'No tip options found. Please try again later.';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Could not load tip options. Please try again later.';
      });
    }
  }

  void _onEvent(TipJarEvent event) {
    if (!mounted) return;
    switch (event) {
      case TipJarSuccess():
        setState(() => _purchaseInFlight = false);
        Navigator.of(context).pop();
        TipThanksDialog.show(context);
      case TipJarError(:final message):
        setState(() => _purchaseInFlight = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.charcoalInput,
          ),
        );
      case TipJarCanceled():
        setState(() => _purchaseInFlight = false);
    }
  }

  Future<void> _onTip(ProductDetails product) async {
    if (_purchaseInFlight) return;
    setState(() => _purchaseInFlight = true);
    try {
      final launched = await TipJarService.buyTip(product);
      if (!launched && mounted) {
        setState(() => _purchaseInFlight = false);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _purchaseInFlight = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Could not start the purchase. Please try again.',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.charcoalInput,
        ),
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
                    LineIcons.heart,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Support Patterns',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Patterns is independent and ad-free. If it has helped you, '
              'a small tip means a lot. Tips are optional and do not unlock anything.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 20),
            _buildBody(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
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
            onPressed: _loadProducts,
            child: const Text('Try again'),
          ),
        ],
      );
    }
    final products = _products ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final product in products) ...[
          _TipChoice(
            product: product,
            disabled: _purchaseInFlight,
            onTap: () => _onTip(product),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _TipChoice extends StatelessWidget {
  final ProductDetails product;
  final bool disabled;
  final VoidCallback onTap;

  const _TipChoice({
    required this.product,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = product.title.isNotEmpty ? product.title : product.id;
    final subtitle = product.description;

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: disabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cleanTitle(title),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                product.price,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Strip the trailing " (Patterns: Journal & OCD Tracker)" that the App Store
  /// appends to localized titles when fetched via StoreKit.
  static String _cleanTitle(String raw) {
    final idx = raw.indexOf(' (');
    return idx > 0 ? raw.substring(0, idx) : raw;
  }
}
