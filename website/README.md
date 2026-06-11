# Patterns Website

Marketing site for [Patterns](https://patterns.maskedsyntax.com/), built with SvelteKit and deployed to GitHub Pages.

## Development

```bash
cd website
npm install
npm run dev
```

Open [http://localhost:5173](http://localhost:5173).

## Build

```bash
npm run build
npm run preview
```

Static output is written to `build/`.

## Deploy

Pushes to `master` that change `website/**` trigger the GitHub Actions workflow at `.github/workflows/deploy-website.yml`.
