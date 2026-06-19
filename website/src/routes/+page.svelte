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
      alternateName: 'Patterns — OCD Tracker & Journal',
      applicationCategory: 'HealthApplication',
      applicationSubCategory: 'Mental Health',
      operatingSystem: 'iOS, macOS, Windows, Linux',
      description:
        'Patterns is a privacy-first OCD tracker and daily journaling app built to support Exposure and Response Prevention (ERP). Record intrusive thoughts and compulsions, rate distress, delay urges, journal reflections, and review your patterns over time — all kept local on your device.',
      url: links.site,
      image: site.ogImage,
      downloadUrl: `${links.site}#download`,
      softwareHelp: links.issues,
      license: links.license,
      softwareVersion: site.appVersion,
      featureList: [
        'Daily journaling for dated reflections',
        'OCD self-tracking for obsessions and compulsions',
        'Distress (SUDS 0–10) rating and trend analysis',
        'Compulsion Delay Tool to support ERP practice',
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
      publisher: { '@type': 'Organization', name: 'MaskedSyntax' }
    }
  ];

  function scrollToDownload() {
    document.getElementById('download')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }
</script>

<Seo
  title="Patterns — Private OCD Tracker & Journaling App for iPhone, Mac, Windows, Linux"
  description="Patterns is a private OCD tracker and journaling app built around ERP (Exposure and Response Prevention). Track obsessions, compulsions, and distress levels, delay urges, and see your patterns — calm, local-first, no accounts, no cloud."
  keywords="OCD tracker app, OCD journal, ERP therapy app, exposure response prevention, intrusive thoughts tracker, compulsion delay, private journaling app, mental health journal, obsessive compulsive self-tracking, local-first journal, OCD app for iPhone"
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
