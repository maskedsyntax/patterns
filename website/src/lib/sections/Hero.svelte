<script lang="ts">
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import PrimaryButton from '$lib/components/PrimaryButton.svelte';
  import SecondaryButton from '$lib/components/SecondaryButton.svelte';
  import JournalMockup from '$lib/components/JournalMockup.svelte';
  import { links } from '$lib/data/links';
  import { logEvent, logGitHubClick } from '$lib/utils/analytics';
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
  <ContentContainer padding={isMobile ? '64px 0 64px' : '140px 0 120px'}>
    <div class="hero-content">
      <div class="badge">
        <span class="dot"></span>
        <span>Open Source & Privacy-First</span>
      </div>

      <h1 id="hero-title" class="headline serif">
        Clarity for<br />the mind.
      </h1>

      <p class="subhead">
        A calm, private app for daily journaling and tracking obsessions and compulsions —
        built to support your ERP practice and help you see the pattern clearly.
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

      <figure class="app-preview">
        <JournalMockup compact={isMobile} />
        <figcaption class="sr-only">
          Patterns journal screen with sidebar navigation, search, save, and writing area
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

  .badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    border-radius: 100px;
    border: 1px solid color-mix(in srgb, var(--accent) 20%, transparent);
    background: color-mix(in srgb, var(--accent) 10%, transparent);
    font-size: 13px;
    font-weight: 500;
    color: var(--accent);
    letter-spacing: 0.5px;
  }

  .dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--accent);
  }

  .headline {
    margin: 40px 0 0;
    font-size: 80px;
    line-height: 1.08;
    letter-spacing: -0.03em;
    font-weight: 400;
  }

  .subhead {
    margin: 24px 0 0;
    max-width: 560px;
    font-size: 19px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  .cta-row {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 16px;
    margin-top: 48px;
  }

  .app-preview {
    width: 100%;
    max-width: 1040px;
    margin: 80px 0 0;
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
      font-size: 64px;
    }

    .app-preview {
      max-width: 920px;
    }
  }

  @media (max-width: 599px) {
    .headline {
      font-size: 48px;
      margin-top: 28px;
    }

    .subhead {
      font-size: 16px;
      line-height: 1.5;
    }

    .cta-row {
      margin-top: 36px;
    }

    .app-preview {
      margin-top: 48px;
    }
  }
</style>
