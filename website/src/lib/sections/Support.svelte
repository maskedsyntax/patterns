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
        <div class="icon-circle">
          <Heart size={26} color="var(--accent)" fill="var(--accent)" />
        </div>
        <h2 id="support-title">Support Patterns</h2>
        <p>
          Patterns is open source, independent, and ad-free. If it has helped you, a small tip
          keeps development going.
        </p>
        <div class="actions">
          <button type="button" class="kofi-btn" onclick={tipKofi}>
            <Coffee size={16} strokeWidth={2.25} />
            <span>Tip on Ko-fi</span>
          </button>
          <button type="button" class="github-btn" onclick={sponsorGitHub}>
            <Heart size={14} strokeWidth={2.25} />
            <span>Sponsor on GitHub</span>
          </button>
        </div>
      </div>
    </AnimatedOnScroll>
  </ContentContainer>
</section>

<style>
  .card {
    max-width: 620px;
    margin: 0 auto;
    padding: 40px;
    text-align: center;
    border-radius: 20px;
    background: var(--surface-alt);
    border: 1px solid color-mix(in srgb, var(--border) 60%, transparent);
  }

  .icon-circle {
    width: 56px;
    height: 56px;
    margin: 0 auto;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    background: color-mix(in srgb, var(--accent) 14%, transparent);
  }

  .card h2 {
    margin: 20px 0 0;
    font-size: 30px;
    font-weight: 600;
    letter-spacing: -0.3px;
  }

  .card p {
    margin: 12px 0 0;
    font-size: 15px;
    line-height: 1.55;
    color: var(--text-secondary);
  }

  .actions {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
    margin-top: 28px;
  }

  .kofi-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    width: 100%;
    max-width: 260px;
    padding: 14px 24px;
    border-radius: 10px;
    font-size: 15px;
    font-weight: 700;
    color: #fff;
    background: #29abe0;
    transition: background 0.2s, transform 0.2s;
  }

  .kofi-btn:hover {
    background: #3db8e8;
    transform: translateY(-1px);
  }

  .github-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 10px 16px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 600;
    color: var(--text-secondary);
    border: 1px solid color-mix(in srgb, var(--border) 70%, transparent);
    background: transparent;
    transition:
      color 0.2s,
      border-color 0.2s,
      background 0.2s;
  }

  .github-btn:hover {
    color: var(--text);
    border-color: color-mix(in srgb, var(--accent) 35%, transparent);
    background: color-mix(in srgb, var(--accent) 6%, transparent);
  }

  @media (max-width: 599px) {
    .card {
      padding: 32px 24px;
    }

    .card h2 {
      font-size: 24px;
    }
  }
</style>
