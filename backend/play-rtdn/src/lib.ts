export const PACKAGE_NAME = process.env.PLAY_PACKAGE_NAME ?? 'com.maskedsyntax.patterns';

// https://developer.android.com/google/play/billing/rtdn-reference#one-time-product-notifications
export const ONE_TIME_PRODUCT_PURCHASED = 1;

export interface OneTimeProductNotification {
  version: string;
  notificationType: number;
  purchaseToken: string;
  sku: string;
}

export interface DeveloperNotification {
  version: string;
  packageName: string;
  eventTimeMillis: string;
  oneTimeProductNotification?: OneTimeProductNotification;
  testNotification?: { version: string };
}

export function decodeNotification(pubsubMessageData: string): DeveloperNotification {
  const json = Buffer.from(pubsubMessageData, 'base64').toString('utf8');
  return JSON.parse(json) as DeveloperNotification;
}

export interface AcknowledgeTarget {
  productId: string;
  purchaseToken: string;
}

/**
 * Returns the purchase to acknowledge for a notification, or null if this
 * notification doesn't need any action (e.g. a cancellation, or Play Console's
 * test notification, which carries no real purchase).
 */
export function acknowledgeTargetFor(
  notification: DeveloperNotification,
): AcknowledgeTarget | null {
  const otp = notification.oneTimeProductNotification;
  if (!otp || otp.notificationType !== ONE_TIME_PRODUCT_PURCHASED) return null;
  return { productId: otp.sku, purchaseToken: otp.purchaseToken };
}
