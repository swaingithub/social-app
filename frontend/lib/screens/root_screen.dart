import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorFilter activeColorFilter = ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn);
    final ColorFilter inactiveColorFilter = ColorFilter.mode(Colors.grey, BlendMode.srcIn);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/vectors/noise_texture.svg',
              fit: BoxFit.cover,
            ),
          ),
          child,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/home.svg', colorFilter: inactiveColorFilter),
            activeIcon: SvgPicture.asset('assets/icons/home.svg', colorFilter: activeColorFilter),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/stories.svg', colorFilter: inactiveColorFilter),
            activeIcon: SvgPicture.asset('assets/icons/stories.svg', colorFilter: activeColorFilter),
            label: 'Stories',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/explore.svg', colorFilter: inactiveColorFilter),
            activeIcon: SvgPicture.asset('assets/icons/explore.svg', colorFilter: activeColorFilter),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/profile.svg', colorFilter: inactiveColorFilter),
            activeIcon: SvgPicture.asset('assets/icons/profile.svg', colorFilter: activeColorFilter),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/explore.svg', colorFilter: inactiveColorFilter),
            activeIcon: SvgPicture.asset('assets/icons/explore.svg', colorFilter: activeColorFilter),
            label: 'News',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location == '/') {
      return 0;
    }
    if (location == '/stories') {
      return 1;
    }
    if (location == '/explore') {
      return 2;
    }
    if (location == '/profile') {
      return 3;
    }
    if (location == '/news') {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/stories');
        break;
      case 2:
        context.go('/explore');
        break;
      case 3:
        context.go('/profile');
        break;
      case 4:
        context.go('/news');
        break;
    }
  }
}
