<script lang="ts">
  import { onMount } from 'svelte';
  import Seo from '$lib/components/Seo.svelte';
  import BrandIcon from '$lib/components/BrandIcon.svelte';
  import { links } from '$lib/data/links';
  import { isAndroid, isIOS } from '$lib/utils/platform';
  import { logEvent } from '$lib/utils/analytics';
  import { siAppstore, siGoogleplay } from 'simple-icons';
  import { ShieldCheck, HeartHandshake, Sparkles } from 'lucide-svelte';

  // Highlight the visitor's platform, but always show BOTH stores so no user is
  // lost if native smart banners fail inside an in-app webview (e.g. YouTube).
  let platform = $state<'ios' | 'android' | 'other'>('other');

  // Campaign params captured from the ad URL (utm_source, utm_campaign, etc.), so
  // each landing view and store tap is stamped with which ad/creative drove it.
  let utm: Record<string, string> = {};

  function readUtm(): Record<string, string> {
    if (typeof window === 'undefined') return {};
    const params = new URLSearchParams(window.location.search);
    const out: Record<string, string> = {};
    for (const key of ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term']) {
      const value = params.get(key);
      if (value) out[key] = value;
    }
    return out;
  }

  onMount(() => {
    platform = isIOS() ? 'ios' : isAndroid() ? 'android' : 'other';
    utm = readUtm();
    logEvent('get_landing_view', { platform, ...utm });
  });

  // Plain same-tab navigation is the most reliable way to hand off to the native
  // store app from inside an in-app browser, so these stay as normal anchors.
  function track(store: 'iOS' | 'Android') {
    logEvent('download', { platform: store, version: 'store', ...utm });
  }

  const trust = [
    { icon: ShieldCheck, title: 'Private by default', body: 'Everything stays on your device. No account, no cloud, no tracking.' },
    { icon: HeartHandshake, title: 'Built around ERP', body: 'Track intrusive thoughts, delay compulsions, and practise recovery.' },
    { icon: Sparkles, title: 'Free to start', body: 'Download free. Unlock the full recovery toolkit once, no subscription.' }
  ];

  const jsonLd = [
    {
      '@context': 'https://schema.org',
      '@type': 'MobileApplication',
      name: 'Patterns - OCD Tracker & Journal',
      operatingSystem: 'iOS, Android',
      applicationCategory: 'HealthApplication',
      url: `${links.site}get`,
      offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
      downloadUrl: [links.ios, links.playStore]
    }
  ];
</script>

<Seo
  title="Get Patterns - Private OCD Tracker & Journal for iPhone & Android"
  description="Download Patterns free on the App Store and Google Play. A private OCD tracker and journal built around ERP - track intrusive thoughts, delay compulsions, and see your progress, all on your device."
  path="get"
  {jsonLd}
/>

<main class="lp">
  <section class="hero">
    <a class="brand" href="/">
      <img src="/assets/logo.png" alt="Patterns" width="72" height="72" />
    </a>

    <span class="eyebrow">Free · Private · No account</span>
    <h1 class="headline serif">A calmer way to face OCD.</h1>
    <p class="sub">
      Patterns is a private OCD tracker and journal built around ERP. Track intrusive
      thoughts, delay compulsions, and watch your progress - all on your device.
    </p>

    <div class="stores" role="group" aria-label="Download Patterns">
      <a
        class="store"
        class:recommended={platform === 'ios'}
        href={links.ios}
        rel="noopener"
        onclick={() => track('iOS')}
      >
        {#if platform === 'ios'}<span class="rec-tag">Recommended for your device</span>{/if}
        <span class="store-inner">
          <BrandIcon icon={siAppstore} size={30} color="#fff" />
          <span class="store-text">
            <small>Download on the</small>
            <strong>App Store</strong>
          </span>
        </span>
      </a>

      <a
        class="store"
        class:recommended={platform === 'android'}
        href={links.playStore}
        rel="noopener"
        onclick={() => track('Android')}
      >
        {#if platform === 'android'}<span class="rec-tag">Recommended for your device</span>{/if}
        <span class="store-inner">
          <BrandIcon icon={siGoogleplay} size={30} color="#fff" />
          <span class="store-text">
            <small>Get it on</small>
            <strong>Google Play</strong>
          </span>
        </span>
      </a>
    </div>

    <p class="reqs">Requires iOS 14 or later · Android 8 or later</p>
  </section>

  <section class="trust" aria-label="Why Patterns">
    <ul>
      {#each trust as item}
        {@const Icon = item.icon}
        <li>
          <div class="t-icon"><Icon size={22} color="var(--accent)" strokeWidth={1.75} /></div>
          <h2>{item.title}</h2>
          <p>{item.body}</p>
        </li>
      {/each}
    </ul>
    <p class="legal">
      <a href="/">patternsocd.com</a>
      <span aria-hidden="true">·</span>
      <a href="/privacy">Privacy</a>
    </p>
  </section>
</main>

<style>
  .lp {
    min-height: 100svh;
    background: var(--hero-gradient, var(--bg));
    color: var(--text);
  }

  /* Hero fills the first viewport so the store buttons are always above the fold,
     even inside an in-app browser with its own chrome (svh handles that). */
  .hero {
    min-height: 100svh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
    padding: 32px 20px 40px;
    gap: 4px;
  }

  .brand img {
    border-radius: 18px;
    box-shadow: 0 10px 30px color-mix(in srgb, #000 45%, transparent);
  }

  .eyebrow {
    margin-top: 22px;
    display: inline-block;
    padding: 6px 14px;
    border-radius: 100px;
    border: 1px solid color-mix(in srgb, var(--accent) 30%, transparent);
    background: color-mix(in srgb, var(--accent) 10%, transparent);
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: var(--accent);
  }

  .headline {
    margin: 18px 0 0;
    font-size: 44px;
    line-height: 1.08;
    max-width: 12ch;
  }

  .sub {
    margin: 16px 0 0;
    max-width: 44ch;
    font-size: 17px;
    line-height: 1.55;
    color: var(--text-secondary);
  }

  .stores {
    margin-top: 30px;
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 14px;
    width: 100%;
    max-width: 520px;
  }

  .store {
    position: relative;
    flex: 1 1 220px;
    min-height: 64px;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 14px 22px;
    border-radius: 16px;
    background: #000;
    border: 1px solid color-mix(in srgb, #fff 22%, transparent);
    color: #fff;
    transition: transform 0.15s, border-color 0.2s, box-shadow 0.2s;
  }

  .store:hover {
    border-color: color-mix(in srgb, #fff 55%, transparent);
    transform: translateY(-2px);
  }

  .store.recommended {
    border-color: var(--accent);
    box-shadow: 0 8px 30px color-mix(in srgb, var(--accent) 28%, transparent);
  }

  .store-inner {
    display: inline-flex;
    align-items: center;
    gap: 14px;
  }

  .store-text {
    display: flex;
    flex-direction: column;
    text-align: left;
    line-height: 1.1;
  }

  .store-text small {
    font-size: 11px;
    opacity: 0.85;
  }

  .store-text strong {
    font-size: 19px;
    font-weight: 700;
  }

  .rec-tag {
    position: absolute;
    top: -11px;
    left: 50%;
    transform: translateX(-50%);
    white-space: nowrap;
    padding: 3px 10px;
    border-radius: 100px;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.03em;
    text-transform: uppercase;
    color: #000;
    background: var(--accent);
  }

  .reqs {
    margin: 18px 0 0;
    font-size: 12.5px;
    color: var(--text-secondary);
  }

  .trust {
    padding: 8px 20px 56px;
  }

  .trust ul {
    list-style: none;
    margin: 0 auto;
    padding: 0;
    max-width: 960px;
    display: grid;
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .trust li {
    padding: 22px;
    border-radius: 16px;
    border: 1px solid color-mix(in srgb, var(--border) 55%, transparent);
    background: color-mix(in srgb, var(--surface) 70%, transparent);
    text-align: left;
  }

  .t-icon {
    width: 44px;
    height: 44px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;
    background: color-mix(in srgb, var(--accent) 10%, transparent);
    margin-bottom: 14px;
  }

  .trust h2 {
    margin: 0;
    font-size: 17px;
    font-weight: 700;
  }

  .trust li p {
    margin: 6px 0 0;
    font-size: 14px;
    line-height: 1.55;
    color: var(--text-secondary);
  }

  .legal {
    margin: 32px auto 0;
    text-align: center;
    font-size: 13px;
    color: var(--text-secondary);
    display: flex;
    gap: 10px;
    justify-content: center;
  }

  .legal a {
    color: var(--text-secondary);
    text-decoration: underline;
    text-underline-offset: 3px;
  }

  .legal a:hover {
    color: var(--accent);
  }

  @media (min-width: 600px) {
    .headline {
      font-size: 56px;
    }

    .trust ul {
      grid-template-columns: repeat(3, 1fr);
    }
  }

  /* Keep the hero compact on phones so the store buttons never fall below the
     fold. */
  @media (max-width: 599px) {
    .brand img {
      width: 60px;
      height: 60px;
    }

    .headline {
      font-size: 34px;
      max-width: 16ch;
    }

    .sub {
      margin-top: 12px;
      font-size: 15px;
      max-width: 38ch;
    }

    .stores {
      margin-top: 22px;
    }
  }

  /* Short viewports (in-app browsers with heavy chrome): anchor from the top and
     trim spacing so the buttons are reachable without any scrolling. */
  @media (max-height: 720px) {
    .hero {
      justify-content: flex-start;
      padding-top: 28px;
      gap: 2px;
    }

    .eyebrow {
      margin-top: 16px;
    }

    .headline {
      margin-top: 12px;
    }

    .stores {
      margin-top: 20px;
    }
  }

  @media (max-width: 380px) {
    .headline {
      font-size: 32px;
    }

    .stores {
      gap: 10px;
    }
  }
</style>
