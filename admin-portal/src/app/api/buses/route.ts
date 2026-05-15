import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabaseServer';

function mapBus(row: any) {
  return {
    id: row.id,
    plateNumber: row.plate_number || '',
    capacity: row.capacity || 0,
    driverName: row.driver_name || '',
    driverPhone: row.driver_phone || undefined,
    routeId: row.route_id || undefined,
    routeName: row.routes?.name || row.route_name || undefined,
    status: row.status || 'inactive',
    currentPassengers: row.current_passengers ?? 0,
  };
}

export async function GET() {
  try {
    const { data, error } = await supabaseAdmin
      .from('buses')
      .select('*, routes!left(name)')
      .order('plate_number');
    if (error) throw error;
    return NextResponse.json((data || []).map(mapBus));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function POST(request: Request) {
  try {
    const b = await request.json();
    const { data, error } = await supabaseAdmin
      .from('buses')
      .insert({
        plate_number: b.plateNumber,
        capacity: b.capacity,
        driver_name: b.driverName,
        driver_phone: b.driverPhone || null,
        route_id: b.routeId || null,
        status: b.status || 'active',
        current_passengers: b.currentPassengers ?? 0,
      })
      .select('*, routes!left(name)')
      .single();
    if (error) throw error;
    return NextResponse.json(mapBus(data));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function PUT(request: Request) {
  try {
    const b = await request.json();
    const { data, error } = await supabaseAdmin
      .from('buses')
      .update({
        plate_number: b.plateNumber,
        capacity: b.capacity,
        driver_name: b.driverName,
        driver_phone: b.driverPhone || null,
        route_id: b.routeId || null,
        status: b.status,
        current_passengers: b.currentPassengers,
      })
      .eq('id', b.id)
      .select('*, routes!left(name)')
      .single();
    if (error) throw error;
    return NextResponse.json(mapBus(data));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function DELETE(request: Request) {
  try {
    const { id } = await request.json();
    if (!id) throw new Error('Missing bus id');
    const { error } = await supabaseAdmin.from('buses').delete().eq('id', id);
    if (error) throw error;
    return NextResponse.json({ success: true });
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}
