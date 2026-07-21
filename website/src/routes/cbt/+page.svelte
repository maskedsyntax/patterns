<script lang="ts">
  import Seo from '$lib/components/Seo.svelte';
  import CbtGuide from '$lib/sections/CbtGuide.svelte';
  import { links } from '$lib/data/links';

  const jsonLd = [
    {
      '@context': 'https://schema.org',
      '@type': 'MedicalWebPage',
      name: 'CBT for OCD - how cognitive behavioral therapy and ERP work',
      description:
        'A plain-language guide to CBT for OCD: what cognitive behavioral therapy is, why ERP (exposure and response prevention) is the CBT approach with the strongest evidence for OCD, and how the Patterns CBT and ERP app supports that work between sessions.',
      url: `${links.site}cbt`,
      about: { '@type': 'MedicalCondition', name: 'Obsessive-Compulsive Disorder' },
      isPartOf: { '@type': 'WebSite', name: 'Patterns', url: links.site }
    },
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: 'Home', item: links.site },
        { '@type': 'ListItem', position: 2, name: 'CBT for OCD', item: `${links.site}cbt` }
      ]
    }
  ];
</script>

<Seo
  title="CBT App for OCD - ERP & Cognitive Behavioral Therapy | Patterns"
  description="Looking for a CBT app for OCD? Patterns is built around ERP - the cognitive behavioral therapy proven for OCD. Track compulsions and practice between sessions."
  keywords="cbt app, cbt app for ocd, cbt for ocd, cognitive behavioral therapy app, erp app, ocd app, cbt therapy app"
  path="cbt"
  {jsonLd}
/>

<CbtGuide />
