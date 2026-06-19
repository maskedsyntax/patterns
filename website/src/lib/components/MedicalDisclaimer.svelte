<script lang="ts">
  import { Info } from 'lucide-svelte';

  let { compact = false }: { compact?: boolean } = $props();
</script>

<aside class="disclaimer" class:compact aria-label="Health disclaimer">
  <Info size={compact ? 18 : 20} color="var(--accent)" strokeWidth={1.75} />
  <p>
    Patterns is a self-reflection and tracking tool. It supports your own journaling
    and ERP practice — it does not diagnose, treat, or cure OCD, and it is
    <strong>not a substitute for care from a qualified clinician</strong>. If you're
    struggling, reaching out to a mental health professional is a sign of strength.
  </p>
</aside>

<style>
  .disclaimer {
    display: flex;
    gap: 12px;
    align-items: flex-start;
    padding: 18px 20px;
    border-radius: 14px;
    border: 1px solid color-mix(in srgb, var(--accent) 24%, transparent);
    background: color-mix(in srgb, var(--accent) 7%, transparent);
  }

  .disclaimer :global(svg) {
    flex-shrink: 0;
    margin-top: 2px;
  }

  .disclaimer p {
    margin: 0;
    font-size: 14px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  .disclaimer strong {
    color: var(--text);
    font-weight: 600;
  }

  .compact {
    padding: 14px 16px;
  }

  .compact p {
    font-size: 13px;
  }
</style>
