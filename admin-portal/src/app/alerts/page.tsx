'use client';

import { useState, useEffect } from 'react';
import DashboardLayout from '@/components/DashboardLayout';
import { DataService } from '@/lib/data';
import { useAuth } from '@/lib/auth';
import type { AdminAlert } from '@/lib/types';
import { PlusCircle, Circle, Clock, CheckCircle, Bell } from 'lucide-react';

const severityColor: Record<string, string> = { high: '#FF3B30', medium: '#F59E0B', low: '#3B82F6' };
const severityClass: Record<string, string> = { high: 'text-red-500', medium: 'text-yellow-500', low: 'text-blue-500' };

function SeverityIcon({ severity }: { severity: string }) {
  return <Circle size={20} className={`${severityClass[severity] || 'text-gray-400'}`} fill="currentColor" />;
}

export default function AlertsPage() {
  const { user } = useAuth();
  const [alerts, setAlerts] = useState<AdminAlert[]>([]);
  const [filtered, setFiltered] = useState<AdminAlert[]>([]);
  const [statusFilter, setStatusFilter] = useState('all');
  const [severityFilter, setSeverityFilter] = useState('all');
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState({ title: '', message: '', severity: 'medium' });

  useEffect(() => {
    DataService.getAlerts().then(a => { setAlerts(a); setFiltered(a); setLoading(false); });
  }, []);

  useEffect(() => {
    let f = alerts;
    if (statusFilter !== 'all') f = f.filter(a => a.status === statusFilter);
    if (severityFilter !== 'all') f = f.filter(a => a.severity === severityFilter);
    setFiltered(f);
  }, [alerts, statusFilter, severityFilter]);

  const openAdd = () => { setForm({ title: '', message: '', severity: 'medium' }); setShowModal(true); };
  const save = async () => {
    await DataService.addAlert({ ...form, status: 'active' } as any);
    setShowModal(false); DataService.getAlerts().then(a => { setAlerts(a); setFiltered(a); });
  };
  const resolve = async (id: string) => {
    if (confirm('Mark this alert as resolved?')) {
      await DataService.resolveAlert(id, user?.name || 'Admin');
      DataService.getAlerts().then(a => { setAlerts(a); setFiltered(a); });
    }
  };

  return (
    <DashboardLayout>
      <div className="p-6 lg:p-8 animate-in">
        <div className="flex items-start justify-between mb-6">
          <div><h1 className="page-title">Emergency Alerts</h1><p className="page-subtitle">{alerts.filter(a => a.status === 'active').length} active alerts</p></div>
          <button onClick={openAdd} className="btn-primary"><PlusCircle size={16} /> Create Alert</button>
        </div>

        <div className="flex flex-wrap gap-3 mb-6">
          <select className="form-input w-40" value={statusFilter} onChange={e => setStatusFilter(e.target.value)}>
            <option value="all">All Status</option>
            <option value="active">Active</option>
            <option value="resolved">Resolved</option>
          </select>
          <select className="form-input w-40" value={severityFilter} onChange={e => setSeverityFilter(e.target.value)}>
            <option value="all">All Severity</option>
            <option value="high">High</option>
            <option value="medium">Medium</option>
            <option value="low">Low</option>
          </select>
        </div>

        <div className="space-y-4">
          {loading ? (
            Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="data-card p-5">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex items-start gap-3 flex-1">
                    <div className="w-5 h-5 rounded-full skeleton mt-0.5" />
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-2">
                        <div className="h-5 w-32 skeleton" />
                        <div className="h-5 w-14 rounded-full skeleton" />
                        <div className="h-5 w-14 rounded-full skeleton" />
                      </div>
                      <div className="h-4 w-3/4 skeleton mb-2" />
                      <div className="h-3 w-48 skeleton" />
                    </div>
                  </div>
                  <div className="h-8 w-20 rounded-xl skeleton shrink-0" />
                </div>
              </div>
            ))
          ) : (
            filtered.map(alert => (
              <div key={alert.id} className={`data-card p-5 ${alert.status === 'active' ? 'border-l-4' : ''}`}
                style={alert.status === 'active' ? { borderLeftColor: severityColor[alert.severity] || '#999' } : {}}>
                <div className="flex items-start justify-between gap-4">
                  <div className="flex items-start gap-3 flex-1 min-w-0">
                    <div className="mt-0.5">
                      <SeverityIcon severity={alert.severity} />
                    </div>
                    <div>
                      <div className="flex items-center gap-2 mb-1">
                        <h3 className="font-bold text-base">{alert.title}</h3>
                        <span className="badge" style={{ backgroundColor: (severityColor[alert.severity] || '#999') + '18', color: severityColor[alert.severity] || '#999' }}>
                          {alert.severity.charAt(0).toUpperCase() + alert.severity.slice(1)}
                        </span>
                        <span className={alert.status === 'active' ? 'badge-red' : 'badge-gray'}>
                          {alert.status.charAt(0).toUpperCase() + alert.status.slice(1)}
                        </span>
                      </div>
                      <p className="text-sm text-gray-600 mb-2">{alert.message}</p>
                      <div className="flex items-center gap-4 text-xs text-gray-400">
                        <span className="flex items-center gap-1"><Clock size={12} /> {new Date(alert.createdAt).toLocaleString()}</span>
                        {alert.resolvedBy && <span className="flex items-center gap-1"><CheckCircle size={12} /> Resolved by {alert.resolvedBy}</span>}
                        {alert.resolvedAt && <span>at {new Date(alert.resolvedAt).toLocaleString()}</span>}
                      </div>
                    </div>
                  </div>
                  {alert.status === 'active' && (
                    <button onClick={() => resolve(alert.id)} className="btn-secondary text-sm shrink-0 flex items-center gap-1"><CheckCircle size={14} /> Resolve</button>
                  )}
                </div>
              </div>
            ))
          )}
          {!loading && filtered.length === 0 && (
            <div className="text-center py-12 text-gray-400">
              <Bell size={40} className="mx-auto mb-3 text-gray-300" />
              <p className="font-medium">No alerts found</p>
            </div>
          )}
        </div>

        {showModal && (
          <div className="modal-overlay" onClick={() => setShowModal(false)}>
            <div className="modal-content p-6" onClick={e => e.stopPropagation()}>
              <h2 className="text-xl font-bold mb-6">Create New Alert</h2>
              <div className="space-y-4">
                <div><label className="form-label">Title</label><input className="form-input" value={form.title} onChange={e => setForm({ ...form, title: e.target.value })} placeholder="e.g. Bus engine issue" /></div>
                <div><label className="form-label">Message</label><textarea className="form-input" rows={4} value={form.message} onChange={e => setForm({ ...form, message: e.target.value })} placeholder="Describe the alert situation..." /></div>
                <div><label className="form-label">Severity</label>
                  <select className="form-input" value={form.severity} onChange={e => setForm({ ...form, severity: e.target.value })}>
                    <option value="high">High</option>
                    <option value="medium">Medium</option>
                    <option value="low">Low</option>
                  </select>
                </div>
              </div>
              <div className="flex justify-end gap-3 mt-6">
                <button onClick={() => setShowModal(false)} className="btn-secondary">Cancel</button>
                <button onClick={save} className="btn-primary">Create Alert</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
