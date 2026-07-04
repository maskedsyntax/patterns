<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import '../app.css';
  import AppInstallBanner from '$lib/components/AppInstallBanner.svelte';
  import Navbar from '$lib/components/Navbar.svelte';
  import { theme } from '$lib/stores/theme';

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
</script>

<svelte:head>
  <!-- Global, always-on tags. Per-page title/description/canonical/OG/JSON-LD
       are set by the <Seo> component in each route. -->
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="author" content="MaskedSyntax" />
  <meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1" />
  <meta name="googlebot" content="index, follow, max-image-preview:large, max-snippet:-1" />
  <meta name="application-name" content="Patterns" />
  <meta name="theme-color" content="#0A0A0A" />
  <meta name="color-scheme" content="dark light" />
  <meta property="og:site_name" content="Patterns" />
  <meta property="og:locale" content="en_US" />
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
