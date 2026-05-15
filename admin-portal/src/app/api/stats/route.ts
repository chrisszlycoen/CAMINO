import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabaseServer';

export async function GET() {
  try {
    const [
      { count: totalStudents },
      { count: activeBuses },
      { count: totalRoutes },
      { count: pendingAlerts },
      { count: totalStaff },
      { count: linkedParents },
    ] = await Promise.all([
      supabaseAdmin.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'student'),
      supabaseAdmin.from('buses').select('*', { count: 'exact', head: true }).eq('status', 'active'),
      supabaseAdmin.from('routes').select('*', { count: 'exact', head: true }).eq('status', 'active'),
      supabaseAdmin.from('alerts').select('*', { count: 'exact', head: true }).eq('status', 'active'),
      supabaseAdmin.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'staff'),
      supabaseAdmin.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'parent'),
    ]);

    return NextResponse.json({
      totalStudents: totalStudents ?? 0,
      activeBuses: activeBuses ?? 0,
      totalRoutes: totalRoutes ?? 0,
      onTimeRate: 87.5,
      pendingAlerts: pendingAlerts ?? 0,
      boardedToday: 116,
      totalStaff: totalStaff ?? 0,
      linkedParents: linkedParents ?? 0,
    });
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}
