'use client';

import { useState, useEffect } from 'react';
import DashboardLayout from '@/components/DashboardLayout';
import { DataService } from '@/lib/data';
import type { AdminUser } from '@/lib/types';
import { Plus } from 'lucide-react';

export default function UsersPage() {
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [filtered, setFiltered] = useState<AdminUser[]>([]);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('all');
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState<AdminUser | null>(null);
  const [form, setForm] = useState({ name: '', email: '', phone: '', school: '', grade: '', role: 'student', isActive: true });

  useEffect(() => {
    DataService.getUsers().then(u => { setUsers(u); setFiltered(u); setLoading(false); });
  }, []);

  useEffect(() => {
    let f = users;
    if (roleFilter !== 'all') f = f.filter(u => u.role === roleFilter);
    if (search) { const q = search.toLowerCase(); f = f.filter(u => u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q)); }
    setFiltered(f);
  }, [users, search, roleFilter]);

  const openAdd = () => { setEditing(null); setForm({ name: '', email: '', phone: '', school: '', grade: '', role: 'student', isActive: true }); setShowModal(true); };
  const openEdit = (u: AdminUser) => { setEditing(u); setForm({ name: u.name, email: u.email, phone: u.phone || '', school: u.school || '', grade: u.grade || '', role: u.role, isActive: u.isActive }); setShowModal(true); };
  const save = async () => {
    const payload = { ...form, role: form.role as any };
    if (editing) { await DataService.updateUser({ ...editing, ...payload }); } else { await DataService.addUser({ ...payload, createdAt: new Date().toISOString().split('T')[0] } as any); }
    setShowModal(false); DataService.getUsers().then(setUsers);
  };
  const del = async (id: string) => { if (confirm('Delete this user?')) { await DataService.deleteUser(id); DataService.getUsers().then(setUsers); } };

  const roleColor = (r: string) => ({ 'student': '#0A3D2F', 'parent': '#007AFF', 'staff': '#F59E0B', 'admin': '#FF3B30' }[r] || '#999');

  return (
    <DashboardLayout>
      <div className="p-6 lg:p-8 animate-in">
        <div className="flex items-start justify-between mb-6">
          <div><h1 className="page-title">User Management</h1><p className="page-subtitle">{users.length} total users</p></div>
          <button onClick={openAdd} className="btn-primary"><Plus size={16} /> Add User</button>
        </div>

        <div className="flex flex-wrap gap-3 mb-6">
          <input className="form-input w-72" placeholder="Search by name or email..." value={search} onChange={e => setSearch(e.target.value)} />
          <select className="form-input w-40" value={roleFilter} onChange={e => setRoleFilter(e.target.value)}>
            <option value="all">All Roles</option>
            <option value="student">Students</option>
            <option value="parent">Parents</option>
            <option value="staff">Staff</option>
            <option value="admin">Admins</option>
          </select>
          <span className="text-sm text-gray-400 self-center">{filtered.length} results</span>
        </div>

        <div className="data-card">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr>
                  <th className="table-header">Name</th>
                  <th className="table-header">Email</th>
                  <th className="table-header">Role</th>
                  <th className="table-header">School</th>
                  <th className="table-header">Status</th>
                  <th className="table-header text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  Array.from({ length: 5 }).map((_, i) => (
                    <tr key={i}>
                      <td className="table-cell"><div className="h-4 w-32 skeleton" /></td>
                      <td className="table-cell"><div className="h-4 w-40 skeleton" /></td>
                      <td className="table-cell"><div className="h-5 w-16 rounded-full skeleton" /></td>
                      <td className="table-cell"><div className="h-4 w-24 skeleton" /></td>
                      <td className="table-cell"><div className="h-5 w-14 rounded-full skeleton" /></td>
                      <td className="table-cell"><div className="h-4 w-16 skeleton ml-auto" /></td>
                    </tr>
                  ))
                ) : (
                  filtered.map(u => (
                    <tr key={u.id} className="hover:bg-gray-50/50">
                      <td className="table-cell font-medium">{u.name}</td>
                      <td className="table-cell text-gray-500">{u.email}</td>
                      <td className="table-cell">
                        <span className="badge" style={{ backgroundColor: roleColor(u.role) + '18', color: roleColor(u.role) }}>
                          {u.role.charAt(0).toUpperCase() + u.role.slice(1)}
                        </span>
                      </td>
                      <td className="table-cell text-gray-500">{u.school || '-'}</td>
                      <td className="table-cell">
                        <span className={u.isActive ? 'badge-green' : 'badge-gray'}>{u.isActive ? 'Active' : 'Inactive'}</span>
                      </td>
                      <td className="table-cell text-right">
                        <button onClick={() => openEdit(u)} className="text-blue-600 hover:text-blue-800 text-sm font-medium mr-3">Edit</button>
                        <button onClick={() => del(u.id)} className="text-red-600 hover:text-red-800 text-sm font-medium">Delete</button>
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
              <h2 className="text-xl font-bold mb-6">{editing ? 'Edit User' : 'Add New User'}</h2>
              <div className="space-y-4">
                <div><label className="form-label">Full Name</label><input className="form-input" value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} /></div>
                <div><label className="form-label">Email</label><input className="form-input" type="email" value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} /></div>
                <div><label className="form-label">Phone</label><input className="form-input" value={form.phone} onChange={e => setForm({ ...form, phone: e.target.value })} /></div>
                <div><label className="form-label">Role</label>
                  <select className="form-input" value={form.role} onChange={e => setForm({ ...form, role: e.target.value })}>
                    <option value="student">Student</option>
                    <option value="parent">Parent</option>
                    <option value="staff">Staff</option>
                    <option value="admin">Admin</option>
                  </select>
                </div>
                {form.role === 'student' && (
                  <><div><label className="form-label">School</label><input className="form-input" value={form.school} onChange={e => setForm({ ...form, school: e.target.value })} /></div>
                  <div><label className="form-label">Grade</label><input className="form-input" value={form.grade} onChange={e => setForm({ ...form, grade: e.target.value })} /></div></>
                )}
                <label className="flex items-center gap-3 cursor-pointer">
                  <input type="checkbox" checked={form.isActive} onChange={e => setForm({ ...form, isActive: e.target.checked })} className="w-4 h-4 rounded border-gray-300" />
                  <span className="text-sm font-medium">Active Account</span>
                </label>
              </div>
              <div className="flex justify-end gap-3 mt-6">
                <button onClick={() => setShowModal(false)} className="btn-secondary">Cancel</button>
                <button onClick={save} className="btn-primary">{editing ? 'Update' : 'Add User'}</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
