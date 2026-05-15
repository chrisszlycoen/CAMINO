import { NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabaseServer';
import type { AdminUser } from '@/lib/types';

// Helper to map Supabase profile row to AdminUser shape (same as client mapUser)
function mapUser(row: any): AdminUser {
  return {
    id: row.id,
    name: row.name ?? '',
    email: row.email ?? '',
    role: row.role,
    phone: row.phone ?? undefined,
    school: row.school ?? undefined,
    grade: row.grade ?? undefined,
    isActive: row.is_active ?? true,
    createdAt: row.created_at ?? new Date().toISOString(),
  };
}

export async function GET() {
  try {
    const { data, error } = await supabaseAdmin
      .from('profiles')
      .select('*')
      .order('created_at', { ascending: false });
    if (error) throw error;
    return NextResponse.json((data || []).map(mapUser));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function PUT(request: Request) {
  try {
    const u = await request.json();
    const { data, error } = await supabaseAdmin
      .from('profiles')
      .update({
        name: u.name,
        phone: u.phone || null,
        role: u.role,
        school: u.school || null,
        grade: u.grade || null,
        is_active: u.isActive,
      })
      .eq('id', u.id)
      .select()
      .single();
    if (error) throw error;
    return NextResponse.json(mapUser(data));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function POST(request: Request) {
  try {
    const u: Omit<AdminUser, 'id'> = await request.json();
    const tempPassword = `${u.role}_${Date.now()}`;
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email: u.email,
      password: tempPassword,
      email_confirm: true,
      user_metadata: { name: u.name, role: u.role },
    });
    if (authError) throw authError;
    if (!authData?.user) throw new Error('Failed to create auth user');

    const { data, error } = await supabaseAdmin
      .from('profiles')
      .upsert({
        id: authData.user.id,
        name: u.name,
        phone: u.phone ?? null,
        role: u.role,
        school: u.school ?? null,
        grade: u.grade ?? null,
        is_active: u.isActive ?? true,
      })
      .select()
      .single();
    if (error) throw error;
    return NextResponse.json(mapUser(data));
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}

export async function DELETE(request: Request) {
  try {
    const { id } = await request.json();
    if (!id) throw new Error('Missing user id');
    const { error } = await supabaseAdmin.auth.admin.deleteUser(id);
    if (error) throw error;
    return NextResponse.json({ success: true });
  } catch (err: any) {
    return NextResponse.json({ error: err.message ?? 'Unexpected error' }, { status: 400 });
  }
}
