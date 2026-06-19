import { links } from './links';

/**
 * Single source of truth for site-wide metadata. Keeping the app version here
 * (rather than hand-copied into JSON-LD) prevents the structured data from
 * drifting out of sync with the shipped app.
 */
export const site = {
  name: 'Patterns',
  /** Keep in sync with the Flutter app's pubspec version (marketing version). */
  appVersion: '1.4.0',
  url: links.site,
  /** Purpose-built 1200×630 social share image. */
  ogImage: `${links.site}og/patterns-og.png`,
  ogImageWidth: 1200,
  ogImageHeight: 630,
  author: { name: 'MaskedSyntax', url: 'https://github.com/maskedsyntax' },
  publisher: { name: 'MaskedSyntax', url: links.maskedsyntax }
} as const;
