'use client';

import { createContext, useContext, useState, useEffect, useCallback, ReactNode } from 'react';
import type { AuthUser } from './types';

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
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);

  useEffect(() => {
    const stored = sessionStorage.getItem(STORAGE_KEY);
    if (stored) try { setUser(JSON.parse(stored)); } catch { sessionStorage.removeItem(STORAGE_KEY); }
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    await new Promise(r => setTimeout(r, 600));
    const found = VALID_USERS.find(u => u.email === email.toLowerCase().trim() && u.password === password);
    if (!found) throw new Error('Invalid email or password');
    const { password: _, ...authUser } = found;
    sessionStorage.setItem(STORAGE_KEY, JSON.stringify(authUser));
    setUser(authUser);
  }, []);

  const logout = useCallback(() => {
    sessionStorage.removeItem(STORAGE_KEY);
    setUser(null);
  }, []);

  return (
    <AuthContext.Provider value={{ user, isAuthenticated: user !== null, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be inside AuthProvider');
  return ctx;
}
