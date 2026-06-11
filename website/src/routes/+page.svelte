<script lang="ts">
  import Hero from '$lib/sections/Hero.svelte';
  import Features from '$lib/sections/Features.svelte';
  import Preview from '$lib/sections/Preview.svelte';
  import Download from '$lib/sections/Download.svelte';
  import Support from '$lib/sections/Support.svelte';
  import Footer from '$lib/sections/Footer.svelte';

  function scrollToDownload() {
    document.getElementById('download')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }
</script>

<Hero onDownload={scrollToDownload} />
<Features />
<Preview />
<Download />
<Support />
<Footer />
