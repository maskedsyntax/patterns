<script lang="ts">
  import Seo from '$lib/components/Seo.svelte';
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import AnimatedOnScroll from '$lib/components/AnimatedOnScroll.svelte';
  import MedicalDisclaimer from '$lib/components/MedicalDisclaimer.svelte';
  import { postsByDate } from '$lib/data/blog';
  import { links } from '$lib/data/links';
  import { ArrowRight, ArrowLeft } from 'lucide-svelte';
  import type { PageData } from './$types';

  let { data }: { data: PageData } = $props();
  const post = $derived(data.post);

  const dateFmt = new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });

  // A couple of other posts to keep readers moving through the blog.
  const more = $derived(postsByDate.filter((p) => p.slug !== post.slug).slice(0, 2));

  const jsonLd = $derived([
    {
      '@context': 'https://schema.org',
      '@type': 'BlogPosting',
      headline: post.title,
      description: post.description,
      datePublished: post.date,
      dateModified: post.date,
      url: `${links.site}blog/${post.slug}`,
      author: { '@type': 'Person', name: 'Aftaab Siddiqui', url: links.maskedsyntax },
      publisher: { '@type': 'Organization', name: 'MaskedSyntax', url: links.maskedsyntax },
      mainEntityOfPage: { '@type': 'WebPage', '@id': `${links.site}blog/${post.slug}` },
      isPartOf: { '@type': 'Blog', name: 'The Patterns Blog', url: `${links.site}blog` }
    },
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: 'Home', item: links.site },
        { '@type': 'ListItem', position: 2, name: 'Blog', item: `${links.site}blog` },
        { '@type': 'ListItem', position: 3, name: post.title, item: `${links.site}blog/${post.slug}` }
      ]
    }
  ]);
</script>

<Seo
  title={`${post.title} | The Patterns Blog`}
  description={post.description}
  path={`blog/${post.slug}`}
  ogType="article"
  article={{ publishedTime: post.date, modifiedTime: post.date, author: 'Aftaab Siddiqui' }}
  {jsonLd}
/>

<article class="post section-pad">
  <ContentContainer>
    <AnimatedOnScroll>
      <a class="crumb" href="/blog"><ArrowLeft size={16} /> The Patterns blog</a>
      <header class="post-head">
        <div class="meta">
          <time datetime={post.date}>{dateFmt.format(new Date(post.date))}</time>
          <span aria-hidden="true">·</span>
          <span>{post.readingMinutes} min read</span>
        </div>
        <h1 class="title serif">{post.title}</h1>
        <p class="byline">Written by the person building Patterns.</p>
      </header>

      <div class="prose reading">
        <!-- eslint-disable-next-line svelte/no-at-html-tags -- trusted, in-repo content -->
        {@html post.content}
      </div>

      <div class="disclaimer-wrap">
        <MedicalDisclaimer />
      </div>

      {#if more.length}
        <nav class="related" aria-label="More posts">
          {#each more as p}
            <a href="/blog/{p.slug}" class="related-card">
              <span>{p.title}</span>
              <ArrowRight size={18} />
            </a>
          {/each}
        </nav>
      {/if}

      <div class="back-wrap"><a href="/blog">← All posts</a></div>
    </AnimatedOnScroll>
  </ContentContainer>
</article>

<style>
  .post {
    background: var(--surface);
  }

  .crumb {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 14px;
    font-weight: 600;
    color: var(--accent);
  }

  .post-head {
    max-width: 720px;
    margin: 24px auto 40px;
    text-align: center;
  }

  .meta {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    font-size: 13px;
    color: var(--text-secondary);
  }

  .title {
    margin: 14px 0 0;
    font-size: 44px;
    line-height: 1.12;
  }

  .byline {
    margin: 16px 0 0;
    font-size: 15px;
    color: var(--text-secondary);
  }

  .prose {
    max-width: 720px;
    margin: 0 auto;
    font-size: 17px;
    color: var(--text-secondary);
  }

  .prose :global(h2) {
    margin: 48px 0 16px;
    font-size: 28px;
    line-height: 1.2;
    color: var(--text);
  }

  .prose :global(p) {
    margin: 0 0 18px;
  }

  .prose :global(strong) {
    color: var(--text);
    font-weight: 600;
  }

  .prose :global(em) {
    color: var(--text);
  }

  .prose :global(a) {
    color: var(--accent);
    text-decoration: underline;
    text-underline-offset: 3px;
  }

  .prose :global(.lead) {
    font-size: 20px;
    line-height: 1.6;
    color: var(--text);
  }

  .prose :global(blockquote) {
    margin: 28px 0;
    padding: 4px 0 4px 22px;
    border-left: 3px solid var(--accent);
    font-size: 19px;
    line-height: 1.55;
    font-style: italic;
    color: var(--text);
  }

  .disclaimer-wrap {
    max-width: 720px;
    margin: 48px auto 0;
  }

  .related {
    max-width: 720px;
    margin: 32px auto 0;
    display: grid;
    gap: 12px;
    grid-template-columns: 1fr;
  }

  .related-card {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 18px 20px;
    border-radius: 14px;
    border: 1px solid color-mix(in srgb, var(--border) 55%, transparent);
    font-weight: 600;
    color: var(--text);
    transition: border-color 0.2s, color 0.2s;
  }

  .related-card:hover {
    border-color: color-mix(in srgb, var(--accent) 55%, transparent);
    color: var(--accent);
  }

  .back-wrap {
    text-align: center;
    margin-top: 48px;
  }

  .back-wrap a {
    font-weight: 600;
    color: var(--accent);
  }

  @media (min-width: 600px) {
    .related {
      grid-template-columns: repeat(2, 1fr);
    }
  }

  @media (max-width: 599px) {
    .title {
      font-size: 32px;
    }

    .prose {
      font-size: 16px;
    }

    .prose :global(h2) {
      font-size: 24px;
    }
  }
</style>
