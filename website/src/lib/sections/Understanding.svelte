<script lang="ts">
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import AnimatedOnScroll from '$lib/components/AnimatedOnScroll.svelte';
  import { ArrowRight } from 'lucide-svelte';

  const steps = [
    { label: 'Obsession', note: 'An intrusive thought latches on' },
    { label: 'Distress', note: 'Anxiety spikes fast' },
    { label: 'Compulsion', note: 'You act to feel safe' },
    { label: 'Relief', note: 'It fades — briefly' }
  ];
</script>

<section class="understanding section-pad content-below-fold" aria-labelledby="understanding-title">
  <ContentContainer>
    <AnimatedOnScroll>
      <div class="header">
        <span class="eyebrow">You're not alone</span>
        <h2 id="understanding-title" class="title serif">
          OCD is a loop.<br />Naming it is how you loosen it.
        </h2>
        <p class="subtitle">
          Intrusive thoughts aren't who you are. OCD keeps you stuck by making one
          thought feel like a threat — and making a ritual feel like the only way out.
          The relief never lasts, so the loop tightens. Seeing the pattern clearly is the
          first step to breaking it.
        </p>
      </div>
    </AnimatedOnScroll>

    <AnimatedOnScroll delay={100}>
      <ul class="cycle" aria-label="The OCD cycle">
        {#each steps as step, i}
          <li class="step">
            <span class="num">{i + 1}</span>
            <span class="step-label">{step.label}</span>
            <span class="step-note">{step.note}</span>
          </li>
          {#if i < steps.length - 1}
            <li class="arrow" aria-hidden="true"><ArrowRight size={18} /></li>
          {/if}
        {/each}
      </ul>
    </AnimatedOnScroll>

    <AnimatedOnScroll delay={150}>
      <div class="cta-row">
        <a href="/ocd" class="link-pill">Understand the OCD cycle <ArrowRight size={16} /></a>
        <a href="/erp" class="link-pill ghost">How ERP helps <ArrowRight size={16} /></a>
      </div>
    </AnimatedOnScroll>
  </ContentContainer>
</section>

<style>
  .understanding {
    background: var(--bg);
  }

  .header {
    text-align: center;
    max-width: 680px;
    margin: 0 auto 48px;
  }

  .eyebrow {
    display: inline-block;
    padding: 6px 14px;
    border-radius: 100px;
    border: 1px solid color-mix(in srgb, var(--accent) 25%, transparent);
    font-size: 12px;
    font-weight: 600;
    color: var(--accent);
    letter-spacing: 1.5px;
    text-transform: uppercase;
  }

  .title {
    margin: 20px 0 0;
    font-size: 44px;
    line-height: 1.12;
  }

  .subtitle {
    margin: 20px auto 0;
    max-width: 600px;
    font-size: 18px;
    line-height: 1.65;
    color: var(--text-secondary);
  }

  .cycle {
    display: flex;
    flex-wrap: wrap;
    align-items: stretch;
    justify-content: center;
    gap: 12px;
    margin: 0 auto;
    padding: 0;
    max-width: 880px;
    list-style: none;
  }

  .step {
    flex: 1 1 170px;
    display: flex;
    flex-direction: column;
    gap: 6px;
    padding: 20px;
    border-radius: 16px;
    border: 1px solid color-mix(in srgb, var(--border) 55%, transparent);
    background: var(--surface);
  }

  .num {
    width: 24px;
    height: 24px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    font-size: 12px;
    font-weight: 700;
    color: #000;
    background: var(--accent);
  }

  .step-label {
    font-size: 16px;
    font-weight: 700;
    color: var(--text);
  }

  .step-note {
    font-size: 13px;
    line-height: 1.45;
    color: var(--text-secondary);
  }

  .arrow {
    display: flex;
    align-items: center;
    color: color-mix(in srgb, var(--accent) 70%, transparent);
  }

  .cta-row {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 14px;
    margin-top: 40px;
  }

  .link-pill {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 12px 22px;
    border-radius: 100px;
    font-size: 15px;
    font-weight: 600;
    color: #000;
    background: var(--accent);
    transition: opacity 0.2s, background 0.2s, color 0.2s;
  }

  .link-pill:hover {
    opacity: 0.9;
  }

  .link-pill.ghost {
    color: var(--text);
    background: transparent;
    border: 1px solid color-mix(in srgb, var(--border) 80%, transparent);
  }

  .link-pill.ghost:hover {
    border-color: color-mix(in srgb, var(--accent) 55%, transparent);
    color: var(--accent);
    opacity: 1;
  }

  @media (max-width: 760px) {
    .arrow {
      display: none;
    }

    .step {
      flex-basis: calc(50% - 12px);
    }
  }

  @media (max-width: 599px) {
    .title {
      font-size: 30px;
    }

    .subtitle {
      font-size: 16px;
    }
  }
</style>
