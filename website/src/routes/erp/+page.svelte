<script lang="ts">
  import Seo from '$lib/components/Seo.svelte';
  import ErpGuide from '$lib/sections/ErpGuide.svelte';
  import { links } from '$lib/data/links';

  const jsonLd = [
    {
      '@context': 'https://schema.org',
      '@type': 'MedicalWebPage',
      name: 'ERP (Exposure and Response Prevention) & how Patterns helps',
      description:
        'A plain-language guide to ERP, the most evidence-based therapy for OCD - what exposure and response prevention mean, why delaying compulsions works, and how Patterns supports ERP practice between sessions.',
      url: `${links.site}erp`,
      about: { '@type': 'MedicalCondition', name: 'Obsessive-Compulsive Disorder' },
      isPartOf: { '@type': 'WebSite', name: 'Patterns', url: links.site }
    },
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: 'Home', item: links.site },
        { '@type': 'ListItem', position: 2, name: 'ERP & how Patterns helps', item: `${links.site}erp` }
      ]
    }
  ];
</script>

<Seo
  title="ERP App for OCD - Exposure & Response Prevention | Patterns"
  description="What is ERP (Exposure and Response Prevention)? Learn how this CBT-based OCD therapy works and how the Patterns ERP app supports your practice between sessions."
  keywords="erp app, erp app for ocd, exposure response prevention app, erp therapy app, ocd app, cbt app for ocd, compulsion delay tool"
  path="erp"
  {jsonLd}
/>

<ErpGuide />
