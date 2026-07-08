<script lang="ts">
  import Seo from '$lib/components/Seo.svelte';
  import Hero from '$lib/sections/Hero.svelte';
  import Understanding from '$lib/sections/Understanding.svelte';
  import Features from '$lib/sections/Features.svelte';
  import Preview from '$lib/sections/Preview.svelte';
  import BuiltForErp from '$lib/sections/BuiltForErp.svelte';
  import Download from '$lib/sections/Download.svelte';
  import Support from '$lib/sections/Support.svelte';
  import Footer from '$lib/sections/Footer.svelte';
  import { links } from '$lib/data/links';
  import { site } from '$lib/data/site';

  const jsonLd = [
    {
      '@context': 'https://schema.org',
      '@type': 'SoftwareApplication',
      name: 'Patterns',
      alternateName: [
        'Patterns - OCD Tracker & Journal',
        'Patterns OCD Journaling',
        'Patterns ERP Journal'
      ],
      applicationCategory: 'HealthApplication',
      applicationSubCategory: 'Mental Health',
      operatingSystem: 'iOS, Android, macOS, Windows, Linux',
      description:
        'Patterns is a privacy-first OCD tracker and daily journaling app for iOS, Android, macOS, Windows, and Linux, built to support Exposure and Response Prevention (ERP). Record intrusive thoughts and compulsions, rate distress, delay urges, journal reflections, and review your patterns over time - all kept local on your device.',
      url: links.site,
      image: site.ogImage,
      screenshot: [
        `${links.site}assets/website-cta-1200.jpg`,
        `${links.site}assets/mockups/feature-graphic.jpg`,
        `${links.site}assets/mockups/frame-1.jpg`,
        `${links.site}assets/mockups/desktop-1.jpg`
      ],
      downloadUrl: `${links.site}#download`,
      installUrl: links.ios,
      sameAs: [links.ios, links.playStore, links.github],
      softwareHelp: links.issues,
      license: links.license,
      softwareVersion: site.appVersion,
      availableOnDevice: ['iOS devices', 'Android devices', 'Mac', 'Windows PC', 'Linux desktop'],
      featureList: [
        'Private OCD journal for dated reflections',
        'OCD self-tracking for obsessions, compulsions, triggers, and responses',
        'Distress (SUDS 0–10) rating and trend analysis',
        'Compulsion Delay Tool to support ERP practice',
        'Mobile app for iOS and Android',
        'Local-first storage - no accounts or cloud sync',
        'Optional app lock with Face ID or device passcode',
        'Manual JSON export and import for backups'
      ],
      offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
      author: { '@type': 'Person', name: site.author.name, url: site.author.url },
      publisher: { '@type': 'Organization', name: site.publisher.name, url: site.publisher.url }
    },
    {
      '@context': 'https://schema.org',
      '@type': 'Organization',
      name: 'MaskedSyntax',
      url: links.maskedsyntax,
      logo: `${links.site}assets/logo.png`,
      sameAs: ['https://github.com/maskedsyntax']
    },
    {
      '@context': 'https://schema.org',
      '@type': 'WebSite',
      name: 'Patterns',
      url: links.site,
      description:
        'Patterns is the official website for the private OCD tracker, ERP journal, and mental health journaling app.',
      inLanguage: 'en',
      publisher: { '@type': 'Organization', name: 'MaskedSyntax' }
    },
    {
      '@context': 'https://schema.org',
      '@type': 'WebPage',
      name: 'Patterns OCD Tracker & Journal',
      url: links.site,
      description:
        'Download Patterns, a private OCD tracker and journaling app for iOS, Android, macOS, Windows, and Linux.',
      primaryImageOfPage: {
        '@type': 'ImageObject',
        url: `${links.site}assets/website-cta-1200.jpg`,
        width: 1536,
        height: 1024
      },
      about: [
        { '@type': 'MedicalCondition', name: 'Obsessive-Compulsive Disorder' },
        { '@type': 'Thing', name: 'Exposure and Response Prevention' },
        { '@type': 'Thing', name: 'OCD tracking app' },
        { '@type': 'Thing', name: 'Private journaling app' }
      ],
      isPartOf: { '@type': 'WebSite', name: 'Patterns', url: links.site }
    }
  ];

  function scrollToDownload() {
    document.getElementById('download')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }
</script>

<Seo
  title="Patterns - Private OCD Tracker & ERP Journal App"
  description="Patterns is a private OCD tracker and ERP journal app for iOS, Android, macOS, Windows, and Linux. Track obsessions, compulsions, triggers, and distress levels, delay urges, and see your patterns - local-first with no accounts or cloud uploads."
  keywords="OCD tracker app, OCD journal app, ERP journal app, exposure response prevention app, intrusive thoughts tracker, compulsion tracker, distress tracking app, private journaling app, mental health journal, obsessive compulsive self-tracking, local-first journal, OCD app for iOS, OCD tracking app for Android, OCD journal app for desktop"
  {jsonLd}
/>

<svelte:head>
  <link
    rel="preload"
    as="image"
    href="/assets/website-cta-800.jpg"
    imagesrcset="/assets/website-cta-480.jpg 480w, /assets/website-cta-800.jpg 800w, /assets/website-cta-1200.jpg 1200w"
    imagesizes="(max-width: 599px) 100vw, (max-width: 1023px) 980px, 1160px"
    fetchpriority="high"
  />
</svelte:head>

<Hero onDownload={scrollToDownload} />
<Understanding />
<Features />
<Preview />
<BuiltForErp />
<Download />
<Support />
<Footer />
