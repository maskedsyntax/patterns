<script lang="ts">
  import Seo from '$lib/components/Seo.svelte';
  import ContentContainer from '$lib/components/ContentContainer.svelte';
  import AnimatedOnScroll from '$lib/components/AnimatedOnScroll.svelte';
  import { postsByDate } from '$lib/data/blog';
  import { links } from '$lib/data/links';
  import { PenLine, ArrowRight } from 'lucide-svelte';

  const dateFmt = new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });

  const jsonLd = [
    {
      '@context': 'https://schema.org',
      '@type': 'Blog',
      name: 'The Patterns Blog',
      description:
        'Personal essays from the person building Patterns - someone who lives with OCD - for everyone else working through the same thoughts and feelings.',
      url: `${links.site}blog`,
      publisher: { '@type': 'Organization', name: 'MaskedSyntax', url: links.maskedsyntax },
      blogPost: postsByDate.map((post) => ({
        '@type': 'BlogPosting',
        headline: post.title,
        description: post.description,
        datePublished: post.date,
        url: `${links.site}blog/${post.slug}`
      }))
    },
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: 'Home', item: links.site },
        { '@type': 'ListItem', position: 2, name: 'Blog', item: `${links.site}blog` }
      ]
    }
  ];
</script>

<Seo
  title="The Patterns Blog - Living with OCD, and building the tool for it"
  description="Personal essays from the person building Patterns, written from the point of view of someone who lives with OCD - on the loop, ERP, privacy, and doing the work."
  path="blog"
  keywords="OCD blog, living with OCD, ERP experience, intrusive thoughts, OCD recovery, building an OCD app"
  {jsonLd}
/>

<article class="blog section-pad">
  <ContentContainer>
    <AnimatedOnScroll>
      <div class="head">
        <div class="icon-tile">
          <PenLine size={34} color="var(--accent)" strokeWidth={1.75} />
        </div>
        <p class="eyebrow">The Patterns blog</p>
        <h1 class="title serif">Notes from inside the loop.</h1>
        <p class="intro">
          I have OCD, and I am building Patterns for everyone else who does. These are
          personal essays - not clinical advice - about the loop, the work, and why the
          app is built the way it is. Written by one person in it, for anyone else in it.
        </p>
      </div>
    </AnimatedOnScroll>

    <div class="list">
      {#each postsByDate as post, i}
        <AnimatedOnScroll delay={i * 80}>
          <a class="post-card" href="/blog/{post.slug}">
            <div class="meta">
              <time datetime={post.date}>{dateFmt.format(new Date(post.date))}</time>
              <span aria-hidden="true">·</span>
              <span>{post.readingMinutes} min read</span>
            </div>
            <h2>{post.title}</h2>
            <p>{post.excerpt}</p>
            <span class="read">Read post <ArrowRight size={16} /></span>
          </a>
        </AnimatedOnScroll>
      {/each}
    </div>

    <div class="back-wrap"><a href="/">← Back to Home</a></div>
  </ContentContainer>
</article>

<style>
  .blog {
    background: var(--surface);
  }

  .head {
    max-width: 720px;
    margin: 0 auto 48px;
    text-align: center;
  }

  .icon-tile {
    width: 80px;
    height: 80px;
    margin: 0 auto 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 20px;
    background: color-mix(in srgb, var(--accent) 10%, transparent);
  }

  .eyebrow {
    margin: 0 0 12px;
    font-size: 13px;
    font-weight: 600;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--accent);
  }

  .title {
    margin: 0;
    font-size: 46px;
    line-height: 1.1;
  }

  .intro {
    margin: 20px auto 0;
    max-width: 620px;
    font-size: 19px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  .list {
    max-width: 760px;
    margin: 0 auto;
    display: grid;
    gap: 20px;
  }

  .post-card {
    display: block;
    padding: 28px;
    border-radius: 18px;
    border: 1px solid color-mix(in srgb, var(--border) 50%, transparent);
    background: var(--bg);
    transition: border-color 0.25s, transform 0.25s;
  }

  .post-card:hover {
    border-color: color-mix(in srgb, var(--accent) 40%, transparent);
    transform: translateY(-2px);
  }

  .meta {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 13px;
    color: var(--text-secondary);
  }

  .post-card h2 {
    margin: 12px 0 0;
    font-size: 24px;
    line-height: 1.25;
    color: var(--text);
  }

  .post-card p {
    margin: 10px 0 0;
    font-size: 16px;
    line-height: 1.6;
    color: var(--text-secondary);
  }

  .read {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    margin-top: 18px;
    font-size: 14px;
    font-weight: 600;
    color: var(--accent);
  }

  .back-wrap {
    text-align: center;
    margin-top: 48px;
  }

  .back-wrap a {
    font-weight: 600;
    color: var(--accent);
  }

  @media (max-width: 599px) {
    .title {
      font-size: 34px;
    }

    .intro {
      font-size: 16px;
    }

    .post-card h2 {
      font-size: 20px;
    }
  }
</style>
