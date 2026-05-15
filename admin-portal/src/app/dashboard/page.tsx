'use client';

import { useState, useEffect } from 'react';
import DashboardLayout from '@/components/DashboardLayout';
import { DataService } from '@/lib/data';
import type { DashboardStats } from '@/lib/types';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { GraduationCap, Bus, Clock, Bell, Plus, ClipboardList, FileText, AlertTriangle, Edit, User } from 'lucide-react';

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [weekly, setWeekly] = useState<any[]>([]);
  const [routes, setRoutes] = useState<any[]>([]);

  useEffect(() => {
    DataService.getDashboardStats().then(setStats);
    setWeekly(DataService.getWeeklyData());
    setRoutes(DataService.getRoutePerformance());
  }, []);

  return (
    <DashboardLayout>
      <div className="p-6 lg:p-8 animate-in">
        <div className="mb-8">
          <h1 className="page-title">Dashboard</h1>
          <p className="page-subtitle">Real-time transport overview</p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          {stats ? (
            <>
              <StatCard title="Total Students" value={String(stats.totalStudents)} subtitle={`${stats.boardedToday} boarded today`} icon={GraduationCap} color="#0A3D2F" change="+8.2%" />
              <StatCard title="Active Buses" value={String(stats.activeBuses)} subtitle={`${stats.totalRoutes} active routes`} icon={Bus} color="#007AFF" change="0%" />
              <StatCard title="On-Time Rate" value={`${stats.onTimeRate}%`} subtitle="Last 7 days" icon={Clock} color="#10B981" change="+3.5%" />
              <StatCard title="Pending Alerts" value={String(stats.pendingAlerts)} subtitle={`${stats.totalStaff} staff on duty`} icon={Bell} color="#FF3B30" />
            </>
          ) : (
            <>
              <SkeletonStatCard />
              <SkeletonStatCard />
              <SkeletonStatCard />
              <SkeletonStatCard />
            </>
          )}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <div className="data-card p-6">
            <h3 className="font-bold text-lg mb-4">Weekly Boarding</h3>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={weekly}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="label" tick={{ fontSize: 12 }} />
                <YAxis tick={{ fontSize: 12 }} />
                <Tooltip />
                <Bar dataKey="value" fill="#0A3D2F" radius={[6, 6, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="data-card p-6">
            <h3 className="font-bold text-lg mb-4">Route Performance %</h3>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={routes} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis type="number" domain={[0, 100]} tick={{ fontSize: 12 }} />
                <YAxis dataKey="label" type="category" tick={{ fontSize: 12 }} width={80} />
                <Tooltip />
                <Bar dataKey="value" fill="#10B981" radius={[0, 6, 6, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="data-card p-6 lg:col-span-1">
            <h3 className="font-bold text-lg mb-4">Quick Actions</h3>
            <div className="grid grid-cols-2 gap-3">
              {[
                { label: 'Add User', icon: Plus },
                { label: 'Schedule Trip', icon: ClipboardList },
                { label: 'Create Alert', icon: Bell },
                { label: 'Generate Report', icon: FileText },
              ].map(action => (
                <button key={action.label} className="flex flex-col items-center gap-2 p-4 rounded-xl bg-white border border-gray-100 hover:shadow-md hover:border-gray-200 transition-all">
                  <div className="w-10 h-10 rounded-lg bg-[#0A3D2F]/10 flex items-center justify-center">
                    <action.icon size={20} className="text-[#0A3D2F]" />
                  </div>
                  <span className="text-xs font-semibold text-gray-600 text-center leading-tight">{action.label}</span>
                </button>
              ))}
            </div>
          </div>

          <div className="data-card p-6 lg:col-span-2">
            <h3 className="font-bold text-lg mb-4">Recent Activity</h3>
            {[
              { text: 'Bus #12 departed Route A', time: '2 min ago', icon: Bus },
              { text: '45 students boarded this morning', time: '15 min ago', icon: GraduationCap },
              { text: 'Alert: Engine issue on Bus #12', time: '1 hour ago', icon: AlertTriangle },
              { text: 'Route B schedule updated', time: '2 hours ago', icon: Edit },
              { text: 'New staff assigned to Route C', time: '4 hours ago', icon: User },
            ].map((act, i) => (
              <div key={i} className="flex items-center gap-3 py-3 border-b border-gray-50 last:border-0">
                <div className="w-9 h-9 rounded-lg bg-gray-100 flex items-center justify-center">
                  <act.icon size={16} className="text-gray-500" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium text-gray-800">{act.text}</p>
                  <p className="text-xs text-gray-400">{act.time}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}

function StatCard({ title, value, subtitle, icon: Icon, color, change }: any) {
  return (
    <div className="stat-card hover:shadow-lg hover:-translate-y-0.5 transition-all duration-200">
      <div className="flex items-start justify-between mb-3">
        <div className="w-11 h-11 rounded-xl flex items-center justify-center" style={{ backgroundColor: color + '18' }}>
          <Icon size={22} style={{ color }} />
        </div>
        {change && (
          <span className={`text-xs font-bold px-2 py-1 rounded-md ${change.startsWith('+') ? 'bg-green-50 text-green-600' : 'bg-gray-50 text-gray-500'}`}>{change}</span>
        )}
      </div>
      <p className="text-xs font-medium text-gray-500 mb-1">{title}</p>
      <p className="text-2xl font-black text-gray-900">{value}</p>
      {subtitle && <p className="text-xs text-gray-400 mt-0.5">{subtitle}</p>}
    </div>
  );
}

function SkeletonStatCard() {
  return (
    <div className="skeleton-card">
      <div className="flex items-start justify-between mb-3">
        <div className="w-11 h-11 rounded-xl skeleton" />
        <div className="w-14 h-5 rounded-md skeleton" />
      </div>
      <div className="w-20 h-3 rounded skeleton mb-3" />
      <div className="w-16 h-8 rounded skeleton mb-2" />
      <div className="w-28 h-3 rounded skeleton" />
    </div>
  );
}
