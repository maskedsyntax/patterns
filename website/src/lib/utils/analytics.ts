declare function gtag(
  command: 'event',
  eventName: string,
  parameters?: Record<string, string>
): void;

export function logEvent(name: string, parameters?: Record<string, string>) {
  try {
    if (typeof gtag === 'function') {
      gtag('event', name, parameters);
    }
  } catch {
    // Analytics may be blocked
  }
}

export function logDownload(platform: string, version: string) {
  logEvent('download', { platform, version });
}

export function logGitHubClick() {
  logEvent('github_click');
}
