<script lang="ts">
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { theme } from '$lib/stores/theme';
  import { links } from '$lib/data/links';
  import ContentContainer from './ContentContainer.svelte';
  import { Menu, X, Sun, Moon, Star } from 'lucide-svelte';

  let {
    onNavigate
  }: {
    onNavigate?: (section: string) => void;
  } = $props();

  let mobileMenuOpen = $state(false);
  let scrolled = $state(false);

  $effect(() => {
    const onScroll = () => {
      scrolled = window.scrollY > 8;
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
    return () => window.removeEventListener('scroll', onScroll);
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
        <button type="button" onclick={() => scrollToSection('preview')}>Preview</button>
        <button type="button" onclick={goPrivacy}>Privacy</button>
        <button type="button" onclick={() => scrollToSection('download')}>Download</button>
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
        <a class="github-btn" href={links.github} target="_blank" rel="noopener noreferrer">
          <Star size={16} color="#000" />
          <span>Star on GitHub</span>
        </a>
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
    <div class="mobile-menu">
      <button type="button" onclick={() => scrollToSection('features')}>Features</button>
      <button type="button" onclick={() => scrollToSection('preview')}>Preview</button>
      <button type="button" onclick={goPrivacy}>Privacy</button>
      <button type="button" onclick={() => scrollToSection('download')}>Download</button>
      <a class="github-btn mobile-github" href={links.github} target="_blank" rel="noopener noreferrer">
        <Star size={16} color="#000" />
        <span>Star on GitHub</span>
      </a>
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

  .desktop-links button {
    font-size: 14px;
    font-weight: 500;
    color: color-mix(in srgb, var(--text) 65%, transparent);
    transition: color 0.2s;
  }

  .desktop-links button:hover {
    color: var(--text);
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
    gap: 6px;
    padding: 10px 20px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    color: #000;
    background: color-mix(in srgb, var(--accent) 90%, transparent);
    transition: background 0.2s;
  }

  .github-btn:hover {
    background: var(--accent);
  }

  .mobile-controls {
    display: flex;
    align-items: center;
    gap: 4px;
  }

  .mobile-menu {
    display: flex;
    flex-direction: column;
    padding: 16px 20px 24px;
    background: color-mix(in srgb, var(--bg) 98%, transparent);
  }

  .mobile-menu button {
    padding: 12px 0;
    text-align: left;
    font-size: 16px;
    font-weight: 500;
    color: color-mix(in srgb, var(--text) 80%, transparent);
  }

  .mobile-github {
    margin-top: 12px;
    align-self: flex-start;
  }

  @media (min-width: 600px) {
    .desktop-links {
      display: flex;
    }

    .mobile-controls,
    .mobile-menu {
      display: none;
    }
  }
</style>
