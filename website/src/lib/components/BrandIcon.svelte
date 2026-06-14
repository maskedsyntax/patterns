<script lang="ts">
  import type { SimpleIcon } from 'simple-icons';

  let {
    icon,
    size = 24,
    color = `#${icon.hex}`
  }: {
    icon: SimpleIcon;
    size?: number;
    color?: string;
  } = $props();
</script>

<svg
  role="img"
  viewBox="0 0 24 24"
  xmlns="http://www.w3.org/2000/svg"
  width={size}
  height={size}
  fill={color}
  aria-hidden="true"
>
  <path d={icon.path} />
</svg>
