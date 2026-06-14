<script lang="ts">
  import { onMount } from 'svelte';
  import { browser } from '$app/environment';
  import { page } from '$app/stores';
  import '../app.css';
  import AppInstallBanner from '$lib/components/AppInstallBanner.svelte';
  import Navbar from '$lib/components/Navbar.svelte';
  import { theme } from '$lib/stores/theme';
  import { links } from '$lib/data/links';

  let { children } = $props();

  onMount(() => {
    theme.init();

    if (window.location.hash === '#/privacy') {
      window.history.replaceState(null, '', '/privacy');
      window.location.href = '/privacy';
    }

    if ($page.url.hash) {
      const id = $page.url.hash.slice(1);
      requestAnimationFrame(() => {
        document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' });
      });
    }
  });

  const isHome = $derived($page.url.pathname === '/');
</script>

<svelte:head>
  {#if isHome}
    <title>Patterns — Private OCD Tracker & Journaling App for iPhone, Mac, Windows, Linux</title>
    <meta
      name="description"
      content="Patterns is a private OCD tracker and journaling app for iPhone, Mac, Windows, and Linux. Track obsessions, compulsions, and distress levels in a calm, local-first space — no accounts, no cloud."
    />
    <meta
      name="keywords"
      content="OCD tracker app, OCD journal, intrusive thoughts tracker, private journaling app, mental health journal, obsessive compulsive self-tracking, local-first journal, journaling app for iPhone, OCD app"
    />
    <link rel="canonical" href={links.site} />
    <meta property="og:title" content="Patterns — Private OCD tracker and journaling app" />
    <meta
      property="og:description"
      content="A calm, private OCD tracker and daily journal. Available on iPhone, Mac, Windows, and Linux. Your reflections stay on your device."
    />
    <meta property="og:url" content={links.site} />
    <meta name="twitter:title" content="Patterns — Private OCD tracker and journaling app" />
    <meta
      name="twitter:description"
      content="Track obsessions, compulsions, and daily reflections in a calm, private app. Local-first, no cloud, no accounts."
    />
    {@html `<script type="application/ld+json">${JSON.stringify({
      '@context': 'https://schema.org',
      '@type': 'SoftwareApplication',
      name: 'Patterns',
      alternateName: 'Patterns — OCD Tracker & Journal',
      applicationCategory: 'HealthApplication',
      applicationSubCategory: 'Mental Health',
      operatingSystem: 'iOS, macOS, Windows, Linux',
      description:
        'Patterns is a privacy-first OCD tracker and daily journaling app. Record intrusive thoughts and compulsions, rate distress, journal reflections, and review your patterns over time — all kept local on your device.',
      url: links.site,
      image: `${links.site}icons/Icon-512.png`,
      downloadUrl: `${links.site}#download`,
      softwareHelp: links.issues,
      license: links.license,
      softwareVersion: '1.1.2',
      featureList: [
        'Daily journaling for dated reflections',
        'OCD self-tracking for obsessions and compulsions',
        'Distress level rating and trend analysis',
        'Local-first storage — no accounts or cloud sync',
        'Optional app lock with Face ID or device passcode',
        'Manual JSON export and import for backups'
      ],
      offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
      author: { '@type': 'Person', name: 'MaskedSyntax', url: 'https://github.com/maskedsyntax' },
      publisher: { '@type': 'Organization', name: 'MaskedSyntax', url: links.maskedsyntax }
    })}</script>`}
    {@html `<script type="application/ld+json">${JSON.stringify({
      '@context': 'https://schema.org',
      '@type': 'Organization',
      name: 'MaskedSyntax',
      url: links.maskedsyntax,
      logo: `${links.site}icons/Icon-512.png`,
      sameAs: ['https://github.com/maskedsyntax']
    })}</script>`}
    {@html `<script type="application/ld+json">${JSON.stringify({
      '@context': 'https://schema.org',
      '@type': 'WebSite',
      name: 'Patterns',
      url: links.site,
      publisher: { '@type': 'Organization', name: 'MaskedSyntax' }
    })}</script>`}
  {/if}

  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="author" content="MaskedSyntax" />
  <meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1" />
  <meta name="theme-color" content="#0A0A0A" />
  <meta name="color-scheme" content="dark light" />
  <meta property="og:site_name" content="Patterns" />
  <meta property="og:type" content="website" />
  <meta property="og:image" content="{links.site}icons/Icon-512.png" />
  <meta property="og:image:width" content="512" />
  <meta property="og:image:height" content="512" />
  <meta property="og:image:alt" content="Patterns app icon — a private OCD tracker and journaling app" />
  <meta property="og:locale" content="en_US" />
  <meta name="twitter:card" content="summary" />
  <meta name="twitter:image" content="{links.site}icons/Icon-512.png" />
  <meta name="twitter:image:alt" content="Patterns app icon" />
  <meta name="mobile-web-app-capable" content="yes" />
  <meta name="apple-mobile-web-app-capable" content="yes" />
  <meta name="apple-mobile-web-app-status-bar-style" content="black" />
  <meta name="apple-mobile-web-app-title" content="Patterns" />
  <link rel="apple-touch-icon" href="/icons/Icon-192.png" />
</svelte:head>

<Navbar />
<AppInstallBanner />
<main>
  {@render children()}
</main>

<style>
  main {
    padding-top: 68px;
  }
</style>
