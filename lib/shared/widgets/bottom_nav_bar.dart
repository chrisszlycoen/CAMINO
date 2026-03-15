import 'package:flutter/material.dart';

/// Ultra-clean structural Navigation Bar
class CaminoBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const CaminoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // We map the BottomNavigationBarItem to NavigationDestination
    final destinations = items.map((item) {
      return NavigationDestination(
        icon: item.icon,
        selectedIcon: item.activeIcon,
        label: item.label ?? '',
      );
    }).toList();

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: destinations,
    );
  }
}
