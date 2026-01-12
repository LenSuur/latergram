import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;

  const MainAppBar({
    super.key,
    required this.currentRoute,
  });

  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 56,

      // Home icon
      flexibleSpace: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home icon
              Expanded(
                flex: 10,
                child: GestureDetector(
                  onTap: () {
                    if (currentRoute != '/home') {
                      context.go('/home');
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(
                        'assets/images/icon_home.png',
                        opacity: currentRoute == '/home'
                            ? AlwaysStoppedAnimation(1.0)
                            : AlwaysStoppedAnimation(0.5),
                      ),
                    ),
                  ),
                ),
              ),

              // Gallery icon
              Expanded(
                flex: 20,
                child: GestureDetector(
                  onTap: () {
                    if (currentRoute != '/gallery') {
                      context.go('/gallery');
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(
                        'assets/images/icon_gallery.png',
                        opacity: currentRoute == '/gallery'
                            ? AlwaysStoppedAnimation(1.0)
                            : AlwaysStoppedAnimation(0.5),
                      ),
                    ),
                  ),
                ),
              ),

              // Profile icon
              Expanded(
                flex: 10,
                child: GestureDetector(
                  onTap: () {
                    if (currentRoute != '/profile') {
                      context.go('/profile');
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(
                        'assets/images/icon_profile.png',
                        opacity: currentRoute == '/profile'
                            ? AlwaysStoppedAnimation(1.0)
                            : AlwaysStoppedAnimation(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}