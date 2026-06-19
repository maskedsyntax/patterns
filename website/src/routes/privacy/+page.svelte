<script lang="ts">
  import Seo from '$lib/components/Seo.svelte';
  import PrivacyContent from '$lib/sections/PrivacyContent.svelte';
  import { links } from '$lib/data/links';

  const jsonLd = [
    {
      '@context': 'https://schema.org',
      '@type': 'WebPage',
      name: 'Privacy Policy — Patterns',
      description:
        'Privacy policy for Patterns, a local-first OCD tracker and journaling app.',
      url: `${links.site}privacy`,
      isPartOf: { '@type': 'WebSite', name: 'Patterns', url: links.site }
    }
  ];
</script>

<Seo
  title="Privacy Policy — Patterns"
  description="Patterns privacy policy: local-first OCD tracker and journal. No cloud sync, no accounts, no telemetry. Your data stays on your device."
  path="privacy"
  {jsonLd}
/>

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
