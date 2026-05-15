import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabaseServer';

function mapRoute(row: any) {
  return {
    id: row.id,
    name: row.name || '',
    stops: Array.isArray(row.stops) ? row.stops : (typeof row.stops === 'string' ? JSON.parse(row.stops) : []),
    status: row.status || 'inactive',
  };
}

export async function GET() {
  try {
    const { data, error } = await supabaseAdmin
      .from('routes')
      .select('*')
      .order('name');
    if (error) throw error;
    return NextResponse.json((data || []).map(mapRoute));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function POST(request: Request) {
  try {
    const r = await request.json();
    const { data, error } = await supabaseAdmin
      .from('routes')
      .insert({
        name: r.name,
        stops: r.stops,
        status: r.status || 'active',
      })
      .select()
      .single();
    if (error) throw error;
    return NextResponse.json(mapRoute(data));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function PUT(request: Request) {
  try {
    const r = await request.json();
    const { data, error } = await supabaseAdmin
      .from('routes')
      .update({
        name: r.name,
        stops: r.stops,
        status: r.status,
      })
      .eq('id', r.id)
      .select()
      .single();
    if (error) throw error;
    return NextResponse.json(mapRoute(data));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function DELETE(request: Request) {
  try {
    const { id } = await request.json();
    if (!id) throw new Error('Missing route id');
    const { error } = await supabaseAdmin.from('routes').delete().eq('id', id);
    if (error) throw error;
    return NextResponse.json({ success: true });
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}
