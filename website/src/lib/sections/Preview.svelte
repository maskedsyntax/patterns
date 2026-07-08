<script lang="ts">
  import { onMount } from 'svelte';
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import AnimatedOnScroll from '$lib/components/AnimatedOnScroll.svelte';

  const desktopMockups = [
    '/assets/mockups/desktop-1.jpg',
    '/assets/mockups/desktop-2.jpg',
    '/assets/mockups/desktop-3.jpg',
    '/assets/mockups/desktop-4.jpg',
    '/assets/mockups/desktop-5.jpg'
  ];

  let carouselIndex = $state(0);
  let reducedMotion = $state(false);
  let isMobile = $state(false);

  onMount(() => {
    reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const mq = window.matchMedia('(max-width: 599px)');
    const update = () => (isMobile = mq.matches);
    update();
    mq.addEventListener('change', update);

    for (const src of desktopMockups) {
      const img = new Image();
      img.src = src;
    }

    const timer = setInterval(() => {
      if (!reducedMotion) {
        carouselIndex = (carouselIndex + 1) % desktopMockups.length;
      }
    }, 4000);

    return () => {
      mq.removeEventListener('change', update);
      clearInterval(timer);
    };
  });
</script>

{#snippet showcase(
  eyebrow: string,
  title: string,
  description: string,
  mockupOnLeft: boolean,
  desktop: boolean,
  mockup: import('svelte').Snippet
)}
  <div
    class="showcase"
    class:reverse={!mockupOnLeft && !isMobile}
    class:desktop-layout={desktop && !isMobile}
  >
    {#if isMobile || mockupOnLeft}
      <div class="mockup-slot" class:desktop-slot={desktop}>
        {@render mockup()}
      </div>
    {/if}
    <div class="copy">
      <span class="tag">{eyebrow}</span>
      <h3 class="serif">{title}</h3>
      <p>{description}</p>
    </div>
    {#if !isMobile && !mockupOnLeft}
      <div class="mockup-slot desktop-slot">
        {@render mockup()}
      </div>
    {/if}
  </div>
{/snippet}

{#snippet mobileGraphic()}
  <div class="mockup-wrap mobile-graphic">
    <img
      src="/assets/mockups/feature-graphic.jpg"
      alt="Patterns mobile preview"
      width="1024"
      height="500"
      loading="lazy"
    />
  </div>
{/snippet}

{#snippet desktopCarousel()}
  <div class="mockup-wrap desktop-carousel" aria-live="polite">
    {#each desktopMockups as src, i}
      <img
        class="carousel-image"
        class:active={i === carouselIndex}
        class:leaving={!reducedMotion && i === (carouselIndex - 1 + desktopMockups.length) % desktopMockups.length}
        {src}
        alt="Patterns desktop screenshot {i + 1}"
        width="1440"
        height="900"
        loading={i === 0 ? 'eager' : 'lazy'}
        fetchpriority={i === 0 ? 'high' : 'auto'}
      />
    {/each}
    <div class="carousel-dots" aria-hidden="true">
      {#each desktopMockups as _, i}
        <span class="dot" class:active={i === carouselIndex}></span>
      {/each}
    </div>
  </div>
{/snippet}

<section id="preview" class="preview section-pad section-scroll-margin content-below-fold" aria-labelledby="preview-title">
  <ContentContainer>
    <AnimatedOnScroll>
      <div class="header">
        <span class="eyebrow">PREVIEW</span>
        <h2 id="preview-title" class="title serif">See it in action</h2>
        <p class="subtitle">
          Real screens from Patterns - at home on mobile and on desktop. The journal, the OCD
          tracker, the analytics, and the settings.
        </p>
      </div>
    </AnimatedOnScroll>

    <div class="showcases">
      <AnimatedOnScroll delay={100}>
        {@render showcase(
          'MOBILE',
          'Pocket-sized reflection',
          'Capture obsessions, log distress, and write a quick journal entry - all from your phone. Your entries stay on your device, no accounts and no uploads.',
          true,
          false,
          mobileGraphic
        )}
      </AnimatedOnScroll>

      <AnimatedOnScroll delay={200}>
        {@render showcase(
          'DESKTOP',
          'Room to think',
          'See your patterns at a glance - analytics, history, and a calm writing space with the room a bigger screen gives you. Native on macOS, Windows, and Linux.',
          false,
          true,
          desktopCarousel
        )}
      </AnimatedOnScroll>
    </div>
  </ContentContainer>
</section>

<style>
  .preview {
    background: var(--bg);
  }

  .header {
    text-align: center;
    margin-bottom: 96px;
  }

  .eyebrow {
    display: inline-block;
    padding: 6px 14px;
    border-radius: 100px;
    border: 1px solid color-mix(in srgb, var(--accent) 25%, transparent);
    font-size: 12px;
    font-weight: 600;
    color: var(--accent);
    letter-spacing: 1.5px;
  }

  .title {
    margin: 20px 0 0;
    font-size: 48px;
    line-height: 1.1;
  }

  .subtitle {
    margin: 16px auto 0;
    max-width: 540px;
    font-size: 17px;
    color: var(--text-secondary);
    line-height: 1.5;
  }

  .showcases {
    display: flex;
    flex-direction: column;
    gap: 96px;
  }

  .showcase {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 32px;
  }

  .mockup-slot {
    width: 100%;
    display: flex;
    justify-content: center;
  }

  .mockup-wrap {
    border-radius: 24px;
    overflow: hidden;
    box-shadow: 0 20px 40px -8px color-mix(in srgb, #000 50%, transparent);
    width: 100%;
  }

  .mobile-graphic {
    max-width: 620px;
  }

  .mobile-graphic img {
    width: 100%;
    height: auto;
    display: block;
  }

  .desktop-carousel {
    position: relative;
    width: 100%;
    aspect-ratio: 1440 / 900;
    background: var(--surface-alt);
  }

  .carousel-image {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
    object-fit: cover;
    object-position: top center;
    opacity: 0;
    transform: scale(1.04);
    transition:
      opacity 1.1s cubic-bezier(0.45, 0.05, 0.2, 1),
      transform 1.4s cubic-bezier(0.45, 0.05, 0.2, 1);
    will-change: opacity, transform;
    z-index: 0;
  }

  .carousel-image.active {
    opacity: 1;
    transform: scale(1);
    z-index: 2;
  }

  .carousel-image.leaving {
    opacity: 0;
    transform: scale(1);
    z-index: 1;
    transition:
      opacity 1.1s cubic-bezier(0.45, 0.05, 0.2, 1),
      transform 1.4s cubic-bezier(0.45, 0.05, 0.2, 1);
  }

  .carousel-dots {
    position: absolute;
    bottom: 14px;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    gap: 7px;
    padding: 6px 10px;
    border-radius: 100px;
    background: color-mix(in srgb, #000 45%, transparent);
    backdrop-filter: blur(8px);
    z-index: 3;
  }

  .carousel-dots .dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.35);
    transition: background 0.4s ease, transform 0.4s ease;
  }

  .carousel-dots .dot.active {
    background: var(--accent);
    transform: scale(1.2);
  }

  @media (prefers-reduced-motion: reduce) {
    .carousel-image {
      transition: none;
      transform: none;
      will-change: auto;
    }

    .carousel-image:not(.active) {
      display: none;
    }
  }

  .copy {
    text-align: center;
    max-width: 480px;
  }

  .tag {
    display: inline-block;
    padding: 4px 10px;
    border-radius: 100px;
    border: 1px solid color-mix(in srgb, var(--accent) 28%, transparent);
    background: color-mix(in srgb, var(--accent) 10%, transparent);
    font-size: 11px;
    font-weight: 700;
    color: var(--accent);
    letter-spacing: 1.2px;
  }

  .copy h3 {
    margin: 16px 0 0;
    font-size: 36px;
    line-height: 1.15;
  }

  .copy p {
    margin: 14px 0 0;
    font-size: 16px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  @media (min-width: 600px) {
    .showcase {
      flex-direction: row;
      align-items: center;
      gap: 48px;
    }

    .showcase.reverse {
      flex-direction: row-reverse;
    }

    .mockup-slot {
      flex-shrink: 0;
      width: auto;
    }

    .copy {
      flex: 1;
      text-align: left;
      max-width: none;
    }

    .showcase.desktop-layout {
      gap: 56px;
    }

    .showcase.desktop-layout .copy {
      flex: 0 1 340px;
      max-width: 380px;
    }

    .showcase.desktop-layout .desktop-slot {
      flex: 1 1 62%;
      min-width: 0;
      max-width: 900px;
    }

    .desktop-carousel {
      min-height: 320px;
    }
  }

  @media (min-width: 1024px) {
    .showcase.desktop-layout {
      gap: 72px;
    }

    .showcase.desktop-layout .copy {
      flex: 0 1 360px;
    }

    .showcase.desktop-layout .desktop-slot {
      flex: 1 1 68%;
      max-width: 960px;
    }

    .desktop-carousel {
      min-height: 380px;
    }
  }

  @media (min-width: 1400px) {
    .showcase.desktop-layout .desktop-slot {
      max-width: 1040px;
    }
  }

  @media (max-width: 599px) {
    .header {
      margin-bottom: 56px;
    }

    .showcases {
      gap: 56px;
    }

    .title {
      font-size: 32px;
    }

    .subtitle {
      font-size: 15px;
    }

    .copy h3 {
      font-size: 28px;
    }

    .desktop-carousel {
      max-height: 220px;
    }
  }
</style>
