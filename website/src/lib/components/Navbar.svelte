<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { theme } from '$lib/stores/theme';
  import { githubStats, links } from '$lib/data/links';
  import { logEvent } from '$lib/utils/analytics';
  import ContentContainer from './ContentContainer.svelte';
  import BrandIcon from './BrandIcon.svelte';
  import { Download, Menu, X, Sun, Moon, Star, ChevronDown } from 'lucide-svelte';
  import { siProducthunt } from 'simple-icons';

  let {
    onNavigate
  }: {
    onNavigate?: (section: string) => void;
  } = $props();

  let mobileMenuOpen = $state(false);
  let scrolled = $state(false);
  let starCount: number = $state(githubStats.stars);
  const starFormatter = new Intl.NumberFormat('en-US');
  const starCountLabel = $derived(starFormatter.format(starCount));

  const learnLinks = [
    { label: 'Understanding OCD', href: '/ocd' },
    { label: 'ERP & how it helps', href: '/erp' },
    { label: 'Recovery toolkit', href: '/toolkit' },
    { label: 'FAQ', href: '/faq' }
  ];

  function closeMobile() {
    mobileMenuOpen = false;
  }

  function trackProductHunt() {
    logEvent('product_hunt_review_click', { source: 'navbar' });
  }

  $effect(() => {
    const onScroll = () => {
      scrolled = window.scrollY > 8;
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
    return () => window.removeEventListener('scroll', onScroll);
  });

  $effect(() => {
    let cancelled = false;

    fetch(links.githubApi, { headers: { Accept: 'application/vnd.github+json' } })
      .then((response) => (response.ok ? response.json() : null))
      .then((repo: { stargazers_count?: number } | null) => {
        if (!cancelled && typeof repo?.stargazers_count === 'number') {
          starCount = repo.stargazers_count;
        }
      })
      .catch(() => {
        starCount = githubStats.stars;
      });

    return () => {
      cancelled = true;
    };
  });

  function scrollToSection(section: string) {
    mobileMenuOpen = false;
    if ($page.url.pathname !== '/') {
      goto(`/#${section}`);
      return;
    }
    onNavigate?.(section);
    const el = document.getElementById(section);
    el?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }

  function goPrivacy() {
    mobileMenuOpen = false;
    goto('/privacy');
  }

  function goHome() {
    mobileMenuOpen = false;
    if ($page.url.pathname === '/') {
      scrollToSection('hero');
    } else {
      goto('/');
    }
  }
  $effect(() => {
    document.body.style.overflow = mobileMenuOpen ? 'hidden' : '';
    return () => {
      document.body.style.overflow = '';
    };
  });
</script>

<header class="navbar" class:scrolled>
  <ContentContainer>
    <nav class="nav-inner" aria-label="Main">
      <button type="button" class="brand" onclick={goHome}>
        <img src="/assets/logo.png" alt="" width="36" height="36" />
        <span>Patterns</span>
      </button>

      <div class="spacer"></div>

      <div class="desktop-links">
        <button type="button" onclick={() => scrollToSection('features')}>Features</button>
        <div class="dropdown">
          <button type="button" class="dropdown-trigger" aria-haspopup="true">
            Learn <ChevronDown size={15} />
          </button>
          <div class="dropdown-menu" role="menu">
            {#each learnLinks as link}
              <a href={link.href} role="menuitem">{link.label}</a>
            {/each}
          </div>
        </div>
        <a href="/blog" class="nav-link">Blog</a>
        <button type="button" onclick={goPrivacy}>Privacy</button>
        <button
          type="button"
          class="icon-btn"
          aria-label="Toggle theme"
          onclick={() => theme.toggle()}
        >
          {#if $theme === 'dark'}
            <Sun size={20} />
          {:else}
            <Moon size={20} />
          {/if}
        </button>
        <a
          class="ph-btn"
          href={links.productHuntReview}
          target="_blank"
          rel="noopener noreferrer"
          onclick={trackProductHunt}
        >
          <BrandIcon icon={siProducthunt} size={16} color="currentColor" />
          <span>Review</span>
        </a>
        <a class="github-btn" href={links.github} target="_blank" rel="noopener noreferrer">
          <Star size={16} />
          <span>Star on GitHub</span>
          <span class="star-count" aria-label={`${starCountLabel} GitHub stars`}>
            {starCountLabel}
          </span>
        </a>
        <button type="button" class="download-btn" onclick={() => scrollToSection('download')}>
          <Download size={16} color="#000" />
          <span>Download</span>
        </button>
      </div>

      <div class="mobile-controls">
        <button
          type="button"
          class="icon-btn"
          aria-label="Toggle theme"
          onclick={() => theme.toggle()}
        >
          {#if $theme === 'dark'}
            <Sun size={20} />
          {:else}
            <Moon size={20} />
          {/if}
        </button>
        <button
          type="button"
          class="icon-btn"
          aria-label={mobileMenuOpen ? 'Close menu' : 'Open menu'}
          onclick={() => (mobileMenuOpen = !mobileMenuOpen)}
        >
          {#if mobileMenuOpen}
            <X size={24} />
          {:else}
            <Menu size={24} />
          {/if}
        </button>
      </div>
    </nav>
  </ContentContainer>

  {#if mobileMenuOpen}
    <button type="button" class="mobile-backdrop" aria-label="Close menu" onclick={closeMobile}></button>
    <div class="mobile-menu" role="dialog" aria-modal="true" aria-label="Site menu">
      <nav class="mobile-nav" aria-label="Mobile">
        <div class="mobile-nav-section">
          <button type="button" onclick={() => scrollToSection('features')}>Features</button>
          <button type="button" onclick={() => scrollToSection('preview')}>Preview</button>
        </div>

        <div class="mobile-nav-section">
          <span class="mobile-group-label">Learn</span>
          <div class="mobile-subnav">
            {#each learnLinks as link}
              <a href={link.href} onclick={closeMobile}>{link.label}</a>
            {/each}
          </div>
        </div>

        <div class="mobile-nav-section">
          <a href="/blog" onclick={closeMobile}>Blog</a>
          <button type="button" onclick={goPrivacy}>Privacy</button>
        </div>
      </nav>

      <div class="mobile-actions">
        <button type="button" class="download-btn mobile-download" onclick={() => scrollToSection('download')}>
          <Download size={16} color="#000" />
          <span>Download</span>
        </button>
        <a class="github-btn mobile-github" href={links.github} target="_blank" rel="noopener noreferrer">
          <Star size={16} />
          <span>Star on GitHub</span>
          <span class="star-count" aria-label={`${starCountLabel} GitHub stars`}>
            {starCountLabel}
          </span>
        </a>
        <a
          class="ph-btn mobile-ph"
          href={links.productHuntReview}
          target="_blank"
          rel="noopener noreferrer"
          onclick={() => {
            trackProductHunt();
            closeMobile();
          }}
        >
          <BrandIcon icon={siProducthunt} size={16} color="currentColor" />
          <span>Review on Product Hunt</span>
        </a>
      </div>
    </div>
  {/if}
</header>

<style>
  .navbar {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 100;
    background: color-mix(in srgb, var(--bg) 92%, transparent);
    transition: backdrop-filter 0.2s, background 0.2s;
  }

  .navbar.scrolled {
    backdrop-filter: blur(12px);
    background: color-mix(in srgb, var(--bg) 88%, transparent);
  }

  .nav-inner {
    display: flex;
    align-items: center;
    padding: 16px 0;
  }

  .brand {
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 20px;
    font-weight: 700;
    color: var(--text);
  }

  .brand img {
    border-radius: 8px;
  }

  .spacer {
    flex: 1;
  }

  .desktop-links {
    display: none;
    align-items: center;
    gap: 32px;
  }

  .desktop-links button,
  .desktop-links .nav-link {
    font-size: 14px;
    font-weight: 500;
    color: color-mix(in srgb, var(--text) 65%, transparent);
    transition: color 0.2s;
  }

  .desktop-links button:hover,
  .desktop-links .nav-link:hover {
    color: var(--text);
  }

  .desktop-links .download-btn,
  .mobile-menu .download-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 10px 18px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 700;
    line-height: 1;
    color: #000;
    background: color-mix(in srgb, var(--accent) 92%, transparent);
    transition: background 0.2s, box-shadow 0.2s;
  }

  .desktop-links .download-btn:hover,
  .mobile-menu .download-btn:hover {
    color: #000;
    background: var(--accent);
    box-shadow: 0 4px 20px color-mix(in srgb, var(--accent) 26%, transparent);
  }

  .dropdown {
    position: relative;
  }

  .dropdown-trigger {
    display: inline-flex;
    align-items: center;
    gap: 4px;
  }

  .dropdown-menu {
    position: absolute;
    top: calc(100% + 12px);
    left: 50%;
    transform: translateX(-50%) translateY(6px);
    min-width: 200px;
    display: flex;
    flex-direction: column;
    padding: 8px;
    border-radius: 14px;
    border: 1px solid color-mix(in srgb, var(--border) 70%, transparent);
    background: color-mix(in srgb, var(--surface) 96%, transparent);
    backdrop-filter: blur(12px);
    box-shadow: 0 12px 32px rgba(0, 0, 0, 0.28);
    opacity: 0;
    visibility: hidden;
    transition: opacity 0.18s, transform 0.18s, visibility 0.18s;
    z-index: 200;
  }

  .dropdown:hover .dropdown-menu,
  .dropdown:focus-within .dropdown-menu {
    opacity: 1;
    visibility: visible;
    transform: translateX(-50%) translateY(0);
  }

  .dropdown-menu a {
    padding: 10px 12px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    color: color-mix(in srgb, var(--text) 75%, transparent);
    transition: background 0.15s, color 0.15s;
  }

  .dropdown-menu a:hover {
    background: color-mix(in srgb, var(--accent) 12%, transparent);
    color: var(--accent);
  }

  .icon-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    color: color-mix(in srgb, var(--text) 70%, transparent);
    padding: 4px;
  }

  .github-btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 9px 14px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    line-height: 1;
    color: color-mix(in srgb, var(--text) 82%, transparent);
    background: var(--surface-alt);
    border: 1px solid var(--border);
    transition: background 0.2s, color 0.2s, border-color 0.2s;
  }

  .github-btn:hover {
    color: var(--text);
    background: color-mix(in srgb, var(--surface-alt) 90%, var(--accent) 10%);
    border-color: color-mix(in srgb, var(--border) 70%, var(--accent) 30%);
  }

  .ph-btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 9px 14px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    line-height: 1;
    color: color-mix(in srgb, var(--text) 82%, transparent);
    background: var(--surface-alt);
    border: 1px solid var(--border);
    transition: background 0.2s, color 0.2s, border-color 0.2s;
  }

  .ph-btn:hover {
    color: var(--accent);
    background: color-mix(in srgb, var(--surface-alt) 90%, var(--accent) 10%);
    border-color: color-mix(in srgb, var(--border) 70%, var(--accent) 30%);
  }

  .star-count {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 22px;
    height: 20px;
    padding: 0 6px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 700;
    color: var(--accent);
    background: color-mix(in srgb, var(--accent) 12%, transparent);
  }

  .mobile-controls {
    display: flex;
    align-items: center;
    gap: 4px;
  }

  .mobile-backdrop {
    position: fixed;
    inset: 68px 0 0;
    z-index: 90;
    border: 0;
    background: rgba(0, 0, 0, 0.55);
    backdrop-filter: blur(2px);
  }

  .mobile-menu {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    z-index: 95;
    display: flex;
    flex-direction: column;
    max-height: calc(100dvh - 68px - env(safe-area-inset-top, 0px));
    padding: 8px 16px calc(20px + env(safe-area-inset-bottom, 0px));
    border-top: 1px solid var(--border);
    background: color-mix(in srgb, var(--bg) 97%, transparent);
    backdrop-filter: blur(16px);
    box-shadow: 0 24px 48px rgba(0, 0, 0, 0.35);
    overflow: hidden;
  }

  .mobile-nav {
    display: flex;
    flex-direction: column;
    gap: 4px;
    overflow-y: auto;
    overscroll-behavior: contain;
  }

  .mobile-nav-section {
    display: flex;
    flex-direction: column;
    gap: 2px;
    padding: 4px 0;
  }

  .mobile-nav-section + .mobile-nav-section {
    margin-top: 4px;
    padding-top: 12px;
    border-top: 1px solid color-mix(in srgb, var(--border) 70%, transparent);
  }

  .mobile-nav button,
  .mobile-nav a {
    display: flex;
    align-items: center;
    width: 100%;
    min-height: 44px;
    padding: 10px 12px;
    border-radius: 10px;
    text-align: left;
    font-size: 16px;
    font-weight: 500;
    color: color-mix(in srgb, var(--text) 88%, transparent);
    transition: background 0.15s, color 0.15s;
  }

  .mobile-nav button:hover,
  .mobile-nav a:hover {
    background: color-mix(in srgb, var(--surface-alt) 80%, transparent);
    color: var(--text);
  }

  .mobile-group-label {
    padding: 0 12px 6px;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    color: var(--accent);
  }

  .mobile-subnav {
    display: flex;
    flex-direction: column;
    gap: 2px;
    padding: 6px;
    border-radius: 12px;
    border: 1px solid color-mix(in srgb, var(--border) 80%, transparent);
    background: color-mix(in srgb, var(--surface-alt) 88%, transparent);
  }

  .mobile-subnav a {
    min-height: 42px;
    font-size: 15px;
    color: color-mix(in srgb, var(--text) 78%, transparent);
  }

  .mobile-actions {
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin-top: 16px;
    padding-top: 16px;
    border-top: 1px solid color-mix(in srgb, var(--border) 70%, transparent);
  }

  .mobile-download,
  .mobile-github,
  .mobile-ph {
    width: 100%;
    justify-content: center;
  }

  .mobile-github {
    margin-top: 0;
  }

  .mobile-ph {
    margin-top: 0;
  }

  .mobile-download {
    margin-top: 0;
  }

  @media (min-width: 600px) {
    .desktop-links {
      display: flex;
    }

    .mobile-controls,
    .mobile-menu,
    .mobile-backdrop {
      display: none;
    }
  }
</style>
