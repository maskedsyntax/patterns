export const IOS_APP_ID = '6762611172';
export const ANDROID_PACKAGE = 'com.maskedsyntax.patterns';

const DISMISS_KEY = 'patterns-app-banner-dismissed';

export function isIOS(): boolean {
  if (typeof navigator === 'undefined') return false;
  return (
    /iPad|iPhone|iPod/.test(navigator.userAgent) ||
    (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1)
  );
}

/** True when Mobile Safari can show the native Smart App Banner. */
export function isIOSSafari(): boolean {
  if (!isIOS()) return false;
  const ua = navigator.userAgent;
  return /Safari/.test(ua) && !/CriOS|FxiOS|OPiOS|EdgiOS/.test(ua);
}

export function isAndroid(): boolean {
  if (typeof navigator === 'undefined') return false;
  return /Android/.test(navigator.userAgent);
}

export function isStandalone(): boolean {
  if (typeof window === 'undefined') return false;
  return (
    window.matchMedia('(display-mode: standalone)').matches ||
    // iOS Safari legacy standalone flag when added to Home Screen
    ('standalone' in navigator && (navigator as Navigator & { standalone?: boolean }).standalone === true)
  );
}

export function isInstallBannerDismissed(): boolean {
  if (typeof localStorage === 'undefined') return false;
  return localStorage.getItem(DISMISS_KEY) === '1';
}

export function dismissInstallBanner(): void {
  localStorage.setItem(DISMISS_KEY, '1');
}

/** Custom banner for Android and non-Safari iOS browsers. Safari uses the native Smart App Banner. */
export function shouldShowCustomInstallBanner(): boolean {
  if (typeof window === 'undefined') return false;
  if (isStandalone() || isInstallBannerDismissed()) return false;
  if (isIOSSafari()) return false;
  return isIOS() || isAndroid();
}
