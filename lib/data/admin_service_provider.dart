import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_admin_service.dart';

final supabaseAdminServiceProvider = Provider<SupabaseAdminService>((ref) {
  return SupabaseAdminService();
});
