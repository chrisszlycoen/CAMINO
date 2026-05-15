import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabaseServer';

function mapSchedule(row: any) {
  return {
    id: row.id,
    busId: row.bus_id || '',
    busPlate: row.buses?.plate_number || row.bus_plate || '',
    routeId: row.route_id || '',
    routeName: row.routes?.name || row.route_name || '',
    date: row.date || '',
    departureTime: row.departure_time || '',
    arrivalTime: row.arrival_time || '',
    status: row.status || 'scheduled',
  };
}

export async function GET() {
  try {
    const { data, error } = await supabaseAdmin
      .from('schedules')
      .select('*, buses!inner(plate_number), routes!inner(name)')
      .order('date', { ascending: false });
    if (error) throw error;
    return NextResponse.json((data || []).map(mapSchedule));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function POST(request: Request) {
  try {
    const s = await request.json();
    const { data, error } = await supabaseAdmin
      .from('schedules')
      .insert({
        bus_id: s.busId,
        route_id: s.routeId,
        date: s.date,
        departure_time: s.departureTime,
        arrival_time: s.arrivalTime,
        status: s.status || 'scheduled',
      })
      .select('*, buses!inner(plate_number), routes!inner(name)')
      .single();
    if (error) throw error;
    return NextResponse.json(mapSchedule(data));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function PUT(request: Request) {
  try {
    const s = await request.json();
    const { data, error } = await supabaseAdmin
      .from('schedules')
      .update({
        bus_id: s.busId,
        route_id: s.routeId,
        date: s.date,
        departure_time: s.departureTime,
        arrival_time: s.arrivalTime,
        status: s.status,
      })
      .eq('id', s.id)
      .select('*, buses!inner(plate_number), routes!inner(name)')
      .single();
    if (error) throw error;
    return NextResponse.json(mapSchedule(data));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function DELETE(request: Request) {
  try {
    const { id } = await request.json();
    if (!id) throw new Error('Missing schedule id');
    const { error } = await supabaseAdmin.from('schedules').delete().eq('id', id);
    if (error) throw error;
    return NextResponse.json({ success: true });
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}
