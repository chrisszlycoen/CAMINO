import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/mock_data.dart';
import '../../../shared/widgets/camino_app_bar.dart';
import '../../../shared/widgets/camino_card.dart';

class LinkedChildrenScreen extends StatelessWidget {
  const LinkedChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final children = MockData.allStudents;

    return Scaffold(
      appBar: CaminoAppBar(
        title: 'Linked Children',
        showNotification: false,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: children.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final child = children[index];
          return CaminoCard(
            padding: EdgeInsets.zero,
            onTap: () => context.pop(),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(child.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${child.school} • ${child.grade}'),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}

