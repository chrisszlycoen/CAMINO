'use client';

const memoryCache = new Map<string, { data: any; timestamp: number }>();

export async function cacheSet(key: string, data: any): Promise<void> {
  memoryCache.set(key, { data, timestamp: Date.now() });
}

export async function cacheGet<T>(key: string, maxAgeMs = 300000): Promise<T | null> {
  const entry = memoryCache.get(key);
  if (!entry) return null;
  if (Date.now() - entry.timestamp > maxAgeMs) {
    memoryCache.delete(key);
    return null;
  }
  return entry.data as T;
}

export async function cacheClear(): Promise<void> {
  memoryCache.clear();
}

export function isOnline(): boolean {
  return typeof navigator !== 'undefined' ? navigator.onLine : true;
}

export function onOnline(callback: () => void): () => void {
  window.addEventListener('online', callback);
  return () => window.removeEventListener('online', callback);
}

export function onOffline(callback: () => void): () => void {
  window.addEventListener('offline', callback);
  return () => window.removeEventListener('offline', callback);
}
