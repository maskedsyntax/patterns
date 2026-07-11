import { error } from '@sveltejs/kit';
import { getPost, posts } from '$lib/data/blog';
import type { EntryGenerator, PageLoad } from './$types';

// Enumerate every post so the static adapter prerenders each blog URL.
export const entries: EntryGenerator = () => posts.map((post) => ({ slug: post.slug }));

export const load: PageLoad = ({ params }) => {
  const post = getPost(params.slug);
  if (!post) {
    throw error(404, 'Post not found');
  }
  return { post };
};
