import 'package:flutter/material.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simply return the Dashboard page - no tabs
    return const DashboardPage();
  }
}
