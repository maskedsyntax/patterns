<script lang="ts">
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import PrimaryButton from '$lib/components/PrimaryButton.svelte';
  import SecondaryButton from '$lib/components/SecondaryButton.svelte';
  import { links } from '$lib/data/links';
  import { logDownload, logEvent, logGitHubClick } from '$lib/utils/analytics';
  import { Download, Github } from 'lucide-svelte';

  let { onDownload }: { onDownload: () => void } = $props();

  let isMobile = $state(false);

  $effect(() => {
    const mq = window.matchMedia('(max-width: 599px)');
    const update = () => (isMobile = mq.matches);
    update();
    mq.addEventListener('change', update);
    return () => mq.removeEventListener('change', update);
  });

  function handleStoreDownload(url: string, platform: string) {
    logDownload(platform, 'hero');
    window.open(url, '_blank', 'noopener');
  }

  function handleDownload() {
    logEvent('hero_download_click');
    onDownload();
  }

  function handleGitHub() {
    logGitHubClick();
    window.open(links.github, '_blank', 'noopener');
  }
</script>

<section id="hero" class="hero section-scroll-margin" aria-labelledby="hero-title">
  <ContentContainer padding={isMobile ? '56px 0 56px' : '92px 0 96px'}>
    <div class="hero-content">
      <div class="hook">
        <div class="badge">
          <span class="dot"></span>
          <span>Private OCD journaling & ERP practice</span>
        </div>

        <h1 id="hero-title" class="headline serif">
          See the loop.<br />Choose your next response.
        </h1>

        <p class="subhead">
          Patterns helps you journal, track OCD events, practice ERP, and spot trends
          without accounts, cloud sync, or anyone else reading your notes.
        </p>

        <div class="cta-row">
          <PrimaryButton
            label="Download for Free"
            icon={Download}
            onclick={handleDownload}
            fullWidth={isMobile}
          />
          <SecondaryButton
            label="View on GitHub"
            icon={Github}
            onclick={handleGitHub}
            fullWidth={isMobile}
          />
        </div>
      </div>

      <figure class="app-preview">
        <img
          class="mobile-preview"
          src="/assets/website-cta.png"
          alt="Patterns mobile app for private journaling, OCD event tracking, ERP practice, insights, and reminders"
          width="1536"
          height="1024"
          fetchpriority="high"
        />
        <a
          class="store-link app-store-link"
          href={links.ios}
          target="_blank"
          rel="noopener noreferrer"
          aria-label="Download Patterns on the App Store"
          onclick={() => handleStoreDownload(links.ios, 'iOS')}
        ></a>
        <a
          class="store-link play-store-link"
          href={links.playStore}
          target="_blank"
          rel="noopener noreferrer"
          aria-label="Get Patterns on Google Play"
          onclick={() => handleStoreDownload(links.playStore, 'Android')}
        ></a>
        <figcaption class="sr-only">
          Patterns mobile app CTA with App Store and Google Play download badges
        </figcaption>
      </figure>
    </div>
  </ContentContainer>
</section>

<style>
  .hero {
    position: relative;
    width: 100%;
    background: var(--hero-gradient);
    overflow: hidden;
  }

  .hero-content {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
  }

  .hook {
    display: flex;
    flex-direction: column;
    align-items: center;
    max-width: 760px;
  }

  .badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    border-radius: 100px;
    border: 1px solid color-mix(in srgb, var(--accent) 20%, transparent);
    background: color-mix(in srgb, var(--accent) 10%, transparent);
    font-size: 13px;
    font-weight: 600;
    color: var(--accent);
    letter-spacing: 0.03em;
  }

  .dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--accent);
  }

  .headline {
    margin: 36px 0 0;
    font-size: 72px;
    line-height: 1.06;
    font-weight: 400;
  }

  .subhead {
    margin: 22px 0 0;
    max-width: 620px;
    font-size: 19px;
    line-height: 1.58;
    color: var(--text-secondary);
  }

  .cta-row {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 16px;
    margin-top: 40px;
  }

  .app-preview {
    position: relative;
    width: 100%;
    max-width: 1160px;
    margin: 72px 0 0;
    border-radius: 28px;
    overflow: hidden;
    box-shadow: 0 34px 100px -42px rgba(0, 0, 0, 0.9);
  }

  .mobile-preview {
    width: 100%;
    height: auto;
    display: block;
  }

  .store-link {
    position: absolute;
    display: block;
    border-radius: 12px;
  }

  .store-link:focus-visible {
    outline: 3px solid var(--accent);
    outline-offset: 3px;
  }

  .app-store-link {
    left: 5.9%;
    top: 82.15%;
    width: 15.4%;
    height: 6.35%;
  }

  .play-store-link {
    left: 22.7%;
    top: 82.15%;
    width: 14.35%;
    height: 6.35%;
  }

  .sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0, 0, 0, 0);
    white-space: nowrap;
    border: 0;
  }

  @media (max-width: 1023px) {
    .headline {
      font-size: 60px;
    }

    .app-preview {
      max-width: 980px;
      border-radius: 24px;
    }
  }

  @media (max-width: 599px) {
    .badge {
      font-size: 12px;
      padding: 7px 12px;
    }

    .headline {
      margin-top: 28px;
      font-size: 44px;
    }

    .subhead {
      font-size: 16px;
      line-height: 1.5;
    }

    .cta-row {
      margin-top: 32px;
    }

    .app-preview {
      width: calc(100% + 12px);
      margin-top: 48px;
      border-radius: 18px;
    }
  }
</style>
