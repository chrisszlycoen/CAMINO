'use client';

import { getSupabase } from './supabase';
import type { RealtimePostgresChangesPayload } from '@supabase/supabase-js';

type Callback = (payload: RealtimePostgresChangesPayload<any>) => void;

export function subscribeToTable(
  table: string,
  event: 'INSERT' | 'UPDATE' | 'DELETE' | '*' = '*',
  callback: Callback,
  filter?: string,
) {
  const supabase = getSupabase();
  const channel = supabase
    .channel(`${table}-changes`)
    .on(
      'postgres_changes',
      { event, schema: 'public', table, filter } as any,
      (payload: any) => callback(payload),
    )
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
}

export function subscribeToBusLocation(busId: string, callback: Callback) {
  return subscribeToTable('bus_locations', 'INSERT', callback, `bus_id=eq.${busId}`);
}

export function subscribeToAlerts(callback: Callback) {
  return subscribeToTable('alerts', '*', callback);
}

export function subscribeToSchedules(callback: Callback) {
  return subscribeToTable('schedules', '*', callback);
}
