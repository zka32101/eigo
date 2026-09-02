import 'package:flutter/material.dart';
import 'admin_system_overview_screen.dart';
import 'admin_user_management_screen.dart';
import 'admin_moderation_panel_screen.dart';
import 'admin_reports_dashboard_screen.dart';
import 'admin_feature_flags_screen.dart';
import 'admin_audit_log_screen.dart';

/// Main admin dashboard screen with navigation
class AdminDashboardMainScreen extends StatefulWidget {
  const AdminDashboardMainScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardMainScreen> createState() =>
      _AdminDashboardMainScreenState();
}

class _AdminDashboardMainScreenState extends State<AdminDashboardMainScreen> {
  int _selectedIndex = 0;

  final List<({String label, IconData icon, Widget screen})> _screens = [
    (
      label: 'ダッシュボード',
      icon: Icons.dashboard,
      screen: const AdminSystemOverviewScreen(),
    ),
    (
      label: 'ユーザー管理',
      icon: Icons.people,
      screen: const AdminUserManagementScreen(),
    ),
    (
      label: 'モデレーション',
      icon: Icons.security,
      screen: const AdminModerationPanelScreen(),
    ),
    (
      label: 'レポート',
      icon: Icons.assessment,
      screen: const AdminReportsDashboardScreen(),
    ),
    (
      label: 'フラグ',
      icon: Icons.flag,
      screen: const AdminFeatureFlagsScreen(),
    ),
    (
      label: '監査ログ',
      icon: Icons.history,
      screen: const AdminAuditLogScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: List.generate(
              _screens.length,
              (index) => NavigationRailDestination(
                icon: Icon(_screens[index].icon),
                label: Text(_screens[index].label),
              ),
            ),
          ),
          // Main content
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens.map((s) => s.screen).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Admin dashboard drawer widget (for mobile)
class AdminDashboardDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminDashboardDrawer({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screens = [
      (label: 'ダッシュボード', icon: Icons.dashboard),
      (label: 'ユーザー管理', icon: Icons.people),
      (label: 'モデレーション', icon: Icons.security),
      (label: 'レポート', icon: Icons.assessment),
      (label: 'フラグ', icon: Icons.flag),
      (label: 'ログ', icon: Icons.history),
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              '管理パネル',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...List.generate(
            screens.length,
            (index) => ListTile(
              leading: Icon(screens[index].icon),
              title: Text(screens[index].label),
              selected: selectedIndex == index,
              onTap: () {
                onItemSelected(index);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
