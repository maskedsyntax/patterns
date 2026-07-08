import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:in_app_purchase/in_app_purchase.dart';

/// Optional one-shot tips from the user to support development.
///
/// Wraps `InAppPurchase` for the three consumable products configured in
/// the app stores. Consumables grant no entitlement — repeat tips are expected.
/// The plugin's `purchaseStream` is subscribed at app start so any interrupted
/// purchases from a prior session are completed before the user can tip again.
class TipJarService {
  static const String productIdSmall = 'com.maskedsyntax.patterns.tip.small';
  static const String productIdMedium = 'com.maskedsyntax.patterns.tip.medium';
  static const String productIdLarge = 'com.maskedsyntax.patterns.tip.large';

  static const Set<String> _productIds = {
    productIdSmall,
    productIdMedium,
    productIdLarge,
  };

  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  static final StreamController<TipJarEvent> _events =
      StreamController<TipJarEvent>.broadcast();
  static List<ProductDetails>? _cachedProducts;

  static Stream<TipJarEvent> get events => _events.stream;

  static bool get isPlatformSupported {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid || Platform.isMacOS;
  }

  /// Call once at app start. Subscribes to the purchase stream so any
  /// pending purchases from a previous session get completed.
  static void init() {
    if (!isPlatformSupported) return;
    _subscription ??= _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (error) => _events.add(TipJarError('$error')),
    );
  }

  /// Whether the store is reachable from this device. False on unsupported
  /// platforms, in restricted environments, or when StoreKit/Billing is
  /// unavailable.
  static Future<bool> isAvailable() async {
    if (!isPlatformSupported) return false;
    try {
      return await _iap.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Fetch the three products with current localized prices from the store.
  /// Cached after first successful load; pass `forceReload: true` to refetch.
  static Future<List<ProductDetails>> loadProducts({
    bool forceReload = false,
  }) async {
    if (!isPlatformSupported) return const [];
    final cached = _cachedProducts;
    if (cached != null && !forceReload) return cached;

    final response = await _iap.queryProductDetails(_productIds);
    if (response.error != null) {
      throw TipJarException(response.error!.message);
    }
    final products = List<ProductDetails>.from(response.productDetails)
      ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    _cachedProducts = products;
    return products;
  }

  /// Launches the native purchase sheet. Outcome is delivered on the
  /// `events` stream.
  static Future<bool> buyTip(ProductDetails product) async {
    if (!isPlatformSupported) return false;
    init();
    final param = PurchaseParam(productDetails: product);
    return _iap.buyConsumable(purchaseParam: param);
  }

  static Future<void> _onPurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          _events.add(TipJarSuccess(purchase.productID));
        case PurchaseStatus.error:
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          _events.add(
            TipJarError(purchase.error?.message ?? 'Purchase failed'),
          );
        case PurchaseStatus.canceled:
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          _events.add(const TipJarCanceled());
      }
    }
  }
}

sealed class TipJarEvent {
  const TipJarEvent();
}

class TipJarSuccess extends TipJarEvent {
  final String productId;
  const TipJarSuccess(this.productId);
}

class TipJarError extends TipJarEvent {
  final String message;
  const TipJarError(this.message);
}

class TipJarCanceled extends TipJarEvent {
  const TipJarCanceled();
}

class TipJarException implements Exception {
  final String message;
  TipJarException(this.message);

  @override
  String toString() => 'TipJarException: $message';
}
