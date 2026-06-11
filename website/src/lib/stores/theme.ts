import { browser } from '$app/environment';
import { writable } from 'svelte/store';

export type Theme = 'dark' | 'light';

const STORAGE_KEY = 'patterns-theme';

function getInitialTheme(): Theme {
  if (!browser) return 'dark';
  const stored = localStorage.getItem(STORAGE_KEY);
  if (stored === 'light' || stored === 'dark') return stored;
  return 'dark';
}

function createThemeStore() {
  const { subscribe, set, update } = writable<Theme>(getInitialTheme());

  return {
    subscribe,
    toggle: () =>
      update((current) => {
        const next = current === 'dark' ? 'light' : 'dark';
        if (browser) {
          localStorage.setItem(STORAGE_KEY, next);
          document.documentElement.dataset.theme = next;
        }
        return next;
      }),
    init: () => {
      if (!browser) return;
      const theme = getInitialTheme();
      document.documentElement.dataset.theme = theme;
      set(theme);
    }
  };
}

export const theme = createThemeStore();
