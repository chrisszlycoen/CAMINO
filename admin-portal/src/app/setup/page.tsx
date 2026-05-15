'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { getSupabase } from '@/lib/supabase';
import { useAuth } from '@/lib/auth';

export default function SetupPage() {
  const { user, requiresSetup, loading, refreshProfile } = useAuth();
  const router = useRouter();
  const [name, setName] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (!loading && !user) {
      router.push('/login');
    }
    if (!loading && user && !requiresSetup) {
      router.push('/dashboard');
    }
  }, [loading, user, requiresSetup, router]);

  if (loading || !user || !requiresSetup) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-700" />
      </div>
    );
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError('');

    if (!user) return;
    if (user.requiresNameChange && !name.trim()) {
      setError('Name is required');
      return;
    }
    if (user.requiresPasswordChange) {
      if (!password || password.length < 6) {
        setError('Password must be at least 6 characters');
        return;
      }
      if (password !== confirmPassword) {
        setError('Passwords do not match');
        return;
      }
    }

    setSaving(true);
    try {
      const supabase = getSupabase();
      const updates: Record<string, any> = {};

      if (user.requiresNameChange && name.trim()) {
        updates.name = name.trim();
        updates.requires_name_change = false;
      }

      if (user.requiresPasswordChange && password) {
        const { error: pwdErr } = await supabase.auth.updateUser({ password });
        if (pwdErr) throw pwdErr;
        updates.requires_password_change = false;
      }

      if (Object.keys(updates).length > 0) {
        const { error: updateErr } = await supabase
          .from('profiles')
          .update(updates)
          .eq( 'id', user.id);
        if (updateErr) throw updateErr;
      }

      await refreshProfile();
      router.push('/dashboard');
    } catch (err: any) {
      setError(err.message || 'Setup failed');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <div className="bg-white rounded-2xl shadow-sm border border-gray-200 p-8">
          <div className="text-center mb-8">
            <div className="w-16 h-16 bg-emerald-700 rounded-xl flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <h1 className="text-2xl font-bold text-gray-900">Complete Your Setup</h1>
            <p className="text-gray-500 mt-1">Set your name and password before continuing.</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            {user.requiresNameChange && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none"
                  placeholder="Enter your full name"
                />
              </div>
            )}

            {user.requiresPasswordChange && (
              <>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">New Password</label>
                  <input
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none"
                    placeholder="Min. 6 characters"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Confirm Password</label>
                  <input
                    type="password"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none"
                    placeholder="Repeat your password"
                  />
                </div>
              </>
            )}

            {error && (
              <p className="text-red-500 text-sm">{error}</p>
            )}

            <button
              type="submit"
              disabled={saving}
              className="w-full py-2.5 bg-emerald-700 text-white rounded-lg font-semibold hover:bg-emerald-800 disabled:opacity-50 transition-colors"
            >
              {saving ? 'Saving...' : 'Complete Setup'}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
