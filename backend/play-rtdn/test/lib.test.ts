import assert from 'node:assert/strict';
import { test } from 'node:test';
import { acknowledgeTargetFor, decodeNotification, ONE_TIME_PRODUCT_PURCHASED } from '../src/lib';

function encode(obj: unknown): string {
  return Buffer.from(JSON.stringify(obj), 'utf8').toString('base64');
}

const purchaseNotification = {
  version: '1.0',
  packageName: 'com.maskedsyntax.patterns',
  eventTimeMillis: '1234567890',
  oneTimeProductNotification: {
    version: '1.0',
    notificationType: ONE_TIME_PRODUCT_PURCHASED,
    purchaseToken: 'token-abc',
    sku: 'com.maskedsyntax.patterns.pro',
  },
};

test('decodeNotification parses a base64-encoded Pub/Sub payload', () => {
  assert.deepEqual(decodeNotification(encode(purchaseNotification)), purchaseNotification);
});

test('acknowledgeTargetFor returns the purchase for a ONE_TIME_PRODUCT_PURCHASED notification', () => {
  assert.deepEqual(acknowledgeTargetFor(purchaseNotification), {
    productId: 'com.maskedsyntax.patterns.pro',
    purchaseToken: 'token-abc',
  });
});

test('acknowledgeTargetFor ignores other one-time-product notification types', () => {
  const canceled = {
    ...purchaseNotification,
    oneTimeProductNotification: {
      ...purchaseNotification.oneTimeProductNotification,
      notificationType: 2, // ONE_TIME_PRODUCT_CANCELED
    },
  };
  assert.equal(acknowledgeTargetFor(canceled), null);
});

test('acknowledgeTargetFor ignores notifications without a one-time-product payload', () => {
  const testNotification = {
    version: '1.0',
    packageName: 'com.maskedsyntax.patterns',
    eventTimeMillis: '1234567890',
    testNotification: { version: '1.0' },
  };
  assert.equal(acknowledgeTargetFor(testNotification), null);
});
