'use client';

import { useState, useEffect } from 'react';
import DashboardLayout from '@/components/DashboardLayout';
import { DataService } from '@/lib/data';
import type { DashboardStats } from '@/lib/types';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, LineChart, Line } from 'recharts';

const COLORS = ['#0A3D2F', '#007AFF', '#10B981', '#F59E0B', '#FF3B30', '#8B5CF6'];

const monthlyBoarding = [
  { month: 'Jan', students: 2450, staff: 380, parents: 420 },
  { month: 'Feb', students: 2680, staff: 410, parents: 390 },
  { month: 'Mar', students: 3010, staff: 430, parents: 450 },
  { month: 'Apr', students: 2750, staff: 390, parents: 410 },
  { month: 'May', students: 3200, staff: 460, parents: 480 },
];

const routeDistribution = [
  { name: 'Route A', value: 32 },
  { name: 'Route B', value: 28 },
  { name: 'Route C', value: 20 },
  { name: 'Route D', value: 8 },
  { name: 'Route E', value: 12 },
];

export default function AnalyticsPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null);

  useEffect(() => { DataService.getDashboardStats().then(setStats); }, []);

  return (
    <DashboardLayout>
      <div className="p-6 lg:p-8 animate-in">
        <div className="mb-8">
          <h1 className="page-title">Analytics</h1>
          <p className="page-subtitle">Detailed metrics and insights</p>
        </div>

        {stats && (
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-8">
            <MetricCard label="Total Students" value={String(stats.totalStudents)} icon="🎓" />
            <MetricCard label="Staff" value={String(stats.totalStaff)} icon="👤" />
            <MetricCard label="Linked Parents" value={String(stats.linkedParents)} icon="👪" />
            <MetricCard label="Boardings Today" value={String(stats.boardedToday)} icon="🎯" />
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <div className="data-card p-6">
            <h3 className="font-bold text-lg mb-4">Monthly Boarding Trends</h3>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={monthlyBoarding}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="month" tick={{ fontSize: 12 }} />
                <YAxis tick={{ fontSize: 12 }} />
                <Tooltip />
                <Bar dataKey="students" fill="#0A3D2F" radius={[4, 4, 0, 0]} name="Students" />
                <Bar dataKey="staff" fill="#007AFF" radius={[4, 4, 0, 0]} name="Staff" />
                <Bar dataKey="parents" fill="#10B981" radius={[4, 4, 0, 0]} name="Parents" />
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="data-card p-6">
            <h3 className="font-bold text-lg mb-4">Route Usage Distribution</h3>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie data={routeDistribution} cx="50%" cy="50%" innerRadius={60} outerRadius={100} paddingAngle={4} dataKey="value">
                  {routeDistribution.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
            <div className="flex flex-wrap justify-center gap-4 mt-2">
              {routeDistribution.map((r, i) => (
                <div key={r.name} className="flex items-center gap-2 text-sm">
                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: COLORS[i] }} />
                  <span className="text-gray-600">{r.name} ({r.value}%)</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <div className="data-card p-6">
            <h3 className="font-bold text-lg mb-4">On-Time Performance Trend</h3>
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={[
                { week: 'W1', rate: 84 }, { week: 'W2', rate: 86 },
                { week: 'W3', rate: 83 }, { week: 'W4', rate: 88 },
                { week: 'W5', rate: 87 }, { week: 'W6', rate: 90 },
              ]}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="week" tick={{ fontSize: 12 }} />
                <YAxis domain={[70, 100]} tick={{ fontSize: 12 }} />
                <Tooltip />
                <Line type="monotone" dataKey="rate" stroke="#10B981" strokeWidth={3} dot={{ fill: '#10B981', r: 5 }} />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div className="data-card p-6">
            <h3 className="font-bold text-lg mb-4">Key Performance Indicators</h3>
            <div className="space-y-4">
              <KPIRow label="Fleet Utilization" value="76%" sub="38 of 50 seats filled avg" />
              <KPIRow label="Route Efficiency" value="88%" sub="5 active routes, 92% on time" />
              <KPIRow label="Student Attendance" value="94%" sub="3200 registered, 3010 boarding" />
              <KPIRow label="Incident Resolution" value="67%" sub="2 resolved of 3 total alerts" />
              <KPIRow label="Parent Engagement" value="82%" sub="410 linked parents active" />
            </div>
          </div>
        </div>

        <div className="data-card p-6">
          <h3 className="font-bold text-lg mb-4">Route Performance Details</h3>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr>
                  <th className="table-header">Route</th>
                  <th className="table-header">Distance</th>
                  <th className="table-header">Stops</th>
                  <th className="table-header">Avg Time</th>
                  <th className="table-header">On-Time %</th>
                  <th className="table-header">Daily Riders</th>
                </tr>
              </thead>
              <tbody>
                {[
                  { name: 'Route A', dist: '12.5 km', stops: 5, time: '1h 45m', ontime: 92, riders: 320 },
                  { name: 'Route B', dist: '14.2 km', stops: 4, time: '1h 50m', ontime: 85, riders: 280 },
                  { name: 'Route C', dist: '10.8 km', stops: 4, time: '1h 35m', ontime: 78, riders: 210 },
                  { name: 'Route D', dist: '8.5 km', stops: 3, time: '1h 10m', ontime: 0, riders: 0 },
                  { name: 'Route E', dist: '11.3 km', stops: 4, time: '1h 40m', ontime: 88, riders: 180 },
                ].map(r => (
                  <tr key={r.name} className="hover:bg-gray-50/50">
                    <td className="table-cell font-medium">{r.name}</td>
                    <td className="table-cell text-gray-500">{r.dist}</td>
                    <td className="table-cell">{r.stops}</td>
                    <td className="table-cell">{r.time}</td>
                    <td className="table-cell">
                      <div className="flex items-center gap-2">
                        <div className="flex-1 max-w-[120px] h-2 rounded-full bg-gray-100">
                          <div className="h-2 rounded-full transition-all" style={{ width: `${r.ontime}%`, backgroundColor: r.ontime >= 85 ? '#10B981' : r.ontime >= 70 ? '#F59E0B' : '#FF3B30' }} />
                        </div>
                        <span className="text-sm font-medium">{r.ontime}%</span>
                      </div>
                    </td>
                    <td className="table-cell font-semibold">{r.riders}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}

function MetricCard({ label, value, icon }: any) {
  return (
    <div className="stat-card">
      <div className="flex items-center gap-3 mb-2">
        <span className="text-lg">{icon}</span>
        <p className="text-xs font-medium text-gray-500">{label}</p>
      </div>
      <p className="text-2xl font-black text-gray-900">{value}</p>
    </div>
  );
}

function KPIRow({ label, value, sub }: any) {
  return (
    <div className="flex items-center justify-between py-2">
      <div>
        <p className="text-sm font-medium text-gray-800">{label}</p>
        <p className="text-xs text-gray-400">{sub}</p>
      </div>
      <span className="text-lg font-black text-gray-900">{value}</span>
    </div>
  );
}
