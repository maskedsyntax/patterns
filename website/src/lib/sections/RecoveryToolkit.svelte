<script lang="ts">
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import AnimatedOnScroll from '$lib/components/AnimatedOnScroll.svelte';
  import { freeTools, proTools } from '$lib/data/toolkit';
  import { ArrowRight, Check, Lock } from 'lucide-svelte';

  // Show a representative slice on the homepage; the full set lives on /toolkit.
  const proPreview = proTools.slice(0, 6);
</script>

<section
  id="toolkit"
  class="toolkit section-pad section-scroll-margin content-below-fold"
  aria-labelledby="toolkit-title"
>
  <ContentContainer>
    <AnimatedOnScroll>
      <div class="header">
        <span class="eyebrow">Recovery toolkit</span>
        <h2 id="toolkit-title" class="title serif">
          Beyond tracking:<br />tools to actually practise recovery.
        </h2>
        <p class="subtitle">
          Patterns now includes a full recovery toolkit built around ERP - the same moves
          a therapist would guide you through, turned into a calm daily habit you can keep
          on your own terms. Start free, and unlock the rest when you are ready.
        </p>
      </div>
    </AnimatedOnScroll>

    <AnimatedOnScroll delay={80}>
      <div class="tier">
        <div class="tier-head">
          <h3>Free tools</h3>
          <span class="pill free">Included</span>
        </div>
        <div class="grid">
          {#each freeTools as tool}
            {@const Icon = tool.icon}
            <article class="card">
              <div class="icon-wrap">
                <Icon size={22} color="var(--accent)" strokeWidth={1.75} />
              </div>
              <h4>{tool.title}</h4>
              <p>{tool.description}</p>
            </article>
          {/each}
        </div>
      </div>
    </AnimatedOnScroll>

    <AnimatedOnScroll delay={120}>
      <div class="tier">
        <div class="tier-head">
          <h3>Patterns Pro tools</h3>
          <span class="pill pro"><Lock size={12} /> One-time unlock</span>
        </div>
        <div class="grid">
          {#each proPreview as tool}
            {@const Icon = tool.icon}
            <article class="card pro-card">
              <div class="icon-wrap">
                <Icon size={22} color="var(--accent)" strokeWidth={1.75} />
              </div>
              <h4>{tool.title}</h4>
              <p>{tool.description}</p>
            </article>
          {/each}
        </div>
      </div>
    </AnimatedOnScroll>

    <AnimatedOnScroll delay={150}>
      <div class="pro-banner">
        <div class="pro-copy">
          <h3>Patterns Pro</h3>
          <p>
            Move beyond tracking and practise recovery. A one-time unlock, yours for good -
            no subscription, no account, and the same privacy promise as everything else.
          </p>
          <ul class="pro-points">
            <li><Check size={16} /> Exposure hierarchy builder &amp; exposure materials</li>
            <li><Check size={16} /> Urge surfing &amp; response-prevention trackers</li>
            <li><Check size={16} /> Structured ERP programs &amp; uncertainty training</li>
            <li><Check size={16} /> Action planner, behavioral experiments &amp; recovery metrics</li>
          </ul>
        </div>
        <div class="pro-actions">
          <a href="/toolkit" class="link-pill">See every tool <ArrowRight size={16} /></a>
          <a href="#download" class="link-pill ghost">Download Patterns <ArrowRight size={16} /></a>
        </div>
      </div>
    </AnimatedOnScroll>
  </ContentContainer>
</section>

<style>
  .toolkit {
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
    margin: 16px auto 0;
    max-width: 620px;
    font-size: 17px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  .tier {
    margin-top: 40px;
  }

  .tier-head {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 20px;
  }

  .tier-head h3 {
    margin: 0;
    font-size: 20px;
    font-weight: 700;
  }

  .pill {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 4px 11px;
    border-radius: 100px;
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 0.02em;
  }

  .pill.free {
    color: var(--text-secondary);
    border: 1px solid color-mix(in srgb, var(--border) 60%, transparent);
  }

  .pill.pro {
    color: var(--accent);
    background: color-mix(in srgb, var(--accent) 12%, transparent);
  }

  .grid {
    display: grid;
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .card {
    padding: 24px;
    border-radius: 16px;
    border: 1px solid color-mix(in srgb, var(--border) 50%, transparent);
    background: var(--surface);
    height: 100%;
    transition: border-color 0.25s;
  }

  .card:hover {
    border-color: color-mix(in srgb, var(--accent) 20%, transparent);
  }

  .pro-card {
    background: color-mix(in srgb, var(--surface) 70%, var(--accent) 4%);
  }

  .icon-wrap {
    width: 44px;
    height: 44px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;
    background: color-mix(in srgb, var(--accent) 10%, transparent);
    margin-bottom: 16px;
  }

  .card h4 {
    margin: 0;
    font-size: 16px;
    font-weight: 700;
  }

  .card p {
    margin: 8px 0 0;
    font-size: 14px;
    line-height: 1.55;
    color: var(--text-secondary);
  }

  .pro-banner {
    margin-top: 48px;
    padding: 36px;
    border-radius: 20px;
    border: 1px solid color-mix(in srgb, var(--accent) 22%, transparent);
    background: color-mix(in srgb, var(--accent) 6%, transparent);
    display: flex;
    flex-direction: column;
    gap: 28px;
  }

  .pro-copy h3 {
    margin: 0;
    font-size: 24px;
    font-weight: 700;
  }

  .pro-copy p {
    margin: 12px 0 0;
    max-width: 620px;
    font-size: 16px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  .pro-points {
    margin: 20px 0 0;
    padding: 0;
    list-style: none;
    display: grid;
    gap: 10px;
  }

  .pro-points li {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    font-size: 14px;
    line-height: 1.5;
    color: var(--text);
  }

  .pro-points :global(svg) {
    flex-shrink: 0;
    margin-top: 2px;
    color: var(--accent);
  }

  .pro-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
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
    transition: opacity 0.2s, border-color 0.2s, color 0.2s;
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

  @media (min-width: 600px) {
    .grid {
      grid-template-columns: repeat(2, 1fr);
    }
  }

  @media (min-width: 1024px) {
    .grid {
      grid-template-columns: repeat(3, 1fr);
    }

    .pro-banner {
      flex-direction: row;
      align-items: center;
      justify-content: space-between;
    }

    .pro-actions {
      flex-direction: column;
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
