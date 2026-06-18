import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return ListView(
      children: [
        const SizedBox(height: 8),
        _sectionHeader('Appearance'),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode),
          title: const Text('Dark Mode'),
          value: isDark,
          activeThumbColor: AppColors.primary,
          onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
        ),
        const Divider(),
        _sectionHeader('Account'),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Logout', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            }
          },
        ),
        const Divider(),
        _sectionHeader('About'),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Version'),
          trailing: Text('1.0.0', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
              letterSpacing: 0.8)),
    );
  }
}
