<script lang="ts">
  import Seo from '$lib/components/Seo.svelte';
  import Faq from '$lib/sections/Faq.svelte';
  import { faqs } from '$lib/data/faq';
  import { links } from '$lib/data/links';

  const jsonLd = [
    {
      '@context': 'https://schema.org',
      '@type': 'FAQPage',
      mainEntity: faqs.map((f) => ({
        '@type': 'Question',
        name: f.question,
        acceptedAnswer: { '@type': 'Answer', text: f.answer }
      }))
    },
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: 'Home', item: links.site },
        { '@type': 'ListItem', position: 2, name: 'FAQ', item: `${links.site}faq` }
      ]
    }
  ];
</script>

<Seo
  title="FAQ - OCD, ERP & Privacy | Patterns"
  description="Common questions about Patterns: is it a replacement for therapy, what is OCD and ERP, how the Compulsion Delay Tool and distress scale work, privacy, platforms, and pricing."
  path="faq"
  {jsonLd}
/>

<Faq />
