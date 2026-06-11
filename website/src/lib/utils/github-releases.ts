export type ReleaseAssets = {
  linuxUrl: string | null;
  windowsUrl: string | null;
  version: string | null;
};

export async function fetchLatestRelease(): Promise<ReleaseAssets> {
  try {
    const response = await fetch(
      'https://api.github.com/repos/maskedsyntax/patterns/releases/latest',
      { headers: { Accept: 'application/vnd.github+json' } }
    );
    if (!response.ok) {
      return { linuxUrl: null, windowsUrl: null, version: null };
    }
    const data = await response.json();
    let linuxUrl: string | null = null;
    let windowsUrl: string | null = null;
    for (const asset of data.assets ?? []) {
      const name = asset.name as string;
      const url = asset.browser_download_url as string;
      if (name.endsWith('.deb')) linuxUrl = url;
      if (name.endsWith('.exe')) windowsUrl = url;
    }
    return {
      linuxUrl,
      windowsUrl,
      version: (data.tag_name as string) ?? null
    };
  } catch {
    return { linuxUrl: null, windowsUrl: null, version: null };
  }
}
