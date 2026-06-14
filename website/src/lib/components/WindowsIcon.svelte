<script lang="ts">
  let {
    size = 24,
    color = 'currentColor'
  }: {
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
  <path
    d="M0 0h11.377v11.372H0V0Zm12.623 0H24v11.372H12.623V0ZM0 12.623h11.377V24H0v-11.377Zm12.623 0H24V24H12.623v-11.377Z"
  />
</svg>
