import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    '/dashboard',
    '/transactions',
    '/reports',
    '/settings',
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _tabs.indexWhere((tab) => location.startsWith(tab));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index != currentIndex) {
            context.go(_tabs[index]);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'خانه',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'تراکنش ها',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'گزارش ها',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'تنظیمات',
          ),
        ],
      ),
    );
  }
}
