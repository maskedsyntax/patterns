import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:in_app_purchase/in_app_purchase.dart';

import '../mobile/preferences.dart';

/// One-time "Patterns Pro" unlock.
///
/// Wraps `InAppPurchase` for a single non-consumable product. Unlike the tip
/// jar, a Pro purchase grants a lasting entitlement, so the result is persisted
/// to [mobilePreferences] under [proUnlockedKey] and restored on a new device
/// via [restore]. The plugin's `purchaseStream` is subscribed at app start so a
/// purchase or restore from a previous session is honoured on next launch.
class ProService {
  static const String productIdPro = 'com.maskedsyntax.patterns.pro';

  static const Set<String> _productIds = {productIdPro};

  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  static final StreamController<ProEvent> _events =
      StreamController<ProEvent>.broadcast();
  static ProductDetails? _cachedProduct;

  static Stream<ProEvent> get events => _events.stream;

  /// Whether Pro has been unlocked on this device. Reads the persisted flag so
  /// gating works synchronously and offline. Defaults to false (incl. desktop
  /// where `mobilePreferences` is null).
  static bool get isUnlocked =>
      mobilePreferences?.getBool(proUnlockedKey) ?? false;

  static bool get isPlatformSupported {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid || Platform.isMacOS;
  }

  /// Call once at app start. Subscribes to the purchase stream so any pending
  /// purchase or restore from a previous session is completed and persisted.
  static void init() {
    if (!isPlatformSupported) return;
    _subscription ??= _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (error) => _events.add(ProError('$error')),
    );
  }

  /// Whether the store is reachable. False on unsupported platforms, in
  /// restricted environments, or when StoreKit/Billing is unavailable.
  static Future<bool> isAvailable() async {
    if (!isPlatformSupported) return false;
    try {
      return await _iap.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Fetch the Pro product with its localized price. Cached after first
  /// successful load; pass `forceReload: true` to refetch.
  static Future<ProductDetails?> loadProduct({bool forceReload = false}) async {
    if (!isPlatformSupported) return null;
    final cached = _cachedProduct;
    if (cached != null && !forceReload) return cached;

    final response = await _iap.queryProductDetails(_productIds);
    if (response.error != null) {
      throw ProException(response.error!.message);
    }
    if (response.productDetails.isEmpty) return null;
    final product = response.productDetails.first;
    _cachedProduct = product;
    return product;
  }

  /// Launches the native purchase sheet for the Pro unlock. Outcome is
  /// delivered on the [events] stream.
  static Future<bool> buyPro(ProductDetails product) async {
    if (!isPlatformSupported) return false;
    init();
    final param = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Re-applies a previous Pro purchase on this account/device. Required for
  /// non-consumables by App Store review. Results arrive on [events] as the
  /// restored purchases flow through the stream.
  static Future<void> restore() async {
    if (!isPlatformSupported) return;
    init();
    await _iap.restorePurchases();
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
          if (purchase.productID == productIdPro) {
            await mobilePreferences?.setBool(proUnlockedKey, true);
          }
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          _events.add(
            ProSuccess(restored: purchase.status == PurchaseStatus.restored),
          );
        case PurchaseStatus.error:
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          _events.add(ProError(purchase.error?.message ?? 'Purchase failed'));
        case PurchaseStatus.canceled:
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          _events.add(const ProCanceled());
      }
    }
  }
}

sealed class ProEvent {
  const ProEvent();
}

class ProSuccess extends ProEvent {
  /// True when the entitlement came from a restore rather than a fresh buy.
  final bool restored;
  const ProSuccess({this.restored = false});
}

class ProError extends ProEvent {
  final String message;
  const ProError(this.message);
}

class ProCanceled extends ProEvent {
  const ProCanceled();
}

class ProException implements Exception {
  final String message;
  ProException(this.message);

  @override
  String toString() => 'ProException: $message';
}
