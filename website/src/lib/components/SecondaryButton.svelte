<script lang="ts">
  import type { LucideIcon } from '$lib/types/icons';

  let {
    label,
    icon: Icon,
    onclick,
    fullWidth = false
  }: {
    label: string;
    icon: LucideIcon;
    onclick: () => void;
    fullWidth?: boolean;
  } = $props();
</script>

<button
  type="button"
  class="secondary-btn"
  class:full-width={fullWidth}
  {onclick}
>
  <Icon size={16} />
  <span>{label}</span>
</button>

<style>
  .secondary-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 14px 22px;
    border-radius: 12px;
    font-size: 14px;
    font-weight: 600;
    color: color-mix(in srgb, var(--text) 80%, transparent);
    background: var(--surface-alt);
    border: 1px solid var(--border);
    transition:
      background 0.2s,
      color 0.2s;
  }

  .secondary-btn:hover {
    background: color-mix(in srgb, var(--surface-alt) 92%, var(--accent) 8%);
    color: var(--text);
  }

  .full-width {
    width: 224px;
    max-width: 100%;
  }
</style>
