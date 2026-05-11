'use client';

import { createContext, useContext, useState, useEffect, useCallback, ReactNode } from 'react';
import { getSupabase } from './supabase';
import type { AuthUser } from './types';


const SUPABASE_CONFIGURED = !!(process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);

const STORAGE_KEY = 'camino_auth';

const VALID_USERS: (AuthUser & { password: string })[] = [
  { id: 'ADM-001', email: 'admin@camino.rw', name: 'Admin User', role: 'admin', password: 'admin123' },
  { id: 'STU-001', email: 'student@camino.rw', name: 'Jean Niyonzima', role: 'student', password: 'student123' },
  { id: 'STF-001', email: 'staff@camino.rw', name: 'Jean Baptiste', role: 'staff', password: 'staff123' },
  { id: 'PAR-001', email: 'parent@camino.rw', name: 'Sarah Uwimana', role: 'parent', password: 'parent123' },
  { id: 'STF-002', email: 'driver@camino.rw', name: 'Alex Rukundo', role: 'staff', password: 'driver123' },
];

interface AuthContextType {
  user: AuthUser | null;
  isAuthenticated: boolean;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(!SUPABASE_CONFIGURED);

  useEffect(() => {
    if (!SUPABASE_CONFIGURED) {
      const stored = sessionStorage.getItem(STORAGE_KEY);
      if (stored) try { setUser(JSON.parse(stored)); } catch { sessionStorage.removeItem(STORAGE_KEY); }
      setLoading(false);
      return;
    }

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
        setLoading(false);
      }
    });

    return () => subscription.unsubscribe();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function fetchProfile(su: any) {
    try {
      const supabase = getSupabase();
      const { data } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', su.id)
        .single();

      if (data) {
        setUser({
          id: data.id,
          email: su.email || '',
          name: data.name || su.email?.split('@')[0] || 'User',
          role: data.role as AuthUser['role'],
        });
      }
    } catch {
      setUser({
        id: su.id,
        email: su.email || '',
        name: su.email?.split('@')[0] || 'User',
        role: 'parent',
      });
    }
    setLoading(false);
  }

  const login = useCallback(async (email: string, password: string) => {
    if (!SUPABASE_CONFIGURED) {
      await new Promise(r => setTimeout(r, 400));
      const found = VALID_USERS.find(u => u.email === email.toLowerCase().trim() && u.password === password);
      if (!found) throw new Error('Invalid email or password');
      const { password: _, ...authUser } = found;
      sessionStorage.setItem(STORAGE_KEY, JSON.stringify(authUser));
      setUser(authUser);
      return;
    }

    const supabase = getSupabase();
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw error;
  }, []);

  const logout = useCallback(async () => {
    if (!SUPABASE_CONFIGURED) {
      sessionStorage.removeItem(STORAGE_KEY);
      setUser(null);
      return;
    }
    const supabase = getSupabase();
    await supabase.auth.signOut();
    setUser(null);
  }, []);

  return (
    <AuthContext.Provider value={{ user, isAuthenticated: user !== null, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be inside AuthProvider');
  return ctx;
}
