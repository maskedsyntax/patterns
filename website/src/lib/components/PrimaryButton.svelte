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
  class="primary-btn"
  class:full-width={fullWidth}
  {onclick}
>
  <Icon size={16} color="#000" />
  <span>{label}</span>
</button>

<style>
  .primary-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 14px 22px;
    border-radius: 12px;
    font-size: 14px;
    font-weight: 600;
    color: #000;
    background: color-mix(in srgb, var(--accent) 90%, transparent);
    transition:
      background 0.2s,
      box-shadow 0.2s;
  }

  .primary-btn:hover {
    background: var(--accent);
    box-shadow: 0 4px 20px color-mix(in srgb, var(--accent) 30%, transparent);
  }

  .full-width {
    width: 224px;
    max-width: 100%;
  }
</style>
