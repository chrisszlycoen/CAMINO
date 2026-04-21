import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_app_bar.dart';
import '../../../shared/widgets/camino_card.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CaminoAppBar(
        title: 'Help & Support',
        showNotification: false,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          CaminoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick help', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                Text('If you can’t find what you need, contact support below.', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          CaminoCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.chat_bubble_outline),
                  title: Text('Chat with support', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.chevron_right, size: 20),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.phone_outlined),
                  title: Text('Call support', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.chevron_right, size: 20),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text('Email support', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.chevron_right, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

