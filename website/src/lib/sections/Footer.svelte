<script lang="ts">
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import { links } from '$lib/data/links';
  import { logEvent } from '$lib/utils/analytics';

  const footerLinks = [
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
      </div>
      <nav class="links" aria-label="Footer">
        {#each footerLinks as link}
          <a
            href={link.url}
            target="_blank"
            rel="noopener noreferrer"
            onclick={() => trackClick(link.label)}
          >{link.label}</a>
        {/each}
      </nav>
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

  .links {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 12px 24px;
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

    .links {
      justify-content: flex-end;
    }
  }
</style>
