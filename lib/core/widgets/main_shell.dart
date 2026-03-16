import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/shared/data/models/user_model.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final UserModel user;

  const MainShell({super.key, required this.child, required this.user});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/tasks')) return 1;
    if (location.startsWith('/users')) return user.role == 'admin' ? 2 : 1;
    if (location.startsWith('/profile')) return user.role == 'admin' ? 3 : 2;
    return 0;
  }

  List<NavigationDestination> _destinations(bool isAdmin, ColorScheme colorScheme) {
    return [
      NavigationDestination(
        icon: ColorFiltered(
          colorFilter: ColorFilter.mode(
            colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
          child: Image.asset('assets/icons/home.png', height: 24, width: 24),
        ),
        selectedIcon: ColorFiltered(
          colorFilter: ColorFilter.mode(
            colorScheme.onSecondary,
            BlendMode.srcIn,
          ),
          child: Image.asset('assets/icons/home.png', height: 24, width: 24),
        ),
        label: 'Início',
      ),
      NavigationDestination(
        icon: ColorFiltered(
          colorFilter: ColorFilter.mode(
            colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
          child: Image.asset('assets/icons/check.png', height: 24, width: 24),
        ),
        selectedIcon: ColorFiltered(
          colorFilter: ColorFilter.mode(
            colorScheme.onSecondary,
            BlendMode.srcIn,
          ),
          child: Image.asset('assets/icons/check.png', height: 24, width: 24),
        ),
        label: 'Tarefas',
      ),
      if (isAdmin)
        NavigationDestination(
          icon: ColorFiltered(
            colorFilter: ColorFilter.mode(
              colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
            child: Image.asset('assets/icons/group.png', height: 24, width: 24),
          ),
          selectedIcon: ColorFiltered(
            colorFilter: ColorFilter.mode(
              colorScheme.onSecondary,
              BlendMode.srcIn,
            ),
            child: Image.asset('assets/icons/group.png', height: 24, width: 24),
          ),
          label: 'Usuários',
        ),
      NavigationDestination(
        icon: ColorFiltered(
          colorFilter: ColorFilter.mode(
            colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
          child: Image.asset('assets/icons/person.png', height: 24, width: 24),
        ),
        selectedIcon: ColorFiltered(
          colorFilter: ColorFilter.mode(
            colorScheme.onSecondary,
            BlendMode.srcIn,
          ),
          child: Image.asset('assets/icons/person.png', height: 24, width: 24),
        ),
        label: 'Perfil',
      ),
    ];
  }

  void _onTap(BuildContext context, int index, bool isAdmin) {
    switch (index) {
      case 0:
        context.go('/dashboard', extra: user);
      case 1:
        context.go('/tasks', extra: user);
      case 2:
        if (isAdmin) {
          context.go('/users', extra: user);
        } else {
          context.go('/profile', extra: user);
        }
      case 3:
        context.go('/profile', extra: user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == 'admin';
    final currentIndex = _currentIndex(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.onPrimary
              : colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) => _onTap(context, index, isAdmin),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: _destinations(isAdmin, colorScheme),
        ),
      ),
    );
  }
}