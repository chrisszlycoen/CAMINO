'use client';

import { useState } from 'react';
import DashboardLayout from '@/components/DashboardLayout';
import { useAuth } from '@/lib/auth';

export default function SettingsPage() {
  const { user } = useAuth();
  const [profile, setProfile] = useState({ name: user?.name || '', email: user?.email || '' });
  const [saved, setSaved] = useState(false);
  const [prefs, setPrefs] = useState({ emailAlerts: true, smsAlerts: false, darkReport: false, autoResolve: true });

  const saveProfile = () => { setSaved(true); setTimeout(() => setSaved(false), 2000); };

  return (
    <DashboardLayout>
      <div className="p-6 lg:p-8 animate-in max-w-3xl">
        <div className="mb-8">
          <h1 className="page-title">Settings</h1>
          <p className="page-subtitle">Manage your preferences and account</p>
        </div>

        <div className="data-card p-6 mb-6">
          <h2 className="text-lg font-bold mb-1">Profile Information</h2>
          <p className="text-sm text-gray-500 mb-6">Update your personal details</p>
          <div className="space-y-4 max-w-md">
            <div><label className="form-label">Full Name</label><input className="form-input" value={profile.name} onChange={e => setProfile({ ...profile, name: e.target.value })} /></div>
            <div><label className="form-label">Email</label><input className="form-input" type="email" value={profile.email} onChange={e => setProfile({ ...profile, email: e.target.value })} /></div>
            <div className="flex items-center gap-3">
              <button onClick={saveProfile} className="btn-primary">Save Changes</button>
              {saved && <span className="text-sm text-green-600 font-medium">✅ Saved successfully</span>}
            </div>
          </div>
        </div>

        <div className="data-card p-6 mb-6">
          <h2 className="text-lg font-bold mb-1">Notification Preferences</h2>
          <p className="text-sm text-gray-500 mb-6">Choose how you receive updates</p>
          <div className="space-y-4">
            <ToggleRow label="Email Alerts" desc="Receive alert notifications via email" enabled={prefs.emailAlerts} onChange={v => setPrefs({ ...prefs, emailAlerts: v })} />
            <ToggleRow label="SMS Notifications" desc="Get SMS for high-severity alerts" enabled={prefs.smsAlerts} onChange={v => setPrefs({ ...prefs, smsAlerts: v })} />
            <ToggleRow label="Dark Mode Reports" desc="Use dark theme in exported PDF reports" enabled={prefs.darkReport} onChange={v => setPrefs({ ...prefs, darkReport: v })} />
            <ToggleRow label="Auto-Resolve" desc="Auto-resolve low severity alerts after 24h" enabled={prefs.autoResolve} onChange={v => setPrefs({ ...prefs, autoResolve: v })} />
          </div>
        </div>

        <div className="data-card p-6 mb-6">
          <h2 className="text-lg font-bold mb-1">API Configuration</h2>
          <p className="text-sm text-gray-500 mb-6">Backend connection settings</p>
          <div className="space-y-4 max-w-md">
            <div><label className="form-label">API Base URL</label><input className="form-input" defaultValue="http://localhost:3000/api" placeholder="https://api.camino.rw" /></div>
            <div><label className="form-label">API Key</label>
              <div className="relative">
                <input className="form-input pr-10" type="password" defaultValue="sk-camino-dev-key" />
                <button className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">👁️</button>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <button className="btn-primary">Test Connection</button>
              <button className="btn-secondary">Save Config</button>
            </div>
          </div>
        </div>

        <div className="data-card p-6 border-red-100">
          <h2 className="text-lg font-bold mb-1 text-red-600">Danger Zone</h2>
          <p className="text-sm text-gray-500 mb-6">Irreversible actions</p>
          <div className="flex flex-wrap gap-3">
            <button className="btn-danger">🗑️ Reset All Data</button>
            <button className="btn-secondary border-red-200 text-red-600 hover:bg-red-50">📤 Export Data</button>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}

function ToggleRow({ label, desc, enabled, onChange }: { label: string; desc: string; enabled: boolean; onChange: (v: boolean) => void }) {
  return (
    <div className="flex items-center justify-between py-2">
      <div>
        <p className="text-sm font-medium text-gray-800">{label}</p>
        <p className="text-xs text-gray-400">{desc}</p>
      </div>
      <button
        onClick={() => onChange(!enabled)}
        className={`relative w-11 h-6 rounded-full transition-colors duration-200 ${enabled ? 'bg-[var(--primary)]' : 'bg-gray-200'}`}
      >
        <div className={`absolute w-5 h-5 bg-white rounded-full shadow-sm top-0.5 transition-transform duration-200 ${enabled ? 'translate-x-[22px]' : 'translate-x-0.5'}`} />
      </button>
    </div>
  );
}
