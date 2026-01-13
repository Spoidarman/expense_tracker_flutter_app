import 'dart:async';
import 'package:expense_tracker_app/shared/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/auth_service.dart'; // Import the new widget
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../registration/presentation/pages/registration_page.dart';
import '../../../funds/presentation/pages/funds_page.dart';
import '../../../expenses/presentation/pages/expenses_page.dart';
import '../../../members/presentation/pages/members_page.dart';
import '../../../members/presentation/pages/meal_preference_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String userName = 'User';
  bool _isLoading = true;
  int _currentSliderIndex = 0;
  PageController? _pageController;
  Timer? _sliderTimer;
  int _currentBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _sliderTimer?.cancel();
    super.dispose();
  }

  void _initializeSlider() {
    _pageController ??= PageController(viewportFraction: 0.85);
    _sliderTimer ??= Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController?.hasClients ?? false) {
        final nextPage = (_currentSliderIndex + 1) % 3; // 3 cards in slider
        _pageController?.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService.getUserData();
    if (mounted) {
      setState(() {
        userName = userData['user_name'] ?? 'User';
        _isLoading = false;
      });
      // Initialize slider after data is loaded
      _initializeSlider();
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MembersPage()),
        );
        // Don't reset index here - let the back button handle it
        break;
      case 2:
        // This is the plus button - handled separately
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FundsPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
    }
  }

  void _onPlusButtonPressed() {
    // Navigate to Meal Preference Page with normal push
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealPreferencePage(memberName: userName),
      ),
    );
  }

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
                  icon: HugeIcons.strokeRoundedHouse02,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Expense Manager',
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
        automaticallyImplyLeading: false, // This removes the back button
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedNotification01,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: _isLoading
          ? _buildShimmerLoading()
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Card
                        _buildWelcomeCard(),
                        const SizedBox(height: 20),

                        // Stats Slider
                        _buildStatsSlider(),
                        const SizedBox(height: 24),

                        // Quick Actions Row
                        _buildQuickActionsRow(),
                        const SizedBox(height: 24),

                        // Today's Overview
                        _buildTodaysOverview(),
                      ],
                    ),
                  ),
                ),

                // Absent Members List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: _buildAbsentMembersList(),
                ),
              ],
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTapped,
        onPlusPressed: _onPlusButtonPressed,
      ),
    );
  }

  // All other methods remain the same (WelcomeCard, StatsSlider, etc.)
  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage your hostel activities',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          FloatingActionButton.small(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegistrationPage(),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedUserAdd01,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSlider() {
    // Initialize slider if not already initialized
    if (_pageController == null) {
      _initializeSlider();
    }

    final statsCards = [
      _buildStatCard(
        title: 'Monthly Expense',
        amount: '₹12,450',
        icon: HugeIcons.strokeRoundedChartDown,
        color: AppColors.danger,
        gradient: [AppColors.danger, const Color(0xFFF75555)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExpensesPage()),
        ),
      ),
      _buildStatCard(
        title: 'Available Funds',
        amount: '₹25,680',
        icon: HugeIcons.strokeRoundedWallet01,
        color: AppColors.success,
        gradient: [AppColors.success, const Color(0xFF47C272)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FundsPage()),
        ),
      ),
      _buildStatCard(
        title: 'Meal Count',
        amount: '22',
        icon: HugeIcons.strokeRoundedServingFood,
        color: AppColors.primary,
        gradient: [AppColors.primary, AppColors.secondary],
        onTap: () {},
      ),
    ];

    return SizedBox(
      height: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Quick Stats',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: _pageController != null
                ? PageView.builder(
                    controller: _pageController!,
                    onPageChanged: (index) {
                      setState(() {
                        _currentSliderIndex = index;
                      });
                    },
                    itemCount: statsCards.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: statsCards[index],
                      );
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(statsCards.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentSliderIndex == index
                      ? AppColors.primary
                      : Colors.grey.shade300,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: HugeIcon(icon: icon, color: Colors.white, size: 20),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    final actions = [
      {
        'title': 'Add Member',
        'icon': HugeIcons.strokeRoundedUserAdd01,
        'color': AppColors.primary,
        'route': const RegistrationPage(),
      },
      {
        'title': 'View All',
        'icon': HugeIcons.strokeRoundedUserGroup,
        'color': AppColors.success,
        'route': const MembersPage(),
      },
      {
        'title': 'Add Expense',
        'icon': HugeIcons.strokeRoundedReceiptDollar,
        'color': AppColors.warning,
        'route': const ExpensesPage(),
      },
      {
        'title': 'Add Funds',
        'icon': HugeIcons.strokeRoundedMoneyBag01,
        'color': AppColors.primary,
        'route': const FundsPage(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Row(
          children: actions.map((action) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => action['route'] as Widget,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (action['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: action['icon'] as IconData,
                            color: action['color'] as Color,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['title'] as String,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTodaysOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Overview',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'LIVE',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMealCard(
                  title: 'Lunch',
                  count: '12',
                  icon: HugeIcons.strokeRoundedStreetFood,
                  color: AppColors.warning,
                  time: '12:30 PM',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMealCard(
                  title: 'Dinner',
                  count: '10',
                  icon: HugeIcons.strokeRoundedOrganicFood,
                  color: AppColors.primary,
                  time: '8:00 PM',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: HugeIcon(icon: icon, color: color, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            'Members',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  SliverList _buildAbsentMembersList() {
    final absentMembers = [
      {'name': 'Rahul Kumar', 'meal': 'Lunch & Dinner', 'time': '2 days'},
      {'name': 'Priya Singh', 'meal': 'Dinner Only', 'time': 'Today'},
      {'name': 'Amit Sharma', 'meal': 'Lunch Only', 'time': 'Today'},
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return _buildAbsentMemberItem(
          name: absentMembers[index]['name']!,
          mealInfo: absentMembers[index]['meal']!,
          time: absentMembers[index]['time']!,
        );
      }, childCount: absentMembers.length),
    );
  }

  Widget _buildAbsentMemberItem({
    required String name,
    required String mealInfo,
    required String time,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MembersPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedUserRemove01,
                  color: AppColors.danger,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mealInfo,
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Welcome card shimmer
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            // Stats slider shimmer
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
