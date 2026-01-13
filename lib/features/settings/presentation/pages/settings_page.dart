import 'package:expense_tracker_app/features/reports/presentation/pages/reports_page.dart';
import 'package:expense_tracker_app/shared/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/constants/colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedSettings01,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedAnalytics01,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsPage()),
              );
            },
            tooltip: 'Reports',
          ),
        ],
      ),
      drawer: const AppDrawer(currentPage: 'settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedUser,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'John Doe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Admin',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Premium Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Sections
            _buildSettingsSection(
              'General',
              HugeIcons.strokeRoundedRectangular,
              const Color(0xFF6366F1),
              [
                _buildSettingsTile(
                  HugeIcons.strokeRoundedUser,
                  'Profile',
                  'Manage your personal information',
                  AppColors.primary,
                  () {},
                ),
                _buildSettingsTile(
                  HugeIcons.strokeRoundedNotification01,
                  'Notifications',
                  'Configure alert preferences',
                  const Color(0xFFF59E0B),
                  () {},
                ),
                _buildSettingsTile(
                  HugeIcons.strokeRoundedGlobe,
                  'Language',
                  'English (US)',
                  const Color(0xFF10B981),
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSettingsSection(
              'Hostel Management',
              HugeIcons.strokeRoundedHome01,
              const Color(0xFF8B5CF6),
              [
                _buildSettingsTile(
                  HugeIcons.strokeRoundedHome04,
                  'Hostel Info',
                  'Edit hostel details & rules',
                  const Color(0xFF8B5CF6),
                  () {},
                ),
                _buildSettingsTile(
                  HugeIcons.strokeRoundedRestaurant01,
                  'Meal Settings',
                  'Configure meal timings & types',
                  const Color(0xFFF59E0B),
                  () {},
                ),
                _buildSettingsTile(
                  HugeIcons.strokeRoundedDollar02,
                  'Fee Structure',
                  'Manage fee rates & schedules',
                  AppColors.success,
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSettingsSection(
              'Reports & Analytics',
              HugeIcons.strokeRoundedChart,
              const Color(0xFFEC4899),
              [
                _buildSettingsTile(
                  HugeIcons.strokeRoundedChartUp,
                  'Financial Reports',
                  'Generate expense & income reports',
                  AppColors.success,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportsPage(),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  HugeIcons.strokeRoundedPieChart,
                  'Analytics Dashboard',
                  'View detailed analytics',
                  const Color(0xFF6366F1),
                  () {},
                ),
                _buildSettingsTile(
                  HugeIcons.strokeRoundedFileDownload,
                  'Export Data',
                  'Export data to CSV/Excel',
                  const Color(0xFFF59E0B),
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSettingsSection(
              'Account',
              HugeIcons.strokeRoundedShield02,
              AppColors.danger,
              [
                _buildSettingsTile(
                  HugeIcons.strokeRoundedLock,
                  'Security',
                  'Change password & 2FA',
                  AppColors.primary,
                  () {},
                ),
                _buildSettingsTile(
                  HugeIcons.strokeRoundedEye,
                  'Privacy',
                  'Manage privacy settings',
                  const Color(0xFF8B5CF6),
                  () {},
                ),
                _buildSettingsTile(
                  HugeIcons.strokeRoundedLogout02,
                  'Logout',
                  'Sign out from all devices',
                  AppColors.danger,
                  () {},
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> tiles,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: HugeIcon(icon: icon, color: color, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
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
    Color color,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? AppColors.danger.withOpacity(0.1)
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: icon,
                      color: isDestructive ? AppColors.danger : color,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? AppColors.danger
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: Colors.grey.shade500,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
