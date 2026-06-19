<script lang="ts">
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import AnimatedOnScroll from '$lib/components/AnimatedOnScroll.svelte';
  import { Timer, Gauge, TrendingUp, ArrowRight } from 'lucide-svelte';

  const mappings = [
    {
      icon: Timer,
      title: 'Delay the urge',
      description:
        'The Compulsion Delay Tool helps you pause and ride out a wave instead of acting on it — the core move of response prevention.'
    },
    {
      icon: Gauge,
      title: 'Rate your distress',
      description:
        'Log distress on a 0–10 scale (SUDS), the same language used in ERP, and watch anxiety rise and fall over time.'
    },
    {
      icon: TrendingUp,
      title: 'See it get easier',
      description:
        'Charts and history make progress visible, so you arrive at therapy sessions with clear, concrete notes.'
    }
  ];
</script>

<section class="erp section-pad content-below-fold" aria-labelledby="erp-title">
  <ContentContainer>
    <AnimatedOnScroll>
      <div class="header">
        <span class="eyebrow">Designed around ERP</span>
        <h2 id="erp-title" class="title serif">Built to support the work that works.</h2>
        <p class="subtitle">
          Exposure and Response Prevention is the most evidence-based therapy for OCD.
          Patterns turns its core moves into a calm daily habit you can keep between
          sessions.
        </p>
      </div>
    </AnimatedOnScroll>

    <div class="grid">
      {#each mappings as item, i}
        {@const Icon = item.icon}
        <AnimatedOnScroll delay={i * 100}>
          <article class="card">
            <div class="icon-wrap">
              <Icon size={24} color="var(--accent)" strokeWidth={1.75} />
            </div>
            <h3>{item.title}</h3>
            <p>{item.description}</p>
          </article>
        </AnimatedOnScroll>
      {/each}
    </div>

    <AnimatedOnScroll delay={150}>
      <div class="cta-row">
        <a href="/erp" class="link-pill">Learn how ERP works in Patterns <ArrowRight size={16} /></a>
      </div>
    </AnimatedOnScroll>
  </ContentContainer>
</section>

<style>
  .erp {
    background: var(--bg);
  }

  .header {
    text-align: center;
    max-width: 640px;
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
    margin: 16px auto 0;
    max-width: 560px;
    font-size: 17px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  .grid {
    display: grid;
    grid-template-columns: 1fr;
    gap: 24px;
  }

  .card {
    padding: 32px;
    border-radius: 16px;
    border: 1px solid color-mix(in srgb, var(--border) 50%, transparent);
    background: var(--surface);
    height: 100%;
    transition: border-color 0.25s;
  }

  .card:hover {
    border-color: color-mix(in srgb, var(--accent) 20%, transparent);
  }

  .icon-wrap {
    width: 48px;
    height: 48px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;
    background: color-mix(in srgb, var(--accent) 10%, transparent);
    margin-bottom: 20px;
  }

  .card h3 {
    margin: 0;
    font-size: 18px;
    font-weight: 700;
  }

  .card p {
    margin: 10px 0 0;
    font-size: 14px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  .cta-row {
    display: flex;
    justify-content: center;
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
    transition: opacity 0.2s;
  }

  .link-pill:hover {
    opacity: 0.9;
  }

  @media (min-width: 600px) {
    .grid {
      grid-template-columns: repeat(3, 1fr);
    }
  }

  @media (max-width: 599px) {
    .title {
      font-size: 30px;
    }

    .subtitle {
      font-size: 15px;
    }
  }
</style>
