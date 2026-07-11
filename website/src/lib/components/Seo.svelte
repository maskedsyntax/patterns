<script lang="ts">
  import { links } from '$lib/data/links';
  import { site } from '$lib/data/site';

  let {
    title,
    description,
    /** Path relative to the site root, no leading slash. '' for the homepage. */
    path = '',
    image = site.ogImage,
    imageAlt = 'Patterns - a private OCD tracker and journaling app',
    ogType = 'website',
    twitterCard = 'summary_large_image',
    keywords,
    jsonLd = [],
    article
  }: {
    title: string;
    description: string;
    path?: string;
    image?: string;
    imageAlt?: string;
    ogType?: string;
    twitterCard?: string;
    keywords?: string;
    jsonLd?: Record<string, unknown>[];
    /** Extra Open Graph metadata for article pages (blog posts). */
    article?: { publishedTime?: string; modifiedTime?: string; author?: string };
  } = $props();

  const url = $derived(`${links.site}${path}`);
</script>

<svelte:head>
  <title>{title}</title>
  <meta name="description" content={description} />
  {#if keywords}
    <meta name="keywords" content={keywords} />
  {/if}
  <link rel="canonical" href={url} />

  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <meta property="og:url" content={url} />
  <meta property="og:type" content={ogType} />
  <meta property="og:image" content={image} />
  <meta property="og:image:width" content={String(site.ogImageWidth)} />
  <meta property="og:image:height" content={String(site.ogImageHeight)} />
  <meta property="og:image:alt" content={imageAlt} />

  {#if article}
    {#if article.publishedTime}
      <meta property="article:published_time" content={article.publishedTime} />
    {/if}
    {#if article.modifiedTime}
      <meta property="article:modified_time" content={article.modifiedTime} />
    {/if}
    {#if article.author}
      <meta property="article:author" content={article.author} />
    {/if}
  {/if}

  <meta name="twitter:card" content={twitterCard} />
  <meta name="twitter:title" content={title} />
  <meta name="twitter:description" content={description} />
  <meta name="twitter:image" content={image} />
  <meta name="twitter:image:alt" content={imageAlt} />

  {#each jsonLd as block}
    {@html `<script type="application/ld+json">${JSON.stringify(block)}</script>`}
  {/each}
</svelte:head>
