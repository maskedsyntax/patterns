<script lang="ts">
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import { links } from '$lib/data/links';
  import { logEvent } from '$lib/utils/analytics';

  const resourceLinks = [
    { label: 'Understanding OCD', url: '/ocd' },
    { label: 'ERP & how it helps', url: '/erp' },
    { label: 'CBT for OCD', url: '/cbt' },
    { label: 'Recovery toolkit', url: '/toolkit' },
    { label: 'Blog', url: '/blog' },
    { label: 'FAQ', url: '/faq' },
    { label: 'Privacy', url: '/privacy' }
  ];

  const projectLinks = [
    { label: 'GitHub', url: links.github },
    { label: 'Ko-fi', url: links.kofi },
    { label: 'Sponsor', url: links.sponsors },
    { label: 'Releases', url: links.releases },
    { label: 'Issues', url: links.issues },
    { label: 'License', url: links.license }
  ];

  function trackClick(label: string) {
    logEvent('footer_link_click', { label });
  }

  const year = new Date().getFullYear();
</script>

<footer class="footer">
  <hr />
  <ContentContainer padding="48px 0">
    <div class="footer-grid">
      <div class="brand">
        <img src="/assets/logo.png" alt="" width="28" height="28" />
        <span>Patterns</span>
        <p>Clarity for the mind through<br />structured reflection.</p>
        <a
          class="ph-badge"
          href={links.productHuntReview}
          target="_blank"
          rel="noopener noreferrer"
          onclick={() => trackClick('product_hunt_review')}
        >
          <img
            src="https://api.producthunt.com/widgets/embed-image/v1/product_review.svg?product_id=1265014&theme=neutral"
            alt="Patterns - Track urges, mood & exposure | Product Hunt"
            width="250"
            height="54"
            loading="lazy"
          />
        </a>
      </div>
      <div class="link-groups">
        <nav class="links" aria-label="Resources">
          <span class="group-label">Learn</span>
          {#each resourceLinks as link}
            <a href={link.url} onclick={() => trackClick(link.label)}>{link.label}</a>
          {/each}
        </nav>
        <nav class="links" aria-label="Project">
          <span class="group-label">Project</span>
          {#each projectLinks as link}
            <a
              href={link.url}
              target="_blank"
              rel="noopener noreferrer"
              onclick={() => trackClick(link.label)}
            >{link.label}</a>
          {/each}
        </nav>
      </div>
    </div>
    <hr class="divider" />
    <p class="copyright">© {year} Patterns. MIT License.</p>
  </ContentContainer>
</footer>

<style>
  .footer {
    background: var(--surface);
  }

  .footer > hr {
    margin: 0;
    border: none;
    border-top: 1px solid color-mix(in srgb, var(--border) 50%, transparent);
  }

  .footer-grid {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    gap: 32px;
  }

  .brand {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
  }

  .brand > span {
    font-size: 18px;
    font-weight: 700;
  }

  .brand img {
    border-radius: 8px;
  }

  .brand p {
    margin: 4px 0 0;
    font-size: 14px;
    line-height: 1.5;
    color: var(--text-secondary);
  }

  .ph-badge {
    margin-top: 4px;
    display: inline-flex;
    line-height: 0;
  }

  .ph-badge img {
    border-radius: 0;
  }

  .link-groups {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 40px 64px;
  }

  .links {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
  }

  .group-label {
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--text);
  }

  .links a {
    font-size: 14px;
    font-weight: 500;
    color: var(--text-secondary);
    transition: color 0.2s;
  }

  .links a:hover {
    color: var(--accent);
  }

  .divider {
    margin: 40px 0 24px;
    border: none;
    border-top: 1px solid color-mix(in srgb, var(--border) 30%, transparent);
  }

  .copyright {
    margin: 0;
    font-size: 13px;
    color: var(--text-secondary);
    text-align: center;
  }

  @media (min-width: 600px) {
    .footer-grid {
      flex-direction: row;
      align-items: flex-start;
      text-align: left;
    }

    .brand {
      align-items: flex-start;
      flex-direction: row;
      flex-wrap: wrap;
      flex: 1;
    }

    .brand > span {
      align-self: center;
    }

    .brand p {
      width: 100%;
      margin-left: 38px;
    }

    .link-groups {
      flex-wrap: nowrap;
      justify-content: flex-end;
    }

    .links {
      align-items: flex-start;
    }
  }
</style>
