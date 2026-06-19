<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { LucideIcon } from '$lib/types/icons';
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import AnimatedOnScroll from '$lib/components/AnimatedOnScroll.svelte';
  import MedicalDisclaimer from '$lib/components/MedicalDisclaimer.svelte';
  import { ArrowRight } from 'lucide-svelte';

  type RelatedLink = { label: string; href: string };

  let {
    icon,
    eyebrow,
    title,
    intro,
    children,
    related = []
  }: {
    icon: LucideIcon;
    eyebrow: string;
    title: string;
    intro: string;
    children: Snippet;
    related?: RelatedLink[];
  } = $props();

  const Icon = $derived(icon);
</script>

<article class="guide section-pad">
  <ContentContainer>
    <AnimatedOnScroll>
      <div class="head">
        <div class="icon-tile">
          <Icon size={34} color="var(--accent)" strokeWidth={1.75} />
        </div>
        <p class="eyebrow">{eyebrow}</p>
        <h1 class="title serif">{title}</h1>
        <p class="intro">{intro}</p>
      </div>

      <div class="prose reading">
        {@render children()}
      </div>

      <div class="disclaimer-wrap">
        <MedicalDisclaimer />
      </div>

      {#if related.length}
        <nav class="related" aria-label="Related pages">
          {#each related as link}
            <a href={link.href} class="related-card">
              <span>{link.label}</span>
              <ArrowRight size={18} />
            </a>
          {/each}
        </nav>
      {/if}

      <div class="back-wrap">
        <a href="/">← Back to Home</a>
      </div>
    </AnimatedOnScroll>
  </ContentContainer>
</article>

<style>
  .guide {
    background: var(--surface);
  }

  .head {
    max-width: 720px;
    margin: 0 auto 48px;
    text-align: center;
  }

  .icon-tile {
    width: 80px;
    height: 80px;
    margin: 0 auto 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 20px;
    background: color-mix(in srgb, var(--accent) 10%, transparent);
  }

  .eyebrow {
    margin: 0 0 12px;
    font-size: 13px;
    font-weight: 600;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--accent);
  }

  .title {
    margin: 0;
    font-size: 48px;
    line-height: 1.1;
  }

  .intro {
    margin: 20px auto 0;
    max-width: 620px;
    font-size: 19px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  /* Long-form prose. Children supply <h2>, <p>, <ul>, etc. */
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

  .prose :global(h3) {
    margin: 32px 0 10px;
    font-size: 20px;
    color: var(--text);
  }

  .prose :global(p) {
    margin: 0 0 18px;
  }

  .prose :global(strong) {
    color: var(--text);
    font-weight: 600;
  }

  .prose :global(a) {
    color: var(--accent);
    text-decoration: underline;
    text-underline-offset: 3px;
  }

  .prose :global(ul) {
    margin: 0 0 18px;
    padding-left: 22px;
  }

  .prose :global(li) {
    margin: 0 0 10px;
  }

  .prose :global(.lead) {
    font-size: 20px;
    line-height: 1.6;
    color: var(--text);
  }

  /* Reusable "cycle" / step visual used inside guides. */
  .prose :global(.cycle) {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    align-items: stretch;
    margin: 8px 0 28px;
  }

  .prose :global(.cycle-step) {
    flex: 1 1 140px;
    padding: 16px;
    border-radius: 14px;
    border: 1px solid color-mix(in srgb, var(--border) 55%, transparent);
    background: color-mix(in srgb, var(--bg) 40%, transparent);
  }

  .prose :global(.cycle-step h4) {
    margin: 0 0 6px;
    font-size: 15px;
    font-weight: 700;
    color: var(--text);
  }

  .prose :global(.cycle-step p) {
    margin: 0;
    font-size: 14px;
    line-height: 1.5;
  }

  /* Callout box for "How Patterns helps" moments. */
  .prose :global(.callout) {
    margin: 28px 0;
    padding: 24px;
    border-radius: 16px;
    border: 1px solid color-mix(in srgb, var(--accent) 22%, transparent);
    background: color-mix(in srgb, var(--accent) 6%, transparent);
  }

  .prose :global(.callout h3) {
    margin: 0 0 8px;
  }

  .prose :global(.callout p:last-child) {
    margin-bottom: 0;
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

  @media (min-width: 600px) {
    .related {
      grid-template-columns: repeat(2, 1fr);
    }
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

  @media (max-width: 599px) {
    .title {
      font-size: 34px;
    }

    .intro {
      font-size: 16px;
    }

    .prose {
      font-size: 16px;
    }

    .prose :global(h2) {
      font-size: 24px;
    }
  }
</style>
