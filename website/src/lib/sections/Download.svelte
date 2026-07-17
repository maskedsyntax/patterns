<script lang="ts">
  import { onMount } from 'svelte';
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import AnimatedOnScroll from '$lib/components/AnimatedOnScroll.svelte';
  import { links } from '$lib/data/links';
  import { fetchLatestRelease } from '$lib/utils/github-releases';
  import { logDownload, logGitHubClick } from '$lib/utils/analytics';
  import BrandIcon from '$lib/components/BrandIcon.svelte';
  import WindowsIcon from '$lib/components/WindowsIcon.svelte';
  import { siAppstore, siGoogleplay, siLinux } from 'simple-icons';
  import { Download as DownloadIcon, Hammer } from 'lucide-svelte';

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
          A calm, local-first space for journaling and OCD self-tracking - available where you
          reflect.
        </p>
      </div>

      <div class="mobile-hero">
        {#if isMobile}
          <div class="phone-wrap">
            <img
              src="/assets/mockups/frame-1.jpg"
              alt="Patterns home screen on a phone"
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
            on your device - no accounts, no uploads.
          </p>
          <div class="store-badges">
            <a class="store-badge" href={links.ios} target="_blank" rel="noopener noreferrer" onclick={() => open(links.ios, 'iOS')}>
              <BrandIcon icon={siAppstore} size={24} color="#fff" />
              <span>
                <small>Download on the</small>
                <strong>App Store</strong>
              </span>
            </a>
            <a class="store-badge" href={links.playStore} target="_blank" rel="noopener noreferrer" onclick={() => open(links.playStore, 'Android')}>
              <BrandIcon icon={siGoogleplay} size={24} color="#fff" />
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
              alt="Patterns home screen on a phone"
              width="148"
              height="320"
              loading="lazy"
            />
          </div>
        {/if}
      </div>

      <div class="desktop-notice" role="note">
        <div class="notice-icon" aria-hidden="true">
          <Hammer size={18} />
        </div>
        <div class="notice-copy">
          <span class="notice-badge">Rebuilding now</span>
          <h4>A fresh desktop app is on the way</h4>
          <p>
            We're rebuilding Patterns for desktop from scratch - cleaner, calmer, and made for a big
            screen. Journaling and self-tracking stay free; Pro lives on mobile, where it belongs.
          </p>
        </div>
      </div>

      <div class="other-header">
        <h3 class="serif">Download for desktop</h3>
        <p>Available today while the new experience is on its way.</p>
      </div>

      <div class="platform-grid">
        <button type="button" class="platform-card" onclick={() => open(links.macos, 'macOS')}>
          <BrandIcon icon={siAppstore} size={28} color="var(--accent)" />
          <h4>macOS</h4>
          <p>macOS 12 Monterey or later</p>
          <span class="action"><BrandIcon icon={siAppstore} size={14} color="var(--accent)" /> Open in App Store</span>
        </button>
        <button
          type="button"
          class="platform-card"
          onclick={() => open(windowsUrl ?? links.releasesLatest, 'Windows')}
        >
          <WindowsIcon size={28} color="var(--accent)" />
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
          <BrandIcon icon={siLinux} size={28} color="var(--accent)" />
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

  .desktop-notice {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    gap: 14px;
    padding: 28px 24px;
    border-radius: 18px;
    background: color-mix(in srgb, var(--accent) 6%, var(--surface-alt));
    border: 1px solid color-mix(in srgb, var(--accent) 18%, transparent);
    margin: 0 auto 48px;
    max-width: 560px;
  }

  .notice-icon {
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 36px;
    height: 36px;
    border-radius: 999px;
    background: color-mix(in srgb, var(--accent) 15%, transparent);
    color: var(--accent);
  }

  .notice-badge {
    display: inline-block;
    padding: 3px 9px;
    border-radius: 100px;
    background: color-mix(in srgb, var(--accent) 14%, transparent);
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    color: var(--accent);
  }

  .notice-copy {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .notice-copy h4 {
    margin: 12px 0 0;
    font-size: 18px;
    font-weight: 700;
    line-height: 1.25;
    color: var(--text);
  }

  .notice-copy p {
    margin: 8px 0 0;
    font-size: 14px;
    line-height: 1.55;
    color: var(--text-secondary);
    max-width: 42ch;
  }

  .other-header {
    text-align: center;
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
    align-items: center;
    text-align: center;
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
    text-align: center;
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
