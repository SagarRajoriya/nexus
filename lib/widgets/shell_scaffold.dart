import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class _NavItem {
  final String path;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavItem(this.path, this.label, this.icon, this.activeIcon);
}

const _navItems = [
  _NavItem('/', 'Home', Icons.home_outlined, Icons.home_rounded),
  _NavItem('/devices', 'Devices', Icons.devices_outlined, Icons.devices_rounded),
  _NavItem('/transfer', 'Transfer', Icons.swap_horiz_outlined, Icons.swap_horiz_rounded),
  _NavItem('/stream', 'Stream', Icons.cast_outlined, Icons.cast_rounded),
  _NavItem('/mouse', 'Control', Icons.mouse_outlined, Icons.mouse_rounded),
  _NavItem('/clipboard', 'Clipboard', Icons.content_paste_outlined, Icons.content_paste_rounded),
  _NavItem('/notifications', 'Notify', Icons.notifications_outlined, Icons.notifications_rounded),
  _NavItem('/cloud', 'Cloud', Icons.cloud_outlined, Icons.cloud_rounded),
  _NavItem('/settings', 'Settings', Icons.settings_outlined, Icons.settings_rounded),
];

class ShellScaffold extends StatelessWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final idx = _navItems.indexWhere((n) => n.path == loc);
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    final selected = _selectedIndex(context);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _SideRail(selected: selected),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomBar(selected: selected),
    );
  }
}

class _SideRail extends StatelessWidget {
  final int selected;
  const _SideRail({required this.selected});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 220,
      color: scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 52),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.hub_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text('Nexus',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (context, i) {
                final item = _navItems[i];
                final isSelected = selected == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    selected: isSelected,
                    selectedTileColor: AppTheme.primary.withOpacity(0.12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    leading: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 20,
                      color: isSelected
                          ? AppTheme.primary
                          : scheme.onSurface.withOpacity(0.4),
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? AppTheme.primary
                            : scheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    onTap: () => context.go(item.path),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    minLeadingWidth: 20,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int selected;
  const _BottomBar({required this.selected});

  // Show only the first 5 items on mobile bottom bar
  static const _mobileItems = [0, 1, 2, 3, 7]; // home, devices, transfer, stream, cloud

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _mobileItems.indexOf(selected) < 0
          ? 0
          : _mobileItems.indexOf(selected),
      onTap: (i) => context.go(_navItems[_mobileItems[i]].path),
      items: _mobileItems
          .map((i) => BottomNavigationBarItem(
                icon: Icon(_navItems[i].icon),
                activeIcon: Icon(_navItems[i].activeIcon),
                label: _navItems[i].label,
              ))
          .toList(),
    );
  }
}
