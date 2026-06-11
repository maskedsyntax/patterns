<script lang="ts">
  import PrivacyContent from '$lib/sections/PrivacyContent.svelte';
  import { links } from '$lib/data/links';
</script>

<svelte:head>
  <title>Privacy Policy — Patterns</title>
  <meta
    name="description"
    content="Patterns privacy policy: local-first OCD tracker and journal. No cloud sync, no accounts, no telemetry. Your data stays on your device."
  />
  <link rel="canonical" href="{links.site}privacy" />
  <meta property="og:title" content="Privacy Policy — Patterns" />
  <meta
    property="og:description"
    content="Your data stays yours. Patterns is completely offline with no cloud sync or telemetry."
  />
  <meta property="og:url" content="{links.site}privacy" />
  {@html `<script type="application/ld+json">${JSON.stringify({
    '@context': 'https://schema.org',
    '@type': 'WebPage',
    name: 'Privacy Policy — Patterns',
    description:
      'Privacy policy for Patterns, a local-first OCD tracker and journaling app.',
    url: `${links.site}privacy`,
    isPartOf: { '@type': 'WebSite', name: 'Patterns', url: links.site }
  })}</script>`}
</svelte:head>

<PrivacyContent />

<div class="back-wrap">
  <a href="/">← Back to Home</a>
</div>

<style>
  .back-wrap {
    text-align: center;
    padding: 40px 0 60px;
  }

  .back-wrap a {
    font-weight: 600;
    color: var(--accent);
  }
</style>
