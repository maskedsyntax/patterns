<script lang="ts">
  import type { Snippet } from 'svelte';

  let {
    children,
    delay = 0
  }: {
    children: Snippet;
    delay?: number;
  } = $props();

  let visible = $state(false);
  let el: HTMLElement;

  $effect(() => {
    if (!el) return;
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          visible = true;
          observer.disconnect();
        }
      },
      { threshold: 0.1, rootMargin: '0px 0px -40px 0px' }
    );
    observer.observe(el);
    return () => observer.disconnect();
  });
</script>

<div
  bind:this={el}
  class="animate-on-scroll"
  class:visible
  style="--delay: {delay}ms"
>
  {@render children()}
</div>
