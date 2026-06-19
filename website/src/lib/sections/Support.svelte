<script lang="ts">
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import AnimatedOnScroll from '$lib/components/AnimatedOnScroll.svelte';
  import { links } from '$lib/data/links';
  import { logEvent } from '$lib/utils/analytics';
  import { Coffee, Heart } from 'lucide-svelte';

  function tipKofi() {
    logEvent('kofi_click', { source: 'support_section' });
    window.open(links.kofi, '_blank', 'noopener');
  }

  function sponsorGitHub() {
    logEvent('sponsor_click', { source: 'support_section' });
    window.open(links.sponsors, '_blank', 'noopener');
  }
</script>

<section class="support content-below-fold" aria-labelledby="support-title">
  <ContentContainer padding="56px 0">
    <AnimatedOnScroll>
      <div class="card">
        <div class="glow" aria-hidden="true"></div>
        <div class="icon-tile">
          <Heart size={26} color="var(--accent)" fill="var(--accent)" />
        </div>
        <h2 id="support-title" class="serif">Support Patterns</h2>
        <p>
          Patterns is open source, independent, and ad-free. If it has helped you, a small tip
          keeps development going.
        </p>
        <div class="actions">
          <button type="button" class="btn primary" onclick={tipKofi}>
            <Coffee size={17} strokeWidth={2.25} />
            <span>Tip on Ko-fi</span>
          </button>
          <button type="button" class="btn ghost" onclick={sponsorGitHub}>
            <Heart size={15} strokeWidth={2.25} />
            <span>Sponsor on GitHub</span>
          </button>
        </div>
      </div>
    </AnimatedOnScroll>
  </ContentContainer>
</section>

<style>
  .card {
    position: relative;
    overflow: hidden;
    max-width: 640px;
    margin: 0 auto;
    padding: 52px 40px;
    text-align: center;
    border-radius: 24px;
    background: linear-gradient(
      180deg,
      var(--surface-alt) 0%,
      var(--surface) 100%
    );
    border: 1px solid color-mix(in srgb, var(--accent) 18%, var(--border));
    box-shadow: 0 24px 60px rgba(0, 0, 0, 0.35);
  }

  /* Warm radial wash behind the heart so the card reads as part of the
     amber/charcoal system instead of a flat block. */
  .glow {
    position: absolute;
    top: -120px;
    left: 50%;
    transform: translateX(-50%);
    width: 420px;
    height: 320px;
    pointer-events: none;
    background: radial-gradient(
      ellipse at center,
      color-mix(in srgb, var(--accent) 22%, transparent) 0%,
      transparent 70%
    );
    filter: blur(8px);
    opacity: 0.7;
  }

  .icon-tile {
    position: relative;
    width: 60px;
    height: 60px;
    margin: 0 auto;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 18px;
    background: color-mix(in srgb, var(--accent) 12%, transparent);
    border: 1px solid color-mix(in srgb, var(--accent) 28%, transparent);
  }

  .card h2 {
    position: relative;
    margin: 22px 0 0;
    font-size: 32px;
    line-height: 1.1;
  }

  .card p {
    position: relative;
    margin: 14px auto 0;
    max-width: 440px;
    font-size: 16px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  .actions {
    position: relative;
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: center;
    gap: 12px;
    margin-top: 32px;
  }

  .btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 9px;
    padding: 14px 26px;
    border-radius: 12px;
    font-size: 15px;
    font-weight: 600;
    transition: background 0.2s, border-color 0.2s, color 0.2s, transform 0.2s;
  }

  .btn:hover {
    transform: translateY(-1px);
  }

  .btn.primary {
    color: #000;
    background: var(--accent);
  }

  .btn.primary:hover {
    background: color-mix(in srgb, var(--accent) 88%, #fff);
  }

  .btn.ghost {
    color: var(--text);
    background: transparent;
    border: 1px solid color-mix(in srgb, var(--border) 80%, transparent);
  }

  .btn.ghost:hover {
    color: var(--accent);
    border-color: color-mix(in srgb, var(--accent) 45%, transparent);
    background: color-mix(in srgb, var(--accent) 6%, transparent);
  }

  @media (max-width: 599px) {
    .card {
      padding: 40px 24px;
    }

    .card h2 {
      font-size: 26px;
    }

    .actions {
      flex-direction: column;
    }

    .btn {
      width: 100%;
      max-width: 280px;
    }
  }
</style>
