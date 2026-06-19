<script lang="ts">
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import AnimatedOnScroll from '$lib/components/AnimatedOnScroll.svelte';
  import MedicalDisclaimer from '$lib/components/MedicalDisclaimer.svelte';
  import { faqs } from '$lib/data/faq';
  import { HelpCircle, Plus } from 'lucide-svelte';
</script>

<section class="faq section-pad" aria-labelledby="faq-title">
  <ContentContainer>
    <AnimatedOnScroll>
      <div class="head">
        <div class="icon-tile">
          <HelpCircle size={34} color="var(--accent)" strokeWidth={1.75} />
        </div>
        <p class="eyebrow">Frequently asked questions</p>
        <h1 id="faq-title" class="title serif">Questions, answered.</h1>
        <p class="intro">
          A few common questions about OCD, ERP, and how Patterns works — and what it
          isn't.
        </p>
      </div>

      <div class="list">
        {#each faqs as item}
          <details class="item">
            <summary>
              <span>{item.question}</span>
              <Plus class="chev" size={20} />
            </summary>
            <p>{item.answer}</p>
          </details>
        {/each}
      </div>

      <div class="disclaimer-wrap">
        <MedicalDisclaimer />
      </div>

      <nav class="related" aria-label="Related pages">
        <a href="/ocd" class="related-card">Understanding OCD</a>
        <a href="/erp" class="related-card">How ERP works in Patterns</a>
      </nav>

      <div class="back-wrap">
        <a href="/">← Back to Home</a>
      </div>
    </AnimatedOnScroll>
  </ContentContainer>
</section>

<style>
  .faq {
    background: var(--surface);
  }

  .head {
    max-width: 680px;
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
    max-width: 560px;
    font-size: 18px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  .list {
    max-width: 760px;
    margin: 0 auto;
  }

  .item {
    border-bottom: 1px solid color-mix(in srgb, var(--border) 55%, transparent);
  }

  .item summary {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 16px;
    padding: 22px 4px;
    cursor: pointer;
    list-style: none;
    font-size: 18px;
    font-weight: 600;
    color: var(--text);
  }

  .item summary::-webkit-details-marker {
    display: none;
  }

  .item summary :global(.chev) {
    flex-shrink: 0;
    color: var(--accent);
    transition: transform 0.25s ease;
  }

  .item[open] summary :global(.chev) {
    transform: rotate(45deg);
  }

  .item p {
    margin: 0;
    padding: 0 4px 24px;
    font-size: 16px;
    line-height: 1.65;
    color: var(--text-secondary);
  }

  .disclaimer-wrap {
    max-width: 760px;
    margin: 48px auto 0;
  }

  .related {
    max-width: 760px;
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

    .item summary {
      font-size: 16px;
    }
  }
</style>
