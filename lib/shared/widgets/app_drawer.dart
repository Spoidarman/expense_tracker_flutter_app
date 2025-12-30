import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/members/presentation/pages/members_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/funds/presentation/pages/funds_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/registration/presentation/pages/registration_page.dart';

class AppDrawer extends StatelessWidget {
  final String currentPage;
  
  const AppDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Profile Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'M',
                style: TextStyle(
                  fontSize: 40,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: const Text(
              'Mainak',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: const Text('mainak@hostel.com'),
            otherAccountsPictures: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // Edit profile
                },
              ),
            ],
          ),
          
          // Dashboard
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            page: 'dashboard',
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (currentPage != 'dashboard') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardPage()),
                );
              }
            },
          ),
          
          // Expenses
          _buildDrawerItem(
            context,
            icon: Icons.receipt_long,
            title: 'Expenses',
            page: 'expenses',
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (currentPage != 'expenses') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpensesPage()),
                );
              }
            },
          ),
          
          // Members
          _buildDrawerItem(
            context,
            icon: Icons.people,
            title: 'Members',
            page: 'members',
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (currentPage != 'members') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MembersPage()),
                );
              }
            },
          ),
          
          // Reports
          _buildDrawerItem(
            context,
            icon: Icons.bar_chart,
            title: 'Reports',
            page: 'reports',
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (currentPage != 'reports') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportsPage()),
                );
              }
            },
          ),
          
          const Divider(),
          
          // Funds
          _buildDrawerItem(
            context,
            icon: Icons.account_balance_wallet,
            title: 'Fund Management',
            page: 'funds',
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FundsPage()),
              );
            },
          ),
          
          // Add Member
          _buildDrawerItem(
            context,
            icon: Icons.person_add,
            title: 'Add New Member',
            page: 'registration',
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegistrationPage()),
              );
            },
          ),
          
          const Divider(),
          
          // Settings
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            page: 'settings',
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          
          // Logout - Same styling as other items
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            page: 'logout',
            isDestructive: true,
            onTap: () {
              Navigator.pop(context); // Close drawer first
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Perform logout and navigate to login
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String page,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isSelected = currentPage == page;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primary.withOpacity(0.1) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive 
              ? AppColors.danger 
              : (isSelected ? AppColors.primary : AppColors.textSecondary),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive 
                ? AppColors.danger 
                : (isSelected ? AppColors.primary : AppColors.textPrimary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
