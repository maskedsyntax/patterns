<script lang="ts">
  import type { Snippet } from 'svelte';

  let {
    children,
    class: className = '',
    padding
  }: {
    children: Snippet;
    class?: string;
    padding?: string;
  } = $props();
</script>

<div class="content-container {className}" style:padding>
  {@render children()}
</div>

<style>
  .content-container {
    width: calc(100% - 32px);
    max-width: 100%;
    margin-inline: auto;
  }

  @media (min-width: 600px) {
    .content-container {
      width: 90%;
    }
  }

  @media (min-width: 1024px) {
    .content-container {
      width: 85%;
    }
  }

  @media (min-width: 1400px) {
    .content-container {
      width: 1200px;
    }
  }
</style>
