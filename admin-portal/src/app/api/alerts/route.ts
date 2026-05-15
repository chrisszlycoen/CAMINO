import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabaseServer';

function mapAlert(row: any) {
  return {
    id: row.id,
    title: row.title || '',
    message: row.message || '',
    severity: row.severity || 'low',
    status: row.status || 'active',
    createdAt: row.created_at || new Date().toISOString(),
    resolvedBy: row.resolved_by_name || undefined,
    resolvedAt: row.resolved_at || undefined,
  };
}

export async function GET() {
  try {
    const { data, error } = await supabaseAdmin
      .from('alerts')
      .select('*')
      .order('created_at', { ascending: false });
    if (error) throw error;
    return NextResponse.json((data || []).map(mapAlert));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function POST(request: Request) {
  try {
    const a = await request.json();
    const { data, error } = await supabaseAdmin
      .from('alerts')
      .insert({
        title: a.title,
        message: a.message,
        severity: a.severity,
        status: 'active',
        created_by: a.createdBy || null,
      })
      .select()
      .single();
    if (error) throw error;
    return NextResponse.json(mapAlert(data));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function PUT(request: Request) {
  try {
    const a = await request.json();
    const { data, error } = await supabaseAdmin
      .from('alerts')
      .update({
        status: a.status || 'resolved',
        resolved_by: a.resolvedBy || null,
        resolved_at: a.status === 'resolved' ? new Date().toISOString() : undefined,
      })
      .eq('id', a.id)
      .select()
      .single();
    if (error) throw error;
    return NextResponse.json(mapAlert(data));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function DELETE(request: Request) {
  try {
    const { id } = await request.json();
    if (!id) throw new Error('Missing alert id');
    const { error } = await supabaseAdmin.from('alerts').delete().eq('id', id);
    if (error) throw error;
    return NextResponse.json({ success: true });
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}
