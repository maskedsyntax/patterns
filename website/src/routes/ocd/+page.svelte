<script lang="ts">
  import Seo from '$lib/components/Seo.svelte';
  import OcdGuide from '$lib/sections/OcdGuide.svelte';
  import { links } from '$lib/data/links';

  const jsonLd = [
    {
      '@context': 'https://schema.org',
      '@type': 'MedicalWebPage',
      name: 'Understanding OCD - the obsessive-compulsive cycle',
      description:
        'A calm, plain-language explanation of OCD: what obsessions and compulsions are, how the OCD cycle reinforces itself, and how self-tracking helps you see the pattern.',
      url: `${links.site}ocd`,
      about: { '@type': 'MedicalCondition', name: 'Obsessive-Compulsive Disorder' },
      isPartOf: { '@type': 'WebSite', name: 'Patterns', url: links.site }
    },
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: 'Home', item: links.site },
        { '@type': 'ListItem', position: 2, name: 'Understanding OCD', item: `${links.site}ocd` }
      ]
    }
  ];
</script>

<Seo
  title="Understanding OCD - Obsessions, Compulsions & the OCD Cycle | Patterns"
  description="What is OCD, really? A clear, empathetic guide to obsessions, compulsions, and the OCD cycle - and how the Patterns OCD app helps you loosen its grip."
  keywords="ocd app, ocd tracker app, understanding ocd, ocd cycle, obsessions and compulsions, intrusive thoughts, ocd journal app"
  path="ocd"
  {jsonLd}
/>

<OcdGuide />
