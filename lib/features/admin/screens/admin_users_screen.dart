import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/admin_stats_card.dart';
import '../data/mock_admin_data.dart';
import '../models/admin_models.dart';
import '../../../core/theme/app_colors.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  List<AdminUser> _users = [];
  List<AdminUser> _filtered = [];
  bool _loading = true;
  String _searchQuery = '';
  String _roleFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final users = await MockAdminData.getUsers();
    if (mounted) setState(() { _users = users; _applyFilter(); _loading = false; });
  }

  void _applyFilter() {
    _filtered = _users.where((u) {
      if (_roleFilter != 'all' && u.role != _roleFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q) || u.id.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  Future<void> _showUserDialog({AdminUser? user}) async {
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final schoolCtrl = TextEditingController(text: user?.school ?? '');
    final gradeCtrl = TextEditingController(text: user?.grade ?? '');
    String role = user?.role ?? 'student';
    bool isActive = user?.isActive ?? true;
    final isEditing = user != null;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit User' : 'Add New User'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()), textCapitalization: TextCapitalization.words),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'student', child: Text('Student')),
                      DropdownMenuItem(value: 'parent', child: Text('Parent')),
                      DropdownMenuItem(value: 'staff', child: Text('Staff')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (v) => setDialogState(() => role = v!),
                  ),
                  const SizedBox(height: 12),
                  if (role == 'student') ...[
                    TextField(controller: schoolCtrl, decoration: const InputDecoration(labelText: 'School', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: gradeCtrl, decoration: const InputDecoration(labelText: 'Grade', border: OutlineInputBorder())),
                  ],
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Active Account'),
                    value: isActive,
                    onChanged: (v) => setDialogState(() => isActive = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, {'name': nameCtrl.text, 'email': emailCtrl.text, 'phone': phoneCtrl.text, 'school': schoolCtrl.text, 'grade': gradeCtrl.text, 'role': role, 'isActive': isActive}),
              child: Text(isEditing ? 'Update' : 'Add User'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      if (isEditing) {
        await MockAdminData.updateUser(user!.copyWith(
          name: result['name'], email: result['email'], phone: result['phone'],
          school: result['school'], grade: result['grade'], role: result['role'], isActive: result['isActive'],
        ));
      } else {
        await MockAdminData.addUser(AdminUser(
          id: MockAdminData.generateId('USR'),
          name: result['name'], email: result['email'], phone: result['phone'],
          school: result['school'], grade: result['grade'], role: result['role'],
          isActive: result['isActive'], createdAt: DateTime.now(),
        ));
      }
      _loadUsers();
    }

    nameCtrl.dispose(); emailCtrl.dispose(); phoneCtrl.dispose(); schoolCtrl.dispose(); gradeCtrl.dispose();
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'student': return AppColors.primary;
      case 'parent': return AppColors.info;
      case 'staff': return AppColors.warning;
      case 'admin': return AppColors.error;
      default: return AppColors.textSecondaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : const Color(0xFFF5F5F7);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          AdminPageHeader(
            title: 'User Management',
            subtitle: '${_users.length} total users',
            action: ElevatedButton.icon(
              onPressed: () => _showUserDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add User'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
            ),
          ),
          // Filters
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Row(
              children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                    onChanged: (v) { setState(() { _searchQuery = v; _applyFilter(); }); },
                    decoration: InputDecoration(
                      hintText: 'Search by name, email or ID...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimaryLight),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _roleFilter,
                  dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                  style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimaryLight),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Roles')),
                    DropdownMenuItem(value: 'student', child: Text('Students')),
                    DropdownMenuItem(value: 'parent', child: Text('Parents')),
                    DropdownMenuItem(value: 'staff', child: Text('Staff')),
                    DropdownMenuItem(value: 'admin', child: Text('Admins')),
                  ],
                  onChanged: (v) { setState(() { _roleFilter = v!; _applyFilter(); }); },
                ),
                const Spacer(),
                Text('${_filtered.length} results', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              ],
            ),
          ),
          // Table
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 800) {
                                return _buildMobileList(isDark);
                              }
                              return _buildTable(isDark);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final headerColor = isDark ? AppColors.surfaceDarkElevated : const Color(0xFFF5F5F7);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowColor: WidgetStatePropertyAll(headerColor),
        columns: const [
          DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.w700))),
          DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.w700))),
          DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.w700))),
          DataColumn(label: Text('School', style: TextStyle(fontWeight: FontWeight.w700))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w700))),
          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
        ],
        rows: _filtered.map((u) => DataRow(cells: [
          DataCell(Text(u.name, style: TextStyle(fontWeight: FontWeight.w500, color: textColor))),
          DataCell(Text(u.email, style: TextStyle(color: secondaryColor, fontSize: 13))),
          DataCell(_RoleBadge(role: u.role, color: _roleColor(u.role))),
          DataCell(Text(u.school ?? '-', style: TextStyle(color: secondaryColor))),
          DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: (u.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Text(u.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 12, color: u.isActive ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600)))),
          DataCell(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showUserDialog(user: u), color: AppColors.info),
              IconButton(icon: const Icon(Icons.delete, size: 18), onPressed: () async {
                final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete User'), content: Text('Delete ${u.name}?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Delete'))]));
                if (confirm == true) { await MockAdminData.deleteUser(u.id); _loadUsers(); }
              }, color: AppColors.error),
            ],
          )),
        ])).toList(),
      ),
    );
  }

  Widget _buildMobileList(bool isDark) {
    return Column(
      children: _filtered.map((u) => ListTile(
        leading: CircleAvatar(backgroundColor: _roleColor(u.role).withValues(alpha: 0.2), child: Icon(Icons.person, color: _roleColor(u.role), size: 20)),
        title: Text(u.name, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimaryLight)),
        subtitle: Text('${u.email}  •  ${u.role}', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showUserDialog(user: u), color: AppColors.info),
            IconButton(icon: const Icon(Icons.delete, size: 18), onPressed: () async {
              final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete User'), content: Text('Delete ${u.name}?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Delete'))]));
              if (confirm == true) { await MockAdminData.deleteUser(u.id); _loadUsers(); }
            }, color: AppColors.error),
          ],
        ),
      )).toList(),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  final Color color;
  const _RoleBadge({required this.role, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(role[0].toUpperCase() + role.substring(1), style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
