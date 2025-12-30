import 'package:expense_tracker_app/shared/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
       drawer: const AppDrawer(currentPage: 'settings'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsSection(
            'General',
            [
              _buildSettingsTile(Icons.person, 'Profile', 'Manage your profile', () {}),
              _buildSettingsTile(Icons.notifications, 'Notifications', 'Configure notifications', () {}),
              _buildSettingsTile(Icons.language, 'Language', 'English', () {}),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSettingsSection(
            'Hostel',
            [
              _buildSettingsTile(Icons.home, 'Hostel Info', 'Edit hostel details', () {}),
              _buildSettingsTile(Icons.restaurant, 'Meal Settings', 'Configure meal times', () {}),
              _buildSettingsTile(Icons.currency_rupee, 'Fee Structure', 'Manage fees', () {}),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSettingsSection(
            'Account',
            [
              _buildSettingsTile(Icons.lock, 'Change Password', 'Update your password', () {}),
              _buildSettingsTile(Icons.privacy_tip, 'Privacy', 'Privacy settings', () {}),
              _buildSettingsTile(Icons.logout, 'Logout', 'Sign out of app', () {}, isDestructive: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive 
              ? AppColors.danger.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.danger : AppColors.primary,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppColors.danger : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}
