'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useAuth } from '@/lib/auth';
import { BarChart3, Users, Bus, Map, Calendar, TrendingUp, Bell, Settings, LogOut } from 'lucide-react';

const NAV_ITEMS = [
  { href: '/dashboard', label: 'Dashboard', icon: BarChart3 },
  { href: '/users', label: 'Users', icon: Users },
  { href: '/buses', label: 'Buses', icon: Bus },
  { href: '/routes', label: 'Routes', icon: Map },
  { href: '/schedules', label: 'Schedules', icon: Calendar },
  { href: '/analytics', label: 'Analytics', icon: TrendingUp },
  { href: '/alerts', label: 'Alerts', icon: Bell },
  { href: '/settings', label: 'Settings', icon: Settings },
];

export default function Sidebar() {
  const pathname = usePathname();
  const { user, logout } = useAuth();
  const router = useRouter();

  return (
    <aside className="flex flex-col shrink-0" style={{ width: 'var(--sidebar-width)', backgroundColor: '#0A3D2F' }}>
      <div className="p-5 border-b border-white/10">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-white/20 flex items-center justify-center text-white"><Bus size={20} /></div>
          <div>
            <div className="text-white font-black text-lg tracking-tight">CAMINO</div>
            <div className="text-white/50 text-[10px] font-semibold tracking-widest uppercase">Admin Portal</div>
          </div>
        </div>
      </div>

      <nav className="flex-1 p-3 space-y-1 overflow-y-auto">
        {NAV_ITEMS.map(item => {
          const isActive = pathname.startsWith(item.href);
          return (
            <Link key={item.href} href={item.href}
              className={`sidebar-link ${isActive ? 'active' : 'text-white/70'}`}>
              <item.icon size={20} />
              <span>{item.label}</span>
            </Link>
          );
        })}
      </nav>

      <div className="p-4 border-t border-white/10">
        <div className="flex items-center gap-3 mb-3">
          <div className="w-9 h-9 rounded-full bg-white/20 flex items-center justify-center text-white text-sm font-bold">
            {user?.name?.charAt(0) || 'A'}
          </div>
          <div className="flex-1 min-w-0">
            <div className="text-white text-sm font-semibold truncate">{user?.name}</div>
            <div className="text-white/50 text-xs truncate">{user?.email}</div>
          </div>
        </div>
        <button onClick={() => { logout(); router.replace('/login'); }}
          className="flex items-center gap-2 text-white/60 hover:text-white text-sm transition-colors w-full">
          <LogOut size={16} />
          <span>Sign Out</span>
        </button>
      </div>
    </aside>
  );
}
