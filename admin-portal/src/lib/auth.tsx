'use client';

import { createContext, useContext, useState, useEffect, useCallback, ReactNode } from 'react';
import { useRouter } from 'next/navigation';
import { getSupabase } from './supabase';
import type { AuthUser } from './types';

const STORAGE_KEY = 'camino_auth';

interface AuthContextType {
  user: AuthUser | null;
  isAuthenticated: boolean;
  loading: boolean;
  requiresSetup: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  clearSetupFlag: () => void;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);
  const [requiresSetup, setRequiresSetup] = useState(false);
  const router = useRouter();

  const fetchProfile = useCallback(async (su: any) => {
    try {
      const supabase = getSupabase();
      const { data } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', su.id)
        .single();

      if (data) {
        const authUser: AuthUser = {
          id: data.id,
          email: su.email || '',
          name: data.name || su.email?.split('@')[0] || 'User',
          role: data.role as AuthUser['role'],
          requiresPasswordChange: data.requires_password_change ?? true,
          requiresNameChange: data.requires_name_change ?? true,
        };
        setUser(authUser);
        const needsSetup = !!(authUser.requiresPasswordChange || authUser.requiresNameChange);
        setRequiresSetup(needsSetup);
        if (needsSetup && window.location.pathname !== '/setup') {
          router.push('/setup');
        }
      }
    } catch {
      setUser(null);
    }
    setLoading(false);
  }, [router]);

  useEffect(() => {
    const supabase = getSupabase();

    supabase.auth.getSession().then(({ data: { session } }: any) => {
      if (session?.user) {
        fetchProfile(session.user);
      } else {
        setLoading(false);
      }
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event: string, session: any) => {
      if (session?.user) {
        fetchProfile(session.user);
      } else {
        setUser(null);
        setRequiresSetup(false);
        setLoading(false);
      }
    });

    return () => subscription.unsubscribe();
  }, [fetchProfile]);

  const login = useCallback(async (email: string, password: string) => {
    const supabase = getSupabase();
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw error;
  }, []);

  const logout = useCallback(async () => {
    const supabase = getSupabase();
    await supabase.auth.signOut();
    setUser(null);
    setRequiresSetup(false);
  }, []);

  const clearSetupFlag = useCallback(() => {
    setRequiresSetup(false);
  }, []);

  const refreshProfile = useCallback(async () => {
    const supabase = getSupabase();
    const { data: { user: su } } = await supabase.auth.getUser();
    if (su) {
      await fetchProfile(su);
    }
  }, [fetchProfile]);

  return (
    <AuthContext.Provider value={{ user, isAuthenticated: user !== null, loading, requiresSetup, login, logout, clearSetupFlag, refreshProfile }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be inside AuthProvider');
  return ctx;
}
