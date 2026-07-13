import { cloudEvent, type CloudEvent } from '@google-cloud/functions-framework';
import { google } from 'googleapis';
import { acknowledgeTargetFor, decodeNotification, PACKAGE_NAME } from './lib';

interface PubSubMessage {
  data?: string;
  attributes?: Record<string, string>;
}

const ACKNOWLEDGED = 1;

const auth = new google.auth.GoogleAuth({
  scopes: ['https://www.googleapis.com/auth/androidpublisher'],
});
const androidpublisher = google.androidpublisher('v3');

function describeApiError(err: unknown): string {
  const e = err as { code?: number; errors?: unknown; response?: { data?: unknown } };
  return JSON.stringify({ code: e?.code, errors: e?.errors, responseData: e?.response?.data });
}

async function acknowledgeIfNeeded(productId: string, purchaseToken: string): Promise<void> {
  let purchase;
  try {
    purchase = await androidpublisher.purchases.products.get({
      auth,
      packageName: PACKAGE_NAME,
      productId,
      token: purchaseToken,
    });
  } catch (err: unknown) {
    console.error(
      `get() failed for ${productId}/${purchaseToken}: ${describeApiError(err)}`,
    );
    throw err;
  }

  if (purchase.data.acknowledgementState === ACKNOWLEDGED) {
    console.log(`Already acknowledged: ${productId}/${purchaseToken}`);
    return;
  }

  try {
    await androidpublisher.purchases.products.acknowledge({
      auth,
      packageName: PACKAGE_NAME,
      productId,
      token: purchaseToken,
      requestBody: {},
    });
    console.log(`Acknowledged purchase: ${productId}/${purchaseToken}`);
  } catch (err: unknown) {
    // A retried delivery of the same notification may have already
    // acknowledged this purchase between our get() and acknowledge() calls.
    const code = (err as { code?: number })?.code;
    if (code === 400 || code === 410) {
      console.log(`Already handled by a concurrent retry: ${productId}/${purchaseToken}`);
      return;
    }
    console.error(
      `acknowledge() failed for ${productId}/${purchaseToken}: ${describeApiError(err)}`,
    );
    throw err;
  }
}

cloudEvent('acknowledgePurchase', async (event: CloudEvent<unknown>) => {
  const message = (event.data as { message?: PubSubMessage } | undefined)?.message;
  if (!message?.data) {
    console.log('No Pub/Sub message data; ignoring.');
    return;
  }

  const notification = decodeNotification(message.data);

  if (notification.testNotification) {
    console.log('Received a Play Console test notification.');
    return;
  }

  const target = acknowledgeTargetFor(notification);
  if (!target) {
    console.log(`No action needed for notification: ${JSON.stringify(notification)}`);
    return;
  }

  await acknowledgeIfNeeded(target.productId, target.purchaseToken);
});
