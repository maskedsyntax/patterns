<script lang="ts">
  import Seo from '$lib/components/Seo.svelte';
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import AnimatedOnScroll from '$lib/components/AnimatedOnScroll.svelte';
  import MedicalDisclaimer from '$lib/components/MedicalDisclaimer.svelte';
  import { freeTools, proTools } from '$lib/data/toolkit';
  import { links } from '$lib/data/links';
  import { LayoutGrid, ArrowRight, Check, Lock } from 'lucide-svelte';

  const steps = [
    {
      title: 'Journal it',
      body: 'Capture intrusive thoughts, feelings, and daily reflections in a private, dated space. Naming a pattern is the first step to loosening its grip.'
    },
    {
      title: 'Track the moment',
      body: 'Log obsessions and compulsions as they happen and rate the distress on a 0–10 (SUDS) scale - the same language used in ERP.'
    },
    {
      title: 'Delay the urge',
      body: 'Use the Compulsion Delay tool to put a pause between urge and action, and watch the wave rise and fall without acting on it.'
    },
    {
      title: 'Practise recovery',
      body: 'Work through guided ERP and the recovery toolkit - exposure ladders, urge surfing, response prevention - at your own pace.'
    },
    {
      title: 'Review your patterns',
      body: 'Charts and recovery metrics turn your entries into trends, so progress becomes visible even when a single day feels like a loss.'
    }
  ];

  const jsonLd = [
    {
      '@context': 'https://schema.org',
      '@type': 'MedicalWebPage',
      name: 'The Patterns recovery toolkit - every tool, free and Pro',
      description:
        'A full tour of the Patterns recovery toolkit: guided ERP, compulsion delay, emergency toolkit, coping library, and the Patterns Pro tools for exposure hierarchies, urge surfing, response prevention, and more.',
      url: `${links.site}toolkit`,
      about: { '@type': 'MedicalCondition', name: 'Obsessive-Compulsive Disorder' },
      isPartOf: { '@type': 'WebSite', name: 'Patterns', url: links.site }
    },
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: 'Home', item: links.site },
        { '@type': 'ListItem', position: 2, name: 'Recovery toolkit', item: `${links.site}toolkit` }
      ]
    }
  ];
</script>

<Seo
  title="The Patterns Recovery Toolkit - Every Tool & Patterns Pro"
  description="Tour every tool in Patterns: guided ERP, compulsion delay, emergency toolkit, coping library, plus the Patterns Pro tools - exposure hierarchies, urge surfing, response prevention, structured programs, and recovery metrics."
  path="toolkit"
  keywords="OCD recovery toolkit, ERP tools app, exposure hierarchy app, urge surfing, response prevention tracker, compulsion delay, Patterns Pro"
  {jsonLd}
/>

<article class="toolkit section-pad">
  <ContentContainer>
    <AnimatedOnScroll>
      <div class="head">
        <div class="icon-tile">
          <LayoutGrid size={34} color="var(--accent)" strokeWidth={1.75} />
        </div>
        <p class="eyebrow">Recovery toolkit</p>
        <h1 class="title serif">Everything Patterns gives you to do the work.</h1>
        <p class="intro">
          Patterns started as a private OCD tracker. It grew into a full recovery toolkit
          built around ERP - the therapy that actually helps. Here is every tool, how the
          app fits together day to day, and exactly what is free versus what Patterns Pro
          unlocks.
        </p>
      </div>
    </AnimatedOnScroll>

    <AnimatedOnScroll delay={80}>
      <section class="block" aria-labelledby="how-title">
        <h2 id="how-title" class="block-title">How Patterns works, day to day</h2>
        <p class="block-sub">
          You do not have to use all of it. Most days are just a check-in. But when you
          need more, the toolkit follows the same rhythm ERP asks of you.
        </p>
        <ol class="steps">
          {#each steps as step, i}
            <li class="step">
              <span class="num">{i + 1}</span>
              <div>
                <h3>{step.title}</h3>
                <p>{step.body}</p>
              </div>
            </li>
          {/each}
        </ol>
      </section>
    </AnimatedOnScroll>

    <AnimatedOnScroll delay={100}>
      <section class="block" aria-labelledby="free-title">
        <div class="tier-head">
          <h2 id="free-title" class="block-title">Free tools</h2>
          <span class="pill free">Included, no account</span>
        </div>
        <p class="block-sub">
          Everything you need to start is free - the journal, the OCD tracker, distress
          charts, and these core recovery tools.
        </p>
        <div class="grid">
          {#each freeTools as tool}
            {@const Icon = tool.icon}
            <article class="card">
              <div class="icon-wrap">
                <Icon size={22} color="var(--accent)" strokeWidth={1.75} />
              </div>
              <h3>{tool.title}</h3>
              <p>{tool.description}</p>
            </article>
          {/each}
        </div>
      </section>
    </AnimatedOnScroll>

    <AnimatedOnScroll delay={120}>
      <section class="block" aria-labelledby="pro-title">
        <div class="tier-head">
          <h2 id="pro-title" class="block-title">Patterns Pro tools</h2>
          <span class="pill pro"><Lock size={12} /> One-time unlock</span>
        </div>
        <p class="block-sub">
          When you are ready to go deeper, Patterns Pro adds the structured ERP tools -
          the ones that turn tracking into a real recovery practice.
        </p>
        <div class="grid">
          {#each proTools as tool}
            {@const Icon = tool.icon}
            <article class="card pro-card">
              <div class="icon-wrap">
                <Icon size={22} color="var(--accent)" strokeWidth={1.75} />
              </div>
              <h3>{tool.title}</h3>
              <p>{tool.description}</p>
            </article>
          {/each}
        </div>
      </section>
    </AnimatedOnScroll>

    <AnimatedOnScroll delay={140}>
      <section class="pro-banner" aria-labelledby="unlock-title">
        <h2 id="unlock-title">A one-time unlock, yours for good</h2>
        <p>
          Patterns Pro is a single purchase - not a subscription. You own it, it works
          offline, and it keeps the same privacy promise as the rest of the app: nothing
          leaves your device. Buying Pro is also how a person with OCD gets to keep
          building this for everyone else, without ever turning your hardest moments into
          an ad.
        </p>
        <ul class="pro-points">
          <li><Check size={16} /> Every tool above, unlocked forever on your account</li>
          <li><Check size={16} /> No subscription, no login, no cloud</li>
          <li><Check size={16} /> Restore your purchase on any device you own</li>
        </ul>
        <div class="actions">
          <a href="/#download" class="link-pill">Download Patterns <ArrowRight size={16} /></a>
          <a href="/erp" class="link-pill ghost">How ERP works <ArrowRight size={16} /></a>
        </div>
      </section>
    </AnimatedOnScroll>

    <div class="disclaimer-wrap">
      <MedicalDisclaimer />
    </div>

    <nav class="related" aria-label="Related pages">
      <a href="/ocd" class="related-card"><span>Understanding the OCD cycle</span><ArrowRight size={18} /></a>
      <a href="/erp" class="related-card"><span>ERP &amp; how Patterns helps</span><ArrowRight size={18} /></a>
    </nav>

    <div class="back-wrap"><a href="/">← Back to Home</a></div>
  </ContentContainer>
</article>

<style>
  .toolkit {
    background: var(--surface);
  }

  .head {
    max-width: 720px;
    margin: 0 auto 56px;
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
    font-size: 46px;
    line-height: 1.1;
  }

  .intro {
    margin: 20px auto 0;
    max-width: 640px;
    font-size: 19px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  .block {
    max-width: 960px;
    margin: 0 auto 64px;
  }

  .block-title {
    margin: 0;
    font-size: 28px;
    line-height: 1.2;
  }

  .tier-head {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 12px;
  }

  .block-sub {
    margin: 12px 0 24px;
    max-width: 640px;
    font-size: 16px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  .pill {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 4px 11px;
    border-radius: 100px;
    font-size: 12px;
    font-weight: 600;
  }

  .pill.free {
    color: var(--text-secondary);
    border: 1px solid color-mix(in srgb, var(--border) 60%, transparent);
  }

  .pill.pro {
    color: var(--accent);
    background: color-mix(in srgb, var(--accent) 12%, transparent);
  }

  .steps {
    margin: 0;
    padding: 0;
    list-style: none;
    display: grid;
    gap: 14px;
  }

  .step {
    display: flex;
    gap: 16px;
    padding: 20px 22px;
    border-radius: 16px;
    border: 1px solid color-mix(in srgb, var(--border) 50%, transparent);
    background: var(--bg);
  }

  .num {
    flex-shrink: 0;
    width: 28px;
    height: 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    font-size: 13px;
    font-weight: 700;
    color: #000;
    background: var(--accent);
  }

  .step h3 {
    margin: 2px 0 0;
    font-size: 17px;
    font-weight: 700;
  }

  .step p {
    margin: 6px 0 0;
    font-size: 14px;
    line-height: 1.6;
    color: var(--text-secondary);
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
    background: var(--bg);
    height: 100%;
    transition: border-color 0.25s;
  }

  .card:hover {
    border-color: color-mix(in srgb, var(--accent) 20%, transparent);
  }

  .pro-card {
    background: color-mix(in srgb, var(--bg) 82%, var(--accent) 5%);
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

  .card h3 {
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
    max-width: 960px;
    margin: 0 auto 56px;
    padding: 36px;
    border-radius: 20px;
    border: 1px solid color-mix(in srgb, var(--accent) 22%, transparent);
    background: color-mix(in srgb, var(--accent) 6%, transparent);
  }

  .pro-banner h2 {
    margin: 0;
    font-size: 24px;
  }

  .pro-banner p {
    margin: 12px 0 0;
    max-width: 680px;
    font-size: 16px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  .pro-points {
    margin: 20px 0 24px;
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

  .actions {
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

  .disclaimer-wrap {
    max-width: 720px;
    margin: 0 auto;
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
    .grid {
      grid-template-columns: repeat(2, 1fr);
    }

    .related {
      grid-template-columns: repeat(2, 1fr);
    }
  }

  @media (min-width: 1024px) {
    .grid {
      grid-template-columns: repeat(3, 1fr);
    }
  }

  @media (max-width: 599px) {
    .title {
      font-size: 34px;
    }

    .intro {
      font-size: 16px;
    }

    .block-title {
      font-size: 24px;
    }
  }
</style>
