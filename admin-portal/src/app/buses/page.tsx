'use client';

import { useState, useEffect } from 'react';
import DashboardLayout from '@/components/DashboardLayout';
import { DataService } from '@/lib/data';
import type { AdminBus } from '@/lib/types';
import { Plus } from 'lucide-react';

export default function BusesPage() {
  const [buses, setBuses] = useState<AdminBus[]>([]);
  const [filtered, setFiltered] = useState<AdminBus[]>([]);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState<AdminBus | null>(null);
  const [routes, setRoutes] = useState<any[]>([]);
  const [form, setForm] = useState({ plateNumber: '', driverName: '', driverPhone: '', capacity: 45, routeId: '', routeName: '', status: 'active' });

  useEffect(() => {
    Promise.all([
      DataService.getBuses(),
      DataService.getRoutes(),
    ]).then(([b, r]) => {
      setBuses(b); setFiltered(b); setRoutes(r); setLoading(false);
    });
  }, []);

  useEffect(() => {
    let f = buses;
    if (statusFilter !== 'all') f = f.filter(b => b.status === statusFilter);
    if (search) { const q = search.toLowerCase(); f = f.filter(b => b.plateNumber.toLowerCase().includes(q) || b.driverName.toLowerCase().includes(q)); }
    setFiltered(f);
  }, [buses, search, statusFilter]);

  const openAdd = () => { setEditing(null); setForm({ plateNumber: '', driverName: '', driverPhone: '', capacity: 45, routeId: '', routeName: '', status: 'active' }); setShowModal(true); };
  const openEdit = (b: AdminBus) => { setEditing(b); setForm({ plateNumber: b.plateNumber, driverName: b.driverName, driverPhone: b.driverPhone || '', capacity: b.capacity, routeId: b.routeId || '', routeName: b.routeName || '', status: b.status }); setShowModal(true); };
  const save = async () => {
    const payload = { ...form, currentPassengers: editing?.currentPassengers || 0 };
    if (editing) { await DataService.updateBus({ ...editing, ...payload }); } else { await DataService.addBus(payload as any); }
    setShowModal(false); DataService.getBuses().then(setBuses);
  };
  const del = async (id: string) => { if (confirm('Delete this bus?')) { await DataService.deleteBus(id); DataService.getBuses().then(setBuses); } };

  const statusColor: Record<string, string> = { active: '#10B981', maintenance: '#F59E0B', inactive: '#FF3B30' };

  return (
    <DashboardLayout>
      <div className="p-6 lg:p-8 animate-in">
        <div className="flex items-start justify-between mb-6">
          <div><h1 className="page-title">Bus Management</h1><p className="page-subtitle">{buses.length} total buses</p></div>
          <button onClick={openAdd} className="btn-primary"><Plus size={16} /> Add Bus</button>
        </div>

        <div className="flex flex-wrap gap-3 mb-6">
          <input className="form-input w-72" placeholder="Search by plate or driver..." value={search} onChange={e => setSearch(e.target.value)} />
          <select className="form-input w-40" value={statusFilter} onChange={e => setStatusFilter(e.target.value)}>
            <option value="all">All Status</option>
            <option value="active">Active</option>
            <option value="maintenance">Maintenance</option>
            <option value="inactive">Inactive</option>
          </select>
        </div>

        <div className="data-card">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr>
                  <th className="table-header">Plate #</th>
                  <th className="table-header">Driver</th>
                  <th className="table-header">Capacity</th>
                  <th className="table-header">Route</th>
                  <th className="table-header">Passengers</th>
                  <th className="table-header">Status</th>
                  <th className="table-header text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  Array.from({ length: 5 }).map((_, i) => (
                    <tr key={i}>
                      <td className="table-cell"><div className="h-4 w-24 skeleton" /></td>
                      <td className="table-cell"><div className="h-4 w-28 skeleton" /></td>
                      <td className="table-cell"><div className="h-4 w-12 skeleton" /></td>
                      <td className="table-cell"><div className="h-4 w-20 skeleton" /></td>
                      <td className="table-cell"><div className="h-4 w-16 skeleton" /></td>
                      <td className="table-cell"><div className="h-5 w-16 rounded-full skeleton" /></td>
                      <td className="table-cell"><div className="h-4 w-16 skeleton ml-auto" /></td>
                    </tr>
                  ))
                ) : (
                  filtered.map(b => (
                    <tr key={b.id} className="hover:bg-gray-50/50">
                      <td className="table-cell font-medium">{b.plateNumber}</td>
                      <td className="table-cell">{b.driverName}<br /><span className="text-xs text-gray-400">{b.driverPhone}</span></td>
                      <td className="table-cell">{b.capacity}</td>
                      <td className="table-cell text-gray-500">{b.routeName || 'Unassigned'}</td>
                      <td className="table-cell">{b.currentPassengers}/{b.capacity}</td>
                      <td className="table-cell">
                        <span className="badge" style={{ backgroundColor: (statusColor[b.status] || '#999') + '18', color: statusColor[b.status] || '#999' }}>
                          {b.status.charAt(0).toUpperCase() + b.status.slice(1)}
                        </span>
                      </td>
                      <td className="table-cell text-right">
                        <button onClick={() => openEdit(b)} className="text-blue-600 hover:text-blue-800 text-sm font-medium mr-3">Edit</button>
                        <button onClick={() => del(b.id)} className="text-red-600 hover:text-red-800 text-sm font-medium">Delete</button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>

        {showModal && (
          <div className="modal-overlay" onClick={() => setShowModal(false)}>
            <div className="modal-content p-6" onClick={e => e.stopPropagation()}>
              <h2 className="text-xl font-bold mb-6">{editing ? 'Edit Bus' : 'Add New Bus'}</h2>
              <div className="space-y-4">
                <div><label className="form-label">Plate Number</label><input className="form-input" value={form.plateNumber} onChange={e => setForm({ ...form, plateNumber: e.target.value })} /></div>
                <div><label className="form-label">Driver Name</label><input className="form-input" value={form.driverName} onChange={e => setForm({ ...form, driverName: e.target.value })} /></div>
                <div><label className="form-label">Driver Phone</label><input className="form-input" value={form.driverPhone} onChange={e => setForm({ ...form, driverPhone: e.target.value })} /></div>
                <div><label className="form-label">Capacity</label><input className="form-input" type="number" value={form.capacity} onChange={e => setForm({ ...form, capacity: +e.target.value })} /></div>
                <div><label className="form-label">Route</label>
                  <select className="form-input" value={form.routeId} onChange={e => { const r = routes.find(r => r.id === e.target.value); setForm({ ...form, routeId: e.target.value, routeName: r?.name || '' }); }}>
                    <option value="">None</option>
                    {routes.map(r => <option key={r.id} value={r.id}>{r.name}</option>)}
                  </select>
                </div>
                <div><label className="form-label">Status</label>
                  <select className="form-input" value={form.status} onChange={e => setForm({ ...form, status: e.target.value })}>
                    <option value="active">Active</option>
                    <option value="maintenance">Maintenance</option>
                    <option value="inactive">Inactive</option>
                  </select>
                </div>
              </div>
              <div className="flex justify-end gap-3 mt-6">
                <button onClick={() => setShowModal(false)} className="btn-secondary">Cancel</button>
                <button onClick={save} className="btn-primary">{editing ? 'Update' : 'Add Bus'}</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
