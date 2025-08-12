import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/logout_view_model.dart';
import '../../../view_models/user/setting_view_model.dart';
import '../update_password/update_password_screen.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({super.key});
  @override
  Widget build(BuildContext context) {
    var settingsVM = Provider.of<SettingsViewModel>(context);
    var logoutVM = Provider.of<LogoutViewModel>(context, listen: false);

    return Column(
      children: [
        _SettingsItem(
          icon: Icons.notifications_none,
          title: 'Notifications',
          trailing: Switch(
            value: settingsVM.notificationsEnabled,
            activeColor: Colors.green,
            onChanged: settingsVM.toggleNotifications,
          ),
        ),
        _SettingsItem(
          icon: Icons.nightlight,
          title: 'Dark mode',
          trailing: Switch(
            value: settingsVM.darkModeEnabled,
            onChanged: settingsVM.toggleDarkMode,
          ),
        ),
        _SettingsItem(
          icon: Icons.lock_outline,
          title: 'Password',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UpdatePasswordScreen()),
          ),
        ),
        _SettingsItem(
          icon: Icons.logout,
          title: 'Logout',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: logoutVM.showDialog,
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 18),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
            trailing,
          ],
        ),
      ),
    );
  }
}
