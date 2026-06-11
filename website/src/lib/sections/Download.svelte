<script lang="ts">
  import { onMount } from 'svelte';
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import AnimatedOnScroll from '$lib/components/AnimatedOnScroll.svelte';
  import { links } from '$lib/data/links';
  import { fetchLatestRelease } from '$lib/utils/github-releases';
  import { logDownload, logGitHubClick } from '$lib/utils/analytics';
  import { Apple, Download as DownloadIcon, ExternalLink } from 'lucide-svelte';

  let loading = $state(true);
  let linuxUrl = $state<string | null>(null);
  let windowsUrl = $state<string | null>(null);
  let version = $state<string | null>(null);
  let isMobile = $state(false);

  onMount(() => {
    const mq = window.matchMedia('(max-width: 599px)');
    const update = () => (isMobile = mq.matches);
    update();
    mq.addEventListener('change', update);

    fetchLatestRelease().then((release) => {
      linuxUrl = release.linuxUrl;
      windowsUrl = release.windowsUrl;
      version = release.version;
      loading = false;
    });

    return () => mq.removeEventListener('change', update);
  });

  function open(url: string, platform: string) {
    logDownload(platform, version ?? 'unknown');
    window.open(url, '_blank', 'noopener');
  }
</script>

<section id="download" class="download section-pad section-scroll-margin content-below-fold" aria-labelledby="download-title">
  <ContentContainer>
    <AnimatedOnScroll>
      <div class="header">
        <h2 id="download-title" class="title serif">Download Patterns</h2>
        <p class="subtitle">
          A calm, local-first space for journaling and OCD self-tracking — available where you
          reflect.
        </p>
      </div>

      <div class="mobile-hero">
        {#if isMobile}
          <div class="phone-wrap">
            <img
              src="/assets/mockups/frame-1.jpg"
              alt="Patterns home screen on iPhone"
              width="148"
              height="320"
              loading="lazy"
            />
          </div>
        {/if}
        <div class="mobile-copy">
          <span class="tag">Mobile</span>
          <h3 class="serif">On your phone</h3>
          <p>
            Track obsessions, log distress, and journal in a calm private space. Your entries stay
            on your device — no accounts, no uploads.
          </p>
          <div class="store-badges">
            <a class="store-badge" href={links.ios} target="_blank" rel="noopener noreferrer" onclick={() => open(links.ios, 'iOS')}>
              <Apple size={24} color="#fff" />
              <span>
                <small>Download on the</small>
                <strong>App Store</strong>
              </span>
            </a>
            <a class="store-badge" href={links.playStore} target="_blank" rel="noopener noreferrer" onclick={() => open(links.playStore, 'Android')}>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="#fff" aria-hidden="true"><path d="M3.6 1.8l10.2 10.2L3.6 22.2c-.4-.2-.6-.6-.6-1.1V2.9c0-.5.2-.9.6-1.1zm12.3 8.7l2.5-2.5 3.4 1.9c.5.3.8.8.8 1.4s-.3 1.1-.8 1.4l-3.4 1.9-2.5-2.5 2.5-2.6zm-2.5 2.6l-2.5 2.5 3.4 1.9c.5.3 1 .3 1.5 0l3.4-1.9-3.4-1.9-3.4 1.9zM3 2.9v18.2l10.2-10.2L3 2.9z"/></svg>
              <span>
                <small>Get it on</small>
                <strong>Google Play</strong>
              </span>
            </a>
          </div>
          <p class="requirements">Requires iOS 14 or later · Android 8 or later</p>
        </div>
        {#if !isMobile}
          <div class="phone-wrap">
            <img
              src="/assets/mockups/frame-1.jpg"
              alt="Patterns home screen on iPhone"
              width="148"
              height="320"
              loading="lazy"
            />
          </div>
        {/if}
      </div>

      <div class="other-header">
        <h3 class="serif">Other download options</h3>
        <p>Patterns runs natively on every desktop you use.</p>
      </div>

      <div class="platform-grid">
        <button type="button" class="platform-card" onclick={() => open(links.macos, 'macOS')}>
          <Apple size={28} color="var(--accent)" />
          <h4>macOS</h4>
          <p>macOS 12 Monterey or later</p>
          <span class="action"><ExternalLink size={14} /> Open in App Store</span>
        </button>
        <button
          type="button"
          class="platform-card"
          onclick={() => open(windowsUrl ?? links.releasesLatest, 'Windows')}
        >
          <svg width="28" height="28" viewBox="0 0 24 24" fill="var(--accent)" aria-hidden="true"><path d="M3 5.5L10.5 4.6V11.5H3V5.5zm0 13V12.5h7.5v7.9L3 18.5zM11.5 11.5h9.7l.1-7.9L11.5 4.4V11.5zm9.8 1.5H11.5V20l9.9-1.4V13z"/></svg>
          <h4>Windows</h4>
          <p>Windows 10 or later</p>
          <span class="action">
            {#if loading}
              Loading…
            {:else}
              <DownloadIcon size={14} /> Download .exe
            {/if}
          </span>
        </button>
        <button
          type="button"
          class="platform-card"
          onclick={() => open(linuxUrl ?? links.releasesLatest, 'Linux')}
        >
          <svg width="28" height="28" viewBox="0 0 24 24" fill="var(--accent)" aria-hidden="true"><path d="M12.5 2c-3.6 0-6.5 2.4-6.5 5.4 0 1.5.7 2.9 1.9 3.9-.3.8-.5 1.7-.5 2.6 0 3.3 2.5 6 5.6 6.3.4 1.5 1.8 2.6 3.5 2.6h1.2c1.7 0 3.1-1.1 3.5-2.6 3.1-.3 5.6-3 5.6-6.3 0-.9-.2-1.8-.5-2.6 1.2-1 1.9-2.4 1.9-3.9C19 4.4 16.1 2 12.5 2zm-2.8 14.5c-.8 0-1.4-.6-1.4-1.4s.6-1.4 1.4-1.4 1.4.6 1.4 1.4-.6 1.4-1.4 1.4zm5.6 0c-.8 0-1.4-.6-1.4-1.4s.6-1.4 1.4-1.4 1.4.6 1.4 1.4-.6 1.4-1.4 1.4z"/></svg>
          <h4>Linux</h4>
          <p>Ubuntu, Debian, and derivatives</p>
          <span class="action">
            {#if loading}
              Loading…
            {:else}
              <DownloadIcon size={14} /> Download .deb
            {/if}
          </span>
        </button>
      </div>

      {#if version}
        <p class="version">Latest desktop release: {version}</p>
      {/if}

      <p class="source">
        Or build from source on
        <a
          href={links.github}
          target="_blank"
          rel="noopener noreferrer"
          onclick={() => logGitHubClick()}
        >GitHub</a>
      </p>
    </AnimatedOnScroll>
  </ContentContainer>
</section>

<style>
  .download {
    background: var(--bg);
  }

  .header {
    text-align: center;
    margin-bottom: 56px;
  }

  .title {
    margin: 0;
    font-size: 48px;
    line-height: 1.1;
  }

  .subtitle {
    margin: 16px auto 0;
    max-width: 560px;
    font-size: 17px;
    color: var(--text-secondary);
    line-height: 1.6;
  }

  .mobile-hero {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 28px;
    padding: 28px;
    border-radius: 24px;
    background: var(--surface-alt);
    border: 1px solid color-mix(in srgb, var(--border) 50%, transparent);
    margin-bottom: 80px;
  }

  @media (min-width: 600px) {
    .mobile-hero {
      flex-direction: row;
      padding: 40px;
      gap: 40px;
    }

    .mobile-copy {
      flex: 1;
      text-align: left;
    }
  }

  .phone-wrap {
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 14px 28px color-mix(in srgb, #000 40%, transparent);
    flex-shrink: 0;
  }

  .phone-wrap img {
    width: auto;
    height: 320px;
    display: block;
  }

  .mobile-copy {
    text-align: center;
  }

  .tag {
    display: inline-block;
    padding: 4px 10px;
    border-radius: 100px;
    border: 1px solid color-mix(in srgb, var(--accent) 25%, transparent);
    background: color-mix(in srgb, var(--accent) 12%, transparent);
    font-size: 11px;
    font-weight: 700;
    color: var(--accent);
    letter-spacing: 1px;
    text-transform: uppercase;
  }

  .mobile-copy h3 {
    margin: 14px 0 0;
    font-size: 36px;
    line-height: 1.1;
  }

  .mobile-copy > p {
    margin: 12px 0 0;
    font-size: 15px;
    line-height: 1.55;
    color: var(--text-secondary);
  }

  .store-badges {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    margin-top: 24px;
    justify-content: center;
  }

  @media (min-width: 600px) {
    .store-badges {
      justify-content: flex-start;
    }
  }

  .store-badge {
    display: inline-flex;
    align-items: center;
    gap: 12px;
    padding: 12px 18px;
    border-radius: 12px;
    background: #000;
    border: 1px solid color-mix(in srgb, #fff 18%, transparent);
    color: #fff;
    transition: border-color 0.2s;
  }

  .store-badge:hover {
    border-color: color-mix(in srgb, #fff 50%, transparent);
  }

  .store-badge span {
    display: flex;
    flex-direction: column;
    text-align: left;
  }

  .store-badge small {
    font-size: 10px;
    opacity: 0.8;
    line-height: 1;
  }

  .store-badge strong {
    font-size: 17px;
    font-weight: 700;
    line-height: 1.2;
  }

  .requirements {
    margin: 14px 0 0;
    font-size: 12px;
    color: var(--text-secondary);
  }

  .other-header {
    margin-bottom: 32px;
  }

  .other-header h3 {
    margin: 0;
    font-size: 28px;
  }

  .other-header p {
    margin: 6px 0 0;
    font-size: 14px;
    color: var(--text-secondary);
  }

  .platform-grid {
    display: grid;
    grid-template-columns: 1fr;
    gap: 12px;
  }

  @media (min-width: 600px) {
    .platform-grid {
      grid-template-columns: repeat(3, 1fr);
      gap: 16px;
    }
  }

  .platform-card {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    text-align: left;
    padding: 24px;
    border-radius: 16px;
    border: 1px solid color-mix(in srgb, var(--border) 50%, transparent);
    background: transparent;
    transition:
      background 0.2s,
      border-color 0.2s;
    height: 100%;
  }

  .platform-card:hover {
    background: var(--surface-alt);
    border-color: color-mix(in srgb, var(--accent) 35%, transparent);
  }

  .platform-card h4 {
    margin: 16px 0 0;
    font-size: 18px;
    font-weight: 600;
  }

  .platform-card p {
    margin: 4px 0 0;
    font-size: 13px;
    color: var(--text-secondary);
    line-height: 1.4;
  }

  .action {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    margin-top: 18px;
    font-size: 13px;
    font-weight: 700;
    color: var(--accent);
  }

  .version {
    margin: 20px 0 0;
    font-size: 12px;
    color: var(--text-secondary);
  }

  .source {
    margin: 32px 0 0;
    font-size: 14px;
    color: var(--text-secondary);
    text-align: center;
  }

  .source a {
    font-weight: 600;
    color: var(--accent);
    text-decoration: underline;
    text-decoration-color: color-mix(in srgb, var(--accent) 40%, transparent);
  }

  @media (max-width: 599px) {
    .title {
      font-size: 32px;
    }

    .subtitle {
      font-size: 15px;
    }

    .mobile-copy h3 {
      font-size: 28px;
    }

    .mobile-hero {
      margin-bottom: 56px;
    }
  }
</style>
