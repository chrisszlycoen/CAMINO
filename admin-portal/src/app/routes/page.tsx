'use client';

import { useState, useEffect } from 'react';
import DashboardLayout from '@/components/DashboardLayout';
import { DataService } from '@/lib/data';
import type { AdminRoute } from '@/lib/types';
import { Plus, Map } from 'lucide-react';

export default function RoutesPage() {
  const [routes, setRoutes] = useState<AdminRoute[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState<AdminRoute | null>(null);
  const [form, setForm] = useState({ name: '', stopsText: '', status: 'active' });

  useEffect(() => { DataService.getRoutes().then(r => { setRoutes(r); setLoading(false); }); }, []);

  const openAdd = () => { setEditing(null); setForm({ name: '', stopsText: '', status: 'active' }); setShowModal(true); };
  const openEdit = (r: AdminRoute) => { setEditing(r); setForm({ name: r.name, stopsText: r.stops.join('\n'), status: r.status }); setShowModal(true); };
  const save = async () => {
    const stops = form.stopsText.split('\n').map(s => s.trim()).filter(Boolean);
    if (editing) { await DataService.updateRoute({ ...editing, name: form.name, stops, status: form.status }); }
    else { await DataService.addRoute({ name: form.name, stops, status: form.status }); }
    setShowModal(false); DataService.getRoutes().then(setRoutes);
  };
  const del = async (id: string) => { if (confirm('Delete this route?')) { await DataService.deleteRoute(id); DataService.getRoutes().then(setRoutes); } };

  return (
    <DashboardLayout>
      <div className="p-6 lg:p-8 animate-in">
        <div className="flex items-start justify-between mb-6">
          <div><h1 className="page-title">Route Management</h1><p className="page-subtitle">{routes.length} total routes</p></div>
          <button onClick={openAdd} className="btn-primary"><Plus size={16} /> Add Route</button>
        </div>

        <div className="space-y-4">
          {loading ? (
            Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="data-card p-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl skeleton" />
                    <div>
                      <div className="h-5 w-40 skeleton mb-2" />
                      <div className="h-4 w-28 skeleton" />
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <div className="h-5 w-16 rounded-full skeleton" />
                    <div className="h-4 w-10 skeleton" />
                    <div className="h-4 w-12 skeleton" />
                  </div>
                </div>
                <div className="space-y-3">
                  {Array.from({ length: 3 }).map((_, j) => (
                    <div key={j} className="flex items-center gap-3">
                      <div className="w-3 h-3 rounded-full skeleton" />
                      <div className="h-4 w-32 skeleton" />
                    </div>
                  ))}
                </div>
              </div>
            ))
          ) : (
            routes.map(r => (
              <div key={r.id} className="data-card p-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-[#0A3D2F]/10 flex items-center justify-center"><Map size={20} className="text-[#0A3D2F]" /></div>
                    <div>
                      <h3 className="font-bold text-lg">{r.name}</h3>
                      <p className="text-sm text-gray-500">{r.stops.length} stops • {r.status}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className={r.status === 'active' ? 'badge-green' : 'badge-gray'}>{r.status.charAt(0).toUpperCase() + r.status.slice(1)}</span>
                    <button onClick={() => openEdit(r)} className="text-blue-600 hover:text-blue-800 text-sm font-medium">Edit</button>
                    <button onClick={() => del(r.id)} className="text-red-600 hover:text-red-800 text-sm font-medium">Delete</button>
                  </div>
                </div>
                <div className="space-y-0">
                  {r.stops.map((stop, i) => (
                    <div key={i} className="flex items-start gap-3">
                      <div className="flex flex-col items-center pt-1">
                        <div className="w-3 h-3 rounded-full border-2 border-[#0A3D2F]" />
                        {i < r.stops.length - 1 && <div className="w-0.5 h-6 bg-gray-200" />}
                      </div>
                      <p className={`text-sm py-1 ${i === 0 ? 'font-semibold' : ''}`}>{stop}</p>
                    </div>
                  ))}
                </div>
              </div>
            ))
          )}
        </div>

        {showModal && (
          <div className="modal-overlay" onClick={() => setShowModal(false)}>
            <div className="modal-content p-6" onClick={e => e.stopPropagation()}>
              <h2 className="text-xl font-bold mb-6">{editing ? 'Edit Route' : 'Add New Route'}</h2>
              <div className="space-y-4">
                <div><label className="form-label">Route Name</label><input className="form-input" value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} /></div>
                <div><label className="form-label">Stops (one per line)</label><textarea className="form-input" rows={5} value={form.stopsText} onChange={e => setForm({ ...form, stopsText: e.target.value })} placeholder="Stop 1&#10;Stop 2&#10;Stop 3" /></div>
                <div><label className="form-label">Status</label>
                  <select className="form-input" value={form.status} onChange={e => setForm({ ...form, status: e.target.value })}>
                    <option value="active">Active</option>
                    <option value="inactive">Inactive</option>
                  </select>
                </div>
              </div>
              <div className="flex justify-end gap-3 mt-6">
                <button onClick={() => setShowModal(false)} className="btn-secondary">Cancel</button>
                <button onClick={save} className="btn-primary">{editing ? 'Update' : 'Add Route'}</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
