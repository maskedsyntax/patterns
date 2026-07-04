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
        'Patterns — OCD Tracker & Journal',
        'Patterns OCD Journaling',
        'Patterns ERP Journal'
      ],
      applicationCategory: 'HealthApplication',
      applicationSubCategory: 'Mental Health',
      operatingSystem: 'iOS, Android, macOS, Windows, Linux',
      description:
        'Patterns is a privacy-first OCD tracker and daily journaling app for iPhone, Android, Mac, Windows, and Linux, built to support Exposure and Response Prevention (ERP). Record intrusive thoughts and compulsions, rate distress, delay urges, journal reflections, and review your patterns over time — all kept local on your device.',
      url: links.site,
      image: site.ogImage,
      screenshot: [
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
      availableOnDevice: ['iPhone', 'Android phone', 'Mac', 'Windows PC', 'Linux desktop'],
      featureList: [
        'Private OCD journal for dated reflections',
        'OCD self-tracking for obsessions, compulsions, triggers, and responses',
        'Distress (SUDS 0–10) rating and trend analysis',
        'Compulsion Delay Tool to support ERP practice',
        'Mobile app for iPhone and Android',
        'Local-first storage — no accounts or cloud sync',
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
      logo: `${links.site}icons/Icon-512.png`,
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
        'Download Patterns, a private OCD tracker and journaling app for iPhone, Android, Mac, Windows, and Linux.',
      primaryImageOfPage: {
        '@type': 'ImageObject',
        url: `${links.site}assets/mockups/feature-graphic.jpg`,
        width: 1024,
        height: 500
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
  title="Patterns — Private OCD Tracker & ERP Journal App for iPhone"
  description="Patterns is a private OCD tracker and ERP journal app for iPhone, Android, Mac, Windows, and Linux. Track obsessions, compulsions, triggers, and distress levels, delay urges, and see your patterns — local-first with no accounts or cloud uploads."
  keywords="OCD tracker app, OCD journal app, ERP journal app, exposure response prevention app, intrusive thoughts tracker, compulsion tracker, distress tracking app, private journaling app, mental health journal, obsessive compulsive self-tracking, local-first journal, OCD app for iPhone, OCD tracking app for Android"
  {jsonLd}
/>

<Hero onDownload={scrollToDownload} />
<Understanding />
<Features />
<Preview />
<BuiltForErp />
<Download />
<Support />
<Footer />
