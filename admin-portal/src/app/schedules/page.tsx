'use client';

import { useState, useEffect } from 'react';
import DashboardLayout from '@/components/DashboardLayout';
import { DataService } from '@/lib/data';
import type { AdminSchedule } from '@/lib/types';
import { ClipboardList } from 'lucide-react';

export default function SchedulesPage() {
  const [schedules, setSchedules] = useState<AdminSchedule[]>([]);
  const [filtered, setFiltered] = useState<AdminSchedule[]>([]);
  const [statusFilter, setStatusFilter] = useState('all');
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState<AdminSchedule | null>(null);
  const [buses, setBuses] = useState<any[]>([]);
  const [routes, setRoutes] = useState<any[]>([]);
  const [form, setForm] = useState({ busId: '', busPlate: '', routeId: '', routeName: '', date: '', departureTime: '', arrivalTime: '', status: 'scheduled' });

  useEffect(() => {
    Promise.all([
      DataService.getSchedules(),
      DataService.getBuses(),
      DataService.getRoutes(),
    ]).then(([s, b, r]) => {
      setSchedules(s); setFiltered(s); setBuses(b); setRoutes(r); setLoading(false);
    });
  }, []);

  useEffect(() => {
    if (statusFilter === 'all') { setFiltered(schedules); return; }
    setFiltered(schedules.filter(s => s.status === statusFilter));
  }, [schedules, statusFilter]);

  const openAdd = () => {
    setEditing(null);
    setForm({ busId: '', busPlate: '', routeId: '', routeName: '', date: '', departureTime: '', arrivalTime: '', status: 'scheduled' });
    setShowModal(true);
  };
  const openEdit = (s: AdminSchedule) => {
    setEditing(s);
    setForm({ busId: s.busId, busPlate: s.busPlate, routeId: s.routeId, routeName: s.routeName, date: s.date, departureTime: s.departureTime, arrivalTime: s.arrivalTime, status: s.status });
    setShowModal(true);
  };
  const save = async () => {
    if (editing) { await DataService.updateSchedule({ ...editing, ...form }); }
    else { await DataService.addSchedule(form as any); }
    setShowModal(false); DataService.getSchedules().then(s => { setSchedules(s); setFiltered(s); });
  };
  const del = async (id: string) => { if (confirm('Delete this schedule?')) { await DataService.deleteSchedule(id); DataService.getSchedules().then(s => { setSchedules(s); setFiltered(s); }); } };

  const handleBusChange = (busId: string) => {
    const b = buses.find(x => x.id === busId);
    setForm({ ...form, busId, busPlate: b?.plateNumber || '' });
  };
  const handleRouteChange = (routeId: string) => {
    const r = routes.find(x => x.id === routeId);
    setForm({ ...form, routeId, routeName: r?.name || '' });
  };

  const statusColor: Record<string, string> = { completed: '#10B981', scheduled: '#3B82F6', 'in-progress': '#F59E0B', cancelled: '#FF3B30' };

  return (
    <DashboardLayout>
      <div className="p-6 lg:p-8 animate-in">
        <div className="flex items-start justify-between mb-6">
          <div><h1 className="page-title">Schedule Management</h1><p className="page-subtitle">{schedules.length} total trips</p></div>
          <button onClick={openAdd} className="btn-primary"><ClipboardList size={16} /> Add Trip</button>
        </div>

        <div className="flex flex-wrap gap-3 mb-6">
          <select className="form-input w-40" value={statusFilter} onChange={e => setStatusFilter(e.target.value)}>
            <option value="all">All Status</option>
            <option value="scheduled">Scheduled</option>
            <option value="in-progress">In Progress</option>
            <option value="completed">Completed</option>
            <option value="cancelled">Cancelled</option>
          </select>
        </div>

        <div className="data-card">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr>
                  <th className="table-header">Bus</th>
                  <th className="table-header">Route</th>
                  <th className="table-header">Date</th>
                  <th className="table-header">Departure</th>
                  <th className="table-header">Arrival</th>
                  <th className="table-header">Status</th>
                  <th className="table-header text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  Array.from({ length: 5 }).map((_, i) => (
                    <tr key={i}>
                      <td className="table-cell"><div className="h-4 w-20 skeleton" /></td>
                      <td className="table-cell"><div className="h-4 w-24 skeleton" /></td>
                      <td className="table-cell"><div className="h-4 w-28 skeleton" /></td>
                      <td className="table-cell"><div className="h-4 w-16 skeleton" /></td>
                      <td className="table-cell"><div className="h-4 w-16 skeleton" /></td>
                      <td className="table-cell"><div className="h-5 w-20 rounded-full skeleton" /></td>
                      <td className="table-cell"><div className="h-4 w-16 skeleton ml-auto" /></td>
                    </tr>
                  ))
                ) : (
                  filtered.map(s => (
                    <tr key={s.id} className="hover:bg-gray-50/50">
                      <td className="table-cell font-medium">{s.busPlate}</td>
                      <td className="table-cell text-gray-500">{s.routeName}</td>
                      <td className="table-cell">{s.date}</td>
                      <td className="table-cell">{s.departureTime}</td>
                      <td className="table-cell">{s.arrivalTime}</td>
                      <td className="table-cell">
                        <span className="badge" style={{ backgroundColor: (statusColor[s.status] || '#999') + '18', color: statusColor[s.status] || '#999' }}>
                          {s.status === 'in-progress' ? 'In Progress' : s.status.charAt(0).toUpperCase() + s.status.slice(1)}
                        </span>
                      </td>
                      <td className="table-cell text-right">
                        <button onClick={() => openEdit(s)} className="text-blue-600 hover:text-blue-800 text-sm font-medium mr-3">Edit</button>
                        <button onClick={() => del(s.id)} className="text-red-600 hover:text-red-800 text-sm font-medium">Delete</button>
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
              <h2 className="text-xl font-bold mb-6">{editing ? 'Edit Trip' : 'Add New Trip'}</h2>
              <div className="space-y-4">
                <div><label className="form-label">Bus</label>
                  <select className="form-input" value={form.busId} onChange={e => handleBusChange(e.target.value)}>
                    <option value="">Select Bus</option>
                    {buses.map(b => <option key={b.id} value={b.id}>{b.plateNumber} - {b.driverName}</option>)}
                  </select>
                </div>
                <div><label className="form-label">Route</label>
                  <select className="form-input" value={form.routeId} onChange={e => handleRouteChange(e.target.value)}>
                    <option value="">Select Route</option>
                    {routes.map(r => <option key={r.id} value={r.id}>{r.name}</option>)}
                  </select>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div><label className="form-label">Date</label><input className="form-input" type="date" value={form.date} onChange={e => setForm({ ...form, date: e.target.value })} /></div>
                  <div><label className="form-label">Status</label>
                    <select className="form-input" value={form.status} onChange={e => setForm({ ...form, status: e.target.value })}>
                      <option value="scheduled">Scheduled</option>
                      <option value="in-progress">In Progress</option>
                      <option value="completed">Completed</option>
                      <option value="cancelled">Cancelled</option>
                    </select>
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div><label className="form-label">Departure Time</label><input className="form-input" type="time" value={form.departureTime} onChange={e => setForm({ ...form, departureTime: e.target.value })} /></div>
                  <div><label className="form-label">Arrival Time</label><input className="form-input" type="time" value={form.arrivalTime} onChange={e => setForm({ ...form, arrivalTime: e.target.value })} /></div>
                </div>
              </div>
              <div className="flex justify-end gap-3 mt-6">
                <button onClick={() => setShowModal(false)} className="btn-secondary">Cancel</button>
                <button onClick={save} className="btn-primary">{editing ? 'Update' : 'Add Trip'}</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
